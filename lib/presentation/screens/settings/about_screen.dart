import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';
import 'package:planpal/core/constants/app_colors.dart';
import 'package:planpal/core/constants/app_sizes.dart';
import 'package:planpal/core/constants/app_strings.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.about)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.spaceXL),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(AppSizes.radiusL),
                ),
                child: const Icon(BootstrapIcons.check_circle,
                    color: Colors.white, size: 48),
              ),
              const SizedBox(height: AppSizes.spaceL),
              const Text(
                AppStrings.appName,
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: AppSizes.spaceXS),
              Text(
                'Version ${AppStrings.appVersion}',
                style: TextStyle(
                  fontSize: AppSizes.fontBody,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.55),
                ),
              ),
              const SizedBox(height: AppSizes.spaceL),
              Text(
                AppStrings.appDescription,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: AppSizes.fontBody,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
