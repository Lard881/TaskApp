import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:planpal/application/providers/hive_providers.dart';
import 'package:planpal/core/constants/app_colors.dart';
import 'package:planpal/core/constants/app_sizes.dart';
import 'package:planpal/core/constants/app_strings.dart';
import 'package:planpal/infrastructure/hive_init.dart';
import 'package:planpal/presentation/widgets/app_snackbar.dart';

/// Entry point screen shown while Hive initialises.
///
/// Sequence (Req 28):
/// 1. Display logo + name for minimum 500ms
/// 2. Run [initHive] (open boxes, register adapters, seed data)
/// 3. Navigate to /home with a fade transition ≤ 400ms
/// 4. If init exceeds 3s, navigate anyway and show "Could not load" snackbar
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Fade-in animation for the logo
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );
    _fadeController.forward();

    _runInitSequence();
  }

  Future<void> _runInitSequence() async {
    // Enforce minimum display time of 500ms (Req 28.1)
    final minDisplay = Future<void>.delayed(const Duration(milliseconds: 500));

    // Enforce 3-second timeout (Req 28.5)
    bool timedOut = false;
    HiveInitResult? result;

    try {
      result = await initHive().timeout(
        const Duration(seconds: 3),
        onTimeout: () {
          timedOut = true;
          // Return a dummy — we navigate anyway and show the snackbar
          throw TimeoutException();
        },
      );
    } on TimeoutException {
      timedOut = true;
    } catch (_) {
      timedOut = true;
    }

    // Wait for minimum display time before navigating
    await minDisplay;

    if (!mounted) return;

    if (result != null) {
      // Store repositories in providers so the rest of the app can access them
      ref.read(hiveInitResultProvider.notifier).state = result;
    }

    if (timedOut && mounted) {
      AppSnackbar.show(context, AppStrings.dataLoadFailed);
    }

    if (mounted) {
      context.go('/home');
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Logo placeholder — replace with an actual asset when available
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppSizes.radiusL),
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.primary,
                  size: 48,
                ),
              ),
              const SizedBox(height: AppSizes.spaceL),
              const Text(
                AppStrings.appName,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: AppSizes.spaceS),
              Text(
                'Stay organised. Stay ahead.',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: AppSizes.fontBody,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Internal exception used to signal a timeout during Hive init.
class TimeoutException implements Exception {}
