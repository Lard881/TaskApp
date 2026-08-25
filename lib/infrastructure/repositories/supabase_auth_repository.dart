import 'dart:io';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:planpal/core/config/supabase_config.dart';
import 'package:planpal/infrastructure/repositories/auth_repository.dart';

/// Supabase-backed implementation of [AuthRepository].
class SupabaseAuthRepository implements AuthRepository {
  SupabaseAuthRepository(this._client);

  final SupabaseClient _client;

  @override
  Session? get currentSession => _client.auth.currentSession;

  @override
  User? get currentUser => _client.auth.currentUser;

  @override
  Stream<AuthState> get authStateChanges =>
      _client.auth.onAuthStateChange;

  // ── Email / Password ──────────────────────────────────────────────────────

  @override
  Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) =>
      _client.auth.signInWithPassword(email: email, password: password);

  @override
  Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
    String? firstName,
    String? lastName,
  }) =>
      _client.auth.signUp(
        email: email,
        password: password,
        data: {
          if (firstName != null) 'given_name': firstName,
          if (lastName != null) 'family_name': lastName,
          if (firstName != null && lastName != null)
            'full_name': '$firstName $lastName',
        },
      );

  // ── Google ────────────────────────────────────────────────────────────────

  @override
  Future<bool> signInWithGoogle() async {
    final googleSignIn = GoogleSignIn(
      clientId: Platform.isIOS ? null : SupabaseConfig.googleWebClientId,
      serverClientId: SupabaseConfig.googleWebClientId,
    );

    final googleUser = await googleSignIn.signIn();
    if (googleUser == null) return false; // user cancelled

    final googleAuth = await googleUser.authentication;
    final idToken = googleAuth.idToken;
    final accessToken = googleAuth.accessToken;

    if (idToken == null || accessToken == null) return false;

    await _client.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
      accessToken: accessToken,
    );
    return true;
  }

  // ── Apple ─────────────────────────────────────────────────────────────────

  @override
  Future<bool> signInWithApple() async {
    final credential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
    );

    final idToken = credential.identityToken;
    if (idToken == null) return false;

    await _client.auth.signInWithIdToken(
      provider: OAuthProvider.apple,
      idToken: idToken,
    );
    return true;
  }

  // ── Password reset ────────────────────────────────────────────────────────

  @override
  Future<void> resetPassword(String email) =>
      _client.auth.resetPasswordForEmail(email);

  @override
  Future<UserResponse> updatePassword(String newPassword) =>
      _client.auth.updateUser(UserAttributes(password: newPassword));

  // ── Sign out ──────────────────────────────────────────────────────────────

  @override
  Future<void> signOut() => _client.auth.signOut();
}
