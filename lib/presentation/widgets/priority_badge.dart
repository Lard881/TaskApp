import 'package:flutter/material.dart';
import 'package:planpal/core/constants/app_colors.dart';
import 'package:planpal/core/constants/app_sizes.dart';
import 'package:planpal/domain/enums/task_priority.dart';

/// Colored pill badge showing task priority, or a checkmark for completed tasks.
class PriorityBadge extends StatelessWidget {
  const PriorityBadge({
    super.key,
    required this.priority,
    this.isCompleted = false,
  });

  final TaskPriority priority;
  final bool isCompleted;

  @override
  Widget build(BuildContext context) {
    if (isCompleted) {
      return const Icon(
        Icons.check_circle_rounded,
        color: AppColors.success,
        size: AppSizes.iconSizeM,
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.badgePaddingH,
        vertical: AppSizes.badgePaddingV,
      ),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(AppSizes.radiusFull),
        border: Border.all(color: _color.withOpacity(0.4)),
      ),
      child: Text(
        priority.shortLabel,
        style: TextStyle(
          color: _color,
          fontSize: AppSizes.fontSmall,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Color get _color {
    switch (priority) {
      case TaskPriority.high:
        return AppColors.priorityHigh;
      case TaskPriority.medium:
        return AppColors.priorityMedium;
      case TaskPriority.low:
        return AppColors.priorityLow;
    }
  }
}
