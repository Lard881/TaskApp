import 'package:planpal/domain/models/workspace.dart';

/// Abstract contract for workspace persistence.
abstract class WorkspaceRepository {
  /// Returns all workspaces the current user belongs to.
  Future<List<Workspace>> getAll();

  /// Returns the current user's personal workspace.
  Future<Workspace?> getPersonal();

  /// Creates a new team workspace owned by the current user.
  Future<Workspace> create({
    required String name,
    required String emoji,
  });

  /// Updates workspace name / emoji.
  Future<void> update(Workspace workspace);

  /// Returns all members of [workspaceId] with embedded profile data.
  Future<List<WorkspaceMember>> getMembers(String workspaceId);

  /// Creates an invite for [workspaceId].
  /// Returns the invite code.
  Future<String> createInvite({
    required String workspaceId,
    String? invitedEmail,
  });

  /// Looks up an invite by [code]. Returns null if not found or expired.
  Future<WorkspaceInvite?> getInvite(String code);

  /// Accepts an invite — adds the current user to the workspace.
  Future<void> acceptInvite(String code);

  /// Removes a member from a workspace.
  Future<void> removeMember({
    required String workspaceId,
    required String userId,
  });

  /// Streams the workspace list so the switcher updates in real time.
  Stream<List<Workspace>> watchAll();
}

/// Lightweight invite model used in onboarding.
class WorkspaceInvite {
  const WorkspaceInvite({
    required this.id,
    required this.workspaceId,
    required this.inviteCode,
    required this.createdBy,
    required this.expiresAt,
    this.invitedEmail,
    this.usedAt,
  });

  final String id;
  final String workspaceId;
  final String inviteCode;
  final String createdBy;
  final DateTime expiresAt;
  final String? invitedEmail;
  final DateTime? usedAt;

  bool get isExpired => DateTime.now().isAfter(expiresAt);
  bool get isUsed => usedAt != null;
  bool get isValid => !isExpired && !isUsed;

  factory WorkspaceInvite.fromJson(Map<String, dynamic> json) =>
      WorkspaceInvite(
        id: json['id'] as String,
        workspaceId: json['workspace_id'] as String,
        inviteCode: json['invite_code'] as String,
        createdBy: json['created_by'] as String,
        expiresAt: DateTime.parse(json['expires_at'] as String),
        invitedEmail: json['invited_email'] as String?,
        usedAt: json['used_at'] != null
            ? DateTime.parse(json['used_at'] as String)
            : null,
      );
}
