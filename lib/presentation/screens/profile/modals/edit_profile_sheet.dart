import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:planpal/application/notifiers/user_notifier.dart';
import 'package:planpal/core/constants/app_sizes.dart';
import 'package:planpal/core/constants/app_strings.dart';
import 'package:planpal/core/validators/profile_validator.dart';
import 'package:planpal/domain/models/user.dart';
import 'package:planpal/presentation/widgets/app_snackbar.dart';

class EditProfileSheet extends ConsumerStatefulWidget {
  const EditProfileSheet({super.key, required this.user});
  final User user;

  @override
  ConsumerState<EditProfileSheet> createState() =>
      _EditProfileSheetState();
}

class _EditProfileSheetState
    extends ConsumerState<EditProfileSheet> {
  late final TextEditingController _firstNameCtrl;
  late final TextEditingController _lastNameCtrl;
  late final TextEditingController _roleCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _phoneCtrl;

  Map<String, String> _errors = {};

  @override
  void initState() {
    super.initState();
    _firstNameCtrl =
        TextEditingController(text: widget.user.firstName);
    _lastNameCtrl =
        TextEditingController(text: widget.user.lastName);
    _roleCtrl =
        TextEditingController(text: widget.user.role ?? '');
    _emailCtrl =
        TextEditingController(text: widget.user.email);
    _phoneCtrl =
        TextEditingController(text: widget.user.phone ?? '');
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _roleCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final errors = ProfileValidator.validateAll(
      firstName: _firstNameCtrl.text,
      lastName: _lastNameCtrl.text,
      email: _emailCtrl.text,
      role: _roleCtrl.text,
      phone: _phoneCtrl.text,
    );
    setState(() => _errors = errors);
    if (errors.isNotEmpty) return;

    try {
      final updated = widget.user.copyWith(
        firstName: _firstNameCtrl.text.trim(),
        lastName: _lastNameCtrl.text.trim(),
        role: _roleCtrl.text.trim().isEmpty
            ? null
            : _roleCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        phone: _phoneCtrl.text.trim().isEmpty
            ? null
            : _phoneCtrl.text.trim(),
        clearRole: _roleCtrl.text.trim().isEmpty,
        clearPhone: _phoneCtrl.text.trim().isEmpty,
      );
      await ref
          .read(currentUserProvider.notifier)
          .updateProfile(updated);
      if (mounted) {
        Navigator.of(context).pop();
        AppSnackbar.show(context, AppStrings.profileUpdated);
      }
    } catch (_) {
      if (mounted) {
        AppSnackbar.show(context, AppStrings.profileSaveFailed,
            isError: true);
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
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin:
                    const EdgeInsets.only(bottom: AppSizes.spaceM),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text('Edit Profile',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppSizes.spaceM),

            _field(
              controller: _firstNameCtrl,
              label: AppStrings.firstNameLabel,
              maxLength: 50,
              error: _errors['firstName'],
            ),
            const SizedBox(height: AppSizes.spaceM),
            _field(
              controller: _lastNameCtrl,
              label: AppStrings.lastNameLabel,
              maxLength: 50,
              error: _errors['lastName'],
            ),
            const SizedBox(height: AppSizes.spaceM),
            _field(
              controller: _roleCtrl,
              label: AppStrings.roleLabel,
              maxLength: 100,
              error: _errors['role'],
            ),
            const SizedBox(height: AppSizes.spaceM),
            _field(
              controller: _emailCtrl,
              label: AppStrings.emailLabel,
              maxLength: 254,
              keyboardType: TextInputType.emailAddress,
              error: _errors['email'],
            ),
            const SizedBox(height: AppSizes.spaceM),
            _field(
              controller: _phoneCtrl,
              label: AppStrings.phoneLabel,
              maxLength: 20,
              keyboardType: TextInputType.phone,
              error: _errors['phone'],
            ),
            const SizedBox(height: AppSizes.spaceM),

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

  Widget _field({
    required TextEditingController controller,
    required String label,
    required int maxLength,
    String? error,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      maxLength: maxLength,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        errorText: error,
      ),
    );
  }
}
