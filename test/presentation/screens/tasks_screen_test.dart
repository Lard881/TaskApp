import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:planpal/application/notifiers/task_notifier.dart';
import 'package:planpal/core/constants/app_strings.dart';
import 'package:planpal/domain/enums/filter_tab.dart';
import 'package:planpal/domain/enums/task_priority.dart';
import 'package:planpal/domain/enums/task_status.dart';
import 'package:planpal/domain/models/task.dart';
import 'package:planpal/presentation/screens/tasks/tasks_screen.dart';

Task makeTask({
  String id = 'task-1',
  String name = 'Test Task',
  TaskStatus status = TaskStatus.todo,
  TaskPriority priority = TaskPriority.medium,
  DateTime? dueDate,
}) {
  final now = DateTime.now();
  return Task(
    id: id,
    name: name,
    priority: priority,
    status: status,
    dueDate: dueDate,
    createdAt: now,
    updatedAt: now,
  );
}

// Provides a tasksProvider override with a fixed list
ProviderContainer makeContainer(List<Task> tasks) {
  return ProviderContainer(
    overrides: [
      tasksProvider.overrideWith(() => _FakeTaskNotifier(tasks)),
    ],
  );
}

class _FakeTaskNotifier extends TaskNotifier {
  _FakeTaskNotifier(this._tasks);
  final List<Task> _tasks;

  @override
  Future<List<Task>> build() async => _tasks;
}

GoRouter _router({FilterTab? filter}) => GoRouter(
      initialLocation: '/tasks',
      routes: [
        GoRoute(
          path: '/tasks',
          builder: (_, state) =>
              TasksScreen(initialFilter: filter),
        ),
        GoRoute(path: '/home', builder: (_, __) => const Scaffold()),
      ],
    );

Widget buildTasksScreen(List<Task> tasks, {FilterTab? filter}) {
  return ProviderScope(
    overrides: [
      tasksProvider.overrideWith(() => _FakeTaskNotifier(tasks)),
    ],
    child: MaterialApp.router(
      routerConfig: _router(filter: filter),
    ),
  );
}

void main() {
  group('TasksScreen — filter tabs', () {
    testWidgets('renders all 4 filter tabs', (tester) async {
      await tester.pumpWidget(buildTasksScreen([]));
      await tester.pump();
      expect(find.text('All'), findsOneWidget);
      expect(find.text('Today'), findsOneWidget);
      expect(find.text('Upcoming'), findsOneWidget);
      expect(find.text('Completed'), findsOneWidget);
    });

    testWidgets('tapping a filter tab does not crash', (tester) async {
      await tester.pumpWidget(buildTasksScreen([]));
      await tester.pump();
      await tester.tap(find.text('Today'));
      await tester.pump();
      // No exception — filter state changed
    });
  });

  group('TasksScreen — empty state', () {
    testWidgets('shows empty state message when no tasks', (tester) async {
      await tester.pumpWidget(buildTasksScreen([]));
      await tester.pump();
      expect(find.text(AppStrings.noTasksEmpty), findsOneWidget);
    });
  });

  group('TasksScreen — task list', () {
    testWidgets('shows task names for non-empty list', (tester) async {
      final tasks = [
        makeTask(id: '1', name: 'Fix bug #123'),
        makeTask(id: '2', name: 'Write tests'),
      ];
      await tester.pumpWidget(buildTasksScreen(tasks));
      await tester.pumpAndSettle();
      expect(find.text('Fix bug #123'), findsOneWidget);
      expect(find.text('Write tests'), findsOneWidget);
    });
  });

  group('TasksScreen — FAB', () {
    testWidgets('FAB is visible', (tester) async {
      await tester.pumpWidget(buildTasksScreen([]));
      await tester.pump();
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets('FAB shows + Add Task label', (tester) async {
      await tester.pumpWidget(buildTasksScreen([]));
      await tester.pump();
      expect(find.textContaining('Add Task'), findsOneWidget);
    });
  });

  group('TasksScreen — sort button', () {
    testWidgets('sort icon button is present in top bar', (tester) async {
      await tester.pumpWidget(buildTasksScreen([]));
      await tester.pump();
      // TopBar contains an IconButton for sorting
      expect(find.byType(IconButton), findsWidgets);
    });
  });
}
