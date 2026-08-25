import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:planpal/application/notifiers/auth_notifier.dart';
import 'package:planpal/application/notifiers/workspace_notifier.dart';
import 'package:planpal/core/constants/app_colors.dart';
import 'package:planpal/core/constants/app_sizes.dart';
import 'package:planpal/presentation/widgets/app_snackbar.dart';

/// First onboarding screen — shown after sign-up when no workspace exists.
///
/// Two paths:
///   "Just for me"   → personal workspace already auto-created by DB trigger
///                     → mark onboarding complete → go to /home
///   "For my team"   → go to CreateWorkspaceScreen
class OnboardingWelcomeScreen extends ConsumerStatefulWidget {
  const OnboardingWelcomeScreen({super.key});

  @override
  ConsumerState<OnboardingWelcomeScreen> createState() =>
      _OnboardingWelcomeScreenState();
}

class _OnboardingWelcomeScreenState
    extends ConsumerState<OnboardingWelcomeScreen> {
  bool _personalLoading = false;

  Future<void> _goPersonal() async {
    setState(() => _personalLoading = true);
    try {
      // The personal workspace was already created by the DB trigger.
      // We just need to load workspaces to confirm, then mark done.
      await ref.read(workspacesProvider.future);
      ref.read(authProvider.notifier).markOnboardingComplete();
      // Router redirects to /home automatically
    } catch (e) {
      if (mounted) {
        AppSnackbar.show(context, 'Something went wrong. Please try again.',
            isError: true);
        setState(() => _personalLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FF),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.spaceXL, vertical: AppSizes.spaceL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(flex: 2),

              // ── Logo ─────────────────────────────────────────────────────
              Center(
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      'P',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.spaceL),

              // ── Headline ──────────────────────────────────────────────────
              const Text(
                'Welcome to PlanPal!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1A1D2E),
                ),
              ),
              const SizedBox(height: AppSizes.spaceS),
              Text(
                'How will you use PlanPal?',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: AppSizes.fontBody,
                    color: Colors.grey.shade500),
              ),

              const Spacer(flex: 2),

              // ── Personal card ─────────────────────────────────────────────
              _ChoiceCard(
                icon: BootstrapIcons.person_circle,
                title: 'Just for me',
                subtitle:
                    'Personal tasks, goals, and notes — all in one place.',
                color: AppColors.primary,
                loading: _personalLoading,
                onTap: _goPersonal,
              ),
              const SizedBox(height: AppSizes.spaceM),

              // ── Team card ─────────────────────────────────────────────────
              _ChoiceCard(
                icon: BootstrapIcons.people,
                title: 'For my team',
                subtitle:
                    'Collaborate on tasks, chat, and track team progress.',
                color: const Color(0xFF22C55E),
                loading: false,
                onTap: () => context.go('/onboarding/create-workspace'),
              ),

              const Spacer(flex: 3),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChoiceCard extends StatelessWidget {
  const _ChoiceCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.loading,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final bool loading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: title,
      child: GestureDetector(
        onTap: loading ? null : onTap,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppSizes.radiusL),
            border: Border.all(color: color.withOpacity(0.3), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.08),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: loading
                    ? Center(
                        child: SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                              strokeWidth: 2.5, color: color),
                        ),
                      )
                    : Icon(icon, color: color, size: 26),
              ),
              const SizedBox(width: AppSizes.spaceM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1D2E),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                          fontSize: AppSizes.fontSmall,
                          color: Colors.grey.shade500),
                    ),
                  ],
                ),
              ),
              Icon(BootstrapIcons.chevron_right,
                  color: Colors.grey.shade300, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}
