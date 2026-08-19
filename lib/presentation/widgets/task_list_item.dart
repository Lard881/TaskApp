import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:planpal/application/notifiers/user_notifier.dart';
import 'package:planpal/core/constants/app_sizes.dart';
import 'package:planpal/core/formatters/datetime_formatter.dart';
import 'package:planpal/domain/models/task.dart';
import 'package:planpal/presentation/widgets/avatar_widget.dart';
import 'package:planpal/presentation/widgets/priority_badge.dart';

/// A single task row used in both the Home and Tasks screens.
class TaskListItem extends ConsumerWidget {
  const TaskListItem({
    super.key,
    required this.task,
    required this.onTap,
    this.onLongPress,
    this.onDismissed,
    this.showDismissible = false,
  });

  final Task task;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onDismissed;
  final bool showDismissible;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assigneeAsync = task.assigneeId != null
        ? ref.watch(userByIdProvider(task.assigneeId!))
        : null;
    final assignee = assigneeAsync?.valueOrNull;

    final tile = Semantics(
      label: 'Task: ${task.name}',
      button: true,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSizes.spaceM,
          vertical: AppSizes.spaceXS,
        ),
        onTap: onTap,
        onLongPress: onLongPress,
        title: Text(
          task.name,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: AppSizes.fontBody,
            fontWeight: FontWeight.w600,
            decoration:
                task.isCompleted ? TextDecoration.lineThrough : null,
            color: task.isCompleted
                ? Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withOpacity(0.45)
                : null,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: AppSizes.spaceXS),
          child: Text(
            DateTimeFormatter.formatDueDate(task.dueDate, task.dueTime),
            style: TextStyle(
              fontSize: AppSizes.fontSmall,
              color: task.isOverdue
                  ? Colors.red
                  : Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withOpacity(0.55),
            ),
          ),
        ),
        leading: PriorityBadge(
          priority: task.priority,
          isCompleted: task.isCompleted,
        ),
        trailing: assignee != null
            ? AvatarWidget(
                initials: assignee.initials,
                imagePath: assignee.avatarPath,
                diameter: AppSizes.avatarSmall,
              )
            : null,
      ),
    );

    if (!showDismissible || onDismissed == null) return tile;

    return Dismissible(
      key: ValueKey(task.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSizes.spaceL),
        color: Colors.red,
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      confirmDismiss: (_) async => false, // we handle via onDismissed
      onUpdate: (details) {
        if (details.reached) onDismissed?.call();
      },
      child: tile,
    );
  }
}
