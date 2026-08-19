/// The type of action recorded in the Recent Activity feed (Req 17).
enum ActivityType {
  created,
  updated,
  completed;

  /// Human-readable past-tense verb for activity descriptions.
  String get verb {
    switch (this) {
      case ActivityType.created:
        return 'created';
      case ActivityType.updated:
        return 'updated';
      case ActivityType.completed:
        return 'completed';
    }
  }
}
