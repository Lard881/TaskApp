import 'package:supabase_flutter/supabase_flutter.dart';

/// Abstract contract for authentication operations.
abstract class AuthRepository {
  /// The current Supabase session, or null if not signed in.
  Session? get currentSession;

  /// The current auth user, or null if not signed in.
  User? get currentUser;

  /// Stream of auth state changes.
  Stream<AuthState> get authStateChanges;

  /// Sign in with email and password.
  Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  });

  /// Sign up with email and password.
  Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
    String? firstName,
    String? lastName,
  });

  /// Sign in with Google OAuth.
  Future<bool> signInWithGoogle();

  /// Sign in with Apple OAuth.
  Future<bool> signInWithApple();

  /// Send a password reset email.
  Future<void> resetPassword(String email);

  /// Update the current user's password.
  Future<UserResponse> updatePassword(String newPassword);

  /// Sign out the current user.
  Future<void> signOut();
}
