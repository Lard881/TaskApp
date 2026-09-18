import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:planpal/application/notifiers/auth_notifier.dart';
import 'package:planpal/core/constants/app_colors.dart';
import 'package:planpal/core/constants/app_sizes.dart';

/// Set new password screen after code verification
class SetNewPasswordScreen extends ConsumerStatefulWidget {
  final String email;
  final String code;

  const SetNewPasswordScreen({
    super.key,
    required this.email,
    required this.code,
  });

  @override
  ConsumerState<SetNewPasswordScreen> createState() =>
      _SetNewPasswordScreenState();
}

class _SetNewPasswordScreenState extends ConsumerState<SetNewPasswordScreen> {
  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _loading = false;
  String? _passwordError;
  String? _confirmError;

  @override
  void dispose() {
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  String? _validatePassword(String password) {
    if (password.isEmpty) return 'Password is required';
    if (password.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  String? _validateConfirmPassword(String confirm) {
    if (confirm.isEmpty) return 'Please confirm your password';
    if (confirm != _passwordCtrl.text) return 'Passwords do not match';
    return null;
  }

  Future<void> _submit() async {
    final passErr = _validatePassword(_passwordCtrl.text);
    final confirmErr = _validateConfirmPassword(_confirmPasswordCtrl.text);

    setState(() {
      _passwordError = passErr;
      _confirmError = confirmErr;
    });

    if (passErr != null || confirmErr != null) return;

    setState(() => _loading = true);

    try {
      print('🔵 Resetting password for: ${widget.email}');
      await ref.read(authProvider.notifier).resetPasswordWithCode(
            widget.email,
            widget.code,
            _passwordCtrl.text.trim(),
          );

      print('✅ Password reset successful');
      if (context.mounted) {
        // Show success and navigate to login
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password updated successfully! You can now sign in.'),
            backgroundColor: AppColors.success,
            duration: Duration(seconds: 3),
          ),
        );
        context.go('/login');
      }
    } catch (e) {
      print('❌ Reset password error: $e');
      if (context.mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppColors.error,
          ),
        );
      }
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.spaceXL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSizes.spaceL),

              // ── Icon illustration ────────────────────────────────────────
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    BootstrapIcons.lock_fill,
                    color: AppColors.primary,
                    size: 36,
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.spaceL),

              // ── Headline ─────────────────────────────────────────────────
              const Text(
                'Set new password',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1A1D2E),
                ),
              ),
              const SizedBox(height: AppSizes.spaceS),
              Text(
                'Enter your new password below',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: AppSizes.fontBody,
                  color: Colors.grey.shade500,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: AppSizes.spaceXL),

              // ── New password field ───────────────────────────────────────
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'New password',
                    style: TextStyle(
                      fontSize: AppSizes.fontBody,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1D2E),
                    ),
                  ),
                  const SizedBox(height: AppSizes.spaceXS),
                  TextField(
                    controller: _passwordCtrl,
                    obscureText: _obscurePassword,
                    onChanged: (_) => setState(() => _passwordError = null),
                    style: const TextStyle(
                      fontSize: AppSizes.fontBody,
                      color: Color(0xFF1A1D2E),
                    ),
                    decoration: InputDecoration(
                      hintText: 'Enter new password',
                      hintStyle: TextStyle(color: Colors.grey.shade400),
                      prefixIcon: Icon(
                        BootstrapIcons.lock,
                        size: AppSizes.iconSizeM,
                        color: _passwordError != null
                            ? AppColors.error
                            : Colors.grey.shade400,
                      ),
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
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.spaceM,
                        vertical: 14,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppSizes.radiusM),
                        borderSide: BorderSide(
                          color: _passwordError != null
                              ? AppColors.error
                              : AppColors.divider,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppSizes.radiusM),
                        borderSide: BorderSide(
                          color: _passwordError != null
                              ? AppColors.error
                              : AppColors.divider,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppSizes.radiusM),
                        borderSide: BorderSide(
                          color: _passwordError != null
                              ? AppColors.error
                              : AppColors.primary,
                          width: 2,
                        ),
                      ),
                      errorText: _passwordError,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.spaceM),

              // ── Confirm password field ───────────────────────────────────
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Confirm password',
                    style: TextStyle(
                      fontSize: AppSizes.fontBody,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1D2E),
                    ),
                  ),
                  const SizedBox(height: AppSizes.spaceXS),
                  TextField(
                    controller: _confirmPasswordCtrl,
                    obscureText: _obscureConfirm,
                    onChanged: (_) => setState(() => _confirmError = null),
                    style: const TextStyle(
                      fontSize: AppSizes.fontBody,
                      color: Color(0xFF1A1D2E),
                    ),
                    decoration: InputDecoration(
                      hintText: 'Re-enter new password',
                      hintStyle: TextStyle(color: Colors.grey.shade400),
                      prefixIcon: Icon(
                        BootstrapIcons.lock_fill,
                        size: AppSizes.iconSizeM,
                        color: _confirmError != null
                            ? AppColors.error
                            : Colors.grey.shade400,
                      ),
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
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.spaceM,
                        vertical: 14,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppSizes.radiusM),
                        borderSide: BorderSide(
                          color: _confirmError != null
                              ? AppColors.error
                              : AppColors.divider,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppSizes.radiusM),
                        borderSide: BorderSide(
                          color: _confirmError != null
                              ? AppColors.error
                              : AppColors.divider,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppSizes.radiusM),
                        borderSide: BorderSide(
                          color: _confirmError != null
                              ? AppColors.error
                              : AppColors.primary,
                          width: 2,
                        ),
                      ),
                      errorText: _confirmError,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.spaceXL),

              // ── Submit button ────────────────────────────────────────────
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _loading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusM),
                    ),
                    elevation: 0,
                  ),
                  child: _loading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
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
}
