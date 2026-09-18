import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:planpal/application/providers/supabase_providers.dart';
import 'package:planpal/infrastructure/repositories/api_client.dart';
import 'package:planpal/infrastructure/repositories/auth_repository.dart';

class ApiAuthRepository implements AuthRepository {
  ApiAuthRepository(this.ref) {
    _controller = StreamController<AuthState>.broadcast();
    _initializeSession();
  }

  final Ref ref;

  late final StreamController<AuthState> _controller;

  AuthSession? _currentSession;

  @override
  AuthSession? get currentSession => _currentSession;

  @override
  AuthUser? get currentUser => _currentSession?.user;

  @override
  Stream<AuthState> get authStateChanges => _controller.stream;

  /// Initialize session from saved token
  Future<void> _initializeSession() async {
    try {
      final token = await ApiConfig.loadToken();
      if (token != null && token.isNotEmpty) {
        // Verify token by getting current user
        final response = await http.get(
          Uri.parse('${ApiConfig.baseUrl}/auth/me'),
          headers: await ApiConfig.headers(),
        ).timeout(const Duration(seconds: 10));

        if (response.statusCode >= 200 && response.statusCode < 300) {
          final payload = await _decodeBody(response);
          final user = AuthUser.fromJson(payload as Map<String, dynamic>);
          _currentSession = AuthSession(
            accessToken: token,
            refreshToken: token,
            user: user,
          );
          _emit(AuthChangeEvent.initialSession, session: _currentSession);
        } else {
          // Token invalid, clear it
          await ApiConfig.clearToken();
        }
      }
    } catch (e) {
      // Session restore failed, user will need to login
      print('Session restore failed: $e');
    }
  }

  Future<Map<String, dynamic>> _decodeBody(http.Response response) async {
    final raw = response.body;
    if (raw.isEmpty) {
      throw AuthException('The server returned an empty response.');
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) return decoded;
      throw AuthException('Unexpected auth response from the server.');
    } on FormatException {
      throw AuthException('Could not parse the auth response.');
    }
  }

  void _emit(AuthChangeEvent event, {AuthSession? session}) {
    _controller.add(AuthState(event: event, session: session));
  }

  @override
  Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/auth/signin'),
      headers: await ApiConfig.headers(includeAuth: false),
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final payload = await _decodeBody(response);
      throw AuthException((payload['error'] ?? 'Invalid email or password.').toString());
    }

    final payload = await _decodeBody(response);
    final token = payload['token'] as String?;
    if (token == null || token.isEmpty) {
      throw AuthException('No token was returned by the backend.');
    }

    await ApiConfig.saveToken(token);

    final user = AuthUser.fromJson(payload['user'] as Map<String, dynamic>);
    _currentSession = AuthSession(
      accessToken: token,
      refreshToken: token,
      user: user,
    );
    _emit(AuthChangeEvent.signedIn, session: _currentSession);

    return AuthResponse(user: user, session: _currentSession!);
  }

  @override
  Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
    String? firstName,
    String? lastName,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/auth/signup'),
      headers: await ApiConfig.headers(includeAuth: false),
      body: jsonEncode({
        'email': email,
        'password': password,
        'firstName': firstName,
        'lastName': lastName,
      }),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final payload = await _decodeBody(response);
      throw AuthException((payload['error'] ?? 'Sign up failed.').toString());
    }

    final payload = await _decodeBody(response);
    final token = payload['token'] as String?;
    if (token == null || token.isEmpty) {
      throw AuthException('No token was returned by the backend.');
    }

    await ApiConfig.saveToken(token);

    final user = AuthUser.fromJson(payload['user'] as Map<String, dynamic>);
    _currentSession = AuthSession(
      accessToken: token,
      refreshToken: token,
      user: user,
    );
    _emit(AuthChangeEvent.signedIn, session: _currentSession);

    return AuthResponse(user: user, session: _currentSession!);
  }

  @override
  Future<bool> signInWithGoogle() async => false;

  @override
  Future<bool> signInWithApple() async => false;

  @override
  Future<void> resetPassword(String email) async {
    try {
      print('🔵 Calling backend API /forgot-password: $email');
      
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/auth/forgot-password'),
        headers: await ApiConfig.headers(includeAuth: false),
        body: jsonEncode({'email': email.trim().toLowerCase()}),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Request timed out. The server may be waking up. Please try again in a moment.');
        },
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        final payload = await _decodeBody(response);
        throw AuthException((payload['message'] ?? 'Unable to send reset code.').toString());
      }
      
      print('✅ Password reset code sent via backend');
    } catch (e) {
      print('❌ Backend error: $e');
      if (e is AuthException) rethrow;
      throw AuthException('Unable to send reset code. Please try again.');
    }
  }

  /// Verify the 6-digit reset code
  Future<void> verifyResetCode({
    required String email,
    required String code,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/auth/verify-reset-code'),
      headers: await ApiConfig.headers(includeAuth: false),
      body: jsonEncode({
        'email': email.trim().toLowerCase(),
        'code': code.trim(),
      }),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final payload = await _decodeBody(response);
      throw AuthException((payload['message'] ?? 'Invalid or expired code.').toString());
    }
  }

  /// Reset password with 6-digit code
  Future<void> resetPasswordWithCode({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/auth/reset-password'),
      headers: await ApiConfig.headers(includeAuth: false),
      body: jsonEncode({
        'email': email.trim().toLowerCase(),
        'code': code.trim(),
        'newPassword': newPassword,
      }),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final payload = await _decodeBody(response);
      throw AuthException((payload['message'] ?? 'Unable to reset password.').toString());
    }
  }

  /// Verify reset token and update password (PassportVault style)
  Future<void> resetPasswordWithToken({
    required String token,
    required String newPassword,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/auth/reset-password'),
      headers: await ApiConfig.headers(includeAuth: false),
      body: jsonEncode({
        'token': token,
        'newPassword': newPassword,
      }),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final payload = await _decodeBody(response);
      throw AuthException((payload['message'] ?? 'Unable to reset password.').toString());
    }
  }

  @override
  Future<UserResponse> updatePassword(String newPassword) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/auth/update-password'),
      headers: await ApiConfig.headers(),
      body: jsonEncode({'newPassword': newPassword}),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final payload = await _decodeBody(response);
      throw AuthException((payload['error'] ?? 'Unable to update your password.').toString());
    }

    final payload = await _decodeBody(response);
    final user = AuthUser.fromJson(payload['user'] as Map<String, dynamic>);
    if (_currentSession != null) {
      _currentSession = AuthSession(
        accessToken: _currentSession!.accessToken,
        refreshToken: _currentSession!.refreshToken,
        user: user,
      );
    }
    _emit(AuthChangeEvent.userUpdated, session: _currentSession);
    return UserResponse(user: user);
  }

  @override
  Future<void> signOut() async {
    await ApiConfig.clearToken();
    _currentSession = null;
    _emit(AuthChangeEvent.signedOut);
  }
}