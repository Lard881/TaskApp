import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:planpal/domain/models/workspace.dart';
import 'package:planpal/infrastructure/repositories/api_client.dart';
import 'package:planpal/infrastructure/repositories/workspace_repository.dart';

class ApiWorkspaceRepository implements WorkspaceRepository {
  @override
  Future<List<Workspace>> getAll() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/workspaces'),
      headers: await ApiConfig.headers(),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Unable to load workspaces.');
    }

    final list = jsonDecode(response.body) as List<dynamic>;
    return list.map((item) => Workspace.fromJson(item as Map<String, dynamic>)).toList();
  }

  @override
  Future<Workspace?> getPersonal() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/workspaces/personal'),
      headers: await ApiConfig.headers(),
    );

    if (response.statusCode == 404) return null;
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Unable to load personal workspace.');
    }

    final payload = jsonDecode(response.body) as Map<String, dynamic>;
    return Workspace.fromJson(payload);
  }

  @override
  Future<Workspace> create({required String name, required String emoji}) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/workspaces'),
      headers: await ApiConfig.headers(),
      body: jsonEncode({'name': name, 'emoji': emoji}),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      String msg = 'Unable to create workspace.';
      try {
        final err = jsonDecode(response.body);
        if (err is Map && err['error'] != null) {
          msg = err['error'].toString();
        }
      } catch (_) {}
      throw Exception(msg);
    }

    final payload = jsonDecode(response.body) as Map<String, dynamic>;
    return Workspace.fromJson(payload);
  }

  @override
  Future<void> update(Workspace workspace) async {
    final response = await http.put(
      Uri.parse('${ApiConfig.baseUrl}/workspaces/${workspace.id}'),
      headers: await ApiConfig.headers(),
      body: jsonEncode({'name': workspace.name, 'emoji': workspace.emoji}),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Unable to update workspace.');
    }
  }

  @override
  Future<void> delete(String workspaceId) async {
    final response = await http.delete(
      Uri.parse('${ApiConfig.baseUrl}/workspaces/$workspaceId'),
      headers: await ApiConfig.headers(),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      String msg = 'Unable to delete workspace.';
      try {
        final err = jsonDecode(response.body);
        if (err is Map && err['error'] != null) {
          msg = err['error'].toString();
        }
      } catch (_) {}
      throw Exception(msg);
    }
  }

  @override
  Future<List<WorkspaceMember>> getMembers(String workspaceId) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/workspaces/$workspaceId/members'),
      headers: await ApiConfig.headers(),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Unable to load workspace members.');
    }

    final list = jsonDecode(response.body) as List<dynamic>;
    return list
        .map((item) => WorkspaceMember.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<String> createInvite({
    required String workspaceId,
    String? invitedEmail,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/workspaces/$workspaceId/invite'),
      headers: await ApiConfig.headers(),
      body: jsonEncode({'invitedEmail': invitedEmail}),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Unable to create invite.');
    }

    final payload = jsonDecode(response.body) as Map<String, dynamic>;
    return payload['inviteCode'] as String;
  }

  @override
  Future<WorkspaceInvite?> getInvite(String code) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/workspaces/invite/$code'),
      headers: await ApiConfig.headers(),
    );

    if (response.statusCode == 404) return null;
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Unable to load invite.');
    }

    final payload = jsonDecode(response.body) as Map<String, dynamic>;
    return WorkspaceInvite.fromJson(payload);
  }

  @override
  Future<void> acceptInvite(String code) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/workspaces/invite/accept'),
      headers: await ApiConfig.headers(),
      body: jsonEncode({'code': code}),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Invite could not be accepted.');
    }
  }

  @override
  Future<void> removeMember({
    required String workspaceId,
    required String userId,
  }) async {
    final response = await http.delete(
      Uri.parse('${ApiConfig.baseUrl}/workspaces/$workspaceId/members/$userId'),
      headers: await ApiConfig.headers(),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Unable to remove workspace member.');
    }
  }

  @override
  Stream<List<Workspace>> watchAll() {
    // Poll every 10 seconds for workspace updates
    return Stream.periodic(const Duration(seconds: 10))
        .asyncMap((_) => getAll())
        .handleError((error) {
      return <Workspace>[];
    });
  }
}