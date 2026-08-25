import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:planpal/application/notifiers/task_filter_notifier.dart';
import 'package:planpal/application/notifiers/task_notifier.dart';
import 'package:planpal/application/notifiers/user_notifier.dart';
import 'package:planpal/core/constants/app_colors.dart';
import 'package:planpal/core/constants/app_sizes.dart';
import 'package:planpal/core/constants/app_strings.dart';
import 'package:planpal/core/formatters/datetime_formatter.dart';
import 'package:planpal/domain/enums/filter_tab.dart';
import 'package:planpal/domain/enums/sort_option.dart';
import 'package:planpal/domain/enums/task_priority.dart';
import 'package:planpal/domain/models/task.dart';
import 'package:planpal/presentation/screens/tasks/modals/add_task_sheet.dart';
import 'package:planpal/presentation/screens/tasks/modals/edit_task_sheet.dart';
import 'package:planpal/presentation/screens/tasks/modals/task_detail_modal.dart';
import 'package:planpal/presentation/widgets/app_snackbar.dart';
import 'package:planpal/presentation/widgets/avatar_widget.dart';
import 'package:planpal/presentation/widgets/confirmation_dialog.dart';
import 'package:planpal/presentation/widgets/empty_state_widget.dart';

class TasksScreen extends ConsumerStatefulWidget {
  const TasksScreen({super.key, this.initialFilter});
  final FilterTab? initialFilter;

  @override
  ConsumerState<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends ConsumerState<TasksScreen> {
  @override
  void initState() {
    super.initState();
    if (widget.initialFilter != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref
            .read(taskFilterProvider.notifier)
            .setFilter(widget.initialFilter!);
      });
    }
  }

  void _showSortModal() {
    final current = ref.read(taskSortProvider);
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _SortModal(current: current),
    );
  }

  void _showAddSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const AddTaskSheet(),
    );
  }

  void _showDetail(Task task) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => TaskDetailModal(task: task),
    );
  }

  void _showContextMenu(Task task) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _TaskContextMenu(task: task),
    );
  }

  void _confirmDelete(Task task) {
    ConfirmationDialog.show(
      context: context,
      title: AppStrings.deleteTaskConfirm,
      body: 'This action cannot be undone.',
      confirmLabel: AppStrings.delete,
      isDestructive: true,
      onConfirm: () async {
        await ref.read(tasksProvider.notifier).deleteTask(task.id);
        if (mounted) AppSnackbar.show(context, AppStrings.taskDeleted);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeFilter = ref.watch(taskFilterProvider);
    final activeSort = ref.watch(taskSortProvider);
    final tasksAsync = ref.watch(tasksProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FF),
      body: SafeArea(
        child: Column(
          children: [
            // ── Top bar ──────────────────────────────────────────────────
            _TopBar(onSortTap: _showSortModal),
            const SizedBox(height: 16),

            // ── Filter tabs ───────────────────────────────────────────────
            _FilterTabBar(
              active: activeFilter,
              onSelected: (tab) =>
                  ref.read(taskFilterProvider.notifier).setFilter(tab),
            ),
            const SizedBox(height: 8),

            // ── Task list ─────────────────────────────────────────────────
            Expanded(
              child: tasksAsync.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (e, _) => EmptyStateWidget(
                  message: e.toString(),
                  icon: BootstrapIcons.exclamation_circle,
                ),
                data: (allTasks) {
                  final filtered = filterTasks(allTasks, activeFilter);
                  final sorted = sortTasks(filtered, activeSort);

                  if (sorted.isEmpty) {
                    return const EmptyStateWidget(
                      message: AppStrings.noTasksEmpty,
                      icon: BootstrapIcons.clipboard_check,
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
                    itemCount: sorted.length,
                    itemBuilder: (_, index) {
                      final task = sorted[index];
                      return Dismissible(
                        key: ValueKey(task.id),
                        direction: DismissDirection.endToStart,
                        confirmDismiss: (_) async {
                          _confirmDelete(task);
                          return false;
                        },
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          margin: const EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            color: Colors.red.shade400,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(BootstrapIcons.trash,
                              color: Colors.white),
                        ),
                        child: _TaskRow(
                          task: task,
                          onTap: () => _showDetail(task),
                          onLongPress: () => _showContextMenu(task),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddSheet,
        backgroundColor: AppColors.primary,
        icon: const Icon(BootstrapIcons.plus_lg, color: Colors.white),
        label: const Text(
          '+ Add Task',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

// ── Top bar ───────────────────────────────────────────────────────────────────

class _TopBar extends ConsumerWidget {
  const _TopBar({required this.onSortTap});
  final VoidCallback onSortTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider).valueOrNull;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text('P',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 16)),
          ),
          const SizedBox(width: 8),
          const Text('PlanPal',
              style:
                  TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
          const Spacer(),
          IconButton(
              icon: const Icon(BootstrapIcons.bell),
              onPressed: () {},
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints()),
          const SizedBox(width: 12),
          AvatarWidget(
            initials: user?.initials ?? 'U',
            imagePath: user?.avatarPath,
            diameter: 36,
          ),
        ],
      ),
    );
  }
}

// ── Task row ──────────────────────────────────────────────────────────────────

class _TaskRow extends ConsumerWidget {
  const _TaskRow({
    required this.task,
    required this.onTap,
    this.onLongPress,
  });
  final Task task;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assigneeAsync = task.assigneeId != null
        ? ref.watch(userByIdProvider(task.assigneeId!))
        : null;
    final assignee = assigneeAsync?.valueOrNull;

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Checkbox-style indicator
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: task.isCompleted
                      ? AppColors.success
                      : Colors.grey.shade300,
                  width: 2,
                ),
                color: task.isCompleted
                    ? AppColors.success
                    : Colors.transparent,
              ),
              child: task.isCompleted
                  ? const Icon(BootstrapIcons.check,
                      color: Colors.white, size: 14)
                  : null,
            ),
            const SizedBox(width: 12),

            // Task info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1A1D2E),
                      decoration: task.isCompleted
                          ? TextDecoration.lineThrough
                          : null,
                      decorationColor: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(BootstrapIcons.clock,
                          size: 11, color: Colors.grey.shade400),
                      const SizedBox(width: 3),
                      Text(
                        DateTimeFormatter.formatDueDate(
                            task.dueDate, task.dueTime),
                        style: TextStyle(
                          fontSize: 11,
                          color: task.isOverdue
                              ? AppColors.priorityHigh
                              : Colors.grey.shade500,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _InlinePriorityBadge(priority: task.priority),
                    ],
                  ),
                ],
              ),
            ),

            // Assignee avatar
            if (assignee != null) ...[
              const SizedBox(width: 8),
              AvatarWidget(
                initials: assignee.initials,
                imagePath: assignee.avatarPath,
                diameter: 28,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _InlinePriorityBadge extends StatelessWidget {
  const _InlinePriorityBadge({required this.priority});
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
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '${priority.label} Priority',
        style: TextStyle(
            fontSize: 10, color: color, fontWeight: FontWeight.w600),
      ),
    );
  }
}

// ── Filter tab bar ────────────────────────────────────────────────────────────

class _FilterTabBar extends StatelessWidget {
  const _FilterTabBar({required this.active, required this.onSelected});
  final FilterTab active;
  final ValueChanged<FilterTab> onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding:
          const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: FilterTab.values.map((tab) {
          final isActive = tab == active;
          return GestureDetector(
            onTap: () => onSelected(tab),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isActive ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(999),
                boxShadow: isActive
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        )
                      ]
                    : [],
              ),
              child: Text(
                tab.label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isActive ? Colors.white : Colors.grey.shade500,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ── Sort modal ────────────────────────────────────────────────────────────────

class _SortModal extends ConsumerWidget {
  const _SortModal({required this.current});
  final SortOption current;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(AppSizes.spaceM),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('Sort by',
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w700)),
              const Spacer(),
              IconButton(
                icon: const Icon(BootstrapIcons.x_lg),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          ...SortOption.values.map((opt) => ListTile(
                title: Text(opt.label,
                    style: const TextStyle(fontSize: 14)),
                leading: Radio<SortOption>(
                  value: opt,
                  groupValue: current,
                  activeColor: AppColors.primary,
                  onChanged: (v) {
                    if (v != null) {
                      ref.read(taskSortProvider.notifier).setSort(v);
                      Navigator.of(context).pop();
                    }
                  },
                ),
                onTap: () {
                  ref.read(taskSortProvider.notifier).setSort(opt);
                  Navigator.of(context).pop();
                },
                contentPadding: EdgeInsets.zero,
              )),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

// ── Context menu ──────────────────────────────────────────────────────────────

class _TaskContextMenu extends ConsumerWidget {
  const _TaskContextMenu({required this.task});
  final Task task;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(BootstrapIcons.pencil),
            title: const Text(AppStrings.edit),
            onTap: () {
              Navigator.of(context).pop();
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                shape: const RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(20)),
                ),
                builder: (_) => EditTaskSheet(task: task),
              );
            },
          ),
          ListTile(
            leading: Icon(task.isCompleted
                ? BootstrapIcons.arrow_counterclockwise
                : BootstrapIcons.check_circle),
            title: Text(task.isCompleted
                ? AppStrings.reopen
                : AppStrings.markComplete),
            onTap: () async {
              Navigator.of(context).pop();
              if (task.isCompleted) {
                await ref
                    .read(tasksProvider.notifier)
                    .reopenTask(task.id);
                if (context.mounted) {
                  AppSnackbar.show(context, AppStrings.taskReopened);
                }
              } else {
                await ref
                    .read(tasksProvider.notifier)
                    .markComplete(task.id);
                if (context.mounted) {
                  AppSnackbar.show(
                      context, AppStrings.taskMarkedComplete);
                }
              }
            },
          ),
          ListTile(
            leading:
                const Icon(BootstrapIcons.trash, color: Colors.red),
            title: const Text(AppStrings.delete,
                style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.of(context).pop();
              ConfirmationDialog.show(
                context: context,
                title: AppStrings.deleteTaskConfirm,
                body: 'This action cannot be undone.',
                confirmLabel: AppStrings.delete,
                isDestructive: true,
                onConfirm: () async {
                  await ref
                      .read(tasksProvider.notifier)
                      .deleteTask(task.id);
                  if (context.mounted) {
                    AppSnackbar.show(context, AppStrings.taskDeleted);
                  }
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
