/// The completion status of a task.
enum TaskStatus {
  todo,
  inProgress,
  completed;

  /// Human-readable label for display.
  String get label {
    switch (this) {
      case TaskStatus.todo:
        return 'To Do';
      case TaskStatus.inProgress:
        return 'In Progress';
      case TaskStatus.completed:
        return 'Completed';
    }
  }
}
