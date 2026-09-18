import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';
import 'package:planpal/core/constants/app_sizes.dart';
import 'package:planpal/core/constants/app_strings.dart';
import 'package:planpal/infrastructure/services/biometric_service.dart';
import 'package:planpal/presentation/screens/settings/modals/change_password_sheet.dart';
import 'package:planpal/presentation/screens/settings/widgets/privacy_policy_sheet.dart';
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
            onTap: () => showModalBottomSheet<void>(
              context: context,
              isScrollControlled: true,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(AppSizes.radiusL),
                ),
              ),
              builder: (_) => const ChangePasswordSheet(),
            ),
          ),
          _BiometricToggle(),
          SettingsListItem(
            icon: BootstrapIcons.file_text,
            label: AppStrings.dataPrivacyPolicy,
            onTap: () => PrivacyPolicySheet.show(context),
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
  bool _loading = true;
  final BiometricService _biometricService = BiometricService();

  @override
  void initState() {
    super.initState();
    _loadBiometricStatus();
  }

  Future<void> _loadBiometricStatus() async {
    final isEnabled = await _biometricService.isBiometricEnabled();
    if (mounted) {
      setState(() {
        _enabled = isEnabled;
        _loading = false;
      });
    }
  }

  Future<void> _toggleBiometric(bool value) async {
    if (value) {
      // Enable biometric
      final canCheck = await _biometricService.canCheckBiometrics();
      if (!canCheck) {
        if (mounted) {
          AppSnackbar.show(
            context,
            'Biometric authentication not available on this device',
            isError: true,
          );
        }
        return;
      }

      // Check if credentials are already stored
      final storedCreds = await _biometricService.getStoredCredentials();
      
      if (storedCreds != null) {
        // Credentials exist, just authenticate to re-enable
        final authenticated = await _biometricService.authenticate(
          reason: 'Authenticate to enable biometric login',
        );

        if (!authenticated) {
          if (mounted) {
            AppSnackbar.show(
              context,
              'Authentication cancelled',
              isError: true,
            );
          }
          return;
        }

        // Re-enable with existing credentials
        await _biometricService.enableBiometricLogin(
          email: storedCreds['email']!,
          password: storedCreds['password']!,
        );

        if (mounted) {
          setState(() => _enabled = true);
          AppSnackbar.show(context, 'Biometric login enabled');
        }
      } else {
        // No stored credentials - need to enter them
        final credentials = await _showCredentialsDialog();
        if (credentials == null) return;

        // Authenticate first to confirm
        final authenticated = await _biometricService.authenticate(
          reason: 'Authenticate to enable biometric login',
        );

        if (!authenticated) {
          if (mounted) {
            AppSnackbar.show(
              context,
              'Authentication cancelled',
              isError: true,
            );
          }
          return;
        }

        // Enable biometric with new credentials
        await _biometricService.enableBiometricLogin(
          email: credentials['email']!,
          password: credentials['password']!,
        );

        if (mounted) {
          setState(() => _enabled = true);
          AppSnackbar.show(context, 'Biometric login enabled');
        }
      }
    } else {
      // Disable biometric - authenticate first to confirm
      final authenticated = await _biometricService.authenticate(
        reason: 'Authenticate to disable biometric login',
      );

      if (!authenticated) {
        if (mounted) {
          AppSnackbar.show(
            context,
            'Authentication cancelled',
            isError: true,
          );
        }
        return;
      }

      await _biometricService.disableBiometricLogin();
      if (mounted) {
        setState(() => _enabled = false);
        AppSnackbar.show(context, 'Biometric login disabled');
      }
    }
  }

  Future<Map<String, String>?> _showCredentialsDialog() async {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    return showDialog<Map<String, String>>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Enter Your Credentials'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'To enable biometric login, please enter your email and password.',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (emailController.text.isEmpty ||
                  passwordController.text.isEmpty) {
                AppSnackbar.show(ctx, 'Please fill all fields', isError: true);
                return;
              }
              Navigator.of(ctx).pop({
                'email': emailController.text.trim(),
                'password': passwordController.text,
              });
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const ListTile(
        leading: Icon(BootstrapIcons.fingerprint),
        title: Text('Biometric Login'),
        trailing: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    return Semantics(
      label: 'Biometric login toggle',
      child: SwitchListTile(
        secondary: const Icon(
          BootstrapIcons.fingerprint,
          size: AppSizes.iconSizeL,
        ),
        title: const Text(
          AppStrings.biometricLogin,
          style: TextStyle(
            fontSize: AppSizes.fontBody,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: _enabled
            ? const Text('Enabled', style: TextStyle(fontSize: 12))
            : const Text('Disabled', style: TextStyle(fontSize: 12)),
        value: _enabled,
        onChanged: _toggleBiometric,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSizes.spaceM,
          vertical: AppSizes.spaceXS,
        ),
      ),
    );
  }
}
