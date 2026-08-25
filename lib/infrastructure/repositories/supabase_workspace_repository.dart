import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:planpal/domain/models/workspace.dart';
import 'package:planpal/infrastructure/repositories/workspace_repository.dart';

/// Supabase-backed implementation of [WorkspaceRepository].
class SupabaseWorkspaceRepository implements WorkspaceRepository {
  SupabaseWorkspaceRepository(this._client);

  final SupabaseClient _client;

  String get _uid => _client.auth.currentUser!.id;

  // ── Read ──────────────────────────────────────────────────────────────────

  @override
  Future<List<Workspace>> getAll() async {
    final rows = await _client
        .from('workspace_members')
        .select('workspaces(*)')
        .eq('user_id', _uid)
        .order('joined_at');

    return (rows as List)
        .map((r) => Workspace.fromJson(r['workspaces'] as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<Workspace?> getPersonal() async {
    final rows = await _client
        .from('workspace_members')
        .select('workspaces(*)')
        .eq('user_id', _uid)
        .eq('workspaces.type', 'personal')
        .limit(1);

    if ((rows as List).isEmpty) return null;
    return Workspace.fromJson(
        (rows.first as Map<String, dynamic>)['workspaces']
            as Map<String, dynamic>);
  }

  @override
  Future<List<WorkspaceMember>> getMembers(String workspaceId) async {
    final rows = await _client
        .from('workspace_members')
        .select('*, profiles(id, first_name, last_name, email, avatar_url, role)')
        .eq('workspace_id', workspaceId)
        .order('joined_at');

    return (rows as List)
        .map((r) => WorkspaceMember.fromJson(r as Map<String, dynamic>))
        .toList();
  }

  // ── Write ─────────────────────────────────────────────────────────────────

  @override
  Future<Workspace> create({
    required String name,
    required String emoji,
  }) async {
    // Insert workspace
    final wsRow = await _client
        .from('workspaces')
        .insert({
          'name': name,
          'type': 'team',
          'emoji': emoji,
          'created_by': _uid,
        })
        .select()
        .single();

    final workspace = Workspace.fromJson(wsRow as Map<String, dynamic>);

    // Add creator as owner
    await _client.from('workspace_members').insert({
      'workspace_id': workspace.id,
      'user_id': _uid,
      'role': 'owner',
    });

    return workspace;
  }

  @override
  Future<void> update(Workspace workspace) async {
    await _client
        .from('workspaces')
        .update({'name': workspace.name, 'emoji': workspace.emoji})
        .eq('id', workspace.id);
  }

  @override
  Future<void> removeMember({
    required String workspaceId,
    required String userId,
  }) async {
    await _client
        .from('workspace_members')
        .delete()
        .eq('workspace_id', workspaceId)
        .eq('user_id', userId);
  }

  // ── Invites ───────────────────────────────────────────────────────────────

  @override
  Future<String> createInvite({
    required String workspaceId,
    String? invitedEmail,
  }) async {
    final row = await _client
        .from('workspace_invites')
        .insert({
          'workspace_id': workspaceId,
          'created_by': _uid,
          if (invitedEmail != null) 'invited_email': invitedEmail,
        })
        .select('invite_code')
        .single();

    return (row as Map<String, dynamic>)['invite_code'] as String;
  }

  @override
  Future<WorkspaceInvite?> getInvite(String code) async {
    final rows = await _client
        .from('workspace_invites')
        .select()
        .eq('invite_code', code)
        .limit(1);

    if ((rows as List).isEmpty) return null;
    return WorkspaceInvite.fromJson(rows.first as Map<String, dynamic>);
  }

  @override
  Future<void> acceptInvite(String code) async {
    final invite = await getInvite(code);
    if (invite == null || !invite.isValid) {
      throw Exception('This invite link is invalid or has expired.');
    }

    // Add user to workspace
    await _client.from('workspace_members').upsert({
      'workspace_id': invite.workspaceId,
      'user_id': _uid,
      'role': 'member',
    });

    // Mark invite as used
    await _client
        .from('workspace_invites')
        .update({'used_at': DateTime.now().toIso8601String(), 'used_by': _uid})
        .eq('invite_code', code);
  }

  // ── Realtime ──────────────────────────────────────────────────────────────

  @override
  Stream<List<Workspace>> watchAll() {
    final controller = StreamController<List<Workspace>>.broadcast();

    Future<void> emit() async {
      if (!controller.isClosed) controller.add(await getAll());
    }

    emit();

    final channel = _client
        .channel('workspace_members_$_uid')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'workspace_members',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: _uid,
          ),
          callback: (_) => emit(),
        )
        .subscribe();

    controller.onCancel = () {
      _client.removeChannel(channel);
      controller.close();
    };

    return controller.stream;
  }
}
