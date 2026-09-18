import 'package:flutter/material.dart';
import 'package:planpal/core/constants/app_colors.dart';
import 'package:planpal/core/constants/app_sizes.dart';

/// Static helper for showing consistently styled snackbars (Req 26.3).
///
/// Usage:
/// ```dart
/// AppSnackbar.show(context, 'Task deleted.');
/// AppSnackbar.show(context, 'Something went wrong.', isError: true);
/// ```
abstract final class AppSnackbar {
  /// Shows a snackbar with [message].
  /// Set [isError] to `true` for error-tinted styling.
  static void show(
    BuildContext context,
    String message, {
    bool isError = false,
    Duration duration = const Duration(seconds: 3),
  }) {
    // Dismiss any current snackbar before showing the new one
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
            fontSize: AppSizes.fontBody,
          ),
        ),
        backgroundColor:
            isError ? AppColors.error : const Color(0xFF323232),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
        ),
        margin: const EdgeInsets.all(AppSizes.spaceM),
        duration: duration,
      ),
    );
  }
}
