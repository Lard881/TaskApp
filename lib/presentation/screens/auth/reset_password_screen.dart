import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:planpal/application/notifiers/auth_notifier.dart';
import 'package:planpal/core/constants/app_colors.dart';
import 'package:planpal/core/constants/app_sizes.dart';
import 'package:planpal/infrastructure/repositories/api_auth_repository.dart';
import 'package:planpal/presentation/widgets/app_snackbar.dart';

/// Reset Password screen - User lands here from email link with token
class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({
    super.key,
    required this.token,
  });

  final String token;

  @override
  ConsumerState<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  String? _passwordError;
  String? _confirmError;
  bool _loading = false;
  bool _success = false;

  @override
  void dispose() {
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _passwordError = null;
      _confirmError = null;
    });

    // Validate
    if (_passwordCtrl.text.isEmpty) {
      setState(() => _passwordError = 'Password is required');
      return;
    }

    if (_passwordCtrl.text.length < 6) {
      setState(() => _passwordError = 'Password must be at least 6 characters');
      return;
    }

    if (_confirmPasswordCtrl.text.isEmpty) {
      setState(() => _confirmError = 'Please confirm your password');
      return;
    }

    if (_passwordCtrl.text != _confirmPasswordCtrl.text) {
      setState(() => _confirmError = 'Passwords do not match');
      return;
    }

    setState(() => _loading = true);

    try {
      // Call reset password with token through auth provider
      await ref.read(authProvider.notifier).resetPasswordWithToken(
        token: widget.token,
        newPassword: _passwordCtrl.text,
      );

      if (mounted) {
        setState(() {
          _loading = false;
          _success = true;
        });
        AppSnackbar.show(
          context,
          'Password reset successful! You can now sign in.',
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        AppSnackbar.show(
          context,
          e.toString().replaceAll('Exception: ', ''),
          isError: true,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (_success) {
      return _buildSuccessView(isDark);
    }

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            BootstrapIcons.arrow_left,
            color: isDark ? AppColors.darkOnSurface : AppColors.lightOnSurface,
          ),
          onPressed: () => context.go('/login'),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),

              // Icon
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    BootstrapIcons.shield_lock,
                    color: AppColors.primary,
                    size: 36,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Title
              Text(
                'Create New Password',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: isDark ? AppColors.darkOnSurface : AppColors.lightOnSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your new password must be different from your previous password',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: AppSizes.fontBody,
                  color: isDark ? AppColors.darkOnSurfaceMuted : Colors.grey.shade500,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),

              // New Password
              _buildPasswordField(
                label: 'New Password',
                controller: _passwordCtrl,
                obscureText: _obscurePassword,
                errorText: _passwordError,
                onToggle: () => setState(() => _obscurePassword = !_obscurePassword),
                isDark: isDark,
              ),
              const SizedBox(height: 16),

              // Confirm Password
              _buildPasswordField(
                label: 'Confirm Password',
                controller: _confirmPasswordCtrl,
                obscureText: _obscureConfirm,
                errorText: _confirmError,
                onToggle: () => setState(() => _obscureConfirm = !_obscureConfirm),
                isDark: isDark,
              ),
              const SizedBox(height: 32),

              // Submit Button
              SizedBox(
                height: 54,
                child: ElevatedButton(
                  onPressed: _loading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusM),
                    ),
                    elevation: 0,
                  ),
                  child: _loading
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Reset Password',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required bool obscureText,
    required String? errorText,
    required VoidCallback onToggle,
    required bool isDark,
  }) {
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
          obscureText: obscureText,
          onChanged: (_) => setState(() {
            _passwordError = null;
            _confirmError = null;
          }),
          style: TextStyle(
            fontSize: AppSizes.fontBody,
            color: isDark ? AppColors.darkOnSurface : AppColors.lightOnSurface,
          ),
          decoration: InputDecoration(
            hintText: '••••••••',
            hintStyle: TextStyle(
              color: isDark ? AppColors.darkOnSurfaceMuted : Colors.grey.shade400,
              fontSize: AppSizes.fontBody,
            ),
            prefixIcon: Icon(
              BootstrapIcons.lock,
              size: AppSizes.iconSizeM,
              color: errorText != null ? AppColors.error : Colors.grey.shade400,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                obscureText ? BootstrapIcons.eye : BootstrapIcons.eye_slash,
                size: AppSizes.iconSizeM,
                color: Colors.grey.shade400,
              ),
              onPressed: onToggle,
            ),
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

  Widget _buildSuccessView(bool isDark) {
    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Success Icon
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    BootstrapIcons.check_circle_fill,
                    color: AppColors.success,
                    size: 40,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Title
              Text(
                'Password Reset!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: isDark ? AppColors.darkOnSurface : AppColors.lightOnSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your password has been successfully reset. You can now sign in with your new password.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: AppSizes.fontBody,
                  color: isDark ? AppColors.darkOnSurfaceMuted : Colors.grey.shade500,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 32),

              // Back to Login Button
              SizedBox(
                height: 54,
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
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
