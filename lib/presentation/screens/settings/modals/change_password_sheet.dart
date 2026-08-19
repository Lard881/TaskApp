import 'package:flutter/material.dart';
import 'package:planpal/core/constants/app_sizes.dart';
import 'package:planpal/core/constants/app_strings.dart';
import 'package:planpal/core/validators/password_validator.dart';
import 'package:planpal/presentation/widgets/app_snackbar.dart';

class ChangePasswordSheet extends StatefulWidget {
  const ChangePasswordSheet({super.key});

  @override
  State<ChangePasswordSheet> createState() => _ChangePasswordSheetState();
}

class _ChangePasswordSheetState extends State<ChangePasswordSheet> {
  final _currentCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  Map<String, String> _errors = {};

  // Phase 1 mock stored password
  static const String _storedPassword = 'Password123';

  @override
  void dispose() {
    _currentCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  void _save() {
    final errors = PasswordValidator.validateAll(
      currentPassword: _currentCtrl.text,
      storedPassword: _storedPassword,
      newPassword: _newCtrl.text,
      confirmPassword: _confirmCtrl.text,
    );
    setState(() => _errors = errors);
    if (errors.isNotEmpty) return;
    Navigator.of(context).pop();
    AppSnackbar.show(context, AppStrings.passwordChanged);
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(
          AppSizes.spaceM, AppSizes.spaceM, AppSizes.spaceM, bottom + AppSizes.spaceM),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40, height: 4,
                margin: const EdgeInsets.only(bottom: AppSizes.spaceM),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(AppStrings.changePassword,
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppSizes.spaceM),

            // Current password
            TextField(
              controller: _currentCtrl,
              obscureText: _obscureCurrent,
              decoration: InputDecoration(
                labelText: AppStrings.currentPassword,
                errorText: _errors['currentPassword'],
                suffixIcon: IconButton(
                  icon: Icon(_obscureCurrent
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined),
                  onPressed: () =>
                      setState(() => _obscureCurrent = !_obscureCurrent),
                ),
              ),
            ),
            const SizedBox(height: AppSizes.spaceM),

            // New password
            TextField(
              controller: _newCtrl,
              obscureText: _obscureNew,
              decoration: InputDecoration(
                labelText: AppStrings.newPassword,
                errorText: _errors['newPassword'],
                suffixIcon: IconButton(
                  icon: Icon(_obscureNew
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined),
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
              decoration: InputDecoration(
                labelText: AppStrings.confirmPassword,
                errorText: _errors['confirmPassword'],
                suffixIcon: IconButton(
                  icon: Icon(_obscureConfirm
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined),
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
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text(AppStrings.cancel),
                  ),
                ),
                const SizedBox(width: AppSizes.spaceS),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _save,
                    child: const Text(AppStrings.save),
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
