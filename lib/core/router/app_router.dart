import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:planpal/application/notifiers/auth_notifier.dart';
import 'package:planpal/domain/enums/filter_tab.dart';
import 'package:planpal/presentation/screens/auth/login_screen.dart';
import 'package:planpal/presentation/screens/auth/sign_up_screen.dart';
import 'package:planpal/presentation/screens/chat/chat_screen.dart';
import 'package:planpal/presentation/screens/chat/conversation_detail_screen.dart';
import 'package:planpal/presentation/screens/home/home_screen.dart';
import 'package:planpal/presentation/screens/onboarding/onboarding_welcome_screen.dart';
import 'package:planpal/presentation/screens/onboarding/create_workspace_screen.dart';
import 'package:planpal/presentation/screens/onboarding/invite_teammates_screen.dart';
import 'package:planpal/presentation/screens/profile/profile_screen.dart';
import 'package:planpal/presentation/screens/settings/about_screen.dart';
import 'package:planpal/presentation/screens/settings/help_screen.dart';
import 'package:planpal/presentation/screens/settings/language_selection_screen.dart';
import 'package:planpal/presentation/screens/settings/notification_preferences_screen.dart';
import 'package:planpal/presentation/screens/settings/security_privacy_screen.dart';
import 'package:planpal/presentation/screens/settings/settings_screen.dart';
import 'package:planpal/presentation/screens/settings/timezone_selection_screen.dart';
import 'package:planpal/presentation/screens/shell/app_shell.dart';
import 'package:planpal/presentation/screens/splash/splash_screen.dart';
import 'package:planpal/presentation/screens/tasks/tasks_screen.dart';

/// Route guard — redirects based on [AppAuthState].
///
/// /splash               — always accessible (entry point)
/// /login, /signup       — only when unauthenticated
/// /onboarding/*         — only when in onboarding state
/// /home, /tasks, etc.   — only when authenticated
String? _redirect(AppAuthState authState, String location) {
  final isOnSplash = location == '/splash';
  final isOnAuth =
      location == '/login' || location == '/signup';
  final isOnOnboarding = location.startsWith('/onboarding');

  // Always let splash through — it resolves auth itself
  if (isOnSplash) return null;

  switch (authState) {
    case AppAuthState.unknown:
      return '/splash';

    case AppAuthState.unauthenticated:
      if (isOnAuth) return null;
      return '/login';

    case AppAuthState.onboarding:
      if (isOnOnboarding) return null;
      return '/onboarding';

    case AppAuthState.authenticated:
      if (isOnAuth || isOnOnboarding) return '/home';
      return null;
  }
}

/// Creates the app router. Takes [ref] so it can watch [authProvider].
GoRouter createAppRouter(Ref ref) {
  // Listenable that rebuilds the router when auth state changes
  final authListenable = _AuthStateListenable(ref);

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: authListenable,
    redirect: (context, state) {
      final authState =
          ref.read(authProvider).valueOrNull ?? AppAuthState.unknown;
      return _redirect(authState, state.matchedLocation);
    },
    routes: [
      // ── Splash ─────────────────────────────────────────────────────────
      GoRoute(
        path: '/splash',
        builder: (_, __) => const SplashScreen(),
      ),

      // ── Auth ────────────────────────────────────────────────────────────
      GoRoute(
        path: '/login',
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (_, __) => const SignUpScreen(),
      ),

      // ── Onboarding ──────────────────────────────────────────────────────
      GoRoute(
        path: '/onboarding',
        builder: (_, __) => const OnboardingWelcomeScreen(),
      ),
      GoRoute(
        path: '/onboarding/create-workspace',
        builder: (_, __) => const CreateWorkspaceScreen(),
      ),
      GoRoute(
        path: '/onboarding/invite',
        builder: (context, state) {
          final workspaceId = state.extra as String? ?? '';
          return InviteTeammatesScreen(workspaceId: workspaceId);
        },
      ),

      // ── Main shell with bottom nav ───────────────────────────────────────
      StatefulShellRoute.indexedStack(
        builder: (_, __, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          // 0 — Home
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/home',
              builder: (_, __) => const HomeScreen(),
            ),
          ]),

          // 1 — Tasks
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/tasks',
              builder: (_, state) {
                final extra = state.extra as Map<String, dynamic>?;
                final filter = extra?['filter'] as FilterTab?;
                return TasksScreen(initialFilter: filter);
              },
            ),
          ]),

          // 2 — Chat
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/chat',
              builder: (_, __) => const ChatScreen(),
              routes: [
                GoRoute(
                  path: ':conversationId',
                  builder: (_, state) => ConversationDetailScreen(
                    conversationId:
                        state.pathParameters['conversationId']!,
                  ),
                ),
              ],
            ),
          ]),

          // 3 — Profile
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/profile',
              builder: (_, __) => const ProfileScreen(),
            ),
          ]),

          // 4 — Settings
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/settings',
              builder: (_, __) => const SettingsScreen(),
              routes: [
                GoRoute(
                  path: 'notifications',
                  builder: (_, __) =>
                      const NotificationPreferencesScreen(),
                ),
                GoRoute(
                  path: 'security',
                  builder: (_, __) => const SecurityPrivacyScreen(),
                ),
                GoRoute(
                  path: 'help',
                  builder: (_, __) => const HelpScreen(),
                ),
                GoRoute(
                  path: 'about',
                  builder: (_, __) => const AboutScreen(),
                ),
                GoRoute(
                  path: 'language',
                  builder: (_, __) => const LanguageSelectionScreen(),
                ),
                GoRoute(
                  path: 'timezone',
                  builder: (_, __) => const TimeZoneSelectionScreen(),
                ),
              ],
            ),
          ]),
        ],
      ),
    ],

    errorBuilder: (_, state) => Scaffold(
      body: Center(child: Text('Page not found: ${state.uri}')),
    ),
  );
}

// ── Auth listenable ───────────────────────────────────────────────────────────

/// Notifies GoRouter to re-evaluate redirects when auth state changes.
class _AuthStateListenable extends ChangeNotifier {
  _AuthStateListenable(Ref ref) {
    ref.listen<AsyncValue<AppAuthState>>(authProvider, (_, __) {
      notifyListeners();
    });
  }
}
