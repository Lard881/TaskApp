import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:planpal/application/notifiers/auth_notifier.dart';
import 'package:planpal/application/notifiers/preferences_notifier.dart';
import 'package:planpal/application/notifiers/user_notifier.dart';
import 'package:planpal/domain/models/app_preferences.dart';
import 'package:planpal/domain/models/user.dart';
import 'package:planpal/presentation/screens/settings/settings_screen.dart';

// ── Fake notifiers ────────────────────────────────────────────────────────────

class _FakeUserNotifier extends UserNotifier {
  @override
  Future<User?> build() async => const User(
        id: 'u1',
        firstName: 'Alex',
        lastName: 'Morgan',
        email: 'alex@planpal.app',
      );
}

class _FakePrefsNotifier extends PreferencesNotifier {
  @override
  Future<AppPreferences> build() async => AppPreferences.defaults;
}

class _FakeAuthNotifier extends AuthNotifier {
  @override
  Future<AppAuthState> build() async => AppAuthState.authenticated;
}

// ── Router ────────────────────────────────────────────────────────────────────

GoRouter _router() => GoRouter(
      initialLocation: '/settings',
      routes: [
        GoRoute(
          path: '/settings',
          builder: (_, __) => const SettingsScreen(),
        ),
        GoRoute(path: '/profile', builder: (_, __) => const Scaffold()),
        GoRoute(
            path: '/settings/notifications',
            builder: (_, __) => const Scaffold()),
        GoRoute(
            path: '/settings/security',
            builder: (_, __) => const Scaffold()),
        GoRoute(
            path: '/settings/language',
            builder: (_, __) => const Scaffold()),
        GoRoute(
            path: '/settings/timezone',
            builder: (_, __) => const Scaffold()),
        GoRoute(
            path: '/settings/help', builder: (_, __) => const Scaffold()),
        GoRoute(
            path: '/settings/about', builder: (_, __) => const Scaffold()),
        GoRoute(path: '/home', builder: (_, __) => const Scaffold()),
        GoRoute(path: '/login', builder: (_, __) => const Scaffold()),
      ],
    );

Widget buildSettings() {
  return ProviderScope(
    overrides: [
      currentUserProvider.overrideWith(() => _FakeUserNotifier()),
      preferencesProvider.overrideWith(() => _FakePrefsNotifier()),
      authProvider.overrideWith(() => _FakeAuthNotifier()),
    ],
    child: MaterialApp.router(routerConfig: _router()),
  );
}

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  group('SettingsScreen — section headers', () {
    testWidgets('shows "ACCOUNT SETTINGS" section label', (tester) async {
      await tester.pumpWidget(buildSettings());
      await tester.pumpAndSettle();
      expect(find.textContaining('ACCOUNT SETTINGS'), findsOneWidget);
    });

    testWidgets('shows "PREFERENCES" section label', (tester) async {
      await tester.pumpWidget(buildSettings());
      await tester.pumpAndSettle();
      expect(find.textContaining('PREFERENCES'), findsOneWidget);
    });

    testWidgets('shows "SUPPORT & LEGALS" section label', (tester) async {
      await tester.pumpWidget(buildSettings());
      await tester.pumpAndSettle();
      expect(find.textContaining('SUPPORT & LEGALS'), findsOneWidget);
    });
  });

  group('SettingsScreen — list items present', () {
    testWidgets('Personal Profile item is visible', (tester) async {
      await tester.pumpWidget(buildSettings());
      await tester.pumpAndSettle();
      expect(find.text('Personal Profile'), findsOneWidget);
    });

    testWidgets('Notification Preferences item is visible', (tester) async {
      await tester.pumpWidget(buildSettings());
      await tester.pumpAndSettle();
      expect(find.text('Notification Preferences'), findsOneWidget);
    });

    testWidgets('Security & Privacy item is visible', (tester) async {
      await tester.pumpWidget(buildSettings());
      await tester.pumpAndSettle();
      expect(find.text('Security & Privacy'), findsOneWidget);
    });

    testWidgets('Interface Theme item is visible', (tester) async {
      await tester.pumpWidget(buildSettings());
      await tester.pumpAndSettle();
      expect(find.text('Interface Theme'), findsOneWidget);
    });

    testWidgets('App Language item is visible', (tester) async {
      await tester.pumpWidget(buildSettings());
      await tester.pumpAndSettle();
      expect(find.text('App Language'), findsOneWidget);
    });

    testWidgets('Time Zone item is visible', (tester) async {
      await tester.pumpWidget(buildSettings());
      await tester.pumpAndSettle();
      expect(find.text('Time Zone'), findsOneWidget);
    });

    testWidgets('Help & Support item is visible', (tester) async {
      await tester.pumpWidget(buildSettings());
      await tester.pumpAndSettle();
      expect(find.text('Help & Support'), findsOneWidget);
    });
  });

  group('SettingsScreen — Log Out button', () {
    testWidgets('Log Out button is present', (tester) async {
      await tester.pumpWidget(buildSettings());
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.textContaining('Log Out'),
        500,
      );
      expect(find.textContaining('Log Out'), findsOneWidget);
    });

    testWidgets('Log Out button is an OutlinedButton', (tester) async {
      await tester.pumpWidget(buildSettings());
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.textContaining('Log Out'),
        500,
      );
      expect(find.byType(OutlinedButton), findsOneWidget);
    });
  });

  group('SettingsScreen — section order', () {
    testWidgets('Account Settings appears before Preferences', (tester) async {
      await tester.pumpWidget(buildSettings());
      await tester.pumpAndSettle();
      final accountY =
          tester.getTopLeft(find.textContaining('ACCOUNT SETTINGS')).dy;
      final prefsY =
          tester.getTopLeft(find.textContaining('PREFERENCES')).dy;
      expect(accountY, lessThan(prefsY));
    });

    testWidgets('Preferences appears before Support & Legals', (tester) async {
      await tester.pumpWidget(buildSettings());
      await tester.pumpAndSettle();
      final prefsY =
          tester.getTopLeft(find.textContaining('PREFERENCES')).dy;
      await tester.scrollUntilVisible(
        find.textContaining('SUPPORT & LEGALS'),
        300,
      );
      final supportY =
          tester.getTopLeft(find.textContaining('SUPPORT & LEGALS')).dy;
      expect(prefsY, lessThan(supportY));
    });
  });
}
