import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:planpal/core/extensions/datetime_extensions.dart';

/// Stateless date/time formatting utilities used across the UI.
/// All methods are pure functions — no side effects.
abstract final class DateTimeFormatter {
  // ── Date format instances (created once, reused) ──────────────────────────
  static final DateFormat _monthDay = DateFormat('MMM dd');         // Jan 15
  static final DateFormat _monthDayTime = DateFormat('MMM dd, HH:mm'); // Jan 15, 09:00
  static final DateFormat _timeOnly = DateFormat('HH:mm');           // 09:00
  static final DateFormat _dayName = DateFormat('EEE');              // Mon

  // ── Greeting / salutation ─────────────────────────────────────────────────

  /// Returns the time-based salutation for the given [DateTime].
  ///
  /// - 05:00–11:59 → "Good Morning"
  /// - 12:00–17:59 → "Good Afternoon"
  /// - 18:00–04:59 → "Good Evening"
  static String salutation(DateTime dt) {
    final hour = dt.hour;
    if (hour >= 5 && hour < 12) return 'Good Morning';
    if (hour >= 12 && hour < 18) return 'Good Afternoon';
    return 'Good Evening';
  }

  /// Builds the greeting line: `"<salutation>, <firstName>"`.
  /// Trims leading/trailing whitespace and guarantees exactly one space
  /// between the salutation and the name.
  static String greetingLine(String firstName, DateTime dt) {
    final name = firstName.trim();
    return '${salutation(dt)}, $name';
  }

  /// Returns the task count subtitle with correct singular/plural grammar.
  ///
  /// - N = 1 → "You have 1 task due today."
  /// - N ≠ 1 → "You have N tasks due today."
  static String taskCountSubtitle(int n) {
    if (n == 1) return 'You have 1 task due today.';
    return 'You have $n tasks due today.';
  }

  // ── Due date / time ───────────────────────────────────────────────────────

  /// Formats a task's due date and optional due time.
  ///
  /// - date + time → "Jan 15, 09:00"
  /// - date only   → "Jan 15"
  /// - neither     → "All day"
  static String formatDueDate(DateTime? date, TimeOfDay? time) {
    if (date == null) return 'All day';
    if (time != null) {
      // Combine date and time into a single DateTime for formatting
      final combined = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
      return _monthDayTime.format(combined);
    }
    return _monthDay.format(date);
  }

  // ── Conversation list timestamp ───────────────────────────────────────────

  /// Formats a conversation's last-message timestamp:
  ///
  /// - Today           → "HH:mm"   (e.g. "14:30")
  /// - 2–7 days ago    → day name  (e.g. "Mon")
  /// - Older than 7    → "MMM DD"  (e.g. "Jan 15")
  static String formatConversationTimestamp(DateTime sentAt) {
    final now = DateTime.now();
    if (sentAt.isSameDay(now)) {
      return _timeOnly.format(sentAt);
    }
    final daysAgo = now.dateOnly.difference(sentAt.dateOnly).inDays;
    if (daysAgo >= 2 && daysAgo <= 7) {
      return _dayName.format(sentAt);
    }
    return _monthDay.format(sentAt);
  }

  // ── Message detail timestamp ──────────────────────────────────────────────

  /// Formats a single message's timestamp:
  ///
  /// - Today     → "HH:mm"          (e.g. "09:45")
  /// - Otherwise → "MMM DD, HH:mm"  (e.g. "Jan 14, 09:45")
  static String formatMessageTimestamp(DateTime sentAt) {
    final now = DateTime.now();
    if (sentAt.isSameDay(now)) {
      return _timeOnly.format(sentAt);
    }
    return _monthDayTime.format(sentAt);
  }
}
