import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:planpal/core/validators/task_validator.dart';
import 'package:planpal/domain/enums/task_priority.dart';

void main() {
  group('TaskValidator.validateName', () {
    test('null → error', () {
      expect(TaskValidator.validateName(null), isNotNull);
    });
    test('empty string → error', () {
      expect(TaskValidator.validateName(''), isNotNull);
    });
    test('whitespace only → error', () {
      expect(TaskValidator.validateName('   '), isNotNull);
    });
    test('1 character → valid', () {
      expect(TaskValidator.validateName('A'), isNull);
    });
    test('100 characters → valid', () {
      expect(TaskValidator.validateName('A' * 100), isNull);
    });
    test('101 characters → error', () {
      expect(TaskValidator.validateName('A' * 101), isNotNull);
    });
    test('valid name → null', () {
      expect(TaskValidator.validateName('Design new feature'), isNull);
    });
  });

  group('TaskValidator.validateDueDate', () {
    test('null → error', () {
      expect(TaskValidator.validateDueDate(null), isNotNull);
    });
    test('a date value → valid', () {
      expect(TaskValidator.validateDueDate(DateTime(2024, 6, 15)), isNull);
    });
  });

  group('TaskValidator.validateDueTime', () {
    test('null → error', () {
      expect(TaskValidator.validateDueTime(null), isNotNull);
    });
    test('a TimeOfDay value → valid', () {
      expect(
        TaskValidator.validateDueTime(const TimeOfDay(hour: 9, minute: 0)),
        isNull,
      );
    });
  });

  group('TaskValidator.validatePriority', () {
    test('null → error', () {
      expect(TaskValidator.validatePriority(null), isNotNull);
    });
    test('high priority → valid', () {
      expect(TaskValidator.validatePriority(TaskPriority.high), isNull);
    });
    test('medium priority → valid', () {
      expect(TaskValidator.validatePriority(TaskPriority.medium), isNull);
    });
    test('low priority → valid', () {
      expect(TaskValidator.validatePriority(TaskPriority.low), isNull);
    });
  });

  group('TaskValidator.validateAll', () {
    final validDate = DateTime(2024, 6, 15);
    const validTime = TimeOfDay(hour: 10, minute: 0);

    test('all valid → empty errors map', () {
      final errors = TaskValidator.validateAll(
        name: 'Valid task',
        dueDate: validDate,
        dueTime: validTime,
        priority: TaskPriority.medium,
      );
      expect(errors, isEmpty);
    });

    test('all invalid → all four keys present', () {
      final errors = TaskValidator.validateAll(
        name: '',
        dueDate: null,
        dueTime: null,
        priority: null,
      );
      expect(errors.containsKey('name'), isTrue);
      expect(errors.containsKey('dueDate'), isTrue);
      expect(errors.containsKey('dueTime'), isTrue);
      expect(errors.containsKey('priority'), isTrue);
    });

    test('only name invalid → only name key in errors', () {
      final errors = TaskValidator.validateAll(
        name: '',
        dueDate: validDate,
        dueTime: validTime,
        priority: TaskPriority.low,
      );
      expect(errors.containsKey('name'), isTrue);
      expect(errors.containsKey('dueDate'), isFalse);
      expect(errors.containsKey('dueTime'), isFalse);
      expect(errors.containsKey('priority'), isFalse);
    });

    test('name at 100 chars with all other fields valid → no errors', () {
      final errors = TaskValidator.validateAll(
        name: 'A' * 100,
        dueDate: validDate,
        dueTime: validTime,
        priority: TaskPriority.high,
      );
      expect(errors, isEmpty);
    });

    test('name at 101 chars → name error only', () {
      final errors = TaskValidator.validateAll(
        name: 'A' * 101,
        dueDate: validDate,
        dueTime: validTime,
        priority: TaskPriority.high,
      );
      expect(errors.containsKey('name'), isTrue);
      expect(errors.length, 1);
    });
  });
}
