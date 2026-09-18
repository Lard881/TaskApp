import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:planpal/application/notifiers/task_notifier.dart';
import 'package:planpal/application/notifiers/user_notifier.dart';
import 'package:planpal/application/notifiers/workspace_notifier.dart';
import 'package:planpal/core/constants/app_colors.dart';
import 'package:planpal/domain/enums/filter_tab.dart';
import 'package:planpal/domain/enums/task_priority.dart';
import 'package:planpal/domain/enums/task_status.dart';
import 'package:planpal/domain/models/workspace.dart';
import 'package:planpal/presentation/screens/home/widgets/analytics_dashboard_sheet.dart';
import 'package:planpal/presentation/screens/home/widgets/documents_notes_sheet.dart';
import 'package:planpal/presentation/screens/shell/app_shell.dart';
import 'package:planpal/presentation/screens/tasks/modals/add_task_sheet.dart';
import 'package:planpal/presentation/widgets/app_snackbar.dart';
import 'package:planpal/presentation/widgets/avatar_widget.dart';
import 'package:planpal/presentation/widgets/skeleton_loader.dart';

class WorkspaceHubScreen extends ConsumerWidget {
  const WorkspaceHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final activeWorkspace = ref.watch(activeWorkspaceProvider);
    final workspaces = ref.watch(workspacesProvider).valueOrNull ?? [];
    final membersAsync = ref.watch(activeMembersProvider);
    final tasksAsync = ref.watch(tasksProvider);
    final currentRole = ref.watch(currentMemberRoleProvider);
    final currentUser = ref.watch(currentUserProvider).valueOrNull;

    final ws = activeWorkspace ??
        (workspaces.isNotEmpty
            ? workspaces.first
            : Workspace(
                id: '',
                name: 'Workspace',
                type: 'personal',
                emoji: '🏠',
                createdBy: '',
                createdAt: DateTime(2026),
              ));

    final tasks = tasksAsync.valueOrNull ?? [];
    final totalTasks = tasks.length;
    final completedTasks =
        tasks.where((t) => t.status == TaskStatus.completed).length;
    final inProgressTasks =
        tasks.where((t) => t.status == TaskStatus.inProgress).length;
    final todoTasks = tasks.where((t) => t.status == TaskStatus.todo).length;
    final highPriorityTasks =
        tasks.where((t) => t.priority == TaskPriority.high).length;
    final mediumPriorityTasks =
        tasks.where((t) => t.priority == TaskPriority.medium).length;
    final lowPriorityTasks =
        tasks.where((t) => t.priority == TaskPriority.low).length;
    final completionRate =
        totalTasks > 0 ? (completedTasks / totalTasks * 100).round() : 0;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ── Top App Bar ──────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                child: Row(
                  children: [
                    // Workspace Switcher Pill Button
                    InkWell(
                      onTap: () => showWorkspaceSwitcherSheet(context, ref),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDark ? Colors.white12 : Colors.black12,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              ws.emoji,
                              style: const TextStyle(fontSize: 18),
                            ),
                            const SizedBox(width: 8),
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 160),
                              child: Text(
                                ws.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                  color: isDark ? AppColors.darkOnSurface : AppColors.lightOnSurface,
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              BootstrapIcons.chevron_down,
                              size: 13,
                              color: isDark ? AppColors.darkOnSurfaceMuted : Colors.grey.shade600,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Spacer(),
                    // Invite Button
                    if (ws.isTeam) ...[
                      FilledButton.icon(
                        onPressed: () => _showInviteDialog(context, ref, ws),
                        icon: const Icon(BootstrapIcons.person_plus, size: 15),
                        label: const Text('Invite', style: TextStyle(fontSize: 13)),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          visualDensity: VisualDensity.compact,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    // Settings / Edit Button
                    IconButton(
                      icon: const Icon(BootstrapIcons.gear, size: 20),
                      color: isDark ? AppColors.darkOnSurfaceMuted : Colors.grey.shade700,
                      onPressed: () => _showWorkspaceSettings(context, ref, ws),
                      tooltip: 'Workspace Settings',
                    ),
                  ],
                ),
              ),
            ),

            // ── Hero Banner ──────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isDark
                          ? [
                              AppColors.primary.withValues(alpha: 0.25),
                              AppColors.darkSurface,
                            ]
                          : [
                              AppColors.primary.withValues(alpha: 0.12),
                              AppColors.primaryMuted.withValues(alpha: 0.1),
                            ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: isDark ? 0.3 : 0.2),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: isDark ? Colors.white12 : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.08),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              ws.emoji,
                              style: const TextStyle(fontSize: 28),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  ws.name,
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                    color: isDark ? AppColors.darkOnSurface : AppColors.lightOnSurface,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: ws.isTeam
                                            ? AppColors.primary.withValues(alpha: 0.15)
                                            : Colors.grey.withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        ws.isTeam ? 'Team Workspace' : 'Personal Workspace',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: ws.isTeam ? AppColors.primary : Colors.grey.shade600,
                                        ),
                                      ),
                                    ),
                                    if (currentRole != null) ...[
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: currentRole == 'owner'
                                              ? Colors.amber.withValues(alpha: 0.2)
                                              : Colors.blue.withValues(alpha: 0.2),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          currentRole == 'owner' ? '👑 Owner' : '🛡️ $currentRole',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            color: currentRole == 'owner'
                                                ? Colors.amber.shade700
                                                : Colors.blue.shade600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Quick Action Buttons Row
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _QuickPillButton(
                            icon: BootstrapIcons.plus_circle_fill,
                            label: 'New Task',
                            isPrimary: true,
                            onTap: () {
                              showModalBottomSheet<void>(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                builder: (_) => const AddTaskSheet(),
                              );
                            },
                          ),
                          _QuickPillButton(
                            icon: BootstrapIcons.chat_dots_fill,
                            label: 'Workspace Chat',
                            onTap: () => context.go('/chat'),
                          ),
                          if (ws.isTeam)
                            _QuickPillButton(
                              icon: BootstrapIcons.share_fill,
                              label: 'Invite Link',
                              onTap: () => _showInviteDialog(context, ref, ws),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ── Key Metrics Bar ──────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: _MetricCard(
                        title: 'Total Tasks',
                        value: '$totalTasks',
                        icon: BootstrapIcons.check2_square,
                        color: AppColors.primary,
                        isDark: isDark,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _MetricCard(
                        title: 'Completed',
                        value: '$completedTasks',
                        icon: BootstrapIcons.check_circle_fill,
                        color: Colors.green,
                        isDark: isDark,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _MetricCard(
                        title: 'In Progress',
                        value: '$inProgressTasks',
                        icon: BootstrapIcons.arrow_repeat,
                        color: Colors.orange,
                        isDark: isDark,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _MetricCard(
                        title: 'Progress',
                        value: '$completionRate%',
                        icon: BootstrapIcons.bar_chart_line_fill,
                        color: Colors.purple,
                        isDark: isDark,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Collaboration Tools / Hub ────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                child: Text(
                  'COLLABORATION TOOLS',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.1,
                    color: isDark ? AppColors.darkOnSurfaceMuted : Colors.grey.shade600,
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _ToolTile(
                            title: 'Task Board',
                            subtitle: '$todoTasks to do • $inProgressTasks in progress',
                            icon: BootstrapIcons.kanban_fill,
                            iconColor: AppColors.primary,
                            isDark: isDark,
                            onTap: () => context.go('/tasks'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _ToolTile(
                            title: 'Team Chat',
                            subtitle: 'Discuss & share updates',
                            icon: BootstrapIcons.chat_fill,
                            iconColor: Colors.indigo,
                            isDark: isDark,
                            onTap: () => context.go('/chat'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _ToolTile(
                            title: 'Performance',
                            subtitle: 'Analytics & velocity',
                            icon: BootstrapIcons.speedometer2,
                            iconColor: Colors.teal,
                            isDark: isDark,
                            onTap: () => AnalyticsDashboardSheet.show(context),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _ToolTile(
                            title: 'Notes & Docs',
                            subtitle: 'Shared team docs',
                            icon: BootstrapIcons.journal_text,
                            iconColor: Colors.amber.shade800,
                            isDark: isDark,
                            onTap: () => DocumentsNotesSheet.show(context),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // ── Dynamic Real Streams Section (NO MOCK DATA) ──────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                child: Row(
                  children: [
                    Text(
                      'TASK STREAMS',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.1,
                        color: isDark ? AppColors.darkOnSurfaceMuted : Colors.grey.shade600,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '$totalTasks Total',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 145,
                child: totalTasks == 0
                    ? Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: InkWell(
                          onTap: () {
                            showModalBottomSheet<void>(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (_) => const AddTaskSheet(),
                            );
                          },
                          borderRadius: BorderRadius.circular(18),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.darkSurface : Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: isDark ? Colors.white12 : Colors.black12,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    BootstrapIcons.plus_circle_fill,
                                    color: AppColors.primary,
                                    size: 22,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'No Tasks in This Workspace',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: isDark ? AppColors.darkOnSurface : AppColors.lightOnSurface,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Tap here to create your first task.',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: isDark ? AppColors.darkOnSurfaceMuted : Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    : ListView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        children: [
                          _ProjectCard(
                            title: 'High Priority',
                            tag: 'Urgent',
                            emoji: '🔥',
                            taskCount: highPriorityTasks,
                            progress: totalTasks > 0 ? (highPriorityTasks / totalTasks) : 0,
                            color: Colors.redAccent,
                            isDark: isDark,
                            onTap: () => context.go('/tasks', extra: {'filter': FilterTab.today}),
                          ),
                          const SizedBox(width: 12),
                          _ProjectCard(
                            title: 'In Progress',
                            tag: 'Active',
                            emoji: '⚡',
                            taskCount: inProgressTasks,
                            progress: totalTasks > 0 ? (inProgressTasks / totalTasks) : 0,
                            color: Colors.orangeAccent,
                            isDark: isDark,
                            onTap: () => context.go('/tasks'),
                          ),
                          const SizedBox(width: 12),
                          _ProjectCard(
                            title: 'To Do',
                            tag: 'Backlog',
                            emoji: '📋',
                            taskCount: todoTasks,
                            progress: totalTasks > 0 ? (todoTasks / totalTasks) : 0,
                            color: AppColors.primary,
                            isDark: isDark,
                            onTap: () => context.go('/tasks'),
                          ),
                          const SizedBox(width: 12),
                          _ProjectCard(
                            title: 'Completed',
                            tag: 'Done',
                            emoji: '✅',
                            taskCount: completedTasks,
                            progress: totalTasks > 0 ? (completedTasks / totalTasks) : 0,
                            color: Colors.green,
                            isDark: isDark,
                            onTap: () => context.go('/tasks', extra: {'filter': FilterTab.completed}),
                          ),
                          if (mediumPriorityTasks > 0) ...[
                            const SizedBox(width: 12),
                            _ProjectCard(
                              title: 'Medium Priority',
                              tag: 'Standard',
                              emoji: '🎯',
                              taskCount: mediumPriorityTasks,
                              progress: totalTasks > 0 ? (mediumPriorityTasks / totalTasks) : 0,
                              color: Colors.blueAccent,
                              isDark: isDark,
                              onTap: () => context.go('/tasks'),
                            ),
                          ],
                          if (lowPriorityTasks > 0) ...[
                            const SizedBox(width: 12),
                            _ProjectCard(
                              title: 'Low Priority',
                              tag: 'Later',
                              emoji: '🌱',
                              taskCount: lowPriorityTasks,
                              progress: totalTasks > 0 ? (lowPriorityTasks / totalTasks) : 0,
                              color: Colors.teal,
                              isDark: isDark,
                              onTap: () => context.go('/tasks'),
                            ),
                          ],
                        ],
                      ),
              ),
            ),

            // ── Team Members Section ─────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                child: Row(
                  children: [
                    Text(
                      ws.isTeam ? 'TEAM MEMBERS' : 'WORKSPACE OWNER',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.1,
                        color: isDark ? AppColors.darkOnSurfaceMuted : Colors.grey.shade600,
                      ),
                    ),
                    const Spacer(),
                    if (ws.isTeam)
                      TextButton.icon(
                        onPressed: () => _showInviteDialog(context, ref, ws),
                        icon: const Icon(BootstrapIcons.plus, size: 16),
                        label: const Text('Add Member'),
                        style: TextButton.styleFrom(
                          visualDensity: VisualDensity.compact,
                          foregroundColor: AppColors.primary,
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Members List
            membersAsync.when(
              loading: () => const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: SkeletonMemberList(),
                ),
              ),
              error: (_, _) => SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Unable to load members list.',
                    style: TextStyle(
                      color: isDark ? AppColors.darkOnSurfaceMuted : Colors.grey.shade600,
                    ),
                  ),
                ),
              ),
              data: (members) {
                if (members.isEmpty) {
                  final me = currentUser;
                  return SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _MemberTile(
                        name: me?.fullName.isNotEmpty == true ? me!.fullName : 'You',
                        email: me?.email ?? '',
                        initials: me?.initials ?? 'U',
                        avatarUrl: me?.avatarPath,
                        role: 'Owner',
                        isCurrentUser: true,
                        isDark: isDark,
                      ),
                    ),
                  );
                }

                return SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final member = members[index];
                        final profile = member.profile;
                        final isMe = member.userId == currentUser?.id;
                        final name = profile?.fullName.isNotEmpty == true
                            ? profile!.fullName
                            : (isMe ? (currentUser?.fullName ?? 'You') : 'Teammate');
                        final email = profile?.email.isNotEmpty == true
                            ? profile!.email
                            : (isMe ? (currentUser?.email ?? '') : '');
                        final initials = profile?.initials ?? (isMe ? (currentUser?.initials ?? 'U') : 'T');

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: _MemberTile(
                            name: name,
                            email: email,
                            initials: initials,
                            avatarUrl: profile?.avatarUrl,
                            role: member.role == 'owner'
                                ? 'Owner'
                                : (member.role == 'admin' ? 'Admin' : 'Member'),
                            isCurrentUser: isMe,
                            isDark: isDark,
                            onRemove: (!isMe && (currentRole == 'owner' || currentRole == 'admin'))
                                ? () => _confirmRemoveMember(
                                      context,
                                      ref,
                                      ws.id,
                                      member.userId,
                                      name,
                                    )
                                : null,
                          ),
                        );
                      },
                      childCount: members.length,
                    ),
                  ),
                );
              },
            ),

            const SliverToBoxAdapter(
              child: SizedBox(height: 40),
            ),
          ],
        ),
      ),
    );
  }

  // ── Invite Dialog ────────────────────────────────────────────────────────
  void _showInviteDialog(BuildContext context, WidgetRef ref, Workspace ws) {
    showDialog<void>(
      context: context,
      builder: (context) => _WorkspaceInviteDialog(workspace: ws),
    );
  }

  // ── Workspace Settings Dialog ─────────────────────────────────────────────
  void _showWorkspaceSettings(
      BuildContext context, WidgetRef ref, Workspace ws) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _WorkspaceSettingsSheet(workspace: ws),
    );
  }

  // ── Remove Member Confirm ────────────────────────────────────────────────
  void _confirmRemoveMember(
    BuildContext context,
    WidgetRef ref,
    String workspaceId,
    String userId,
    String memberName,
  ) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove Teammate?'),
        content: Text(
          'Are you sure you want to remove $memberName from this workspace? They will lose access to all tasks and shared conversations.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.of(ctx).pop();
              try {
                await ref
                    .read(workspacesProvider.notifier)
                    .removeMember(workspaceId: workspaceId, userId: userId);
                if (context.mounted) {
                  AppSnackbar.show(context, 'Member removed.');
                }
              } catch (e) {
                if (context.mounted) {
                  AppSnackbar.show(
                    context,
                    'Unable to remove member.',
                    isError: true,
                  );
                }
              }
            },
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }
}

// ── Quick Pill Button ────────────────────────────────────────────────────────

class _QuickPillButton extends StatelessWidget {
  const _QuickPillButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isPrimary = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: isPrimary
                ? AppColors.primary
                : (isDark ? Colors.white10 : Colors.white),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isPrimary
                  ? AppColors.primary
                  : (isDark ? Colors.white12 : Colors.black12),
            ),
            boxShadow: isPrimary
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 15,
                color: isPrimary
                    ? Colors.white
                    : (isDark ? AppColors.darkOnSurface : AppColors.lightOnSurface),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isPrimary
                      ? Colors.white
                      : (isDark ? AppColors.darkOnSurface : AppColors.lightOnSurface),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Metric Card ──────────────────────────────────────────────────────────────

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.isDark,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white12 : Colors.black.withValues(alpha: 0.05),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 14, color: color),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: isDark ? AppColors.darkOnSurface : AppColors.lightOnSurface,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: isDark ? AppColors.darkOnSurfaceMuted : Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Tool Tile ────────────────────────────────────────────────────────────────

class _ToolTile extends StatelessWidget {
  const _ToolTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.isDark,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? Colors.white12 : Colors.black.withValues(alpha: 0.05),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppColors.darkOnSurface : AppColors.lightOnSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? AppColors.darkOnSurfaceMuted : Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                BootstrapIcons.arrow_up_right,
                size: 12,
                color: isDark ? AppColors.darkOnSurfaceMuted : Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Dynamic Stream Card ──────────────────────────────────────────────────────

class _ProjectCard extends StatelessWidget {
  const _ProjectCard({
    required this.title,
    required this.tag,
    required this.emoji,
    required this.taskCount,
    required this.progress,
    required this.color,
    required this.isDark,
    required this.onTap,
  });

  final String title;
  final String tag;
  final String emoji;
  final int taskCount;
  final double progress;
  final Color color;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          width: 165,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isDark ? Colors.white12 : Colors.black.withValues(alpha: 0.05),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(emoji, style: const TextStyle(fontSize: 22)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      tag,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: color,
                      ),
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.darkOnSurface : AppColors.lightOnSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$taskCount tasks',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? AppColors.darkOnSurfaceMuted : Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress.clamp(0.0, 1.0),
                  backgroundColor: isDark ? Colors.white10 : Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                  minHeight: 5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Member Tile ──────────────────────────────────────────────────────────────

class _MemberTile extends StatelessWidget {
  const _MemberTile({
    required this.name,
    required this.email,
    required this.initials,
    this.avatarUrl,
    required this.role,
    required this.isCurrentUser,
    required this.isDark,
    this.onRemove,
  });

  final String name;
  final String email;
  final String initials;
  final String? avatarUrl;
  final String role;
  final bool isCurrentUser;
  final bool isDark;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    Color roleColor = Colors.grey.shade600;
    Color roleBg = Colors.grey.withValues(alpha: 0.12);

    if (role.toLowerCase() == 'owner') {
      roleColor = Colors.amber.shade700;
      roleBg = Colors.amber.withValues(alpha: 0.15);
    } else if (role.toLowerCase() == 'admin') {
      roleColor = AppColors.primary;
      roleBg = AppColors.primary.withValues(alpha: 0.15);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white12 : Colors.black.withValues(alpha: 0.05),
        ),
      ),
      child: Row(
        children: [
          AvatarWidget(
            initials: initials,
            imagePath: avatarUrl,
            diameter: 38,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: isDark ? AppColors.darkOnSurface : AppColors.lightOnSurface,
                        ),
                      ),
                    ),
                    if (isCurrentUser) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'You',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                if (email.isNotEmpty)
                  Text(
                    email,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? AppColors.darkOnSurfaceMuted : Colors.grey.shade500,
                    ),
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: roleBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              role,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: roleColor,
              ),
            ),
          ),
          if (onRemove != null) ...[
            const SizedBox(width: 4),
            IconButton(
              icon: const Icon(BootstrapIcons.trash, size: 16, color: Colors.redAccent),
              onPressed: onRemove,
              tooltip: 'Remove member',
            ),
          ],
        ],
      ),
    );
  }
}

// ── Workspace Invite Dialog ──────────────────────────────────────────────────

class _WorkspaceInviteDialog extends ConsumerStatefulWidget {
  const _WorkspaceInviteDialog({required this.workspace});
  final Workspace workspace;

  @override
  ConsumerState<_WorkspaceInviteDialog> createState() =>
      _WorkspaceInviteDialogState();
}

class _WorkspaceInviteDialogState
    extends ConsumerState<_WorkspaceInviteDialog> {
  String? _inviteCode;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchInvite();
  }

  Future<void> _fetchInvite() async {
    try {
      final repo = ref.read(workspaceRepositoryProvider);
      final code =
          await repo.createInvite(workspaceId: widget.workspace.id);
      if (mounted) {
        setState(() {
          _inviteCode = code;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final inviteLink =
        _inviteCode != null ? 'https://planpal.app/join/$_inviteCode' : '';

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                BootstrapIcons.person_plus_fill,
                color: AppColors.primary,
                size: 26,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Invite to ${widget.workspace.name}',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: isDark ? AppColors.darkOnSurface : AppColors.lightOnSurface,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Share this link or code with your team to invite them into this workspace.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? AppColors.darkOnSurfaceMuted : Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 20),
            if (_loading)
              const Shimmer(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Column(
                    children: [
                      SkeletonBox(height: 56, borderRadius: 12),
                      SizedBox(height: 12),
                      SkeletonBox(height: 44, borderRadius: 12),
                    ],
                  ),
                ),
              )
            else if (_inviteCode != null) ...[
              // Invite Code Box
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white10 : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? Colors.white12 : Colors.grey.shade300,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'INVITE CODE',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: isDark ? AppColors.darkOnSurfaceMuted : Colors.grey.shade500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _inviteCode!,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 2,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(BootstrapIcons.copy, size: 18),
                      tooltip: 'Copy Code',
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: _inviteCode!));
                        AppSnackbar.show(context, 'Invite code copied!');
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // Full Link Box
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white10 : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(BootstrapIcons.link_45deg, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        inviteLink,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? AppColors.darkOnSurface : AppColors.lightOnSurface,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(BootstrapIcons.copy, size: 16),
                      tooltip: 'Copy Link',
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: inviteLink));
                        AppSnackbar.show(context, 'Invite link copied!');
                      },
                    ),
                  ],
                ),
              ),
            ] else
              Text(
                'Could not generate invite code.',
                style: TextStyle(color: Colors.red.shade400),
              ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Done'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Workspace Settings Sheet (Edit & Delete) ─────────────────────────────────

class _WorkspaceSettingsSheet extends ConsumerStatefulWidget {
  const _WorkspaceSettingsSheet({required this.workspace});
  final Workspace workspace;

  @override
  ConsumerState<_WorkspaceSettingsSheet> createState() =>
      _WorkspaceSettingsSheetState();
}

class _WorkspaceSettingsSheetState
    extends ConsumerState<_WorkspaceSettingsSheet> {
  late final TextEditingController _nameController;
  late String _selectedEmoji;
  bool _saving = false;
  bool _deleting = false;

  final _emojis = const ['🗂️', '🚀', '💼', '💻', '🎯', '🏢', '⚡', '🎨', '📊', '🔥', '🌟', '🛠️'];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.workspace.name);
    _selectedEmoji = widget.workspace.emoji;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final newName = _nameController.text.trim();
    if (newName.isEmpty) return;

    setState(() => _saving = true);
    try {
      await ref.read(workspacesProvider.notifier).updateWorkspace(
            id: widget.workspace.id,
            name: newName,
            emoji: _selectedEmoji,
          );
      if (mounted) {
        Navigator.of(context).pop();
        AppSnackbar.show(context, 'Workspace updated successfully!');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        AppSnackbar.show(context, 'Error updating workspace: $e', isError: true);
      }
    }
  }

  Future<void> _confirmDelete() async {
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(BootstrapIcons.exclamation_triangle_fill, color: Colors.red, size: 22),
            SizedBox(width: 10),
            Text('Delete Workspace?'),
          ],
        ),
        content: Text(
          'Are you sure you want to permanently delete "${widget.workspace.name}"?\n\n'
          'All tasks, comments, and member access in this workspace will be deleted immediately. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.of(ctx).pop();
              setState(() => _deleting = true);
              try {
                await ref
                    .read(workspacesProvider.notifier)
                    .deleteWorkspace(widget.workspace.id);
                if (mounted) {
                  Navigator.of(context).pop();
                  AppSnackbar.show(
                    context,
                    'Workspace "${widget.workspace.name}" deleted.',
                  );
                }
              } catch (e) {
                if (mounted) {
                  setState(() => _deleting = false);
                  AppSnackbar.show(
                    context,
                    'Error deleting workspace: $e',
                    isError: true,
                  );
                }
              }
            },
            child: const Text('Delete Permanently'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
        24,
        16,
        24,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Text(
            'Workspace Settings',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: isDark ? AppColors.darkOnSurface : AppColors.lightOnSurface,
            ),
          ),
          const SizedBox(height: 16),
          // Emoji selection
          Text(
            'Icon Emoji',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.darkOnSurfaceMuted : Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _emojis.map((em) {
                final isSelected = em == _selectedEmoji;
                return GestureDetector(
                  onTap: () => setState(() => _selectedEmoji = em),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary.withValues(alpha: 0.15)
                          : (isDark ? Colors.white10 : Colors.grey.shade100),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected ? AppColors.primary : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Text(em, style: const TextStyle(fontSize: 22)),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
          // Name field
          Text(
            'Workspace Name',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.darkOnSurfaceMuted : Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              filled: true,
              fillColor: isDark ? Colors.white10 : Colors.grey.shade100,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            style: TextStyle(
              color: isDark ? AppColors.darkOnSurface : AppColors.lightOnSurface,
            ),
          ),
          const SizedBox(height: 20),
          // Save Button
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: (_saving || _deleting) ? null : _save,
              child: _saving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text('Save Changes', style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ),
          // Danger Zone (Only for team workspaces)
          if (!widget.workspace.isPersonal) ...[
            const SizedBox(height: 20),
            Divider(color: isDark ? Colors.white12 : Colors.grey.shade200),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: isDark ? 0.12 : 0.06),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: Colors.red.withValues(alpha: 0.25),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Danger Zone',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Permanently delete this workspace, including all tasks, chats, and members.',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? AppColors.darkOnSurfaceMuted : Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: (_saving || _deleting) ? null : _confirmDelete,
                      icon: _deleting
                          ? const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                              ),
                            )
                          : const Icon(BootstrapIcons.trash, size: 14),
                      label: const Text(
                        'Delete Workspace',
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
