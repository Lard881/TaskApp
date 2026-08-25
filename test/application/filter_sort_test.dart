import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:planpal/application/notifiers/task_filter_notifier.dart';
import 'package:planpal/domain/enums/filter_tab.dart';
import 'package:planpal/domain/enums/sort_option.dart';
import 'package:planpal/domain/enums/task_priority.dart';
import 'package:planpal/domain/enums/task_status.dart';
import 'package:planpal/domain/models/task.dart';

// ── helpers ───────────────────────────────────────────────────────────────────

Task makeTask({
  String id = 'id',
  String name = 'Task',
  TaskPriority priority = TaskPriority.medium,
  TaskStatus status = TaskStatus.todo,
  DateTime? dueDate,
  TimeOfDay? dueTime,
  DateTime? createdAt,
}) {
  final now = DateTime.now();
  return Task(
    id: id,
    name: name,
    priority: priority,
    status: status,
    dueDate: dueDate,
    dueTime: dueTime,
    createdAt: createdAt ?? now,
    updatedAt: now,
  );
}

final today = DateTime.now();
final todayMidnight = DateTime(today.year, today.month, today.day);
final tomorrow = todayMidnight.add(const Duration(days: 1));
final yesterday = todayMidnight.subtract(const Duration(days: 1));
final nextWeek = todayMidnight.add(const Duration(days: 7));

// ── filter tests ──────────────────────────────────────────────────────────────

void main() {
  group('filterTasks — FilterTab.all', () {
    test('empty list → empty result', () {
      expect(filterTasks([], FilterTab.all), isEmpty);
    });

    test('returns every task regardless of status or date', () {
      final tasks = [
        makeTask(id: '1', status: TaskStatus.todo, dueDate: yesterday),
        makeTask(id: '2', status: TaskStatus.completed),
        makeTask(id: '3', status: TaskStatus.inProgress, dueDate: nextWeek),
        makeTask(id: '4'), // no due date
      ];
      expect(filterTasks(tasks, FilterTab.all), hasLength(4));
    });
  });

  group('filterTasks — FilterTab.today', () {
    test('empty list → empty', () {
      expect(filterTasks([], FilterTab.today), isEmpty);
    });

    test('only returns tasks due today', () {
      final tasks = [
        makeTask(id: '1', dueDate: todayMidnight),
        makeTask(id: '2', dueDate: tomorrow),
        makeTask(id: '3', dueDate: yesterday),
        makeTask(id: '4'), // no due date
      ];
      final result = filterTasks(tasks, FilterTab.today);
      expect(result, hasLength(1));
      expect(result.first.id, '1');
    });

    test('completed tasks due today ARE included', () {
      final task = makeTask(
          id: '1', dueDate: todayMidnight, status: TaskStatus.completed);
      expect(filterTasks([task], FilterTab.today), hasLength(1));
    });

    test('tasks with no due date are excluded', () {
      final task = makeTask(id: '1');
      expect(filterTasks([task], FilterTab.today), isEmpty);
    });
  });

  group('filterTasks — FilterTab.upcoming', () {
    test('empty list → empty', () {
      expect(filterTasks([], FilterTab.upcoming), isEmpty);
    });

    test('returns tasks with dueDate strictly after today, not completed', () {
      final tasks = [
        makeTask(id: '1', dueDate: tomorrow, status: TaskStatus.todo),
        makeTask(id: '2', dueDate: nextWeek, status: TaskStatus.inProgress),
        makeTask(id: '3', dueDate: todayMidnight), // today — excluded
        makeTask(id: '4', dueDate: yesterday),     // overdue — excluded
        makeTask(id: '5', dueDate: tomorrow, status: TaskStatus.completed), // excluded
        makeTask(id: '6'), // no due date — excluded
      ];
      final result = filterTasks(tasks, FilterTab.upcoming);
      expect(result, hasLength(2));
      expect(result.map((t) => t.id).toSet(), {'1', '2'});
    });
  });

  group('filterTasks — FilterTab.completed', () {
    test('empty list → empty', () {
      expect(filterTasks([], FilterTab.completed), isEmpty);
    });

    test('returns only completed tasks', () {
      final tasks = [
        makeTask(id: '1', status: TaskStatus.completed),
        makeTask(id: '2', status: TaskStatus.todo),
        makeTask(id: '3', status: TaskStatus.inProgress),
        makeTask(id: '4', status: TaskStatus.completed),
      ];
      final result = filterTasks(tasks, FilterTab.completed);
      expect(result, hasLength(2));
      expect(result.every((t) => t.status == TaskStatus.completed), isTrue);
    });
  });

  // ── sort tests ──────────────────────────────────────────────────────────────

  group('sortTasks — preserves all elements', () {
    test('sorted list has same length as input', () {
      final tasks = List.generate(
        5,
        (i) => makeTask(id: '$i', dueDate: todayMidnight.add(Duration(days: i))),
      );
      for (final option in SortOption.values) {
        expect(sortTasks(tasks, option), hasLength(tasks.length));
      }
    });

    test('same IDs appear in result regardless of sort option', () {
      final tasks = [
        makeTask(id: 'a', priority: TaskPriority.high),
        makeTask(id: 'b', priority: TaskPriority.low),
        makeTask(id: 'c', priority: TaskPriority.medium),
      ];
      for (final option in SortOption.values) {
        final ids = sortTasks(tasks, option).map((t) => t.id).toSet();
        expect(ids, {'a', 'b', 'c'});
      }
    });
  });

  group('sortTasks — dueDateAsc', () {
    test('tasks ordered earliest due date first', () {
      final tasks = [
        makeTask(id: 'b', dueDate: nextWeek),
        makeTask(id: 'a', dueDate: tomorrow),
        makeTask(id: 'c', dueDate: todayMidnight),
      ];
      final sorted = sortTasks(tasks, SortOption.dueDateAsc);
      expect(sorted.map((t) => t.id).toList(), ['c', 'a', 'b']);
    });

    test('null due date tasks go to the end', () {
      final tasks = [
        makeTask(id: 'b', dueDate: nextWeek),
        makeTask(id: 'no_date'),
        makeTask(id: 'a', dueDate: tomorrow),
      ];
      final sorted = sortTasks(tasks, SortOption.dueDateAsc);
      expect(sorted.last.id, 'no_date');
    });
  });

  group('sortTasks — dueDateDesc', () {
    test('tasks ordered latest due date first', () {
      final tasks = [
        makeTask(id: 'a', dueDate: tomorrow),
        makeTask(id: 'c', dueDate: todayMidnight),
        makeTask(id: 'b', dueDate: nextWeek),
      ];
      final sorted = sortTasks(tasks, SortOption.dueDateDesc);
      expect(sorted.map((t) => t.id).toList(), ['b', 'a', 'c']);
    });

    test('null due date tasks go to the end regardless of direction', () {
      final tasks = [
        makeTask(id: 'no_date'),
        makeTask(id: 'a', dueDate: tomorrow),
      ];
      final sorted = sortTasks(tasks, SortOption.dueDateDesc);
      expect(sorted.last.id, 'no_date');
    });
  });

  group('sortTasks — priorityHighToLow', () {
    test('high before medium before low', () {
      final tasks = [
        makeTask(id: 'low', priority: TaskPriority.low),
        makeTask(id: 'high', priority: TaskPriority.high),
        makeTask(id: 'med', priority: TaskPriority.medium),
      ];
      final sorted = sortTasks(tasks, SortOption.priorityHighToLow);
      expect(sorted.map((t) => t.id).toList(), ['high', 'med', 'low']);
    });
  });

  group('sortTasks — priorityLowToHigh', () {
    test('low before medium before high', () {
      final tasks = [
        makeTask(id: 'high', priority: TaskPriority.high),
        makeTask(id: 'med', priority: TaskPriority.medium),
        makeTask(id: 'low', priority: TaskPriority.low),
      ];
      final sorted = sortTasks(tasks, SortOption.priorityLowToHigh);
      expect(sorted.map((t) => t.id).toList(), ['low', 'med', 'high']);
    });
  });

  group('sortTasks — nameAZ', () {
    test('alphabetical ascending', () {
      final tasks = [
        makeTask(id: '3', name: 'Zebra'),
        makeTask(id: '1', name: 'Apple'),
        makeTask(id: '2', name: 'Mango'),
      ];
      final sorted = sortTasks(tasks, SortOption.nameAZ);
      expect(sorted.map((t) => t.name).toList(), ['Apple', 'Mango', 'Zebra']);
    });
  });

  group('sortTasks — nameZA', () {
    test('alphabetical descending', () {
      final tasks = [
        makeTask(id: '1', name: 'Apple'),
        makeTask(id: '3', name: 'Zebra'),
        makeTask(id: '2', name: 'Mango'),
      ];
      final sorted = sortTasks(tasks, SortOption.nameZA);
      expect(sorted.map((t) => t.name).toList(), ['Zebra', 'Mango', 'Apple']);
    });
  });

  group('sortTasks — empty list', () {
    test('all options return empty list for empty input', () {
      for (final option in SortOption.values) {
        expect(sortTasks([], option), isEmpty);
      }
    });
  });
}
