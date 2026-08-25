/// Represents a PlanPal workspace (personal or team).
class Workspace {
  const Workspace({
    required this.id,
    required this.name,
    required this.type,
    required this.emoji,
    required this.createdBy,
    required this.createdAt,
  });

  final String id;
  final String name;
  final String type; // 'personal' | 'team'
  final String emoji;
  final String createdBy;
  final DateTime createdAt;

  bool get isPersonal => type == 'personal';
  bool get isTeam => type == 'team';

  factory Workspace.fromJson(Map<String, dynamic> json) => Workspace(
        id: json['id'] as String,
        name: json['name'] as String,
        type: json['type'] as String,
        emoji: json['emoji'] as String? ?? '🗂️',
        createdBy: json['created_by'] as String,
        createdAt: DateTime.parse(json['created_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'type': type,
        'emoji': emoji,
        'created_by': createdBy,
        'created_at': createdAt.toIso8601String(),
      };

  Workspace copyWith({
    String? id,
    String? name,
    String? type,
    String? emoji,
    String? createdBy,
    DateTime? createdAt,
  }) =>
      Workspace(
        id: id ?? this.id,
        name: name ?? this.name,
        type: type ?? this.type,
        emoji: emoji ?? this.emoji,
        createdBy: createdBy ?? this.createdBy,
        createdAt: createdAt ?? this.createdAt,
      );
}

/// A member of a workspace.
class WorkspaceMember {
  const WorkspaceMember({
    required this.id,
    required this.workspaceId,
    required this.userId,
    required this.role,
    required this.joinedAt,
    this.profile,
  });

  final String id;
  final String workspaceId;
  final String userId;
  final String role; // 'owner' | 'admin' | 'member'
  final DateTime joinedAt;
  final WorkspaceMemberProfile? profile;

  bool get isOwner => role == 'owner';
  bool get isAdmin => role == 'admin' || role == 'owner';

  factory WorkspaceMember.fromJson(Map<String, dynamic> json) =>
      WorkspaceMember(
        id: json['id'] as String,
        workspaceId: json['workspace_id'] as String,
        userId: json['user_id'] as String,
        role: json['role'] as String,
        joinedAt: DateTime.parse(json['joined_at'] as String),
        profile: json['profiles'] != null
            ? WorkspaceMemberProfile.fromJson(
                json['profiles'] as Map<String, dynamic>)
            : null,
      );
}

/// Embedded profile data returned when querying workspace members.
class WorkspaceMemberProfile {
  const WorkspaceMemberProfile({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.avatarUrl,
    this.role,
  });

  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String? avatarUrl;
  final String? role;

  String get fullName => '$firstName $lastName'.trim();
  String get initials {
    final f = firstName.isNotEmpty ? firstName[0].toUpperCase() : '';
    final l = lastName.isNotEmpty ? lastName[0].toUpperCase() : '';
    return '$f$l'.isNotEmpty ? '$f$l' : email[0].toUpperCase();
  }

  factory WorkspaceMemberProfile.fromJson(Map<String, dynamic> json) =>
      WorkspaceMemberProfile(
        id: json['id'] as String,
        firstName: json['first_name'] as String? ?? '',
        lastName: json['last_name'] as String? ?? '',
        email: json['email'] as String? ?? '',
        avatarUrl: json['avatar_url'] as String?,
        role: json['role'] as String?,
      );
}
