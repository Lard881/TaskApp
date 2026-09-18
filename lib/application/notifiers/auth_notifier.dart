import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:planpal/application/providers/supabase_providers.dart';
import 'package:planpal/infrastructure/repositories/api_auth_repository.dart';
import 'package:planpal/infrastructure/repositories/auth_repository.dart';

// ── Auth state ────────────────────────────────────────────────────────────────

enum AppAuthState { unknown, authenticated, onboarding, unauthenticated }

// ── Notifier ──────────────────────────────────────────────────────────────────

class AuthNotifier extends AsyncNotifier<AppAuthState> {
  late final AuthRepository _repo;

  @override
  Future<AppAuthState> build() async {
    _repo = ref.watch(authRepositoryProvider);
    return _resolveState();
  }

  // ── Resolve state ─────────────────────────────────────────────────────────

  Future<AppAuthState> _resolveState() async {
    final user = _repo.currentUser;
    if (user == null) return AppAuthState.unauthenticated;

    try {
      return AppAuthState.authenticated;
    } on AuthException {
      return AppAuthState.unauthenticated;
    } catch (_) {
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
      state = AsyncData(await _resolveState());
      return null;
    } on AuthException catch (e) {
      state = const AsyncData(AppAuthState.unauthenticated);
      return _friendlyError(e.message);
    } on Exception catch (_) {
      state = const AsyncData(AppAuthState.unauthenticated);
      return 'Something went wrong. Please try again.';
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
      state = AsyncData(await _resolveState());
      return null;
    } on AuthException catch (e) {
      state = const AsyncData(AppAuthState.unauthenticated);
      return _friendlyError(e.message);
    } on Exception catch (_) {
      state = const AsyncData(AppAuthState.unauthenticated);
      return 'Something went wrong. Please try again.';
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
        return null;
      }
      state = AsyncData(await _resolveState());
      return null;
    } on AuthException catch (e) {
      state = const AsyncData(AppAuthState.unauthenticated);
      return _friendlyError(e.message);
    } on Exception catch (_) {
      state = const AsyncData(AppAuthState.unauthenticated);
      return 'Google sign in failed. Please try again.';
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
      state = AsyncData(await _resolveState());
      return null;
    } on AuthException catch (e) {
      state = const AsyncData(AppAuthState.unauthenticated);
      return _friendlyError(e.message);
    } on Exception catch (_) {
      state = const AsyncData(AppAuthState.unauthenticated);
      return 'Apple sign in failed. Please try again.';
    } catch (e) {
      state = const AsyncData(AppAuthState.unauthenticated);
      return 'Apple sign in failed. Please try again.';
    }
  }

  // ── Password ──────────────────────────────────────────────────────────────

  Future<void> resetPassword(String email) => _repo.resetPassword(email);

  /// Verify the 6-digit reset code
  Future<void> verifyResetCode(String email, String code) async {
    if (_repo is ApiAuthRepository) {
      await (_repo as ApiAuthRepository).verifyResetCode(
        email: email,
        code: code,
      );
    } else {
      throw Exception('Code verification not supported');
    }
  }

  /// Reset password with 6-digit code
  Future<void> resetPasswordWithCode(
    String email,
    String code,
    String newPassword,
  ) async {
    if (_repo is ApiAuthRepository) {
      await (_repo as ApiAuthRepository).resetPasswordWithCode(
        email: email,
        code: code,
        newPassword: newPassword,
      );
    } else {
      throw Exception('Code-based password reset not supported');
    }
  }

  Future<void> resetPasswordWithToken({
    required String token,
    required String newPassword,
  }) async {
    if (_repo is ApiAuthRepository) {
      await (_repo as ApiAuthRepository).resetPasswordWithToken(
        token: token,
        newPassword: newPassword,
      );
    }
  }

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
    if (lower.contains('invalid login') ||
        lower.contains('invalid credentials')) {
      return 'Incorrect email or password.';
    }
    if (lower.contains('email not confirmed')) {
      return 'Please verify your email first. Check your inbox.';
    }
    if (lower.contains('already registered') ||
        lower.contains('already exists')) {
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

final authProvider = AsyncNotifierProvider<AuthNotifier, AppAuthState>(
  AuthNotifier.new,
);

final currentSupabaseUserProvider = Provider<AuthUser?>((ref) {
  ref.watch(authProvider);
  return ref.read(authRepositoryProvider).currentUser;
});
