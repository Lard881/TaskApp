import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:planpal/application/notifiers/task_notifier.dart';
import 'package:planpal/application/notifiers/user_notifier.dart';
import 'package:planpal/core/constants/app_sizes.dart';
import 'package:planpal/core/constants/app_strings.dart';
import 'package:planpal/core/formatters/datetime_formatter.dart';
import 'package:planpal/domain/models/task.dart';
import 'package:planpal/presentation/screens/tasks/modals/edit_task_sheet.dart';
import 'package:planpal/presentation/widgets/app_snackbar.dart';
import 'package:planpal/presentation/widgets/avatar_widget.dart';
import 'package:planpal/presentation/widgets/priority_badge.dart';

class TaskDetailModal extends ConsumerWidget {
  const TaskDetailModal({super.key, required this.task});
  final Task task;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assigneeAsync = task.assigneeId != null
        ? ref.watch(userByIdProvider(task.assigneeId!))
        : null;
    final assignee = assigneeAsync?.valueOrNull;

    return Padding(
      padding: const EdgeInsets.all(AppSizes.spaceM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle + close
          Row(
            children: [
              const Spacer(),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(BootstrapIcons.x_lg),
                onPressed: () => Navigator.of(context).pop(),
                tooltip: 'Close',
              ),
            ],
          ),
          const SizedBox(height: AppSizes.spaceS),

          // Task name — font at least body+4dp (Req 11.1)
          Text(
            task.name,
            style: const TextStyle(
              fontSize: AppSizes.fontHeading,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSizes.spaceM),

          // Due date/time + priority row
          Row(
            children: [
              const Icon(BootstrapIcons.calendar3, size: 16),
              const SizedBox(width: AppSizes.spaceXS),
              Text(
                DateTimeFormatter.formatDueDate(
                    task.dueDate, task.dueTime),
                style: const TextStyle(fontSize: AppSizes.fontBody),
              ),
              const Spacer(),
              PriorityBadge(
                priority: task.priority,
                isCompleted: task.isCompleted,
              ),
            ],
          ),

          // Assignee
          if (assignee != null) ...[
            const SizedBox(height: AppSizes.spaceS),
            Row(
              children: [
                AvatarWidget(
                  initials: assignee.initials,
                  imagePath: assignee.avatarPath,
                  diameter: 24,
                ),
                const SizedBox(width: AppSizes.spaceS),
                Text(assignee.fullName,
                    style: const TextStyle(
                        fontSize: AppSizes.fontBody)),
              ],
            ),
          ],

          // Description — hidden if empty (Req 11.2)
          if (task.description != null &&
              task.description!.isNotEmpty) ...[
            const SizedBox(height: AppSizes.spaceM),
            const Divider(),
            const SizedBox(height: AppSizes.spaceS),
            Text(
              task.description!,
              style: TextStyle(
                fontSize: AppSizes.fontBody,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withOpacity(0.7),
              ),
            ),
          ],

          const SizedBox(height: AppSizes.spaceL),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(BootstrapIcons.pencil),
                  label: const Text(AppStrings.edit),
                  onPressed: () {
                    Navigator.of(context).pop();
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(AppSizes.radiusL),
                        ),
                      ),
                      builder: (_) =>
                          EditTaskSheet(task: task),
                    );
                  },
                ),
              ),
              const SizedBox(width: AppSizes.spaceS),
              Expanded(
                child: ElevatedButton.icon(
                  icon: Icon(task.isCompleted
                      ? BootstrapIcons.arrow_counterclockwise
                      : BootstrapIcons.check2_circle),
                  label: Text(task.isCompleted
                      ? AppStrings.reopen
                      : AppStrings.markComplete),
                  onPressed: () async {
                    if (task.isCompleted) {
                      await ref
                          .read(tasksProvider.notifier)
                          .reopenTask(task.id);
                      if (context.mounted) {
                        Navigator.of(context).pop();
                        AppSnackbar.show(
                            context, AppStrings.taskReopened);
                      }
                    } else {
                      await ref
                          .read(tasksProvider.notifier)
                          .markComplete(task.id);
                      if (context.mounted) {
                        Navigator.of(context).pop();
                        AppSnackbar.show(
                            context, AppStrings.taskMarkedComplete);
                      }
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.spaceM),
        ],
      ),
    );
  }
}
