import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:planpal/application/notifiers/task_notifier.dart';
import 'package:planpal/application/notifiers/user_notifier.dart';
import 'package:planpal/core/constants/app_colors.dart';
import 'package:planpal/core/constants/app_sizes.dart';
import 'package:planpal/core/constants/app_strings.dart';
import 'package:planpal/core/formatters/datetime_formatter.dart';
import 'package:planpal/domain/enums/filter_tab.dart';
import 'package:planpal/domain/enums/task_priority.dart';
import 'package:planpal/domain/models/task.dart';
import 'package:planpal/presentation/screens/tasks/modals/add_task_sheet.dart';
import 'package:planpal/presentation/widgets/app_snackbar.dart';
import 'package:planpal/presentation/widgets/avatar_widget.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);
    final todayTasks = ref.watch(todayTasksProvider);
    final metrics = ref.watch(performanceProvider);
    final allTasksAsync = ref.watch(tasksProvider);
    final now = DateTime.now();

    final user = userAsync.valueOrNull;
    final firstName = user?.firstName ?? 'there';
    final totalTodayCount =
        allTasksAsync.valueOrNull?.where((t) => t.isDueToday).length ?? 0;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FF),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ── Top bar ───────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(
                  children: [
                    // Logo pill
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'P',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'PlanPal',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                      ),
                    ),
                    const Spacer(),
                    // Bell icon
                    IconButton(
                      icon: const Icon(BootstrapIcons.bell),
                      onPressed: () {},
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 12),
                    // Avatar
                    AvatarWidget(
                      initials: user?.initials ?? 'U',
                      imagePath: user?.avatarPath,
                      diameter: 36,
                      semanticLabel: 'Go to Profile',
                      onTap: () => context.go('/profile'),
                    ),
                  ],
                ),
              ),
            ),

            // ── Greeting card ─────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              DateTimeFormatter.greetingLine(
                                  firstName, now),
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF1A1D2E),
                              ),
                            ),
                          ),
                          const Text('☀️', style: TextStyle(fontSize: 20)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Let's make today productive and focused.",
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ── Today's Tasks ─────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Your Tasks Today",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1A1D2E),
                          ),
                        ),
                        if (totalTodayCount > 5)
                          GestureDetector(
                            onTap: () => context.go('/tasks',
                                extra: {'filter': FilterTab.today}),
                            child: const Text(
                              'View All',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (todayTasks.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Text(
                          AppStrings.noTasksToday,
                          style: TextStyle(
                              color: Colors.grey.shade500, fontSize: 13),
                        ),
                      )
                    else
                      SizedBox(
                        height: 136,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: todayTasks.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: 12),
                          itemBuilder: (_, i) =>
                              _TodayTaskCard(task: todayTasks[i]),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // ── Quick Actions ─────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Quick Actions',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1D2E),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _QuickActionTile(
                            label: 'New Task',
                            icon: BootstrapIcons.plus_circle,
                            color: AppColors.primary,
                            onTap: () => showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(20)),
                              ),
                              builder: (_) => const AddTaskSheet(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _QuickActionTile(
                            label: 'Calendar',
                            icon: BootstrapIcons.calendar3,
                            color: const Color(0xFF22C55E),
                            onTap: () => AppSnackbar.show(
                                context, AppStrings.comingSoon),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _QuickActionTile(
                            label: 'Analytics',
                            icon: BootstrapIcons.bar_chart_line,
                            color: const Color(0xFFF59E0B),
                            onTap: () => AppSnackbar.show(
                                context, AppStrings.comingSoon),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _QuickActionTile(
                            label: 'Documents',
                            icon: BootstrapIcons.folder2,
                            color: const Color(0xFF8B5CF6),
                            onTap: () => AppSnackbar.show(
                                context, AppStrings.comingSoon),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // ── Performance Overview ──────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Performance Overview',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1D2E),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          _MetricBox(
                            value: '${metrics.completed}',
                            label: 'Completed',
                            color: const Color(0xFF4F6EF7),
                            onTap: () => context.go('/tasks',
                                extra: {'filter': FilterTab.completed}),
                          ),
                          _divider(),
                          _MetricBox(
                            value: '${metrics.inProgress}',
                            label: 'In Progress',
                            color: const Color(0xFF4F6EF7),
                            onTap: () => context.go('/tasks',
                                extra: {'filter': FilterTab.all}),
                          ),
                          _divider(),
                          _MetricBox(
                            value: '${metrics.overdue}',
                            label: 'Overdue',
                            color: const Color(0xFFEF4444),
                            onTap: () => context.go('/tasks'),
                          ),
                          _divider(),
                          _MetricBox(
                            value: '${metrics.productivity}%',
                            label: 'Productivity',
                            color: const Color(0xFF22C55E),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _divider() => Container(
        width: 1,
        height: 40,
        color: Colors.grey.shade200,
      );
}

// ── Today task horizontal card ────────────────────────────────────────────────

class _TodayTaskCard extends StatelessWidget {
  const _TodayTaskCard({required this.task});
  final Task task;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            task.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1D2E),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            DateTimeFormatter.formatDueDate(task.dueDate, task.dueTime),
            style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
          ),
          const Spacer(),
          _PriorityChip(priority: task.priority),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            height: 28,
            child: OutlinedButton(
              onPressed: () => context.go('/tasks'),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.zero,
                side: BorderSide(color: Colors.grey.shade300),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6)),
              ),
              child: Text(
                task.isCompleted ? 'Done' : 'Details',
                style: const TextStyle(fontSize: 11),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PriorityChip extends StatelessWidget {
  const _PriorityChip({required this.priority});
  final TaskPriority priority;

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (priority) {
      case TaskPriority.high:
        color = AppColors.priorityHigh;
      case TaskPriority.medium:
        color = AppColors.priorityMedium;
      case TaskPriority.low:
        color = AppColors.priorityLow;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 4),
          Text(
            '${priority.label} Priority',
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Quick action colored tile ─────────────────────────────────────────────────

class _QuickActionTile extends StatelessWidget {
  const _QuickActionTile({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      button: true,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 76,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 26),
              const SizedBox(height: 6),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Performance metric box ────────────────────────────────────────────────────

class _MetricBox extends StatelessWidget {
  const _MetricBox({
    required this.value,
    required this.label,
    required this.color,
    this.onTap,
  });
  final String value;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
            ),
          ],
        ),
      ),
    );
  }
}
