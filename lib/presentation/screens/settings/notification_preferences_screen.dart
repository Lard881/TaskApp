import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:planpal/application/notifiers/preferences_notifier.dart';
import 'package:planpal/core/constants/app_sizes.dart';
import 'package:planpal/core/constants/app_strings.dart';
import 'package:planpal/presentation/widgets/app_snackbar.dart';

class NotificationPreferencesScreen extends ConsumerWidget {
  const NotificationPreferencesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(preferencesProvider).valueOrNull;

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.notificationPreferences)),
      body: prefs == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                _NotifToggle(
                  label: AppStrings.taskReminders,
                  icon: BootstrapIcons.bell_fill,
                  value: prefs.notifyTaskReminders,
                  onChanged: (v) async {
                    try {
                      await ref.read(preferencesProvider.notifier).setTaskReminders(v);
                    } catch (_) {
                      if (context.mounted) {
                        AppSnackbar.show(context, AppStrings.prefSaveFailed, isError: true);
                      }
                    }
                  },
                ),
                _NotifToggle(
                  label: AppStrings.dueDateAlerts,
                  icon: BootstrapIcons.calendar_event,
                  value: prefs.notifyDueDateAlerts,
                  onChanged: (v) async {
                    try {
                      await ref.read(preferencesProvider.notifier).setDueDateAlerts(v);
                    } catch (_) {
                      if (context.mounted) {
                        AppSnackbar.show(context, AppStrings.prefSaveFailed, isError: true);
                      }
                    }
                  },
                ),
                _NotifToggle(
                  label: AppStrings.chatMessages,
                  icon: BootstrapIcons.chat_dots,
                  value: prefs.notifyChatMessages,
                  onChanged: (v) async {
                    try {
                      await ref.read(preferencesProvider.notifier).setChatMessages(v);
                    } catch (_) {
                      if (context.mounted) {
                        AppSnackbar.show(context, AppStrings.prefSaveFailed, isError: true);
                      }
                    }
                  },
                ),
                _NotifToggle(
                  label: AppStrings.weeklySummary,
                  icon: BootstrapIcons.graph_up,
                  value: prefs.notifyWeeklySummary,
                  onChanged: (v) async {
                    try {
                      await ref.read(preferencesProvider.notifier).setWeeklySummary(v);
                    } catch (_) {
                      if (context.mounted) {
                        AppSnackbar.show(context, AppStrings.prefSaveFailed, isError: true);
                      }
                    }
                  },
                ),
              ],
            ),
    );
  }
}

class _NotifToggle extends StatelessWidget {
  const _NotifToggle({
    required this.label,
    required this.icon,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final IconData icon;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$label toggle',
      child: SwitchListTile(
        secondary: Icon(icon, size: AppSizes.iconSizeL),
        title: Text(
          label,
          style: const TextStyle(fontSize: AppSizes.fontBody, fontWeight: FontWeight.w500),
        ),
        value: value,
        onChanged: onChanged,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSizes.spaceM,
          vertical: AppSizes.spaceXS,
        ),
      ),
    );
  }
}
