import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:planpal/application/notifiers/auth_notifier.dart';
import 'package:planpal/core/constants/app_colors.dart';
import 'package:planpal/core/constants/app_sizes.dart';
import 'package:planpal/core/constants/app_strings.dart';

/// Splash screen — shown while Supabase resolves the auth session.
///
/// Sequence:
/// 1. Show logo with fade-in animation (600ms)
/// 2. Enforce minimum display time (1 second)
/// 3. Watch [authProvider] — as soon as it resolves (not AsyncLoading),
///    navigate directly to the correct screen.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;
  bool _minDisplayDone = false;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();

    // Fade-in animation
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );
    _fadeController.forward();

    // Enforce minimum 1 second display time
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) {
        setState(() => _minDisplayDone = true);
        _tryNavigate();
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  /// Navigate once both conditions are met:
  /// 1. Minimum display time has passed
  /// 2. Auth state has resolved (not AsyncLoading or AsyncError)
  void _tryNavigate() {
    if (_navigated || !_minDisplayDone) return;

    final authAsync = ref.read(authProvider);

    authAsync.whenOrNull(
      data: (authState) {
        _navigated = true;
        switch (authState) {
          case AppAuthState.authenticated:
            context.go('/home');
          case AppAuthState.onboarding:
            context.go('/onboarding');
          case AppAuthState.unauthenticated:
          case AppAuthState.unknown:
            context.go('/login');
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Watch auth state — rebuild when it changes, then try to navigate
    ref.listen<AsyncValue<AppAuthState>>(authProvider, (_, next) {
      if (_minDisplayDone) _tryNavigate();
    });

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
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
