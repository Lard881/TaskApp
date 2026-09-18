import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:planpal/core/constants/app_colors.dart';
import 'package:planpal/core/constants/app_sizes.dart';
import 'package:planpal/presentation/widgets/app_snackbar.dart';

class RateAppDialog extends StatefulWidget {
  const RateAppDialog({super.key});

  static void show(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (_) => const RateAppDialog(),
    );
  }

  @override
  State<RateAppDialog> createState() => _RateAppDialogState();
}

class _RateAppDialogState extends State<RateAppDialog> {
  int _rating = 5;
  final _feedbackCtrl = TextEditingController();
  bool _submitted = false;

  Future<void> _submitRating() async {
    setState(() => _submitted = true);

    try {
      final inAppReview = InAppReview.instance;
      if (await inAppReview.isAvailable()) {
        await inAppReview.requestReview();
      }
    } catch (_) {
      // Ignored if platform doesn't support native review
    }

    if (mounted) {
      Navigator.pop(context);
      AppSnackbar.show(
        context,
        'Thank you for rating PlanPal $_rating stars! ⭐',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
      ),
      contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFFF59E0B).withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              BootstrapIcons.star_fill,
              color: Color(0xFFF59E0B),
              size: 28,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Enjoying PlanPal?',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your feedback helps us make PlanPal better for everyone.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: isDark
                  ? AppColors.darkOnSurfaceMuted
                  : AppColors.lightOnSurfaceMuted,
            ),
          ),
          const SizedBox(height: 20),

          // 5-Star Row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              final starNum = index + 1;
              final isFilled = starNum <= _rating;

              return IconButton(
                onPressed: () => setState(() => _rating = starNum),
                icon: Icon(
                  isFilled ? BootstrapIcons.star_fill : BootstrapIcons.star,
                  color: const Color(0xFFF59E0B),
                  size: 28,
                ),
              );
            }),
          ),

          const SizedBox(height: 14),

          TextField(
            controller: _feedbackCtrl,
            maxLines: 2,
            decoration: InputDecoration(
              hintText: 'Any thoughts or feature requests? (Optional)',
              hintStyle: const TextStyle(fontSize: 12),
              filled: true,
              fillColor: isDark
                  ? AppColors.darkBackground
                  : const Color(0xFFF8F9FE),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusM),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(12),
            ),
          ),
        ],
      ),
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      actions: [
        Row(
          children: [
            Expanded(
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Not now'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: FilledButton(
                onPressed: _submitted ? null : _submitRating,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusM),
                  ),
                ),
                child: const Text('Submit'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
