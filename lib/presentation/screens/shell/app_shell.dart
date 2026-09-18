import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:planpal/application/notifiers/workspace_notifier.dart';
import 'package:planpal/core/constants/app_colors.dart';
import 'package:planpal/core/constants/app_sizes.dart';
import 'package:planpal/core/constants/app_strings.dart';
import 'package:planpal/domain/models/workspace.dart';
import 'package:planpal/presentation/widgets/app_snackbar.dart';

/// Persistent shell with bottom navigation containing Workspace switcher.
class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.navigationShell});
  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: _BottomNav(navigationShell: navigationShell),
    );
  }
}

// ── Workspace Switcher Sheet & Dialog Helpers ─────────────────────────────────

void showWorkspaceSwitcherSheet(BuildContext context, WidgetRef ref) {
  final workspaces = ref.read(workspacesProvider).valueOrNull ?? [];
  final activeId = ref.read(activeWorkspaceIdProvider);

  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => _WorkspaceSwitcherSheet(
      workspaces: workspaces,
      activeId: activeId,
      onSelect: (id) {
        ref.read(workspacesProvider.notifier).switchWorkspace(id);
        Navigator.of(context).pop();
        AppSnackbar.show(context, 'Switched workspace');
      },
      onCreateNew: () {
        Navigator.of(context).pop();
        context.go('/onboarding/create-workspace');
      },
      onJoin: () {
        Navigator.of(context).pop();
        _showJoinDialog(context, ref);
      },
    ),
  );
}

void _showJoinDialog(BuildContext context, WidgetRef ref) {
  final ctrl = TextEditingController();
  showDialog<void>(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Join a Workspace'),
      content: TextField(
        controller: ctrl,
        decoration: const InputDecoration(
          hintText: 'Enter invite code (8 characters)',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            Navigator.of(context).pop();
            try {
              await ref
                  .read(workspacesProvider.notifier)
                  .acceptInvite(ctrl.text.trim());
              if (context.mounted) {
                AppSnackbar.show(context, 'Joined workspace!');
              }
            } catch (e) {
              if (context.mounted) {
                AppSnackbar.show(
                  context,
                  'Invalid or expired invite code.',
                  isError: true,
                );
              }
            }
          },
          child: const Text('Join'),
        ),
      ],
    ),
  );
}

// ── Workspace switcher sheet ──────────────────────────────────────────────────

class _WorkspaceSwitcherSheet extends StatelessWidget {
  const _WorkspaceSwitcherSheet({
    required this.workspaces,
    required this.activeId,
    required this.onSelect,
    required this.onCreateNew,
    required this.onJoin,
  });

  final List<Workspace> workspaces;
  final String? activeId;
  final ValueChanged<String> onSelect;
  final VoidCallback onCreateNew;
  final VoidCallback onJoin;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: isDark ? Colors.white24 : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: Row(
              children: [
                Text(
                  'Your Workspaces',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),

          // Workspace list
          if (workspaces.isEmpty)
            ListTile(
              leading: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white12 : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: const Text('🏠', style: TextStyle(fontSize: 18)),
              ),
              title: Text(
                'Personal Workspace',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.darkOnSurface : AppColors.lightOnSurface,
                ),
              ),
              subtitle: Text(
                'Personal',
                style: TextStyle(
                  fontSize: AppSizes.fontSmall,
                  color: isDark ? AppColors.darkOnSurfaceMuted : Colors.grey.shade500,
                ),
              ),
              trailing: const Icon(
                BootstrapIcons.check2_circle,
                color: AppColors.primary,
              ),
            ),
          ...workspaces.map((ws) {
            final isActive = ws.id == activeId;
            return ListTile(
              leading: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: ws.isTeam
                      ? AppColors.primary.withValues(alpha: 0.1)
                      : (isDark ? Colors.white12 : Colors.grey.shade100),
                  borderRadius: BorderRadius.circular(8),
                  border: isActive
                      ? Border.all(color: AppColors.primary, width: 2)
                      : null,
                ),
                child: Center(
                  child: Text(ws.emoji, style: const TextStyle(fontSize: 18)),
                ),
              ),
              title: Text(
                ws.name,
                style: TextStyle(
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                  color: isActive ? AppColors.primary : null,
                ),
              ),
              subtitle: Text(
                ws.isPersonal ? 'Personal' : 'Team',
                style: TextStyle(
                  fontSize: AppSizes.fontSmall,
                  color: isDark ? AppColors.darkOnSurfaceMuted : Colors.grey.shade500,
                ),
              ),
              trailing: isActive
                  ? const Icon(
                      BootstrapIcons.check2_circle,
                      color: AppColors.primary,
                    )
                  : null,
              onTap: () => onSelect(ws.id),
            );
          }),

          Divider(height: 8, color: isDark ? Colors.white12 : null),

          // Actions
          ListTile(
            leading: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isDark ? Colors.white12 : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                BootstrapIcons.plus,
                size: 18,
                color: AppColors.primary,
              ),
            ),
            title: const Text('Create new workspace'),
            onTap: onCreateNew,
          ),
          ListTile(
            leading: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isDark ? Colors.white12 : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                BootstrapIcons.box_arrow_in_right,
                size: 18,
                color: AppColors.primary,
              ),
            ),
            title: const Text('Join with invite code'),
            onTap: onJoin,
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

// ── Bottom nav ────────────────────────────────────────────────────────────────

class _BottomNav extends ConsumerWidget {
  const _BottomNav({required this.navigationShell});
  final StatefulNavigationShell navigationShell;

  void _onTap(BuildContext context, int index) {
    if (index == navigationShell.currentIndex) {
      final sc = PrimaryScrollController.maybeOf(context);
      if (sc != null && sc.hasClients) {
        sc.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
        return;
      }
    }
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        border: isDark
            ? Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.08)))
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          height: 60,
          child: Row(
            children: [
              _NavItem(
                icon: BootstrapIcons.house,
                activeIcon: BootstrapIcons.house_fill,
                label: AppStrings.navHome,
                isActive: navigationShell.currentIndex == 0,
                onTap: () => _onTap(context, 0),
              ),
              _NavItem(
                icon: BootstrapIcons.check2_square,
                activeIcon: BootstrapIcons.check2_square,
                label: AppStrings.navTasks,
                isActive: navigationShell.currentIndex == 1,
                onTap: () => _onTap(context, 1),
              ),
              _NavItem(
                icon: BootstrapIcons.building,
                activeIcon: BootstrapIcons.building_fill,
                label: 'Workspace',
                isActive: navigationShell.currentIndex == 2,
                onTap: () => _onTap(context, 2),
              ),
              _NavItem(
                icon: BootstrapIcons.chat,
                activeIcon: BootstrapIcons.chat_fill,
                label: AppStrings.navChat,
                isActive: navigationShell.currentIndex == 3,
                onTap: () => _onTap(context, 3),
              ),
              _NavItem(
                icon: BootstrapIcons.person,
                activeIcon: BootstrapIcons.person_fill,
                label: AppStrings.navProfile,
                isActive: navigationShell.currentIndex == 4,
                onTap: () => _onTap(context, 4),
              ),
              _NavItem(
                icon: BootstrapIcons.gear,
                activeIcon: BootstrapIcons.gear_fill,
                label: AppStrings.navSettings,
                isActive: navigationShell.currentIndex == 5,
                onTap: () => _onTap(context, 5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final unselectedColor =
        isDark ? AppColors.darkOnSurfaceMuted : Colors.grey.shade400;

    return Expanded(
      child: Semantics(
        label: label,
        button: true,
        selected: isActive,
        child: GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isActive ? activeIcon : icon,
                color: isActive ? AppColors.primary : unselectedColor,
                size: 22,
              ),
              const SizedBox(height: 3),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                  color: isActive ? AppColors.primary : unselectedColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
