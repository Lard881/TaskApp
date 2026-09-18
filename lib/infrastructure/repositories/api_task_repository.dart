import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:planpal/domain/enums/task_priority.dart';
import 'package:planpal/domain/enums/task_status.dart';
import 'package:planpal/domain/models/task.dart';
import 'package:planpal/infrastructure/repositories/api_client.dart';
import 'package:planpal/infrastructure/repositories/task_repository.dart';

class ApiTaskRepository implements TaskRepository {
  ApiTaskRepository({required this.workspaceId});

  final String workspaceId;

  Task _fromJson(Map<String, dynamic> json) {
    final dueTimeString = json['due_time'] as String?;
    TimeOfDay? parsedDueTime;
    if (dueTimeString != null && dueTimeString.isNotEmpty) {
      final parts = dueTimeString.split(':');
      if (parts.length >= 2) {
        parsedDueTime = TimeOfDay(
          hour: int.parse(parts[0]),
          minute: int.parse(parts[1]),
        );
      }
    }

    return Task(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      priority: switch (json['priority'] as String? ?? 'medium') {
        'high' => TaskPriority.high,
        'low' => TaskPriority.low,
        _ => TaskPriority.medium,
      },
      status: switch (json['status'] as String? ?? 'todo') {
        'in_progress' => TaskStatus.inProgress,
        'completed' => TaskStatus.completed,
        _ => TaskStatus.todo,
      },
      dueDate: json['due_date'] != null
          ? DateTime.parse(json['due_date'] as String)
          : null,
      dueTime: parsedDueTime,
      assigneeId: json['assignee_id'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  @override
  Future<List<Task>> getAll() async {
    if (workspaceId.trim().isEmpty) return [];

    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/tasks/$workspaceId'),
      headers: await ApiConfig.headers(),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Unable to load tasks.');
    }

    final list = jsonDecode(response.body) as List<dynamic>;
    return list.map((item) => _fromJson(item as Map<String, dynamic>)).toList();
  }

  @override
  Future<Task?> getById(String id) async =>
      (await getAll()).where((task) => task.id == id).firstOrNull;

  @override
  Future<void> save(Task task) async {
    // Convert status and priority to snake_case for backend
    String statusValue;
    switch (task.status) {
      case TaskStatus.inProgress:
        statusValue = 'in_progress';
        break;
      case TaskStatus.completed:
        statusValue = 'completed';
        break;
      case TaskStatus.todo:
      default:
        statusValue = 'todo';
        break;
    }

    final body = jsonEncode({
      'workspaceId': workspaceId,
      'name': task.name,
      'description': task.description,
      'priority': task.priority.name, // 'high', 'medium', 'low' are fine
      'status': statusValue, // Use snake_case format
      'dueDate': task.dueDate?.toIso8601String().split('T').first,
      'dueTime': task.dueTime != null
          ? '${task.dueTime!.hour.toString().padLeft(2, '0')}:${task.dueTime!.minute.toString().padLeft(2, '0')}'
          : null,
      'assigneeId': task.assigneeId,
    });

    print('🔵 Saving task: ${task.name}');
    print('   Workspace ID: $workspaceId');
    print('   Body: $body');

    // Try update first
    var response = await http.put(
      Uri.parse('${ApiConfig.baseUrl}/tasks/${task.id}'),
      headers: await ApiConfig.headers(),
      body: body,
    );

    print('   PUT response: ${response.statusCode}');

    // If 404, task doesn't exist, so create it
    if (response.statusCode == 404) {
      print('   Task not found, creating new...');
      response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/tasks'),
        headers: await ApiConfig.headers(),
        body: body,
      );
      print('   POST response: ${response.statusCode}');
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      print('❌ Error response: ${response.body}');
      throw Exception('Unable to save task: ${response.body}');
    }

    print('✅ Task saved successfully');
  }

  @override
  Future<void> delete(String id) async {
    final response = await http.delete(
      Uri.parse('${ApiConfig.baseUrl}/tasks/$id'),
      headers: await ApiConfig.headers(),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Unable to delete task.');
    }
  }

  @override
  Stream<List<Task>> watch() {
    // Poll every 5 seconds for updates
    return Stream.periodic(const Duration(seconds: 5))
        .asyncMap((_) => getAll())
        .handleError((error) {
      // Silently handle errors, return empty list
      return <Task>[];
    });
  }
}