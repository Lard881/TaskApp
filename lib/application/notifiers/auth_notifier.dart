import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:planpal/application/providers/supabase_providers.dart';
import 'package:planpal/infrastructure/repositories/auth_repository.dart';

// ── Auth state enum ───────────────────────────────────────────────────────────

enum AppAuthState {
  /// Initial — waiting for session check
  unknown,

  /// Signed in and has a profile + workspace
  authenticated,

  /// Signed in but no workspace yet (first login)
  onboarding,

  /// Not signed in
  unauthenticated,
}

// ── Auth notifier ─────────────────────────────────────────────────────────────

/// Manages the global authentication state.
/// Watches Supabase auth stream and exposes sign-in/sign-out methods.
class AuthNotifier extends AsyncNotifier<AppAuthState> {
  late final AuthRepository _repo;

  @override
  Future<AppAuthState> build() async {
    _repo = ref.watch(authRepositoryProvider);

    // Listen to Supabase auth state changes
    _repo.authStateChanges.listen((authState) async {
      final event = authState.event;
      if (event == AuthChangeEvent.signedIn ||
          event == AuthChangeEvent.tokenRefreshed ||
          event == AuthChangeEvent.userUpdated) {
        state = const AsyncLoading();
        state = AsyncData(await _resolveState());
      } else if (event == AuthChangeEvent.signedOut) {
        state = const AsyncData(AppAuthState.unauthenticated);
      }
    });

    return _resolveState();
  }

  /// Resolves auth state based on current session.
  Future<AppAuthState> _resolveState() async {
    final user = _repo.currentUser;
    if (user == null) return AppAuthState.unauthenticated;

    // Check if user has a workspace
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
    } catch (_) {
      // Network error — if we have a session treat as authenticated
      return AppAuthState.authenticated;
    }
  }

  // ── Sign in with email ────────────────────────────────────────────────────

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _repo.signInWithEmail(email: email, password: password);
      return _resolveState();
    });
  }

  // ── Sign up with email ────────────────────────────────────────────────────

  Future<void> signUpWithEmail({
    required String email,
    required String password,
    String? firstName,
    String? lastName,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _repo.signUpWithEmail(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
      );
      return _resolveState();
    });
  }

  // ── Sign in with Google ───────────────────────────────────────────────────

  Future<void> signInWithGoogle() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final success = await _repo.signInWithGoogle();
      if (!success) return AppAuthState.unauthenticated;
      return _resolveState();
    });
  }

  // ── Sign in with Apple ────────────────────────────────────────────────────

  Future<void> signInWithApple() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final success = await _repo.signInWithApple();
      if (!success) return AppAuthState.unauthenticated;
      return _resolveState();
    });
  }

  // ── Reset password ────────────────────────────────────────────────────────

  Future<void> resetPassword(String email) =>
      _repo.resetPassword(email);

  // ── Update password ───────────────────────────────────────────────────────

  Future<void> updatePassword(String newPassword) async {
    await _repo.updatePassword(newPassword);
  }

  // ── Sign out ──────────────────────────────────────────────────────────────

  Future<void> signOut() async {
    await _repo.signOut();
    state = const AsyncData(AppAuthState.unauthenticated);
  }

  // ── Mark onboarding complete ──────────────────────────────────────────────

  /// Called after the user finishes onboarding (workspace created).
  void markOnboardingComplete() {
    state = const AsyncData(AppAuthState.authenticated);
  }
}

final authProvider =
    AsyncNotifierProvider<AuthNotifier, AppAuthState>(AuthNotifier.new);

/// Convenience: just the current Supabase user.
final currentSupabaseUserProvider = Provider<User?>((ref) {
  ref.watch(authProvider);
  return Supabase.instance.client.auth.currentUser;
});
