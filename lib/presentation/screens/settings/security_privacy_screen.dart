import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';
import 'package:planpal/core/constants/app_sizes.dart';
import 'package:planpal/core/constants/app_strings.dart';
import 'package:planpal/presentation/screens/settings/modals/change_password_sheet.dart';
import 'package:planpal/presentation/widgets/app_snackbar.dart';
import 'package:planpal/presentation/widgets/settings_list_item.dart';

class SecurityPrivacyScreen extends StatelessWidget {
  const SecurityPrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.securityPrivacy)),
      body: ListView(
        children: [
          SettingsListItem(
            icon: BootstrapIcons.shield_lock,
            label: AppStrings.changePassword,
            onTap: () => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(
                    top: Radius.circular(AppSizes.radiusL)),
              ),
              builder: (_) => const ChangePasswordSheet(),
            ),
          ),
          _BiometricToggle(),
          SettingsListItem(
            icon: BootstrapIcons.file_text,
            label: AppStrings.dataPrivacyPolicy,
            onTap: () => AppSnackbar.show(context, AppStrings.comingSoon),
          ),
        ],
      ),
    );
  }
}

class _BiometricToggle extends StatefulWidget {
  @override
  State<_BiometricToggle> createState() => _BiometricToggleState();
}

class _BiometricToggleState extends State<_BiometricToggle> {
  bool _enabled = false;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Biometric login toggle',
      child: SwitchListTile(
        secondary: const Icon(BootstrapIcons.fingerprint, size: AppSizes.iconSizeL),
        title: const Text(
          AppStrings.biometricLogin,
          style: TextStyle(fontSize: AppSizes.fontBody, fontWeight: FontWeight.w500),
        ),
        value: _enabled,
        onChanged: (v) => setState(() => _enabled = v),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSizes.spaceM,
          vertical: AppSizes.spaceXS,
        ),
      ),
    );
  }
}
