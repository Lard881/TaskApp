// Integration smoke tests for PlanPal (Task 19.1).
//
// All fake notifiers extend the REAL notifier class (not AsyncNotifier<X>)
// so that overrideWith() type-checks correctly after Phase 2 refactor.
// No network or Supabase calls are made — providers are fully overridden.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:planpal/application/notifiers/auth_notifier.dart';
import 'package:planpal/application/notifiers/conversation_notifier.dart';
import 'package:planpal/application/notifiers/preferences_notifier.dart';
import 'package:planpal/application/notifiers/task_notifier.dart';
import 'package:planpal/application/notifiers/user_notifier.dart';
import 'package:planpal/core/constants/app_strings.dart';
import 'package:planpal/core/theme/app_theme.dart';
import 'package:planpal/domain/enums/task_priority.dart';
import 'package:planpal/domain/enums/task_status.dart';
import 'package:planpal/domain/models/app_preferences.dart';
import 'package:planpal/domain/models/conversation.dart';
import 'package:planpal/domain/models/task.dart';
import 'package:planpal/domain/models/user.dart';
import 'package:planpal/presentation/screens/chat/chat_screen.dart';
import 'package:planpal/presentation/screens/home/home_screen.dart';
import 'package:planpal/presentation/screens/profile/profile_screen.dart';
import 'package:planpal/presentation/screens/settings/settings_screen.dart';
import 'package:planpal/presentation/screens/shell/app_shell.dart';
import 'package:planpal/presentation/screens/tasks/tasks_screen.dart';

// ── Fake notifiers ────────────────────────────────────────────────────────────
// Must extend the REAL notifier class so overrideWith() passes the type check.

class _FakeTaskNotifier extends TaskNotifier {
  // Tasks stored before the notifier is mounted.
  // build() reads from _pending — never call state= before mounting.
  final List<Task> _pending = [];

  @override
  Future<List<Task>> build() async => List<Task>.from(_pending);

  /// Safe to call before or after mounting — stores tasks for next build().
  void seed(List<Task> tasks) {
    _pending
      ..clear()
      ..addAll(tasks);
  }

  @override
  Future<void> addTask(Task task) async {
    _pending.add(task);
    state = AsyncData(List<Task>.from(_pending));
  }

  @override
  Future<void> updateTask(Task task) async {
    final idx = _pending.indexWhere((t) => t.id == task.id);
    if (idx != -1) _pending[idx] = task;
    state = AsyncData(List<Task>.from(_pending));
  }

  @override
  Future<void> deleteTask(String id) async {
    _pending.removeWhere((t) => t.id == id);
    state = AsyncData(List<Task>.from(_pending));
  }

  @override
  Future<void> markComplete(String id) async {
    final idx = _pending.indexWhere((t) => t.id == id);
    if (idx != -1) {
      _pending[idx] = _pending[idx].copyWith(status: TaskStatus.completed);
    }
    state = AsyncData(List<Task>.from(_pending));
  }

  @override
  Future<void> reopenTask(String id) async {
    final idx = _pending.indexWhere((t) => t.id == id);
    if (idx != -1) {
      _pending[idx] = _pending[idx].copyWith(status: TaskStatus.inProgress);
    }
    state = AsyncData(List<Task>.from(_pending));
  }
}

class _FakeUserNotifier extends UserNotifier {
  User? _fakeUser = const User(
    id: 'u1',
    firstName: 'Alex',
    lastName: 'Morgan',
    email: 'alex@planpal.app',
    role: 'Product Manager',
  );

  @override
  Future<User?> build() async => _fakeUser;

  @override
  Future<void> updateProfile(User updated) async {
    _fakeUser = updated;
    state = AsyncData(_fakeUser);
  }

  @override
  Future<void> updateAvatar(String path) async {
    _fakeUser = _fakeUser?.copyWith(avatarPath: path);
    state = AsyncData(_fakeUser);
  }
}

class _FakePreferencesNotifier extends PreferencesNotifier {
  @override
  Future<AppPreferences> build() async => AppPreferences.defaults;

  @override
  Future<void> setTheme(ThemeMode mode) async {
    final current = state.valueOrNull ?? AppPreferences.defaults;
    state = AsyncData(current.copyWith(themeMode: mode));
  }

  @override
  Future<void> setLanguage(String code) async {
    final current = state.valueOrNull ?? AppPreferences.defaults;
    state = AsyncData(current.copyWith(languageCode: code));
  }

  @override
  Future<void> setTimeZone(String tz) async {
    final current = state.valueOrNull ?? AppPreferences.defaults;
    state = AsyncData(current.copyWith(timeZoneId: tz));
  }

  @override
  Future<void> setTaskReminders(bool v) async {
    final current = state.valueOrNull ?? AppPreferences.defaults;
    state = AsyncData(current.copyWith(notifyTaskReminders: v));
  }

  @override
  Future<void> setDueDateAlerts(bool v) async {
    final current = state.valueOrNull ?? AppPreferences.defaults;
    state = AsyncData(current.copyWith(notifyDueDateAlerts: v));
  }

  @override
  Future<void> setChatMessages(bool v) async {
    final current = state.valueOrNull ?? AppPreferences.defaults;
    state = AsyncData(current.copyWith(notifyChatMessages: v));
  }

  @override
  Future<void> setWeeklySummary(bool v) async {
    final current = state.valueOrNull ?? AppPreferences.defaults;
    state = AsyncData(current.copyWith(notifyWeeklySummary: v));
  }
}

class _FakeConversationNotifier extends ConversationNotifier {
  @override
  Future<List<Conversation>> build() async => [];
}

class _FakeAuthNotifier extends AuthNotifier {
  @override
  Future<AppAuthState> build() async => AppAuthState.authenticated;
}

// ── Shared instances ──────────────────────────────────────────────────────────
// Created once. _FakeTaskNotifier.seed() is safe to call before mounting
// because it guards against the LateInitializationError.

final _taskNotifier = _FakeTaskNotifier();
final _userNotifier = _FakeUserNotifier();
final _prefsNotifier = _FakePreferencesNotifier();
final _convNotifier = _FakeConversationNotifier();
final _authNotifier = _FakeAuthNotifier();

// ── Router ────────────────────────────────────────────────────────────────────

GoRouter _appRouter() => GoRouter(
      initialLocation: '/home',
      routes: [
        StatefulShellRoute.indexedStack(
          builder: (_, __, shell) => AppShell(navigationShell: shell),
          branches: [
            StatefulShellBranch(routes: [
              GoRoute(
                path: '/home',
                builder: (_, __) => const HomeScreen(),
              ),
            ]),
            StatefulShellBranch(routes: [
              GoRoute(
                path: '/tasks',
                builder: (_, state) => TasksScreen(
                  initialFilter: state.extra != null
                      ? (state.extra as Map)['filter']
                      : null,
                ),
              ),
            ]),
            StatefulShellBranch(routes: [
              GoRoute(
                path: '/chat',
                builder: (_, __) => const ChatScreen(),
              ),
            ]),
            StatefulShellBranch(routes: [
              GoRoute(
                path: '/profile',
                builder: (_, __) => const ProfileScreen(),
              ),
            ]),
            StatefulShellBranch(routes: [
              GoRoute(
                path: '/settings',
                builder: (_, __) => const SettingsScreen(),
                routes: [
                  GoRoute(
                      path: 'notifications',
                      builder: (_, __) => const Scaffold()),
                  GoRoute(
                      path: 'security',
                      builder: (_, __) => const Scaffold()),
                  GoRoute(
                      path: 'help', builder: (_, __) => const Scaffold()),
                  GoRoute(
                      path: 'about', builder: (_, __) => const Scaffold()),
                  GoRoute(
                      path: 'language',
                      builder: (_, __) => const Scaffold()),
                  GoRoute(
                      path: 'timezone',
                      builder: (_, __) => const Scaffold()),
                ],
              ),
            ]),
          ],
        ),
      ],
    );

// ── App harness ───────────────────────────────────────────────────────────────

Widget buildApp() {
  return ProviderScope(
    overrides: [
      tasksProvider.overrideWith(() => _taskNotifier),
      currentUserProvider.overrideWith(() => _userNotifier),
      preferencesProvider.overrideWith(() => _prefsNotifier),
      conversationsProvider.overrideWith(() => _convNotifier),
      authProvider.overrideWith(() => _authNotifier),
    ],
    child: MaterialApp.router(
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      routerConfig: _appRouter(),
    ),
  );
}

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  setUp(() {
    // Reset tasks before each test — safe before widget mounting
    _taskNotifier.seed([]);
  });

  group('App smoke — initial render', () {
    testWidgets('Home screen renders without error', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();
      expect(find.text('PlanPal'), findsWidgets);
    });

    testWidgets('Bottom nav bar shows 5 tabs', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Tasks'), findsOneWidget);
      expect(find.text('Chat'), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
    });
  });

  group('App smoke — tab navigation', () {
    testWidgets('tapping Tasks tab shows Tasks screen', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();
      await tester.tap(find.text('Tasks'));
      await tester.pumpAndSettle();
      expect(find.text('PlanPal'), findsWidgets);
      expect(find.text('All'), findsOneWidget);
    });

    testWidgets('tapping Chat tab shows Conversations screen',
        (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();
      await tester.tap(find.text('Chat'));
      await tester.pumpAndSettle();
      expect(find.text('Conversations'), findsOneWidget);
    });

    testWidgets('tapping Profile tab shows Profile screen', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();
      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Alex'), findsWidgets);
    });

    testWidgets('tapping Settings tab shows Settings screen', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();
      expect(find.text('Settings'), findsWidgets);
    });

    testWidgets('can navigate back to Home tab', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();
      await tester.tap(find.text('Tasks'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Home'));
      await tester.pumpAndSettle();
      expect(find.text('Quick Actions'), findsOneWidget);
    });
  });

  group('App smoke — tasks flow', () {
    testWidgets('Tasks screen shows empty state when no tasks',
        (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();
      await tester.tap(find.text('Tasks'));
      await tester.pumpAndSettle();
      expect(find.text(AppStrings.noTasksEmpty), findsOneWidget);
    });

    testWidgets('seeded task appears in task list', (tester) async {
      _taskNotifier.seed([
        Task(
          id: 'smoke-1',
          name: 'Smoke test task',
          priority: TaskPriority.high,
          status: TaskStatus.todo,
          dueDate: DateTime.now(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ]);
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();
      await tester.tap(find.text('Tasks'));
      await tester.pumpAndSettle();
      expect(find.text('Smoke test task'), findsOneWidget);
    });

    testWidgets('completed task appears in Completed filter', (tester) async {
      _taskNotifier.seed([
        Task(
          id: 'smoke-done',
          name: 'Completed task',
          priority: TaskPriority.low,
          status: TaskStatus.completed,
          dueDate: DateTime.now(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ]);
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();
      await tester.tap(find.text('Tasks'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Completed'));
      await tester.pumpAndSettle();
      expect(find.text('Completed task'), findsOneWidget);
    });
  });

  group('App smoke — settings', () {
    testWidgets('Settings screen lists all 3 sections', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();
      expect(find.textContaining('ACCOUNT SETTINGS'), findsOneWidget);
      expect(find.textContaining('PREFERENCES'), findsOneWidget);
    });

    testWidgets('tapping Interface Theme opens theme modal', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Interface Theme'));
      await tester.pumpAndSettle();
      expect(find.text('Light'), findsOneWidget);
      expect(find.text('Dark'), findsOneWidget);
      expect(find.text('System Default'), findsOneWidget);
    });
  });
}
