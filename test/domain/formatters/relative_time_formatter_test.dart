import 'package:flutter_test/flutter_test.dart';
import 'package:planpal/core/formatters/relative_time_formatter.dart';

void main() {
  // Helper: create a timestamp [seconds] before [now]
  DateTime ago(DateTime now, {int seconds = 0, int minutes = 0, int hours = 0, int days = 0}) {
    return now.subtract(Duration(
      seconds: seconds,
      minutes: minutes,
      hours: hours,
      days: days,
    ));
  }

  group('RelativeTimeFormatter.formatRelative', () {
    final now = DateTime(2024, 6, 15, 12, 0, 0); // fixed reference

    // ── < 1 minute ────────────────────────────────────────────────────────
    test('0 seconds ago → "Just now"', () {
      expect(
        RelativeTimeFormatter.formatRelative(now, now: now),
        'Just now',
      );
    });
    test('59 seconds ago → "Just now"', () {
      expect(
        RelativeTimeFormatter.formatRelative(ago(now, seconds: 59), now: now),
        'Just now',
      );
    });

    // ── 1–59 minutes ──────────────────────────────────────────────────────
    test('60 seconds ago → "1 minute ago"', () {
      expect(
        RelativeTimeFormatter.formatRelative(ago(now, seconds: 60), now: now),
        '1 minute ago',
      );
    });
    test('59 minutes ago → "59 minutes ago"', () {
      expect(
        RelativeTimeFormatter.formatRelative(ago(now, minutes: 59), now: now),
        '59 minutes ago',
      );
    });
    test('2 minutes ago → "2 minutes ago"', () {
      expect(
        RelativeTimeFormatter.formatRelative(ago(now, minutes: 2), now: now),
        '2 minutes ago',
      );
    });

    // ── 1–23 hours ────────────────────────────────────────────────────────
    test('60 minutes ago → "1 hour ago"', () {
      expect(
        RelativeTimeFormatter.formatRelative(ago(now, minutes: 60), now: now),
        '1 hour ago',
      );
    });
    test('23 hours ago → "23 hours ago"', () {
      expect(
        RelativeTimeFormatter.formatRelative(ago(now, hours: 23), now: now),
        '23 hours ago',
      );
    });
    test('2 hours ago → "2 hours ago"', () {
      expect(
        RelativeTimeFormatter.formatRelative(ago(now, hours: 2), now: now),
        '2 hours ago',
      );
    });

    // ── Yesterday ─────────────────────────────────────────────────────────
    test('exactly 1 calendar day ago → "Yesterday"', () {
      // Same time yesterday = 1 calendar day back
      final yesterday = DateTime(2024, 6, 14, 12, 0, 0);
      expect(
        RelativeTimeFormatter.formatRelative(yesterday, now: now),
        'Yesterday',
      );
    });

    // ── 2–6 days ──────────────────────────────────────────────────────────
    test('2 calendar days ago → "2 days ago"', () {
      final ts = DateTime(2024, 6, 13, 12, 0, 0);
      expect(
        RelativeTimeFormatter.formatRelative(ts, now: now),
        '2 days ago',
      );
    });
    test('6 calendar days ago → "6 days ago"', () {
      final ts = DateTime(2024, 6, 9, 12, 0, 0);
      expect(
        RelativeTimeFormatter.formatRelative(ts, now: now),
        '6 days ago',
      );
    });

    // ── ≥ 7 days → absolute date ──────────────────────────────────────────
    test('7 calendar days ago → "MMM DD" format', () {
      final ts = DateTime(2024, 6, 8, 12, 0, 0);
      expect(
        RelativeTimeFormatter.formatRelative(ts, now: now),
        'Jun 08',
      );
    });
    test('30 days ago → absolute date', () {
      final ts = DateTime(2024, 5, 16, 12, 0, 0);
      final result = RelativeTimeFormatter.formatRelative(ts, now: now);
      expect(result, 'May 16');
    });

    // ── Future timestamp ──────────────────────────────────────────────────
    test('future timestamp → "Just now"', () {
      final future = now.add(const Duration(hours: 1));
      expect(
        RelativeTimeFormatter.formatRelative(future, now: now),
        'Just now',
      );
    });
  });
}
