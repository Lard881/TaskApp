import 'package:flutter/foundation.dart' show kIsWeb;
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
    // Fix 6 — Google Sign In does not work on web without additional setup
    if (kIsWeb) {
      throw AuthException(
        'Google sign in is not supported on web yet. Please use email/password.',
      );
    }

    // On iOS, clientId comes from GoogleService-Info.plist — pass null
    // On Android, we need the web client ID as serverClientId
    final googleSignIn = GoogleSignIn(
      serverClientId: SupabaseConfig.googleWebClientId ==
              'YOUR_GOOGLE_WEB_CLIENT_ID.apps.googleusercontent.com'
          ? null // placeholder not set yet — will fail gracefully
          : SupabaseConfig.googleWebClientId,
    );

    final googleUser = await googleSignIn.signIn();
    if (googleUser == null) return false;

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

  @override
  Future<bool> signInWithApple() async {
    // Fix 6 — Apple Sign In does not work on web
    if (kIsWeb) {
      throw AuthException(
        'Apple sign in is not supported on web yet. Please use email/password.',
      );
    }

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
