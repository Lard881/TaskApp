import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:planpal/application/notifiers/task_notifier.dart';
import 'package:planpal/application/notifiers/user_notifier.dart';
import 'package:planpal/domain/enums/task_priority.dart';
import 'package:planpal/domain/enums/task_status.dart';
import 'package:planpal/domain/models/task.dart';
import 'package:planpal/domain/models/user.dart';
import 'package:planpal/presentation/screens/home/home_screen.dart';

// ── Fake notifiers ────────────────────────────────────────────────────────────

class _FakeTaskNotifier extends TaskNotifier {
  _FakeTaskNotifier(this._tasks);
  final List<Task> _tasks;
  @override
  Future<List<Task>> build() async => _tasks;
}

class _FakeUserNotifier extends UserNotifier {
  _FakeUserNotifier(this._user);
  final User? _user;
  @override
  Future<User?> build() async => _user;
}

// ── Helpers ───────────────────────────────────────────────────────────────────

Task makeTask({
  String id = 't1',
  String name = 'Task',
  TaskStatus status = TaskStatus.todo,
  DateTime? dueDate,
}) {
  final now = DateTime.now();
  return Task(
    id: id,
    name: name,
    priority: TaskPriority.medium,
    status: status,
    dueDate: dueDate ?? DateTime.now(),
    createdAt: now,
    updatedAt: now,
  );
}

const _user = User(
  id: 'u1',
  firstName: 'Alex',
  lastName: 'Morgan',
  email: 'alex@planpal.app',
);

GoRouter _router() => GoRouter(
      initialLocation: '/home',
      routes: [
        GoRoute(
          path: '/home',
          builder: (_, __) => const HomeScreen(),
        ),
        GoRoute(path: '/tasks', builder: (_, __) => const Scaffold()),
        GoRoute(path: '/profile', builder: (_, __) => const Scaffold()),
      ],
    );

Widget buildHome({List<Task> tasks = const [], User? user = _user}) {
  return ProviderScope(
    overrides: [
      tasksProvider.overrideWith(() => _FakeTaskNotifier(tasks)),
      currentUserProvider.overrideWith(() => _FakeUserNotifier(user)),
    ],
    child: MaterialApp.router(routerConfig: _router()),
  );
}

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  group('HomeScreen — greeting', () {
    testWidgets('shows greeting containing user first name', (tester) async {
      await tester.pumpWidget(buildHome());
      await tester.pumpAndSettle();
      // Greeting line: "Good Morning, Alex" or similar
      expect(find.textContaining('Alex'), findsWidgets);
    });

    testWidgets('shows one of the three valid salutations', (tester) async {
      await tester.pumpWidget(buildHome());
      await tester.pumpAndSettle();
      final hasSalutation = find.textContaining('Good Morning').evaluate().isNotEmpty ||
          find.textContaining('Good Afternoon').evaluate().isNotEmpty ||
          find.textContaining('Good Evening').evaluate().isNotEmpty;
      expect(hasSalutation, isTrue);
    });
  });

  group('HomeScreen — quick actions', () {
    testWidgets('shows all 4 quick action labels', (tester) async {
      await tester.pumpWidget(buildHome());
      await tester.pumpAndSettle();
      expect(find.text('New Task'), findsOneWidget);
      expect(find.text('Calendar'), findsOneWidget);
      expect(find.text('Analytics'), findsOneWidget);
      expect(find.text('Documents'), findsOneWidget);
    });
  });

  group('HomeScreen — performance overview', () {
    testWidgets('shows Performance Overview section', (tester) async {
      await tester.pumpWidget(buildHome());
      await tester.pumpAndSettle();
      expect(find.text('Performance Overview'), findsOneWidget);
    });

    testWidgets('shows Completed metric tile', (tester) async {
      await tester.pumpWidget(buildHome());
      await tester.pumpAndSettle();
      expect(find.text('Completed'), findsWidgets);
    });

    testWidgets('shows In Progress metric tile', (tester) async {
      await tester.pumpWidget(buildHome());
      await tester.pumpAndSettle();
      expect(find.text('In Progress'), findsOneWidget);
    });

    testWidgets('shows Overdue metric tile', (tester) async {
      await tester.pumpWidget(buildHome());
      await tester.pumpAndSettle();
      expect(find.text('Overdue'), findsOneWidget);
    });

    testWidgets('shows Productivity metric tile', (tester) async {
      await tester.pumpWidget(buildHome());
      await tester.pumpAndSettle();
      expect(find.text('Productivity'), findsOneWidget);
    });
  });

  group('HomeScreen — today tasks', () {
    testWidgets('shows "No tasks due today" when task list is empty',
        (tester) async {
      await tester.pumpWidget(buildHome(tasks: []));
      await tester.pumpAndSettle();
      expect(find.textContaining('No tasks due today'), findsOneWidget);
    });

    testWidgets('shows today\'s task names when tasks exist', (tester) async {
      final today = DateTime.now();
      final todayTask = makeTask(
        id: 'today-1',
        name: 'Deploy hotfix',
        dueDate: DateTime(today.year, today.month, today.day),
      );
      await tester.pumpWidget(buildHome(tasks: [todayTask]));
      await tester.pumpAndSettle();
      expect(find.text('Deploy hotfix'), findsOneWidget);
    });

    testWidgets('shows "View All" link when more than 5 today tasks',
        (tester) async {
      final today = DateTime.now();
      final todayDate = DateTime(today.year, today.month, today.day);
      final tasks = List.generate(
        6,
        (i) => makeTask(id: 't$i', name: 'Task $i', dueDate: todayDate),
      );
      await tester.pumpWidget(buildHome(tasks: tasks));
      await tester.pumpAndSettle();
      expect(find.text('View All'), findsOneWidget);
    });

    testWidgets('does NOT show "View All" when 5 or fewer today tasks',
        (tester) async {
      final today = DateTime.now();
      final todayDate = DateTime(today.year, today.month, today.day);
      final tasks = List.generate(
        5,
        (i) => makeTask(id: 't$i', name: 'Task $i', dueDate: todayDate),
      );
      await tester.pumpWidget(buildHome(tasks: tasks));
      await tester.pumpAndSettle();
      expect(find.text('View All'), findsNothing);
    });
  });

  group('HomeScreen — subtitle grammar', () {
    testWidgets('singular: "1 task due today"', (tester) async {
      final today = DateTime.now();
      final tasks = [
        makeTask(
          id: '1',
          dueDate: DateTime(today.year, today.month, today.day),
        ),
      ];
      await tester.pumpWidget(buildHome(tasks: tasks));
      await tester.pumpAndSettle();
      expect(find.textContaining('1 task due today'), findsOneWidget);
    });

    testWidgets('plural: "2 tasks due today"', (tester) async {
      final today = DateTime.now();
      final todayDate = DateTime(today.year, today.month, today.day);
      final tasks = [
        makeTask(id: '1', dueDate: todayDate),
        makeTask(id: '2', dueDate: todayDate),
      ];
      await tester.pumpWidget(buildHome(tasks: tasks));
      await tester.pumpAndSettle();
      expect(find.textContaining('2 tasks due today'), findsOneWidget);
    });
  });
}
