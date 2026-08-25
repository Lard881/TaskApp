import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:planpal/application/notifiers/auth_notifier.dart';
import 'package:planpal/core/constants/app_colors.dart';
import 'package:planpal/core/constants/app_sizes.dart';
import 'package:planpal/core/constants/app_strings.dart';

/// Splash screen — shown while Supabase resolves the auth session.
///
/// Sequence:
/// 1. Show logo with fade-in for minimum 1 second
/// 2. Watch [authProvider] — once it resolves, the router redirect
///    takes over automatically (no manual navigation needed here)
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
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );
    _fadeController.forward();

    // The router watches authProvider and will redirect automatically.
    // We just need to ensure a minimum display time so the splash
    // doesn't flash for < 1 second.
    _ensureMinDisplay();
  }

  Future<void> _ensureMinDisplay() async {
    await Future.delayed(const Duration(milliseconds: 1000));
    // After min display, trigger authProvider to load so the router
    // can pick up the resolved state and navigate.
    if (mounted) {
      ref.read(authProvider);
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
                  BootstrapIcons.check_circle,
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


