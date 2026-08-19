import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:planpal/core/constants/app_colors.dart';
import 'package:planpal/core/constants/app_strings.dart';

/// The persistent shell wrapping all five primary screens.
///
/// Renders the [BottomNavigationBar] once and never rebuilds it on tab switch.
/// Each branch maintains its own Navigator stack (StatefulShellRoute).
class AppShell extends StatelessWidget {
  const AppShell({
    super.key,
    required this.navigationShell,
  });

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // The body is the currently active branch's Navigator
      body: navigationShell,

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: navigationShell.currentIndex,
        onTap: _onTap,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home_rounded),
            label: AppStrings.navHome,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.checklist_outlined),
            activeIcon: Icon(Icons.checklist_rounded),
            label: AppStrings.navTasks,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline_rounded),
            activeIcon: Icon(Icons.chat_bubble_rounded),
            label: AppStrings.navChat,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline_rounded),
            activeIcon: Icon(Icons.person_rounded),
            label: AppStrings.navProfile,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings_rounded),
            label: AppStrings.navSettings,
          ),
        ],
      ),
    );
  }

  void _onTap(int index) {
    if (index == navigationShell.currentIndex) {
      // Tapping the active tab scrolls its primary scroll view to top (Req 1.6)
      final scrollController = PrimaryScrollController.maybeOf(
        navigationShell.shellRouteContext,
      );
      if (scrollController != null && scrollController.hasClients) {
        scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
        return;
      }
    }
    // Navigate to the tapped branch
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }
}
