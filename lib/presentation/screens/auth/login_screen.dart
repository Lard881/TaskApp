import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:planpal/application/notifiers/auth_notifier.dart';
import 'package:planpal/core/constants/app_colors.dart';
import 'package:planpal/core/constants/app_sizes.dart';
import 'package:planpal/core/validators/profile_validator.dart';
import 'package:planpal/infrastructure/services/biometric_service.dart';
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
  bool _formLoading = false;
  bool _googleLoading = false;
  bool _appleLoading = false;
  bool _biometricAvailable = false;
  String _biometricType = 'Biometric';

  bool get _busy => _formLoading || _googleLoading || _appleLoading;

  @override
  void initState() {
    super.initState();
    _checkBiometric();
  }

  Future<void> _checkBiometric() async {
    final biometric = BiometricService();
    final isAvailable = await biometric.canCheckBiometrics();
    final isEnabled = await biometric.isBiometricEnabled();
    
    if (isAvailable && isEnabled) {
      final types = await biometric.getAvailableBiometrics();
      setState(() {
        _biometricAvailable = true;
        _biometricType = biometric.getBiometricTypeName(types);
      });
    }
  }

  Future<void> _signInWithBiometric() async {
    if (_busy) return;
    
    final biometric = BiometricService();
    final credentials = await biometric.authenticateAndGetCredentials(
      reason: 'Authenticate to sign in to PlanPal',
    );

    if (credentials == null) {
      if (context.mounted) {
        AppSnackbar.show(context, 'Biometric authentication failed', isError: true);
      }
      return;
    }

    setState(() => _formLoading = true);
    try {
      final error = await ref
          .read(authProvider.notifier)
          .signInWithEmail(
            email: credentials['email']!,
            password: credentials['password']!,
          );

      if (error != null) {
        if (context.mounted) {
          AppSnackbar.show(context, _friendlyError(error), isError: true);
        }
      } else {
        if (context.mounted) {
          context.go('/home');
        }
      }
    } catch (e) {
      if (context.mounted) {
        AppSnackbar.show(context, _friendlyError(e.toString()), isError: true);
      }
    } finally {
      if (context.mounted) setState(() => _formLoading = false);
    }
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  // ── Sign in with email/password ───────────────────────────────────────────
  Future<void> _signInWithEmail() async {
    if (_busy) return;

    final emailErr = ProfileValidator.validateEmail(_emailCtrl.text);
    final pwdErr = _passwordCtrl.text.trim().isEmpty
        ? 'Password is required.'
        : null;

    setState(() {
      _emailError = emailErr;
      _passwordError = pwdErr;
    });

    if (emailErr != null || pwdErr != null) return;

    setState(() => _formLoading = true);
    try {
      final error = await ref
          .read(authProvider.notifier)
          .signInWithEmail(
            email: _emailCtrl.text.trim(),
            password: _passwordCtrl.text,
          );

      if (error != null) {
        if (context.mounted) {
          AppSnackbar.show(context, _friendlyError(error), isError: true);
        }
      } else {
        // Check if should offer biometric setup
        final biometric = BiometricService();
        final canCheck = await biometric.canCheckBiometrics();
        final isEnabled = await biometric.isBiometricEnabled();
        
        if (context.mounted && canCheck && !isEnabled) {
          // Offer to enable biometric login
          final enable = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Enable Biometric Login?'),
              content: const Text('Would you like to use fingerprint or face ID to sign in next time?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('No'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text('Enable'),
                ),
              ],
            ),
          );

          if (enable == true) {
            await biometric.enableBiometricLogin(
              email: _emailCtrl.text.trim(),
              password: _passwordCtrl.text,
            );
          }
        }

        if (context.mounted) {
          context.go('/home');
        }
      }
    } catch (e) {
      if (context.mounted) {
        AppSnackbar.show(context, _friendlyError(e.toString()), isError: true);
      }
    } finally {
      if (context.mounted) setState(() => _formLoading = false);
    }
  }

  // ── Social sign in ────────────────────────────────────────────────────────
  Future<void> _signInWithGoogle() async {
    if (_busy) return;
    setState(() => _googleLoading = true);
    try {
      await ref.read(authProvider.notifier).signInWithGoogle();
    } catch (e) {
      if (context.mounted) {
        AppSnackbar.show(context, _friendlyError(e.toString()), isError: true);
      }
    } finally {
      if (context.mounted) setState(() => _googleLoading = false);
    }
  }

  Future<void> _signInWithApple() async {
    if (_busy) return;
    setState(() => _appleLoading = true);
    try {
      await ref.read(authProvider.notifier).signInWithApple();
    } catch (e) {
      if (context.mounted) {
        AppSnackbar.show(context, _friendlyError(e.toString()), isError: true);
      }
    } finally {
      if (context.mounted) setState(() => _appleLoading = false);
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

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
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
              Text(
                'Welcome back',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: isDark ? AppColors.darkOnSurface : AppColors.lightOnSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Sign in to your PlanPal account',
                style: TextStyle(
                  fontSize: AppSizes.fontBody,
                  color: isDark ? AppColors.darkOnSurfaceMuted : Colors.grey.shade500,
                ),
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
                    MaterialPageRoute<void>(
                      builder: (_) => const ForgotPasswordScreen(),
                    ),
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

              const SizedBox(height: 12),

              // ── Biometric button (if available) ───────────────────────────
              if (_biometricAvailable)
                SizedBox(
                  height: 54,
                  child: OutlinedButton.icon(
                    onPressed: _busy ? null : _signInWithBiometric,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary, width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSizes.radiusM),
                      ),
                    ),
                    icon: const Icon(BootstrapIcons.fingerprint, size: 22),
                    label: Text(
                      'Sign in with $_biometricType',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              if (_biometricAvailable) const SizedBox(height: 12),

              // ── Sign In button ────────────────────────────────────────────
              SizedBox(
                height: 54,
                child: ElevatedButton(
                  onPressed: _busy ? null : _signInWithEmail,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: AppColors.primary.withValues(
                      alpha: 0.5,
                    ),
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
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Sign In',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 24),

              // ── Sign up link ──────────────────────────────────────────────
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Don't have an account?  ",
                      style: TextStyle(
                        fontSize: AppSizes.fontBody,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const SignUpScreen(),
                        ),
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
                color: AppColors.primary.withValues(alpha: 0.3),
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
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          'PlanPal',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.darkOnSurface
                : AppColors.lightOnSurface,
          ),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: AppSizes.fontBody,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.darkOnSurface : AppColors.lightOnSurface,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          onChanged: onChanged,
          style: TextStyle(
            fontSize: AppSizes.fontBody,
            color: isDark ? AppColors.darkOnSurface : AppColors.lightOnSurface,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: isDark ? AppColors.darkOnSurfaceMuted : Colors.grey.shade400,
              fontSize: AppSizes.fontBody,
            ),
            prefixIcon: Icon(
              icon,
              size: AppSizes.iconSizeM,
              color: errorText != null ? AppColors.error : Colors.grey.shade400,
            ),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: isDark ? AppColors.darkSurface : Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSizes.spaceM,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
              borderSide: BorderSide(
                color: errorText != null
                    ? AppColors.error
                    : (isDark ? Colors.white12 : AppColors.divider),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
              borderSide: BorderSide(
                color: errorText != null
                    ? AppColors.error
                    : (isDark ? Colors.white12 : AppColors.divider),
              ),
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
              fontWeight: FontWeight.w500,
            ),
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
                      color: Colors.black.withValues(alpha: 0.07),
                      blurRadius: 12,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: loading
              ? Center(
                  child: SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: foregroundColor,
                    ),
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
                        color: foregroundColor,
                      ),
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
  Widget build(BuildContext context) => SizedBox(
    width: 22,
    height: 22,
    child: CustomPaint(painter: _GooglePainter()),
  );
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
      canvas.drawArc(
        Rect.fromCircle(center: c, radius: r),
        seg.$2,
        seg.$3,
        true,
        p,
      );
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
