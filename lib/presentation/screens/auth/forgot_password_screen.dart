import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:planpal/application/notifiers/auth_notifier.dart';
import 'package:planpal/core/constants/app_colors.dart';
import 'package:planpal/core/constants/app_sizes.dart';
import 'package:planpal/core/validators/profile_validator.dart';

/// Forgot Password screen — wired to Supabase resetPasswordForEmail.
class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState
    extends ConsumerState<ForgotPasswordScreen> {
  final _emailCtrl = TextEditingController();
  String? _emailError;
  bool _loading = false;
  bool _sent = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final err = ProfileValidator.validateEmail(_emailCtrl.text);
    setState(() => _emailError = err);
    if (err != null) return;

    setState(() => _loading = true);
    try {
      await ref
          .read(authProvider.notifier)
          .resetPassword(_emailCtrl.text.trim());
      if (mounted) setState(() { _loading = false; _sent = true; });
    } catch (_) {
      // Always show success to prevent email enumeration attacks
      if (mounted) setState(() { _loading = false; _sent = true; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: AppColors.lightBackground,
        elevation: 0,
        leading: Semantics(
          label: 'Back',
          button: true,
          child: IconButton(
            icon: const Icon(BootstrapIcons.arrow_left,
                color: Color(0xFF1A1D2E)),
            onPressed: () => context.pop(),
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: AppSizes.spaceXL),
          child: _sent ? _SuccessView(email: _emailCtrl.text.trim()) : _FormView(
            emailCtrl: _emailCtrl,
            emailError: _emailError,
            loading: _loading,
            onEmailChanged: (_) => setState(() => _emailError = null),
            onSubmit: _submit,
          ),
        ),
      ),
    );
  }
}

// ── Form view ─────────────────────────────────────────────────────────────────

class _FormView extends StatelessWidget {
  const _FormView({
    required this.emailCtrl,
    required this.emailError,
    required this.loading,
    required this.onEmailChanged,
    required this.onSubmit,
  });

  final TextEditingController emailCtrl;
  final String? emailError;
  final bool loading;
  final ValueChanged<String> onEmailChanged;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: AppSizes.spaceL),

        // ── Icon illustration ────────────────────────────────────────────
        Center(
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              BootstrapIcons.key,
              color: AppColors.primary,
              size: 36,
            ),
          ),
        ),
        const SizedBox(height: AppSizes.spaceL),

        // ── Headline ─────────────────────────────────────────────────────
        const Text(
          'Forgot your password?',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1A1D2E),
          ),
        ),
        const SizedBox(height: AppSizes.spaceS),
        Text(
          'No worries — enter your email and we\'ll send you a reset link.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: AppSizes.fontBody,
            color: Colors.grey.shade500,
            height: 1.5,
          ),
        ),
        const SizedBox(height: AppSizes.spaceXL),

        // ── Email field ──────────────────────────────────────────────────
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Email address',
              style: TextStyle(
                fontSize: AppSizes.fontBody,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1D2E),
              ),
            ),
            const SizedBox(height: AppSizes.spaceXS),
            TextField(
              controller: emailCtrl,
              keyboardType: TextInputType.emailAddress,
              onChanged: onEmailChanged,
              style: const TextStyle(
                fontSize: AppSizes.fontBody,
                color: Color(0xFF1A1D2E),
              ),
              decoration: InputDecoration(
                hintText: 'you@example.com',
                hintStyle: TextStyle(
                  color: Colors.grey.shade400,
                ),
                prefixIcon: Icon(
                  BootstrapIcons.envelope,
                  size: AppSizes.iconSizeM,
                  color: emailError != null
                      ? AppColors.error
                      : Colors.grey.shade400,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.spaceM,
                  vertical: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(AppSizes.radiusM),
                  borderSide: BorderSide(
                      color: emailError != null
                          ? AppColors.error
                          : AppColors.divider),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(AppSizes.radiusM),
                  borderSide: BorderSide(
                      color: emailError != null
                          ? AppColors.error
                          : AppColors.divider),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(AppSizes.radiusM),
                  borderSide: BorderSide(
                    color: emailError != null
                        ? AppColors.error
                        : AppColors.primary,
                    width: 2,
                  ),
                ),
                errorText: emailError,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.spaceXL),

        // ── Send button ──────────────────────────────────────────────────
        SizedBox(
          height: 52,
          child: ElevatedButton(
            onPressed: loading ? null : onSubmit,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusM),
              ),
              elevation: 0,
            ),
            child: loading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    'Send Reset Link',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: AppSizes.spaceL),

        // ── Back to login ────────────────────────────────────────────────
        Center(
          child: GestureDetector(
            onTap: () => context.pop(),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  BootstrapIcons.arrow_left,
                  size: 14,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 4),
                const Text(
                  'Back to Sign In',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: AppSizes.fontBody,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── Success view (after email sent) ──────────────────────────────────────────

class _SuccessView extends StatelessWidget {
  const _SuccessView({required this.email});
  final String email;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: AppSizes.spaceXL),

        // ── Success icon ─────────────────────────────────────────────────
        Center(
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              BootstrapIcons.check_circle_fill,
              color: AppColors.success,
              size: 40,
            ),
          ),
        ),
        const SizedBox(height: AppSizes.spaceL),

        // ── Message ──────────────────────────────────────────────────────
        const Text(
          'Check your inbox',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1A1D2E),
          ),
        ),
        const SizedBox(height: AppSizes.spaceS),
        Text(
          'We\'ve sent a password reset link to\n$email',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: AppSizes.fontBody,
            color: Colors.grey.shade500,
            height: 1.6,
          ),
        ),
        const SizedBox(height: AppSizes.spaceXS),
        Text(
          'Didn\'t receive it? Check your spam folder.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: AppSizes.fontSmall,
            color: Colors.grey.shade400,
          ),
        ),
        const SizedBox(height: AppSizes.spaceXL),

        // ── Back to login ─────────────────────────────────────────────────
        SizedBox(
          height: 52,
          child: ElevatedButton(
            onPressed: () => context.go('/login'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusM),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Back to Sign In',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ],
    );
  }
}
