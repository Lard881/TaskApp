import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:planpal/application/notifiers/auth_notifier.dart';
import 'package:planpal/core/constants/app_colors.dart';
import 'package:planpal/core/constants/app_sizes.dart';
import 'package:planpal/core/validators/password_validator.dart';
import 'package:planpal/core/validators/profile_validator.dart';
import 'package:planpal/presentation/widgets/app_snackbar.dart';

/// Sign Up screen — wired to [AuthNotifier].
class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  // ── Form controllers ──────────────────────────────────────────────────────
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  // ── Errors ────────────────────────────────────────────────────────────────
  String? _firstNameError;
  String? _lastNameError;
  String? _emailError;
  String? _passwordError;
  String? _confirmError;

  // ── State ─────────────────────────────────────────────────────────────────
  bool _agreed = false;
  bool _showTermsError = false;
  bool _formLoading = false;
  bool _googleLoading = false;
  bool _appleLoading = false;

  bool get _busy => _formLoading || _googleLoading || _appleLoading;

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
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

  // ── Create account with form ──────────────────────────────────────────────
  Future<void> _createAccount() async {
    if (!_checkTerms() || _busy) return;

    final fnErr = ProfileValidator.validateFirstName(_firstNameCtrl.text);
    final lnErr = ProfileValidator.validateLastName(_lastNameCtrl.text);
    final emErr = ProfileValidator.validateEmail(_emailCtrl.text);
    final pwErr = PasswordValidator.validateNewPassword(_passwordCtrl.text);
    final cfErr = PasswordValidator.validateConfirmPassword(
        _passwordCtrl.text, _confirmCtrl.text);

    setState(() {
      _firstNameError = fnErr;
      _lastNameError = lnErr;
      _emailError = emErr;
      _passwordError = pwErr;
      _confirmError = cfErr;
    });

    if ([fnErr, lnErr, emErr, pwErr, cfErr].any((e) => e != null)) return;

    setState(() => _formLoading = true);
    try {
      await ref.read(authProvider.notifier).signUpWithEmail(
            email: _emailCtrl.text.trim(),
            password: _passwordCtrl.text,
            firstName: _firstNameCtrl.text.trim(),
            lastName: _lastNameCtrl.text.trim(),
          );
    } catch (e) {
      if (mounted) {
        AppSnackbar.show(context, _friendlyError(e.toString()),
            isError: true);
      }
    } finally {
      if (mounted) setState(() => _formLoading = false);
    }
  }

  Future<void> _signUpWithGoogle() async {
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

  Future<void> _signUpWithApple() async {
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

  String _friendlyError(String raw) {
    if (raw.contains('already registered') ||
        raw.contains('already been registered')) {
      return 'An account with this email already exists.';
    }
    if (raw.contains('network') || raw.contains('socket')) {
      return 'No internet connection. Please try again.';
    }
    return 'Something went wrong. Please try again.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F7FF),
        elevation: 0,
        leading: Semantics(
          label: 'Back to Sign In',
          button: true,
          child: IconButton(
            icon: const Icon(BootstrapIcons.arrow_left,
                color: Color(0xFF1A1D2E)),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(28, 0, 28, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),

              // ── Headline ─────────────────────────────────────────────────
              const Text(
                'Create your account',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1A1D2E),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Join PlanPal and start managing your tasks.',
                style: TextStyle(
                    fontSize: AppSizes.fontBody, color: Colors.grey.shade500),
              ),
              const SizedBox(height: 24),

              // ── First + Last name ─────────────────────────────────────────
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _AuthField(
                      controller: _firstNameCtrl,
                      label: 'First Name',
                      hint: 'Alex',
                      icon: BootstrapIcons.person,
                      errorText: _firstNameError,
                      onChanged: (_) =>
                          setState(() => _firstNameError = null),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _AuthField(
                      controller: _lastNameCtrl,
                      label: 'Last Name',
                      hint: 'Morgan',
                      icon: BootstrapIcons.person,
                      errorText: _lastNameError,
                      onChanged: (_) =>
                          setState(() => _lastNameError = null),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ── Email ─────────────────────────────────────────────────────
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

              // ── Password ──────────────────────────────────────────────────
              _AuthField(
                controller: _passwordCtrl,
                label: 'Password',
                hint: 'Min. 8 characters',
                icon: BootstrapIcons.lock,
                obscureText: _obscurePassword,
                errorText: _passwordError,
                onChanged: (_) =>
                    setState(() => _passwordError = null),
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

              // ── Password strength bar ─────────────────────────────────────
              if (_passwordCtrl.text.isNotEmpty) ...[
                const SizedBox(height: 8),
                _PasswordStrength(password: _passwordCtrl.text),
              ],
              const SizedBox(height: 16),

              // ── Confirm password ──────────────────────────────────────────
              _AuthField(
                controller: _confirmCtrl,
                label: 'Confirm Password',
                hint: 'Re-enter your password',
                icon: BootstrapIcons.lock_fill,
                obscureText: _obscureConfirm,
                errorText: _confirmError,
                onChanged: (_) => setState(() => _confirmError = null),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirm
                        ? BootstrapIcons.eye
                        : BootstrapIcons.eye_slash,
                    size: AppSizes.iconSizeM,
                    color: Colors.grey.shade400,
                  ),
                  onPressed: () =>
                      setState(() => _obscureConfirm = !_obscureConfirm),
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

              // ── Create Account button ─────────────────────────────────────
              SizedBox(
                height: 54,
                child: ElevatedButton(
                  onPressed: _busy ? null : _createAccount,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor:
                        AppColors.primary.withOpacity(0.5),
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
                          'Create Account',
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
                label: 'Sign up with Google',
                icon: _GoogleLogo(),
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF1A1D2E),
                borderColor: AppColors.divider,
                loading: _googleLoading,
                enabled: !_busy,
                onTap: _signUpWithGoogle,
              ),
              const SizedBox(height: 12),

              // ── Apple ─────────────────────────────────────────────────────
              _SocialAuthButton(
                label: 'Sign up with Apple',
                icon: const Icon(BootstrapIcons.apple,
                    size: 22, color: Colors.white),
                backgroundColor: const Color(0xFF1A1D2E),
                foregroundColor: Colors.white,
                borderColor: Colors.transparent,
                loading: _appleLoading,
                enabled: !_busy,
                onTap: _signUpWithApple,
              ),
              const SizedBox(height: 28),

              // ── Already have account ──────────────────────────────────────
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Already have an account?  ',
                      style: TextStyle(
                          fontSize: AppSizes.fontBody,
                          color: Colors.grey.shade500),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: const Text(
                        'Sign In',
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
            fontSize: AppSizes.fontSmall,
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
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSizes.spaceM, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
              borderSide: BorderSide(
                  color: errorText != null
                      ? AppColors.error
                      : AppColors.divider),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
              borderSide: BorderSide(
                  color: errorText != null
                      ? AppColors.error
                      : AppColors.divider),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
              borderSide: BorderSide(
                color:
                    errorText != null ? AppColors.error : AppColors.primary,
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

class _PasswordStrength extends StatelessWidget {
  const _PasswordStrength({required this.password});
  final String password;

  int get _score {
    int s = 0;
    if (password.length >= 8) s++;
    if (password.length >= 12) s++;
    if (password.contains(RegExp(r'[A-Z]'))) s++;
    if (password.contains(RegExp(r'[0-9]'))) s++;
    if (password.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'))) s++;
    return s;
  }

  Color get _color {
    if (_score <= 1) return AppColors.error;
    if (_score <= 2) return AppColors.priorityMedium;
    if (_score <= 3) return const Color(0xFF3B82F6);
    return AppColors.success;
  }

  String get _label {
    if (_score <= 1) return 'Weak';
    if (_score <= 2) return 'Fair';
    if (_score <= 3) return 'Good';
    return 'Strong';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Strength: ',
                style: TextStyle(
                    fontSize: AppSizes.fontSmall,
                    color: Colors.grey.shade500)),
            Text(_label,
                style: TextStyle(
                    fontSize: AppSizes.fontSmall,
                    fontWeight: FontWeight.w700,
                    color: _color)),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: _score / 5,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(_color),
            minHeight: 5,
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
            color: showError
                ? AppColors.error.withOpacity(0.05)
                : Colors.white,
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
                      TextSpan(text: "I agree to PlanPal's "),
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
          child: Text('or',
              style: TextStyle(
                  fontSize: AppSizes.fontSmall,
                  color: Colors.grey.shade400,
                  fontWeight: FontWeight.w500)),
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
      canvas.drawArc(
          Rect.fromCircle(center: c, radius: r), seg.$2, seg.$3, true, p);
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
