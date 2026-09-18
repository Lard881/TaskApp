import 'package:intl/intl.dart';
import 'package:planpal/core/extensions/datetime_extensions.dart';

/// Formats a [DateTime] as a human-readable relative time string,
/// used in the Profile screen's Recent Activity feed (Req 17.3).
abstract final class RelativeTimeFormatter {
  static final DateFormat _monthDay = DateFormat('MMM dd');

  /// Returns a relative time string for the given [timestamp] compared
  /// to [now] (defaults to `DateTime.now()` when omitted — injectable
  /// for testing).
  ///
  /// Rules:
  /// - d < 1 min           → "Just now"
  /// - 1 min ≤ d < 60 min  → "N minutes ago"
  /// - 1 h ≤ d < 24 h      → "N hours ago"
  /// - exactly 1 day back  → "Yesterday"
  /// - 2 ≤ days < 7        → "N days ago"
  /// - ≥ 7 days            → "MMM DD" (e.g. "Jan 08")
  static String formatRelative(DateTime timestamp, {DateTime? now}) {
    final reference = now ?? DateTime.now();
    final diff = reference.difference(timestamp);

    if (diff.isNegative) {
      // Timestamp is in the future — treat as "Just now"
      return 'Just now';
    }

    if (diff.inSeconds < 60) {
      return 'Just now';
    }

    if (diff.inMinutes < 60) {
      final mins = diff.inMinutes;
      return '$mins ${mins == 1 ? 'minute' : 'minutes'} ago';
    }

    if (diff.inHours < 24) {
      final hrs = diff.inHours;
      return '$hrs ${hrs == 1 ? 'hour' : 'hours'} ago';
    }

    // Use calendar-day comparison for "Yesterday" and "N days ago"
    final refDay = reference.dateOnly;
    final tsDay = timestamp.dateOnly;
    final calendarDays = refDay.difference(tsDay).inDays;

    if (calendarDays == 1) {
      return 'Yesterday';
    }

    if (calendarDays < 7) {
      return '$calendarDays days ago';
    }

    return _monthDay.format(timestamp);
  }
}
