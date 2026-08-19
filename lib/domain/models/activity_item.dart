import 'package:hive/hive.dart';
import 'package:planpal/domain/enums/activity_type.dart';

part 'activity_item_adapter.dart';

/// A single entry in the Profile screen's Recent Activity feed.
/// Hive typeId: 4
class ActivityItem {
  const ActivityItem({
    required this.id,
    required this.type,
    required this.taskName,
    required this.timestamp,
    this.taskId,
  });

  final String id;
  final ActivityType type;   // created | updated | completed
  final String? taskId;      // null when the referenced task has been deleted
  final String taskName;     // snapshot of the task name at the time of the activity
  final DateTime timestamp;

  /// Display-safe description of this activity.
  /// Shows "[Deleted task]" if the task no longer exists (taskId is null).
  String description(String? resolvedTaskName) {
    final name = resolvedTaskName ?? '[Deleted task]';
    return 'Task "$name" ${type.verb}';
  }

  ActivityItem copyWith({
    String? id,
    ActivityType? type,
    String? taskId,
    String? taskName,
    DateTime? timestamp,
    bool clearTaskId = false,
  }) {
    return ActivityItem(
      id: id ?? this.id,
      type: type ?? this.type,
      taskId: clearTaskId ? null : (taskId ?? this.taskId),
      taskName: taskName ?? this.taskName,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is ActivityItem && other.id == id);

  @override
  int get hashCode => id.hashCode;
}
