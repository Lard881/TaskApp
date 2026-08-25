import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';
import 'package:planpal/core/constants/app_sizes.dart';

/// Centered icon + message shown when a list is empty.
class EmptyStateWidget extends StatelessWidget {
  const EmptyStateWidget({
    super.key,
    required this.message,
    this.icon = BootstrapIcons.inbox,
  });

  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).colorScheme.onSurface.withOpacity(0.4);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.spaceXL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: muted),
            const SizedBox(height: AppSizes.spaceM),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: muted,
                fontSize: AppSizes.fontBody,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
