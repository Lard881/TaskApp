import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:planpal/application/notifiers/auth_notifier.dart';
import 'package:planpal/application/notifiers/preferences_notifier.dart';
import 'package:planpal/application/notifiers/user_notifier.dart';
import 'package:planpal/core/constants/app_colors.dart';
import 'package:planpal/core/constants/app_sizes.dart';
import 'package:planpal/core/constants/app_strings.dart';
import 'package:planpal/presentation/widgets/app_snackbar.dart';
import 'package:planpal/presentation/widgets/avatar_widget.dart';
import 'package:planpal/presentation/widgets/confirmation_dialog.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider).valueOrNull;
    final prefs = ref.watch(preferencesProvider).valueOrNull;

    // Derive display values for inline badges
    final themeName = _themeName(prefs?.themeMode ?? ThemeMode.light);
    final langName = _langName(prefs?.languageCode ?? 'en');
    final notifOn = prefs?.notifyTaskReminders ?? true;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FF),
      body: SafeArea(
        child: Column(
          children: [
            // ── Top bar ───────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text('P',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 16)),
                  ),
                  const SizedBox(width: 8),
                  const Text('PlanPal',
                      style: TextStyle(
                          fontWeight: FontWeight.w800, fontSize: 18)),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(BootstrapIcons.bell),
                    onPressed: () {},
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 12),
                  AvatarWidget(
                    initials: user?.initials ?? 'U',
                    imagePath: user?.avatarPath,
                    diameter: 36,
                  ),
                ],
              ),
            ),

            // ── Title ─────────────────────────────────────────────────────
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Settings',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1A1D2E),
                  ),
                ),
              ),
            ),

            // ── Scrollable list ───────────────────────────────────────────
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  // Account Settings
                  _SectionLabel('ACCOUNT SETTINGS'),
                  _SettingsCard(children: [
                    _SettingsRow(
                      icon: BootstrapIcons.person,
                      label: AppStrings.personalProfile,
                      onTap: () => context.go('/profile'),
                    ),
                    _divider(),
                    _SettingsRow(
                      icon: BootstrapIcons.bell,
                      label: AppStrings.notificationPreferences,
                      badgeText: notifOn ? 'On' : 'Off',
                      badgeColor: notifOn
                          ? AppColors.success
                          : Colors.grey,
                      onTap: () =>
                          context.go('/settings/notifications'),
                    ),
                    _divider(),
                    _SettingsRow(
                      icon: BootstrapIcons.shield_lock,
                      label: AppStrings.securityPrivacy,
                      onTap: () =>
                          context.go('/settings/security'),
                    ),
                  ]),

                  const SizedBox(height: 20),

                  // Preferences
                  _SectionLabel('PREFERENCES'),
                  _SettingsCard(children: [
                    _SettingsRow(
                      icon: BootstrapIcons.palette,
                      label: AppStrings.interfaceTheme,
                      badgeText: themeName,
                      onTap: () => _showThemeModal(context, ref),
                    ),
                    _divider(),
                    _SettingsRow(
                      icon: BootstrapIcons.translate,
                      label: AppStrings.appLanguage,
                      badgeText: langName,
                      onTap: () =>
                          context.go('/settings/language'),
                    ),
                    _divider(),
                    _SettingsRow(
                      icon: BootstrapIcons.globe,
                      label: AppStrings.timeZone,
                      onTap: () =>
                          context.go('/settings/timezone'),
                    ),
                  ]),

                  const SizedBox(height: 20),

                  // Support & Legals
                  _SectionLabel('SUPPORT & LEGALS'),
                  _SettingsCard(children: [
                    _SettingsRow(
                      icon: BootstrapIcons.question_circle,
                      label: AppStrings.helpSupport,
                      onTap: () => context.go('/settings/help'),
                    ),
                    _divider(),
                    _SettingsRow(
                      icon: BootstrapIcons.info_circle,
                      label: 'About PlanPal v2.4',
                      onTap: () =>
                          context.go('/settings/about'),
                    ),
                    _divider(),
                    _SettingsRow(
                      icon: BootstrapIcons.star,
                      label: AppStrings.rateOurApp,
                      onTap: () => AppSnackbar.show(
                          context, AppStrings.comingSoon),
                    ),
                  ]),

                  const SizedBox(height: 24),

                  // Log out button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton.icon(
                      icon: const Icon(BootstrapIcons.box_arrow_right,
                          color: AppColors.logOutRed),
                      label: const Text(
                        '⊣  Log Out Account',
                        style: TextStyle(
                          color: AppColors.logOutRed,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                            color: AppColors.logOutRed,
                            width: 1.5),
                        backgroundColor:
                            AppColors.logOutRed.withOpacity(0.05),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => _confirmLogOut(context, ref),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _themeName(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System';
    }
  }

  static String _langName(String code) {
    const map = {
      'en': 'English',
      'es': 'Spanish',
      'fr': 'French',
      'de': 'German',
      'pt': 'Portuguese',
    };
    return map[code] ?? code;
  }

  void _showThemeModal(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const _ThemeModal(),
    );
  }

  void _confirmLogOut(BuildContext context, WidgetRef ref) {
    ConfirmationDialog.show(
      context: context,
      title: AppStrings.logOut,
      body: AppStrings.logOutConfirm,
      confirmLabel: AppStrings.logOut,
      isDestructive: true,
      onConfirm: () async {
        await ref.read(authProvider.notifier).signOut();
        // Router redirect handles navigation to /login automatically
      },
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

Widget _divider() => const Divider(height: 1, indent: 48);

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Colors.grey.shade500,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.badgeText,
    this.badgeColor,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final String? badgeText;
  final Color? badgeColor;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      button: true,
      child: ListTile(
        leading: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: AppColors.primary),
        ),
        title: Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF1A1D2E),
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (badgeText != null)
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: (badgeColor ?? AppColors.primary)
                      .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  badgeText!,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: badgeColor ?? AppColors.primary,
                  ),
                ),
              ),
            if (badgeText != null) const SizedBox(width: 6),
            Icon(BootstrapIcons.chevron_right,
                color: Colors.grey.shade400, size: 20),
          ],
        ),
        onTap: onTap,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        minVerticalPadding: 8,
      ),
    );
  }
}

// ── Theme modal ───────────────────────────────────────────────────────────────

class _ThemeModal extends ConsumerWidget {
  const _ThemeModal();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref
            .watch(preferencesProvider)
            .valueOrNull
            ?.themeMode ??
        ThemeMode.light;

    return Padding(
      padding: const EdgeInsets.all(AppSizes.spaceM),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppStrings.interfaceTheme,
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSizes.spaceM),
          _option(context, ref, current, ThemeMode.light,
              AppStrings.themeLight, BootstrapIcons.sun),
          _option(context, ref, current, ThemeMode.dark,
              AppStrings.themeDark, BootstrapIcons.moon),
          _option(context, ref, current, ThemeMode.system,
              AppStrings.themeSystem, BootstrapIcons.display),
          const SizedBox(height: AppSizes.spaceM),
        ],
      ),
    );
  }

  Widget _option(
    BuildContext context,
    WidgetRef ref,
    ThemeMode current,
    ThemeMode mode,
    String label,
    IconData icon,
  ) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      trailing: current == mode
          ? const Icon(BootstrapIcons.check2, color: AppColors.primary)
          : null,
      onTap: () async {
        await ref
            .read(preferencesProvider.notifier)
            .setTheme(mode);
        if (context.mounted) Navigator.of(context).pop();
      },
      contentPadding: EdgeInsets.zero,
    );
  }
}
