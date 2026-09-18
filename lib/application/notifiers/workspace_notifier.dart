import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:planpal/application/providers/supabase_providers.dart';
import 'package:planpal/domain/models/workspace.dart';
import 'package:planpal/infrastructure/repositories/api_workspace_repository.dart';
import 'package:planpal/infrastructure/repositories/workspace_repository.dart';

// ── Provider ──────────────────────────────────────────────────────────────────

final workspaceRepositoryProvider = Provider<WorkspaceRepository>((ref) {
  return ApiWorkspaceRepository();
});

// ── Active workspace ──────────────────────────────────────────────────────────

/// Holds the currently selected workspace id.
/// Defaults to the personal workspace.
final activeWorkspaceIdProvider = StateProvider<String?>((ref) => null);

// ── Workspace list notifier ───────────────────────────────────────────────────

class WorkspaceNotifier extends AsyncNotifier<List<Workspace>> {
  late final WorkspaceRepository _repo;

  @override
  Future<List<Workspace>> build() async {
    _repo = ref.watch(workspaceRepositoryProvider);

    // Stream updates
    _repo.watchAll().listen((workspaces) {
      if (state is! AsyncLoading) state = AsyncData(workspaces);

      // Auto-select personal workspace if nothing is selected yet
      if (ref.read(activeWorkspaceIdProvider) == null &&
          workspaces.isNotEmpty) {
        final personal = workspaces.where((w) => w.isPersonal).firstOrNull;
        ref.read(activeWorkspaceIdProvider.notifier).state =
            personal?.id ?? workspaces.first.id;
      }
    });

    final workspaces = await _repo.getAll();

    // Set default active workspace
    if (ref.read(activeWorkspaceIdProvider) == null && workspaces.isNotEmpty) {
      final personal = workspaces.where((w) => w.isPersonal).firstOrNull;
      ref.read(activeWorkspaceIdProvider.notifier).state =
          personal?.id ?? workspaces.first.id;
    }

    return workspaces;
  }

  /// Creates a new team workspace and switches to it.
  Future<Workspace> createTeamWorkspace({
    required String name,
    required String emoji,
  }) async {
    final workspace = await _repo.create(name: name, emoji: emoji);
    // Refresh list — explicit cast prevents List<dynamic> type error
    final updated = <Workspace>[...(state.valueOrNull ?? []), workspace];
    state = AsyncData(updated);
    // Switch to newly created workspace
    ref.read(activeWorkspaceIdProvider.notifier).state = workspace.id;
    return workspace;
  }

  /// Switches the active workspace.
  void switchWorkspace(String workspaceId) {
    ref.read(activeWorkspaceIdProvider.notifier).state = workspaceId;
  }

  /// Accepts an invite link and refreshes the workspace list.
  Future<void> acceptInvite(String code) async {
    await _repo.acceptInvite(code);
    state = AsyncData(await _repo.getAll());
  }

  /// Updates workspace name / emoji
  Future<void> updateWorkspace({
    required String id,
    required String name,
    required String emoji,
  }) async {
    final existing = state.valueOrNull?.where((w) => w.id == id).firstOrNull;
    if (existing == null) return;
    final updated = existing.copyWith(name: name, emoji: emoji);
    await _repo.update(updated);
    final all = await _repo.getAll();
    state = AsyncData(all);
  }

  /// Deletes a workspace and switches to personal workspace
  Future<void> deleteWorkspace(String workspaceId) async {
    await _repo.delete(workspaceId);
    final all = await _repo.getAll();
    state = AsyncData(all);

    // If active workspace was deleted, fallback to personal or first available
    if (ref.read(activeWorkspaceIdProvider) == workspaceId) {
      final personal = all.where((w) => w.isPersonal).firstOrNull;
      ref.read(activeWorkspaceIdProvider.notifier).state =
          personal?.id ?? (all.isNotEmpty ? all.first.id : null);
    }
  }

  /// Removes a member from a workspace
  Future<void> removeMember({
    required String workspaceId,
    required String userId,
  }) async {
    await _repo.removeMember(workspaceId: workspaceId, userId: userId);
    ref.invalidate(activeMembersProvider);
  }
}

final workspacesProvider =
    AsyncNotifierProvider<WorkspaceNotifier, List<Workspace>>(
      WorkspaceNotifier.new,
    );

/// The currently active workspace object.
final activeWorkspaceProvider = Provider<Workspace?>((ref) {
  final id = ref.watch(activeWorkspaceIdProvider);
  final workspaces = ref.watch(workspacesProvider).valueOrNull ?? [];
  if (id == null) return null;
  return workspaces.where((w) => w.id == id).firstOrNull;
});

/// Members of the currently active workspace.
final activeMembersProvider = FutureProvider<List<WorkspaceMember>>((
  ref,
) async {
  final workspaceId = ref.watch(activeWorkspaceIdProvider);
  if (workspaceId == null) return [];
  final repo = ref.watch(workspaceRepositoryProvider);
  return repo.getMembers(workspaceId);
});

/// Current user's role in the active workspace.
final currentMemberRoleProvider = Provider<String?>((ref) {
  final members = ref.watch(activeMembersProvider).valueOrNull ?? [];
  final uid = ref.watch(authRepositoryProvider).currentUser?.id;
  if (uid == null) return null;
  return members.where((m) => m.userId == uid).firstOrNull?.role;
});
