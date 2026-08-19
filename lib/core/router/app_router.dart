import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:planpal/presentation/screens/shell/app_shell.dart';
import 'package:planpal/presentation/screens/splash/splash_screen.dart';
import 'package:planpal/presentation/screens/home/home_screen.dart';
import 'package:planpal/presentation/screens/tasks/tasks_screen.dart';
import 'package:planpal/presentation/screens/chat/chat_screen.dart';
import 'package:planpal/presentation/screens/chat/conversation_detail_screen.dart';
import 'package:planpal/presentation/screens/profile/profile_screen.dart';
import 'package:planpal/presentation/screens/settings/settings_screen.dart';
import 'package:planpal/presentation/screens/settings/notification_preferences_screen.dart';
import 'package:planpal/presentation/screens/settings/security_privacy_screen.dart';
import 'package:planpal/presentation/screens/settings/help_screen.dart';
import 'package:planpal/presentation/screens/settings/about_screen.dart';
import 'package:planpal/presentation/screens/settings/language_selection_screen.dart';
import 'package:planpal/presentation/screens/settings/timezone_selection_screen.dart';

/// The global go_router configuration.
///
/// Structure:
/// /splash                 → SplashScreen (initial route)
/// /home                   → HomeScreen          (shell branch 0)
/// /tasks                  → TasksScreen         (shell branch 1)
/// /chat                   → ChatScreen          (shell branch 2)
///   /chat/:id             → ConversationDetailScreen
/// /profile                → ProfileScreen       (shell branch 3)
/// /settings               → SettingsScreen      (shell branch 4)
///   /settings/notifications
///   /settings/security
///   /settings/help
///   /settings/about
///   /settings/language
///   /settings/timezone
final GoRouter appRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    // ── Splash ──────────────────────────────────────────────────────────────
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashScreen(),
    ),

    // ── Main shell with BottomNavigationBar ──────────────────────────────────
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          AppShell(navigationShell: navigationShell),
      branches: [
        // Branch 0 — Home
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/home',
              builder: (context, state) => const HomeScreen(),
            ),
          ],
        ),

        // Branch 1 — Tasks
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/tasks',
              builder: (context, state) {
                // Allow pre-selecting a filter tab via extra parameter
                final extra = state.extra as Map<String, dynamic>?;
                return TasksScreen(initialFilter: extra?['filter']);
              },
            ),
          ],
        ),

        // Branch 2 — Chat
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/chat',
              builder: (context, state) => const ChatScreen(),
              routes: [
                GoRoute(
                  path: ':conversationId',
                  builder: (context, state) => ConversationDetailScreen(
                    conversationId:
                        state.pathParameters['conversationId']!,
                  ),
                ),
              ],
            ),
          ],
        ),

        // Branch 3 — Profile
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/profile',
              builder: (context, state) => const ProfileScreen(),
            ),
          ],
        ),

        // Branch 4 — Settings
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/settings',
              builder: (context, state) => const SettingsScreen(),
              routes: [
                GoRoute(
                  path: 'notifications',
                  builder: (context, state) =>
                      const NotificationPreferencesScreen(),
                ),
                GoRoute(
                  path: 'security',
                  builder: (context, state) =>
                      const SecurityPrivacyScreen(),
                ),
                GoRoute(
                  path: 'help',
                  builder: (context, state) => const HelpScreen(),
                ),
                GoRoute(
                  path: 'about',
                  builder: (context, state) => const AboutScreen(),
                ),
                GoRoute(
                  path: 'language',
                  builder: (context, state) =>
                      const LanguageSelectionScreen(),
                ),
                GoRoute(
                  path: 'timezone',
                  builder: (context, state) =>
                      const TimeZoneSelectionScreen(),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  ],

  // Redirect / → /splash
  redirect: (context, state) {
    if (state.matchedLocation == '/') return '/splash';
    return null;
  },

  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Text('Page not found: ${state.uri}'),
    ),
  ),
);
