import 'package:hive/hive.dart';

part 'user_adapter.dart';

/// Represents the current user or a contact in PlanPal.
///
/// Immutable — mutations produce a new instance via [copyWith].
/// Hive typeId: 1
class User {
  const User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.role,
    this.phone,
    this.avatarPath,
  });

  final String id;
  final String firstName;   // max 50 chars
  final String lastName;    // max 50 chars
  final String? role;       // max 100 chars
  final String email;       // max 254 chars
  final String? phone;      // max 20 chars
  final String? avatarPath; // local file path to chosen avatar image

  // ── Computed getters ──────────────────────────────────────────────────────

  String get fullName => '$firstName $lastName';

  /// Two-letter initials used as avatar placeholder.
  String get initials {
    final f = firstName.isNotEmpty ? firstName[0].toUpperCase() : '';
    final l = lastName.isNotEmpty ? lastName[0].toUpperCase() : '';
    return '$f$l';
  }

  // ── copyWith ──────────────────────────────────────────────────────────────

  User copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? role,
    String? email,
    String? phone,
    String? avatarPath,
    bool clearRole = false,
    bool clearPhone = false,
    bool clearAvatarPath = false,
  }) {
    return User(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      role: clearRole ? null : (role ?? this.role),
      email: email ?? this.email,
      phone: clearPhone ? null : (phone ?? this.phone),
      avatarPath:
          clearAvatarPath ? null : (avatarPath ?? this.avatarPath),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is User && other.id == id);

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'User(id: $id, name: $fullName)';
}
