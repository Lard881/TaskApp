import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:planpal/core/formatters/datetime_formatter.dart';

void main() {
  group('DateTimeFormatter.salutation', () {
    DateTime dt(int hour) => DateTime(2024, 1, 15, hour, 0);

    // Morning boundary: 05:00–11:59
    test('returns Good Morning at 05:00', () {
      expect(DateTimeFormatter.salutation(dt(5)), 'Good Morning');
    });
    test('returns Good Morning at 11:00', () {
      expect(DateTimeFormatter.salutation(dt(11)), 'Good Morning');
    });
    test('returns Good Afternoon at 12:00', () {
      expect(DateTimeFormatter.salutation(dt(12)), 'Good Afternoon');
    });
    test('returns Good Afternoon at 17:00', () {
      expect(DateTimeFormatter.salutation(dt(17)), 'Good Afternoon');
    });
    test('returns Good Evening at 18:00', () {
      expect(DateTimeFormatter.salutation(dt(18)), 'Good Evening');
    });
    test('returns Good Evening at 23:00', () {
      expect(DateTimeFormatter.salutation(dt(23)), 'Good Evening');
    });
    test('returns Good Evening at 00:00 (midnight)', () {
      expect(DateTimeFormatter.salutation(dt(0)), 'Good Evening');
    });
    test('returns Good Evening at 04:00', () {
      expect(DateTimeFormatter.salutation(dt(4)), 'Good Evening');
    });
    // Edge: every hour is classified
    test('all 24 hours produce a non-empty salutation', () {
      for (int h = 0; h < 24; h++) {
        final s = DateTimeFormatter.salutation(dt(h));
        expect(s, isNotEmpty, reason: 'hour $h returned empty string');
        expect(
          ['Good Morning', 'Good Afternoon', 'Good Evening'].contains(s),
          isTrue,
          reason: 'hour $h produced unexpected salutation "$s"',
        );
      }
    });
  });

  group('DateTimeFormatter.greetingLine', () {
    final morning = DateTime(2024, 1, 15, 8, 0);

    test('produces "<salutation>, <firstName>" with correct spacing', () {
      final result = DateTimeFormatter.greetingLine('Alex', morning);
      expect(result, 'Good Morning, Alex');
    });
    test('trims whitespace from firstName', () {
      final result = DateTimeFormatter.greetingLine('  Jamie  ', morning);
      expect(result, 'Good Morning, Jamie');
    });
    test('has no leading or trailing whitespace', () {
      final result = DateTimeFormatter.greetingLine('Sam', morning);
      expect(result, result.trim());
    });
    test('contains exactly one comma-space between salutation and name', () {
      final result = DateTimeFormatter.greetingLine('Chris', morning);
      // Should be "Good Morning, Chris" — comma then one space
      expect(result.contains(', '), isTrue);
    });
  });

  group('DateTimeFormatter.taskCountSubtitle', () {
    test('0 tasks → plural form', () {
      expect(
        DateTimeFormatter.taskCountSubtitle(0),
        'You have 0 tasks due today.',
      );
    });
    test('1 task → singular form', () {
      expect(
        DateTimeFormatter.taskCountSubtitle(1),
        'You have 1 task due today.',
      );
    });
    test('2 tasks → plural form', () {
      expect(
        DateTimeFormatter.taskCountSubtitle(2),
        'You have 2 tasks due today.',
      );
    });
    test('100 tasks → plural form', () {
      expect(
        DateTimeFormatter.taskCountSubtitle(100),
        'You have 100 tasks due today.',
      );
    });
  });

  group('DateTimeFormatter.formatDueDate', () {
    final date = DateTime(2024, 1, 15);
    const time = TimeOfDay(hour: 9, minute: 0);

    test('null date → "All day"', () {
      expect(DateTimeFormatter.formatDueDate(null, null), 'All day');
    });
    test('date only → "MMM DD" format', () {
      final result = DateTimeFormatter.formatDueDate(date, null);
      expect(result, 'Jan 15');
    });
    test('date + time → "MMM DD, HH:mm" format', () {
      final result = DateTimeFormatter.formatDueDate(date, time);
      expect(result, 'Jan 15, 09:00');
    });
    test('time with minutes → formatted correctly', () {
      const timeWithMins = TimeOfDay(hour: 14, minute: 30);
      final result = DateTimeFormatter.formatDueDate(date, timeWithMins);
      expect(result, 'Jan 15, 14:30');
    });
  });

  group('DateTimeFormatter.formatConversationTimestamp', () {
    test('today → HH:mm format', () {
      final now = DateTime.now();
      final todaySentAt = DateTime(now.year, now.month, now.day, 10, 30);
      expect(DateTimeFormatter.formatConversationTimestamp(todaySentAt), '10:30');
    });
    test('2 days ago → day name', () {
      final twoDaysAgo = DateTime.now().subtract(const Duration(days: 2));
      final result = DateTimeFormatter.formatConversationTimestamp(twoDaysAgo);
      // Should be a 3-letter day abbreviation
      expect(result.length, 3);
    });
    test('8 days ago → MMM DD format', () {
      final eightDaysAgo = DateTime(2024, 1, 7);
      final result = DateTimeFormatter.formatConversationTimestamp(eightDaysAgo);
      expect(result, contains('Jan'));
    });
  });

  group('DateTimeFormatter.formatMessageTimestamp', () {
    test('today → HH:mm only', () {
      final now = DateTime.now();
      final sentAt = DateTime(now.year, now.month, now.day, 9, 45);
      expect(DateTimeFormatter.formatMessageTimestamp(sentAt), '09:45');
    });
    test('yesterday → MMM DD, HH:mm', () {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final sentAt = DateTime(
          yesterday.year, yesterday.month, yesterday.day, 14, 00);
      final result = DateTimeFormatter.formatMessageTimestamp(sentAt);
      expect(result, contains(':'));
      expect(result, contains(','));
    });
  });
}
