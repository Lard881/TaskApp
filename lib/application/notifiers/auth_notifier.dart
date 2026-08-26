import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:planpal/application/providers/supabase_providers.dart';
import 'package:planpal/infrastructure/repositories/auth_repository.dart';

// ── Auth state ────────────────────────────────────────────────────────────────

enum AppAuthState {
  unknown,
  authenticated,
  onboarding,
  unauthenticated,
}

// ── Notifier ──────────────────────────────────────────────────────────────────

class AuthNotifier extends AsyncNotifier<AppAuthState> {
  late final AuthRepository _repo;
  StreamSubscription<AuthState>? _authSub; // Fix 3 — track subscription

  @override
  Future<AppAuthState> build() async {
    _repo = ref.watch(authRepositoryProvider);

    // Fix 3 — cancel any previous subscription before creating a new one
    await _authSub?.cancel();

    // Fix 3 — store subscription so we can cancel it on rebuild/dispose
    _authSub = _repo.authStateChanges.listen((authState) async {
      final event = authState.event;
      if (event == AuthChangeEvent.signedIn ||
          event == AuthChangeEvent.tokenRefreshed ||
          event == AuthChangeEvent.userUpdated) {
        // Fix 1 — wait a moment for the DB trigger to create the workspace
        if (event == AuthChangeEvent.signedIn) {
          await Future.delayed(const Duration(milliseconds: 1500));
        }
        state = const AsyncLoading();
        state = AsyncData(await _resolveState());
      } else if (event == AuthChangeEvent.signedOut) {
        state = const AsyncData(AppAuthState.unauthenticated);
      }
    });

    // Dispose the subscription when the notifier is destroyed
    ref.onDispose(() {
      _authSub?.cancel();
      _authSub = null;
    });

    return _resolveState();
  }

  // ── Resolve state ─────────────────────────────────────────────────────────

  Future<AppAuthState> _resolveState() async {
    final user = _repo.currentUser;
    if (user == null) return AppAuthState.unauthenticated;

    try {
      final client = ref.read(supabaseClientProvider);
      final workspaces = await client
          .from('workspace_members')
          .select('workspace_id')
          .eq('user_id', user.id)
          .limit(1);

      if ((workspaces as List).isEmpty) {
        return AppAuthState.onboarding;
      }
      return AppAuthState.authenticated;
    } on AuthException {
      // Fix 5 — real auth errors should NOT be treated as authenticated
      return AppAuthState.unauthenticated;
    } catch (_) {
      // Only non-auth errors (network, etc.) fall back to authenticated
      // to avoid logging out users on temporary connectivity issues
      if (_repo.currentSession != null) {
        return AppAuthState.authenticated;
      }
      return AppAuthState.unauthenticated;
    }
  }

  // ── Sign in with email ────────────────────────────────────────────────────

  Future<String?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();
    try {
      await _repo.signInWithEmail(email: email, password: password);
      // Fix 2 — auth stream will update state via the listener above
      // We don't resolve state here — the signedIn event handles it
      return null; // null = success
    } on AuthException catch (e) {
      state = const AsyncData(AppAuthState.unauthenticated);
      return _friendlyError(e.message); // Fix 2 — return error message
    } catch (e) {
      state = const AsyncData(AppAuthState.unauthenticated);
      return 'Something went wrong. Please try again.';
    }
  }

  // ── Sign up with email ────────────────────────────────────────────────────

  Future<String?> signUpWithEmail({
    required String email,
    required String password,
    String? firstName,
    String? lastName,
  }) async {
    state = const AsyncLoading();
    try {
      await _repo.signUpWithEmail(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
      );
      // Fix 1 — after sign up, auth stream fires signedIn
      // The 1500ms delay in the stream listener gives the DB trigger
      // time to create the workspace before we query workspace_members
      return null; // null = success
    } on AuthException catch (e) {
      state = const AsyncData(AppAuthState.unauthenticated);
      return _friendlyError(e.message);
    } catch (e) {
      state = const AsyncData(AppAuthState.unauthenticated);
      return 'Something went wrong. Please try again.';
    }
  }

  // ── Social sign in ────────────────────────────────────────────────────────

  Future<String?> signInWithGoogle() async {
    state = const AsyncLoading();
    try {
      final success = await _repo.signInWithGoogle();
      if (!success) {
        state = const AsyncData(AppAuthState.unauthenticated);
        return null; // user cancelled — not an error
      }
      return null;
    } on AuthException catch (e) {
      state = const AsyncData(AppAuthState.unauthenticated);
      return _friendlyError(e.message);
    } catch (e) {
      state = const AsyncData(AppAuthState.unauthenticated);
      return 'Google sign in failed. Please try again.';
    }
  }

  Future<String?> signInWithApple() async {
    state = const AsyncLoading();
    try {
      final success = await _repo.signInWithApple();
      if (!success) {
        state = const AsyncData(AppAuthState.unauthenticated);
        return null;
      }
      return null;
    } on AuthException catch (e) {
      state = const AsyncData(AppAuthState.unauthenticated);
      return _friendlyError(e.message);
    } catch (e) {
      state = const AsyncData(AppAuthState.unauthenticated);
      return 'Apple sign in failed. Please try again.';
    }
  }

  // ── Password ──────────────────────────────────────────────────────────────

  Future<void> resetPassword(String email) =>
      _repo.resetPassword(email);

  Future<void> updatePassword(String newPassword) =>
      _repo.updatePassword(newPassword);

  // ── Sign out ──────────────────────────────────────────────────────────────

  Future<void> signOut() async {
    await _repo.signOut();
    state = const AsyncData(AppAuthState.unauthenticated);
  }

  // ── Onboarding ────────────────────────────────────────────────────────────

  void markOnboardingComplete() {
    state = const AsyncData(AppAuthState.authenticated);
  }

  // ── Error helper ──────────────────────────────────────────────────────────

  String _friendlyError(String raw) {
    final lower = raw.toLowerCase();
    if (lower.contains('invalid login') || lower.contains('invalid credentials')) {
      return 'Incorrect email or password.';
    }
    if (lower.contains('email not confirmed')) {
      return 'Please verify your email first. Check your inbox.';
    }
    if (lower.contains('already registered') || lower.contains('already exists')) {
      return 'An account with this email already exists.';
    }
    if (lower.contains('password') && lower.contains('short')) {
      return 'Password must be at least 8 characters.';
    }
    if (lower.contains('rate limit')) {
      return 'Too many attempts. Please wait a moment and try again.';
    }
    return raw;
  }
}

// ── Provider ──────────────────────────────────────────────────────────────────

final authProvider =
    AsyncNotifierProvider<AuthNotifier, AppAuthState>(AuthNotifier.new);

final currentSupabaseUserProvider = Provider<User?>((ref) {
  ref.watch(authProvider);
  return Supabase.instance.client.auth.currentUser;
});
