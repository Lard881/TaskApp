/// The priority level of a task.
enum TaskPriority {
  high,
  medium,
  low;

  /// Display label shown in badges and dropdowns.
  String get label {
    switch (this) {
      case TaskPriority.high:
        return 'High';
      case TaskPriority.medium:
        return 'Medium';
      case TaskPriority.low:
        return 'Low';
    }
  }

  /// Short label used in compact task list items (Req 7.3).
  String get shortLabel {
    switch (this) {
      case TaskPriority.high:
        return 'High';
      case TaskPriority.medium:
        return 'Med';
      case TaskPriority.low:
        return 'Low';
    }
  }

  /// Sort weight — lower number = higher priority (used by sort logic).
  int get sortWeight {
    switch (this) {
      case TaskPriority.high:
        return 0;
      case TaskPriority.medium:
        return 1;
      case TaskPriority.low:
        return 2;
    }
  }
}
