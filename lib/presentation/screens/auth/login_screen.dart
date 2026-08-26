import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:planpal/application/notifiers/auth_notifier.dart';
import 'package:planpal/core/constants/app_colors.dart';
import 'package:planpal/core/constants/app_sizes.dart';
import 'package:planpal/core/validators/profile_validator.dart';
import 'package:planpal/presentation/screens/auth/sign_up_screen.dart';
import 'package:planpal/presentation/screens/auth/forgot_password_screen.dart';
import 'package:planpal/presentation/widgets/app_snackbar.dart';

/// Sign In screen — wired to [AuthNotifier] for real Supabase auth.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  // ── Form ────────────────────────────────────────────────────────────────
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscurePassword = true;
  String? _emailError;
  String? _passwordError;

  // ── State ────────────────────────────────────────────────────────────────
  bool _agreed = false;
  bool _showTermsError = false;
  bool _formLoading = false;
  bool _googleLoading = false;
  bool _appleLoading = false;

  bool get _busy => _formLoading || _googleLoading || _appleLoading;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  // ── Terms guard ───────────────────────────────────────────────────────────
  bool _checkTerms() {
    if (!_agreed) {
      setState(() => _showTermsError = true);
      AppSnackbar.show(
        context,
        'Please accept the Terms of Service and Privacy Policy to continue.',
        isError: true,
      );
      return false;
    }
    return true;
  }

  // ── Sign in with email/password ───────────────────────────────────────────
  Future<void> _signInWithEmail() async {
    if (!_checkTerms() || _busy) return;

    final emailErr = ProfileValidator.validateEmail(_emailCtrl.text);
    final pwdErr =
        _passwordCtrl.text.trim().isEmpty ? 'Password is required.' : null;

    setState(() {
      _emailError = emailErr;
      _passwordError = pwdErr;
    });

    if (emailErr != null || pwdErr != null) return;

    setState(() => _formLoading = true);
    try {
      await ref.read(authProvider.notifier).signInWithEmail(
            email: _emailCtrl.text.trim(),
            password: _passwordCtrl.text,
          );
      // Router redirect handles navigation automatically
    } catch (e) {
      if (mounted) {
        AppSnackbar.show(
          context,
          _friendlyError(e.toString()),
          isError: true,
        );
      }
    } finally {
      if (mounted) setState(() => _formLoading = false);
    }
  }

  // ── Social sign in ────────────────────────────────────────────────────────
  Future<void> _signInWithGoogle() async {
    if (!_checkTerms() || _busy) return;
    setState(() => _googleLoading = true);
    try {
      await ref.read(authProvider.notifier).signInWithGoogle();
    } catch (e) {
      if (mounted) {
        AppSnackbar.show(context, _friendlyError(e.toString()),
            isError: true);
      }
    } finally {
      if (mounted) setState(() => _googleLoading = false);
    }
  }

  Future<void> _signInWithApple() async {
    if (!_checkTerms() || _busy) return;
    setState(() => _appleLoading = true);
    try {
      await ref.read(authProvider.notifier).signInWithApple();
    } catch (e) {
      if (mounted) {
        AppSnackbar.show(context, _friendlyError(e.toString()),
            isError: true);
      }
    } finally {
      if (mounted) setState(() => _appleLoading = false);
    }
  }

  /// Maps Supabase error messages to user-friendly strings.
  String _friendlyError(String raw) {
    if (raw.contains('Invalid login credentials')) {
      return 'Incorrect email or password.';
    }
    if (raw.contains('Email not confirmed')) {
      return 'Please verify your email before signing in.';
    }
    if (raw.contains('network') || raw.contains('socket')) {
      return 'No internet connection. Please try again.';
    }
    return 'Something went wrong. Please try again.';
  }

  @override
  Widget build(BuildContext context) {
    // Watch auth state — navigate when sign in succeeds
    ref.listen<AsyncValue<AppAuthState>>(authProvider, (_, next) {
      next.whenOrNull(
        data: (state) {
          if (state == AppAuthState.authenticated) {
            context.go('/home');
          } else if (state == AppAuthState.onboarding) {
            context.go('/onboarding');
          }
        },
      );
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FF),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(28, 0, 28, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),

              // ── Logo ─────────────────────────────────────────────────────
              _BrandLogo(),
              const SizedBox(height: 32),

              // ── Headline ─────────────────────────────────────────────────
              const Text(
                'Welcome back',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1A1D2E),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Sign in to your PlanPal account',
                style: TextStyle(
                    fontSize: AppSizes.fontBody, color: Colors.grey.shade500),
              ),
              const SizedBox(height: 28),

              // ── Email field ───────────────────────────────────────────────
              _AuthField(
                controller: _emailCtrl,
                label: 'Email address',
                hint: 'you@example.com',
                icon: BootstrapIcons.envelope,
                keyboardType: TextInputType.emailAddress,
                errorText: _emailError,
                onChanged: (_) => setState(() => _emailError = null),
              ),
              const SizedBox(height: 16),

              // ── Password field ────────────────────────────────────────────
              _AuthField(
                controller: _passwordCtrl,
                label: 'Password',
                hint: '••••••••',
                icon: BootstrapIcons.lock,
                obscureText: _obscurePassword,
                errorText: _passwordError,
                onChanged: (_) => setState(() => _passwordError = null),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? BootstrapIcons.eye
                        : BootstrapIcons.eye_slash,
                    size: AppSizes.iconSizeM,
                    color: Colors.grey.shade400,
                  ),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
              const SizedBox(height: 8),

              // ── Forgot password ───────────────────────────────────────────
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) => const ForgotPasswordScreen()),
                  ),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 0),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text(
                    'Forgot password?',
                    style: TextStyle(
                      fontSize: AppSizes.fontBody,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // ── Terms & Conditions ────────────────────────────────────────
              _TermsCheckbox(
                agreed: _agreed,
                showError: _showTermsError,
                onChanged: (v) => setState(() {
                  _agreed = v ?? false;
                  if (_agreed) _showTermsError = false;
                }),
              ),
              const SizedBox(height: 20),

              // ── Sign In button ────────────────────────────────────────────
              SizedBox(
                height: 54,
                child: ElevatedButton(
                  onPressed: _busy ? null : _signInWithEmail,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: AppColors.primary.withOpacity(0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusM),
                    ),
                    elevation: 0,
                  ),
                  child: _formLoading
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                              strokeWidth: 2.5, color: Colors.white),
                        )
                      : const Text(
                          'Sign In',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w700),
                        ),
                ),
              ),
              const SizedBox(height: 24),

              // ── Or divider ────────────────────────────────────────────────
              _OrDivider(),
              const SizedBox(height: 20),

              // ── Google ────────────────────────────────────────────────────
              _SocialAuthButton(
                label: 'Continue with Google',
                icon: _GoogleLogo(),
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF1A1D2E),
                borderColor: AppColors.divider,
                loading: _googleLoading,
                enabled: !_busy,
                onTap: _signInWithGoogle,
              ),
              const SizedBox(height: 12),

              // ── Apple ─────────────────────────────────────────────────────
              _SocialAuthButton(
                label: 'Continue with Apple',
                icon: const Icon(BootstrapIcons.apple,
                    size: 22, color: Colors.white),
                backgroundColor: const Color(0xFF1A1D2E),
                foregroundColor: Colors.white,
                borderColor: Colors.transparent,
                loading: _appleLoading,
                enabled: !_busy,
                onTap: _signInWithApple,
              ),
              const SizedBox(height: 28),

              // ── Sign up link ──────────────────────────────────────────────
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Don't have an account?  ",
                      style: TextStyle(
                          fontSize: AppSizes.fontBody,
                          color: Colors.grey.shade500),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) => const SignUpScreen()),
                      ),
                      child: const Text(
                        'Sign Up',
                        style: TextStyle(
                          fontSize: AppSizes.fontBody,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared widgets
// ─────────────────────────────────────────────────────────────────────────────

class _BrandLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Center(
            child: Text(
              'P',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w800),
            ),
          ),
        ),
        const SizedBox(width: 10),
        const Text(
          'PlanPal',
          style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1A1D2E)),
        ),
      ],
    );
  }
}

class _AuthField extends StatelessWidget {
  const _AuthField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.keyboardType,
    this.obscureText = false,
    this.errorText,
    this.onChanged,
    this.suffixIcon,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final TextInputType? keyboardType;
  final bool obscureText;
  final String? errorText;
  final ValueChanged<String>? onChanged;
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: AppSizes.fontBody,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1D2E),
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          onChanged: onChanged,
          style: const TextStyle(
              fontSize: AppSizes.fontBody, color: Color(0xFF1A1D2E)),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
                color: Colors.grey.shade400, fontSize: AppSizes.fontBody),
            prefixIcon: Icon(icon,
                size: AppSizes.iconSizeM,
                color: errorText != null
                    ? AppColors.error
                    : Colors.grey.shade400),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSizes.spaceM, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
              borderSide: BorderSide(
                  color:
                      errorText != null ? AppColors.error : AppColors.divider),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
              borderSide: BorderSide(
                  color:
                      errorText != null ? AppColors.error : AppColors.divider),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
              borderSide: BorderSide(
                color: errorText != null ? AppColors.error : AppColors.primary,
                width: 2,
              ),
            ),
            errorText: errorText,
          ),
        ),
      ],
    );
  }
}

class _TermsCheckbox extends StatelessWidget {
  const _TermsCheckbox({
    required this.agreed,
    required this.showError,
    required this.onChanged,
  });

  final bool agreed;
  final bool showError;
  final ValueChanged<bool?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color:
                showError ? AppColors.error.withOpacity(0.05) : Colors.white,
            borderRadius: BorderRadius.circular(AppSizes.radiusM),
            border: Border.all(
              color: showError
                  ? AppColors.error.withOpacity(0.4)
                  : AppColors.divider,
              width: 1.5,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 24,
                height: 24,
                child: Checkbox(
                  value: agreed,
                  onChanged: onChanged,
                  activeColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4)),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(
                        fontSize: AppSizes.fontSmall,
                        color: Colors.grey.shade600,
                        height: 1.5),
                    children: const [
                      TextSpan(text: 'I agree to the '),
                      TextSpan(
                        text: 'Terms of Service',
                        style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600),
                      ),
                      TextSpan(text: ' and '),
                      TextSpan(
                        text: 'Privacy Policy',
                        style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        if (showError) ...[
          const SizedBox(height: 6),
          Row(
            children: const [
              Icon(BootstrapIcons.exclamation_circle,
                  size: 13, color: AppColors.error),
              SizedBox(width: 4),
              Text(
                'You must accept the terms to continue.',
                style: TextStyle(
                    fontSize: 11,
                    color: AppColors.error,
                    fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _OrDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Divider(color: Colors.grey.shade300, thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'or',
            style: TextStyle(
                fontSize: AppSizes.fontSmall,
                color: Colors.grey.shade400,
                fontWeight: FontWeight.w500),
          ),
        ),
        Expanded(child: Divider(color: Colors.grey.shade300, thickness: 1)),
      ],
    );
  }
}

class _SocialAuthButton extends StatelessWidget {
  const _SocialAuthButton({
    required this.label,
    required this.icon,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.borderColor,
    required this.loading,
    required this.enabled,
    required this.onTap,
  });

  final String label;
  final Widget icon;
  final Color backgroundColor;
  final Color foregroundColor;
  final Color borderColor;
  final bool loading;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      enabled: enabled,
      child: GestureDetector(
        onTap: enabled ? onTap : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 54,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(AppSizes.radiusM),
            border: Border.all(color: borderColor, width: 1.5),
            boxShadow: enabled && backgroundColor == Colors.white
                ? [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.07),
                        blurRadius: 12,
                        offset: const Offset(0, 2))
                  ]
                : null,
          ),
          child: loading
              ? Center(
                  child: SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                        strokeWidth: 2.5, color: foregroundColor),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    icon,
                    const SizedBox(width: 12),
                    Text(
                      label,
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: foregroundColor),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _GoogleLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      SizedBox(width: 22, height: 22, child: CustomPaint(painter: _GooglePainter()));
}

class _GooglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2;
    final p = Paint()..style = PaintingStyle.fill;
    for (final seg in [
      (const Color(0xFF4285F4), -0.52, 1.6),
      (const Color(0xFFEA4335), 1.08, 1.2),
      (const Color(0xFFFBBC05), 2.28, 1.05),
      (const Color(0xFF34A853), 3.33, 1.0),
    ]) {
      p.color = seg.$1;
      canvas.drawArc(Rect.fromCircle(center: c, radius: r), seg.$2, seg.$3, true, p);
    }
    p.color = Colors.white;
    canvas.drawCircle(c, r * 0.62, p);
    p.color = const Color(0xFF4285F4);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(c.dx - r * 0.05, c.dy - r * 0.18, r * 0.95, r * 0.36),
        const Radius.circular(2),
      ),
      p,
    );
    p.color = Colors.white;
    canvas.drawCircle(c, r * 0.38, p);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
