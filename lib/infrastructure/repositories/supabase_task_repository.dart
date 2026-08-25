import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:planpal/domain/enums/task_priority.dart';
import 'package:planpal/domain/enums/task_status.dart';
import 'package:planpal/domain/models/task.dart';
import 'package:planpal/infrastructure/repositories/task_repository.dart';

/// Supabase-backed implementation of [TaskRepository].
///
/// All queries are scoped to the active workspace via [workspaceId].
class SupabaseTaskRepository implements TaskRepository {
  SupabaseTaskRepository(this._client, this.workspaceId);

  final SupabaseClient _client;
  final String workspaceId;

  String get _uid => _client.auth.currentUser!.id;

  // ── Helpers ───────────────────────────────────────────────────────────────

  Task _fromRow(Map<String, dynamic> row) {
    // Parse due_time from "HH:mm:ss" string
    TimeOfDay? dueTime;
    final rawTime = row['due_time'] as String?;
    if (rawTime != null) {
      final parts = rawTime.split(':');
      dueTime = TimeOfDay(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      );
    }

    return Task(
      id: row['id'] as String,
      name: row['name'] as String,
      description: row['description'] as String?,
      priority: _parsePriority(row['priority'] as String),
      status: _parseStatus(row['status'] as String),
      dueDate: row['due_date'] != null
          ? DateTime.parse(row['due_date'] as String)
          : null,
      dueTime: dueTime,
      assigneeId: row['assignee_id'] as String?,
      createdAt: DateTime.parse(row['created_at'] as String),
      updatedAt: DateTime.parse(row['updated_at'] as String),
    );
  }

  Map<String, dynamic> _toRow(Task task) => {
        'id': task.id,
        'workspace_id': workspaceId,
        'name': task.name,
        'description': task.description,
        'priority': task.priority.name,
        'status': task.status.name,
        'due_date': task.dueDate?.toIso8601String().split('T').first,
        'due_time': task.dueTime != null
            ? '${task.dueTime!.hour.toString().padLeft(2, '0')}:${task.dueTime!.minute.toString().padLeft(2, '0')}:00'
            : null,
        'assignee_id': task.assigneeId,
        'created_by': _uid,
        'created_at': task.createdAt.toIso8601String(),
        'updated_at': task.updatedAt.toIso8601String(),
      };

  TaskPriority _parsePriority(String s) => switch (s) {
        'high' => TaskPriority.high,
        'low' => TaskPriority.low,
        _ => TaskPriority.medium,
      };

  TaskStatus _parseStatus(String s) => switch (s) {
        'in_progress' => TaskStatus.inProgress,
        'completed' => TaskStatus.completed,
        _ => TaskStatus.todo,
      };

  // ── Read ──────────────────────────────────────────────────────────────────

  @override
  Future<List<Task>> getAll() async {
    final rows = await _client
        .from('tasks')
        .select()
        .eq('workspace_id', workspaceId)
        .order('created_at', ascending: false);

    return (rows as List).map((r) => _fromRow(r as Map<String, dynamic>)).toList();
  }

  @override
  Future<Task?> getById(String id) async {
    final row = await _client
        .from('tasks')
        .select()
        .eq('id', id)
        .maybeSingle();
    if (row == null) return null;
    return _fromRow(row as Map<String, dynamic>);
  }

  // ── Write ─────────────────────────────────────────────────────────────────

  @override
  Future<void> save(Task task) async {
    await _client.from('tasks').upsert(_toRow(task));
  }

  @override
  Future<void> delete(String id) async {
    await _client.from('tasks').delete().eq('id', id);
  }

  // ── Realtime stream ───────────────────────────────────────────────────────

  @override
  Stream<List<Task>> watch() {
    final controller = StreamController<List<Task>>.broadcast();

    Future<void> emit() async {
      if (!controller.isClosed) controller.add(await getAll());
    }

    emit();

    final channel = _client
        .channel('tasks_$workspaceId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'tasks',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'workspace_id',
            value: workspaceId,
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
