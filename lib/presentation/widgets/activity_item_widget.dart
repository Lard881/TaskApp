import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';
import 'package:planpal/core/constants/app_colors.dart';
import 'package:planpal/core/constants/app_sizes.dart';
import 'package:planpal/core/extensions/string_extensions.dart';
import 'package:planpal/core/formatters/relative_time_formatter.dart';
import 'package:planpal/domain/enums/activity_type.dart';
import 'package:planpal/domain/models/activity_item.dart';

/// A single row in the Profile screen's Recent Activity feed.
class ActivityItemWidget extends StatelessWidget {
  const ActivityItemWidget({
    super.key,
    required this.activity,
    this.resolvedTaskName,
  });

  final ActivityItem activity;
  final String? resolvedTaskName;

  @override
  Widget build(BuildContext context) {
    final name = resolvedTaskName ?? activity.taskName;
    final displayName =
        activity.taskId == null ? '[Deleted task]' : name;
    final description = 'Task "$displayName" ${activity.type.verb}'
        .truncate(60);

    return ListTile(
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: _iconColor.withOpacity(0.12),
          shape: BoxShape.circle,
        ),
        child: Icon(_icon, color: _iconColor, size: AppSizes.iconSizeM),
      ),
      title: Text(
        description,
        style: const TextStyle(fontSize: AppSizes.fontBody),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        RelativeTimeFormatter.formatRelative(activity.timestamp),
        style: TextStyle(
          fontSize: AppSizes.fontSmall,
          color:
              Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSizes.spaceM,
        vertical: AppSizes.spaceXS,
      ),
    );
  }

  IconData get _icon {
    switch (activity.type) {
      case ActivityType.created:
        return BootstrapIcons.plus_circle;
      case ActivityType.updated:
        return BootstrapIcons.pencil;
      case ActivityType.completed:
        return BootstrapIcons.check_circle;
    }
  }

  Color get _iconColor {
    switch (activity.type) {
      case ActivityType.created:
        return AppColors.primary;
      case ActivityType.updated:
        return AppColors.priorityMedium;
      case ActivityType.completed:
        return AppColors.success;
    }
  }
}
