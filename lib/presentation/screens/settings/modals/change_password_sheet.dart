import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:planpal/application/notifiers/auth_notifier.dart';
import 'package:planpal/core/constants/app_sizes.dart';
import 'package:planpal/core/constants/app_strings.dart';
import 'package:planpal/core/validators/password_validator.dart';
import 'package:planpal/presentation/widgets/app_snackbar.dart';

/// Change Password sheet — wired to supabase.auth.updateUser().
///
/// Since the user is already signed in, we only need the new password
/// and confirmation. We skip "current password" verification because
/// Supabase handles session-based auth and doesn't expose a
/// re-authenticate endpoint in the client SDK without re-login.
///
/// If you want stricter re-auth, trigger a re-login flow before
/// opening this sheet (Phase 3 enhancement).
class ChangePasswordSheet extends ConsumerStatefulWidget {
  const ChangePasswordSheet({super.key});

  @override
  ConsumerState<ChangePasswordSheet> createState() =>
      _ChangePasswordSheetState();
}

class _ChangePasswordSheetState
    extends ConsumerState<ChangePasswordSheet> {
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _obscureNew = true;
  bool _obscureConfirm = true;
  String? _newError;
  String? _confirmError;
  bool _loading = false;

  @override
  void dispose() {
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    // Validate new password length
    final newErr =
        PasswordValidator.validateNewPassword(_newCtrl.text);
    // Validate passwords match
    final cfErr = PasswordValidator.validateConfirmPassword(
        _newCtrl.text, _confirmCtrl.text);

    setState(() {
      _newError = newErr;
      _confirmError = cfErr;
    });

    if (newErr != null || cfErr != null) return;

    setState(() => _loading = true);

    try {
      await ref
          .read(authProvider.notifier)
          .updatePassword(_newCtrl.text);

      if (mounted) {
        Navigator.of(context).pop();
        AppSnackbar.show(context, AppStrings.passwordChanged);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        final msg = e.toString().contains('same password')
            ? 'New password must be different from your current one.'
            : AppStrings.passwordSaveFailed;
        AppSnackbar.show(context, msg, isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(AppSizes.spaceM, AppSizes.spaceM,
          AppSizes.spaceM, bottom + AppSizes.spaceM),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: AppSizes.spaceM),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            Text(AppStrings.changePassword,
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(
              'Enter your new password below.',
              style: TextStyle(
                  fontSize: AppSizes.fontSmall,
                  color: Colors.grey.shade500),
            ),
            const SizedBox(height: AppSizes.spaceL),

            // New password
            TextField(
              controller: _newCtrl,
              obscureText: _obscureNew,
              onChanged: (_) => setState(() => _newError = null),
              decoration: InputDecoration(
                labelText: AppStrings.newPassword,
                errorText: _newError,
                suffixIcon: IconButton(
                  icon: Icon(_obscureNew
                      ? BootstrapIcons.eye
                      : BootstrapIcons.eye_slash),
                  onPressed: () =>
                      setState(() => _obscureNew = !_obscureNew),
                ),
              ),
            ),
            const SizedBox(height: AppSizes.spaceM),

            // Confirm password
            TextField(
              controller: _confirmCtrl,
              obscureText: _obscureConfirm,
              onChanged: (_) => setState(() => _confirmError = null),
              decoration: InputDecoration(
                labelText: AppStrings.confirmPassword,
                errorText: _confirmError,
                suffixIcon: IconButton(
                  icon: Icon(_obscureConfirm
                      ? BootstrapIcons.eye
                      : BootstrapIcons.eye_slash),
                  onPressed: () =>
                      setState(() => _obscureConfirm = !_obscureConfirm),
                ),
              ),
            ),
            const SizedBox(height: AppSizes.spaceL),

            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: _loading
                        ? null
                        : () => Navigator.of(context).pop(),
                    child: const Text(AppStrings.cancel),
                  ),
                ),
                const SizedBox(width: AppSizes.spaceS),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _save,
                    child: _loading
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white))
                        : const Text(AppStrings.save),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
