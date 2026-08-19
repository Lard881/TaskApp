import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:planpal/domain/enums/task_priority.dart';
import 'package:planpal/domain/enums/task_status.dart';

part 'task_adapter.dart';

/// A single unit of work in PlanPal.
///
/// Immutable — all mutations produce a new instance via [copyWith].
/// Hive typeId: 0
class Task {
  const Task({
    required this.id,
    required this.name,
    required this.priority,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.dueDate,
    this.dueTime,
    this.assigneeId,
    this.description,
  });

  final String id;
  final String name;           // max 100 chars
  final DateTime? dueDate;     // null = no due date
  final TimeOfDay? dueTime;    // null = all day
  final TaskPriority priority;
  final TaskStatus status;
  final String? assigneeId;    // references User.id
  final String? description;   // max 500 chars
  final DateTime createdAt;
  final DateTime updatedAt;

  // ── Computed getters ──────────────────────────────────────────────────────

  bool get isCompleted => status == TaskStatus.completed;

  /// A task is overdue when its due date is strictly before today and it is
  /// not yet completed.
  bool get isOverdue {
    if (dueDate == null || isCompleted) return false;
    final now = DateTime.now();
    final todayMidnight = DateTime(now.year, now.month, now.day);
    final dueMidnight = DateTime(dueDate!.year, dueDate!.month, dueDate!.day);
    return dueMidnight.isBefore(todayMidnight);
  }

  /// A task is due today when its due date matches today's calendar date.
  bool get isDueToday {
    if (dueDate == null) return false;
    final now = DateTime.now();
    return dueDate!.year == now.year &&
        dueDate!.month == now.month &&
        dueDate!.day == now.day;
  }

  // ── copyWith ──────────────────────────────────────────────────────────────

  Task copyWith({
    String? id,
    String? name,
    DateTime? dueDate,
    TimeOfDay? dueTime,
    TaskPriority? priority,
    TaskStatus? status,
    String? assigneeId,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool clearDueDate = false,
    bool clearDueTime = false,
    bool clearAssigneeId = false,
    bool clearDescription = false,
  }) {
    return Task(
      id: id ?? this.id,
      name: name ?? this.name,
      dueDate: clearDueDate ? null : (dueDate ?? this.dueDate),
      dueTime: clearDueTime ? null : (dueTime ?? this.dueTime),
      priority: priority ?? this.priority,
      status: status ?? this.status,
      assigneeId: clearAssigneeId ? null : (assigneeId ?? this.assigneeId),
      description: clearDescription ? null : (description ?? this.description),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Task && other.id == id);

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Task(id: $id, name: $name, status: $status)';
}
