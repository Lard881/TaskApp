import 'package:flutter_test/flutter_test.dart';
import 'package:planpal/application/notifiers/task_notifier.dart';
import 'package:planpal/domain/enums/task_priority.dart';
import 'package:planpal/domain/enums/task_status.dart';
import 'package:planpal/domain/models/task.dart';

Task makeTask({
  String id = 'id',
  TaskStatus status = TaskStatus.todo,
  DateTime? dueDate,
}) {
  final now = DateTime.now();
  return Task(
    id: id,
    name: 'Task $id',
    priority: TaskPriority.medium,
    status: status,
    dueDate: dueDate,
    createdAt: now,
    updatedAt: now,
  );
}

final yesterday = DateTime.now().subtract(const Duration(days: 2));

void main() {
  group('PerformanceMetrics.fromTasks', () {
    test('empty list → all zeros', () {
      final m = PerformanceMetrics.fromTasks([]);
      expect(m.completed, 0);
      expect(m.inProgress, 0);
      expect(m.overdue, 0);
      expect(m.productivity, 0);
    });

    test('default constructor → all zeros', () {
      const m = PerformanceMetrics();
      expect(m.completed, 0);
      expect(m.inProgress, 0);
      expect(m.overdue, 0);
      expect(m.productivity, 0);
    });

    test('all completed → completed = total, productivity = 100', () {
      final tasks = [
        makeTask(id: '1', status: TaskStatus.completed),
        makeTask(id: '2', status: TaskStatus.completed),
        makeTask(id: '3', status: TaskStatus.completed),
      ];
      final m = PerformanceMetrics.fromTasks(tasks);
      expect(m.completed, 3);
      expect(m.inProgress, 0);
      expect(m.overdue, 0);
      expect(m.productivity, 100);
    });

    test('no completed → productivity = 0', () {
      final tasks = [
        makeTask(id: '1', status: TaskStatus.todo),
        makeTask(id: '2', status: TaskStatus.inProgress),
      ];
      final m = PerformanceMetrics.fromTasks(tasks);
      expect(m.completed, 0);
      expect(m.productivity, 0);
    });

    test('mixed status → correct counts', () {
      final tasks = [
        makeTask(id: '1', status: TaskStatus.completed),
        makeTask(id: '2', status: TaskStatus.completed),
        makeTask(id: '3', status: TaskStatus.inProgress),
        makeTask(id: '4', status: TaskStatus.todo),
      ];
      final m = PerformanceMetrics.fromTasks(tasks);
      expect(m.completed, 2);
      expect(m.inProgress, 1);
      expect(m.productivity, 50); // 2/4 * 100
    });

    test('productivity rounds to nearest integer', () {
      // 1 completed out of 3 = 33.33… → rounds to 33
      final tasks = [
        makeTask(id: '1', status: TaskStatus.completed),
        makeTask(id: '2', status: TaskStatus.todo),
        makeTask(id: '3', status: TaskStatus.todo),
      ];
      final m = PerformanceMetrics.fromTasks(tasks);
      expect(m.productivity, 33);
    });

    test('2 out of 3 completed = 67%', () {
      final tasks = [
        makeTask(id: '1', status: TaskStatus.completed),
        makeTask(id: '2', status: TaskStatus.completed),
        makeTask(id: '3', status: TaskStatus.todo),
      ];
      final m = PerformanceMetrics.fromTasks(tasks);
      expect(m.productivity, 67);
    });

    test('overdue tasks counted correctly', () {
      final tasks = [
        makeTask(id: '1', status: TaskStatus.todo, dueDate: yesterday),
        makeTask(id: '2', status: TaskStatus.inProgress, dueDate: yesterday),
        makeTask(id: '3', status: TaskStatus.completed, dueDate: yesterday),
        // completed → not overdue even if date is past
      ];
      final m = PerformanceMetrics.fromTasks(tasks);
      expect(m.overdue, 2); // only non-completed past-due tasks
    });

    test('completed overdue task is NOT counted in overdue', () {
      final tasks = [
        makeTask(id: '1', status: TaskStatus.completed, dueDate: yesterday),
      ];
      final m = PerformanceMetrics.fromTasks(tasks);
      expect(m.overdue, 0);
    });

    test('single task completed → productivity = 100', () {
      final m = PerformanceMetrics.fromTasks([
        makeTask(id: '1', status: TaskStatus.completed),
      ]);
      expect(m.productivity, 100);
    });

    test('single task not completed → productivity = 0', () {
      final m = PerformanceMetrics.fromTasks([
        makeTask(id: '1', status: TaskStatus.todo),
      ]);
      expect(m.productivity, 0);
    });
  });
}
