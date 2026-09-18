enum AuthChangeEvent {
  initialSession,
  signedIn,
  signedOut,
  tokenRefreshed,
  userUpdated,
}

class AuthUser {
  const AuthUser({
    required this.id,
    required this.email,
    this.firstName,
    this.lastName,
    this.avatarUrl,
    this.role,
    this.phone,
  });

  final String id;
  final String email;
  final String? firstName;
  final String? lastName;
  final String? avatarUrl;
  final String? role;
  final String? phone;

  factory AuthUser.fromJson(Map<String, dynamic> json) => AuthUser(
        id: json['id'] as String,
        email: json['email'] as String? ?? '',
        firstName: json['firstName'] as String? ?? json['first_name'] as String?,
        lastName: json['lastName'] as String? ?? json['last_name'] as String?,
        avatarUrl: json['avatarUrl'] as String? ?? json['avatar_url'] as String?,
        role: json['role'] as String?,
        phone: json['phone'] as String?,
      );
}

class AuthSession {
  const AuthSession({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  final String accessToken;
  final String refreshToken;
  final AuthUser user;
}

class AuthState {
  const AuthState({
    required this.event,
    this.session,
  });

  final AuthChangeEvent event;
  final AuthSession? session;
}

class AuthException implements Exception {
  AuthException(this.message);

  final String message;

  @override
  String toString() => message;
}

class AuthResponse {
  const AuthResponse({
    required this.user,
    required this.session,
  });

  final AuthUser user;
  final AuthSession session;
}

class UserResponse {
  const UserResponse({required this.user});

  final AuthUser user;
}

/// Abstract contract for authentication operations.
abstract class AuthRepository {
  AuthSession? get currentSession;

  AuthUser? get currentUser;

  Stream<AuthState> get authStateChanges;

  Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  });

  Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
    String? firstName,
    String? lastName,
  });

  Future<bool> signInWithGoogle();

  Future<bool> signInWithApple();

  Future<void> resetPassword(String email);

  Future<UserResponse> updatePassword(String newPassword);

  Future<void> signOut();
}
