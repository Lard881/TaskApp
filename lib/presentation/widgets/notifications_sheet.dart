import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:planpal/application/notifiers/task_notifier.dart';
import 'package:planpal/core/constants/app_colors.dart';
import 'package:planpal/core/constants/app_sizes.dart';
import 'package:planpal/domain/models/task.dart';

class NotificationsSheet extends ConsumerStatefulWidget {
  const NotificationsSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const NotificationsSheet(),
    );
  }

  @override
  ConsumerState<NotificationsSheet> createState() => _NotificationsSheetState();
}

class _NotificationsSheetState extends ConsumerState<NotificationsSheet> {
  final Set<String> _readIds = {};

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final taskState = ref.watch(tasksProvider);
    final List<Task> tasks = taskState.valueOrNull ?? <Task>[];

    // Derive notifications from tasks (due soon, overdue, or recently active)
    final now = DateTime.now();
    final items = <_NotificationItem>[];

    for (final task in tasks) {
      if (task.dueDate != null) {
        final diff = task.dueDate!.difference(now).inDays;
        if (diff < 0 && !task.isCompleted) {
          items.add(
            _NotificationItem(
              id: 'overdue_${task.id}',
              title: 'Task Overdue',
              description: '"${task.name}" was due on ${task.dueDate!.month}/${task.dueDate!.day}',
              icon: BootstrapIcons.exclamation_triangle_fill,
              color: AppColors.error,
              time: 'Overdue',
            ),
          );
        } else if (diff >= 0 && diff <= 2 && !task.isCompleted) {
          items.add(
            _NotificationItem(
              id: 'due_${task.id}',
              title: 'Upcoming Deadline',
              description: '"${task.name}" is due in ${diff == 0 ? "Today" : "$diff day(s)"}',
              icon: BootstrapIcons.clock_fill,
              color: AppColors.priorityMedium,
              time: diff == 0 ? 'Today' : 'In $diff days',
            ),
          );
        }
      }
    }


    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppSizes.radiusL),
        ),
      ),
      child: Column(
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      BootstrapIcons.bell_fill,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Notifications',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: AppSizes.fontHeading,
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      for (final item in items) {
                        _readIds.add(item.id);
                      }
                    });
                  },
                  child: const Text(
                    'Mark all as read',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Notification List
          Expanded(
            child: items.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          BootstrapIcons.bell_slash,
                          size: 48,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No new notifications',
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: AppSizes.fontBody,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: items.length,
                    separatorBuilder: (_, _) => const Divider(height: 1, indent: 68),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final isRead = _readIds.contains(item.id);

                      return InkWell(
                        onTap: () {
                          setState(() => _readIds.add(item.id));
                        },
                        child: Container(
                          color: isRead
                              ? Colors.transparent
                              : AppColors.primary.withValues(alpha: 0.04),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 14,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  color: item.color.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(AppSizes.radiusM),
                                ),
                                child: Icon(
                                  item.icon,
                                  color: item.color,
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          item.title,
                                          style: TextStyle(
                                            fontWeight: isRead
                                                ? FontWeight.w500
                                                : FontWeight.w700,
                                            fontSize: 14,
                                          ),
                                        ),
                                        Text(
                                          item.time,
                                          style: TextStyle(
                                            color: Colors.grey.shade400,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      item.description,
                                      style: TextStyle(
                                        color: isDark
                                            ? AppColors.darkOnSurfaceMuted
                                            : AppColors.lightOnSurfaceMuted,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (!isRead) ...[
                                const SizedBox(width: 8),
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: AppColors.primary,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _NotificationItem {
  const _NotificationItem({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.time,
  });

  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final String time;
}
