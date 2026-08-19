/// Extension methods on [DateTime] used throughout the app.
extension DateTimeExtensions on DateTime {
  /// Returns `true` if this [DateTime] falls on the same calendar day
  /// as [other] — year, month, and day must all match.
  bool isSameDay(DateTime other) =>
      year == other.year && month == other.month && day == other.day;

  /// Returns `true` if this [DateTime] is strictly before today at 00:00
  /// in the device's local time zone.
  bool get isStrictlyBeforeToday {
    final now = DateTime.now();
    final todayMidnight = DateTime(now.year, now.month, now.day);
    // Strip time from this DateTime before comparing
    final thisMidnight = DateTime(year, month, day);
    return thisMidnight.isBefore(todayMidnight);
  }

  /// Returns `true` if this [DateTime] is strictly after today at 23:59.
  bool get isStrictlyAfterToday {
    final now = DateTime.now();
    final todayMidnight = DateTime(now.year, now.month, now.day);
    final thisMidnight = DateTime(year, month, day);
    return thisMidnight.isAfter(todayMidnight);
  }

  /// Returns `true` if this [DateTime] is today (same calendar day as now).
  bool get isToday {
    final now = DateTime.now();
    return isSameDay(now);
  }

  /// Returns a new [DateTime] with only the date components (time set to 00:00).
  DateTime get dateOnly => DateTime(year, month, day);

  /// Number of full calendar days between this date and today.
  /// Positive means this is in the future; negative means in the past.
  int get calendarDaysFromToday {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final thisDay = DateTime(year, month, day);
    return thisDay.difference(today).inDays;
  }
}
