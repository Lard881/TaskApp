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

/// Persistent shell with bottom navigation + workspace switcher banner.
class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.navigationShell});
  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Workspace switcher banner ──────────────────────────────────
          _WorkspaceBanner(navigationShell: navigationShell),
          // ── Bottom nav ────────────────────────────────────────────────
          _BottomNav(navigationShell: navigationShell),
        ],
      ),
    );
  }
}

// ── Workspace banner ──────────────────────────────────────────────────────────

class _WorkspaceBanner extends ConsumerWidget {
  const _WorkspaceBanner({required this.navigationShell});
  final StatefulNavigationShell navigationShell;

  void _showSwitcher(BuildContext context, WidgetRef ref) {
    final workspaces = ref.read(workspacesProvider).valueOrNull ?? [];
    final activeId = ref.read(activeWorkspaceIdProvider);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _WorkspaceSwitcherSheet(
        workspaces: workspaces,
        activeId: activeId,
        onSelect: (id) {
          ref.read(workspacesProvider.notifier).switchWorkspace(id);
          Navigator.of(context).pop();
          AppSnackbar.show(
            context,
            'Switched workspace',
          );
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
    showDialog(
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeWorkspace = ref.watch(activeWorkspaceProvider);

    // Only show the banner when a workspace is loaded
    if (activeWorkspace == null) return const SizedBox.shrink();

    return GestureDetector(
      onTap: () => _showSwitcher(context, ref),
      child: Container(
        height: 32,
        decoration: BoxDecoration(
          color: activeWorkspace.isTeam
              ? AppColors.primary.withOpacity(0.08)
              : Colors.grey.shade50,
          border: Border(
            bottom: BorderSide(color: Colors.grey.shade200),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              activeWorkspace.emoji,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(width: 6),
            Text(
              activeWorkspace.name,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: activeWorkspace.isTeam
                    ? AppColors.primary
                    : Colors.grey.shade600,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              BootstrapIcons.chevron_down,
              size: 11,
              color: activeWorkspace.isTeam
                  ? AppColors.primary
                  : Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }
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
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: Row(
              children: [
                Text(
                  'Your Workspaces',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),

          // Workspace list
          ...workspaces.map((ws) {
            final isActive = ws.id == activeId;
            return ListTile(
              leading: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: ws.isTeam
                      ? AppColors.primary.withOpacity(0.1)
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: isActive
                      ? Border.all(color: AppColors.primary, width: 2)
                      : null,
                ),
                child: Center(
                  child: Text(ws.emoji,
                      style: const TextStyle(fontSize: 18)),
                ),
              ),
              title: Text(
                ws.name,
                style: TextStyle(
                  fontWeight:
                      isActive ? FontWeight.w700 : FontWeight.w500,
                  color: isActive ? AppColors.primary : null,
                ),
              ),
              subtitle: Text(
                ws.isPersonal ? 'Personal' : 'Team',
                style: TextStyle(
                    fontSize: AppSizes.fontSmall,
                    color: Colors.grey.shade500),
              ),
              trailing: isActive
                  ? const Icon(BootstrapIcons.check2_circle,
                      color: AppColors.primary)
                  : null,
              onTap: () => onSelect(ws.id),
            );
          }),

          const Divider(height: 8),

          // Actions
          ListTile(
            leading: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(BootstrapIcons.plus,
                  size: 18, color: AppColors.primary),
            ),
            title: const Text('Create new workspace'),
            onTap: onCreateNew,
          ),
          ListTile(
            leading: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(BootstrapIcons.box_arrow_in_right,
                  size: 18, color: AppColors.primary),
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

class _BottomNav extends StatelessWidget {
  const _BottomNav({required this.navigationShell});
  final StatefulNavigationShell navigationShell;

  void _onTap(BuildContext context, int index) {
    if (index == navigationShell.currentIndex) {
      final sc = PrimaryScrollController.maybeOf(context);
      if (sc != null && sc.hasClients) {
        sc.animateTo(0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut);
        return;
      }
    }
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
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
                icon: BootstrapIcons.chat,
                activeIcon: BootstrapIcons.chat_fill,
                label: AppStrings.navChat,
                isActive: navigationShell.currentIndex == 2,
                onTap: () => _onTap(context, 2),
              ),
              _NavItem(
                icon: BootstrapIcons.person,
                activeIcon: BootstrapIcons.person_fill,
                label: AppStrings.navProfile,
                isActive: navigationShell.currentIndex == 3,
                onTap: () => _onTap(context, 3),
              ),
              _NavItem(
                icon: BootstrapIcons.gear,
                activeIcon: BootstrapIcons.gear_fill,
                label: AppStrings.navSettings,
                isActive: navigationShell.currentIndex == 4,
                onTap: () => _onTap(context, 4),
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
                color: isActive ? AppColors.primary : Colors.grey.shade400,
                size: 22,
              ),
              const SizedBox(height: 3),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight:
                      isActive ? FontWeight.w700 : FontWeight.w400,
                  color: isActive
                      ? AppColors.primary
                      : Colors.grey.shade400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
