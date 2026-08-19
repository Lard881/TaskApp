import 'package:flutter/material.dart';
import 'package:planpal/core/constants/app_sizes.dart';

/// A single row in the Settings screen with icon, label, and trailing chevron.
class SettingsListItem extends StatelessWidget {
  const SettingsListItem({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.trailing,
    this.textColor,
    this.iconColor,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Widget? trailing;
  final Color? textColor;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      button: true,
      child: ListTile(
        leading: Icon(icon, color: iconColor, size: AppSizes.iconSizeL),
        title: Text(
          label,
          style: TextStyle(
            fontSize: AppSizes.fontBody,
            fontWeight: FontWeight.w500,
            color: textColor,
          ),
        ),
        trailing: trailing ??
            Icon(
              Icons.chevron_right_rounded,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withOpacity(0.4),
            ),
        onTap: onTap,
        minVerticalPadding: AppSizes.spaceS,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSizes.spaceM,
          vertical: AppSizes.spaceXS,
        ),
      ),
    );
  }
}
