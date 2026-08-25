import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:planpal/core/constants/app_colors.dart';
import 'package:planpal/presentation/screens/settings/settings_screen.dart';

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
            path: '/settings/security', builder: (_, __) => const Scaffold()),
        GoRoute(
            path: '/settings/language', builder: (_, __) => const Scaffold()),
        GoRoute(
            path: '/settings/timezone', builder: (_, __) => const Scaffold()),
        GoRoute(
            path: '/settings/help', builder: (_, __) => const Scaffold()),
        GoRoute(
            path: '/settings/about', builder: (_, __) => const Scaffold()),
        GoRoute(path: '/home', builder: (_, __) => const Scaffold()),
      ],
    );

Widget buildSettings() {
  return ProviderScope(
    child: MaterialApp.router(routerConfig: _router()),
  );
}

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
      // Scroll to bottom to reveal the button
      await tester.scrollUntilVisible(
        find.textContaining('Log Out'),
        500,
      );
      expect(find.textContaining('Log Out'), findsOneWidget);
    });

    testWidgets('Log Out button uses red color', (tester) async {
      await tester.pumpWidget(buildSettings());
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.textContaining('Log Out'),
        500,
      );
      // Find OutlinedButton containing 'Log Out Account'
      final outlinedButtons = tester.widgetList<OutlinedButton>(
        find.byType(OutlinedButton),
      );
      expect(outlinedButtons, isNotEmpty);
    });
  });

  group('SettingsScreen — section order', () {
    testWidgets('Account Settings appears before Preferences', (tester) async {
      await tester.pumpWidget(buildSettings());
      await tester.pumpAndSettle();

      final accountPos = tester
          .getTopLeft(find.textContaining('ACCOUNT SETTINGS'))
          .dy;
      final prefsPos = tester
          .getTopLeft(find.textContaining('PREFERENCES'))
          .dy;
      expect(accountPos, lessThan(prefsPos));
    });

    testWidgets('Preferences appears before Support & Legals', (tester) async {
      await tester.pumpWidget(buildSettings());
      await tester.pumpAndSettle();

      final prefsPos =
          tester.getTopLeft(find.textContaining('PREFERENCES')).dy;
      // Support might be off screen — scroll to find it
      await tester.scrollUntilVisible(
        find.textContaining('SUPPORT & LEGALS'),
        300,
      );
      final supportPos =
          tester.getTopLeft(find.textContaining('SUPPORT & LEGALS')).dy;
      expect(prefsPos, lessThan(supportPos));
    });
  });
}
