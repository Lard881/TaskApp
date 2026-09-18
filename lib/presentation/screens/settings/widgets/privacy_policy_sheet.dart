import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';
import 'package:planpal/core/constants/app_colors.dart';
import 'package:planpal/core/constants/app_sizes.dart';

class PrivacyPolicySheet extends StatelessWidget {
  const PrivacyPolicySheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const PrivacyPolicySheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppSizes.radiusL),
        ),
      ),
      child: Column(
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      BootstrapIcons.shield_lock_fill,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Data & Privacy Policy',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: AppSizes.fontHeading,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(BootstrapIcons.x_lg, size: 18),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Content
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              children: const [
                _PolicySection(
                  title: '1. Overview',
                  body:
                      'PlanPal is committed to protecting your personal data and respect for user privacy. This policy details how we collect, use, and safeguard your information across your workspaces.',
                ),
                _PolicySection(
                  title: '2. Information We Collect',
                  body:
                      '• Account Profile: Your email address, name, and profile settings.\n• Workspace & Task Data: Tasks, deadlines, priorities, descriptions, and comments created by you or your team.\n• Device & Security: Biometric authentication tokens are handled strictly on-device by your operating system.',
                ),
                _PolicySection(
                  title: '3. Data Storage & Security',
                  body:
                      'All communications between your device and our cloud servers are encrypted using modern TLS 1.3 encryption. Your data is stored securely with industry-standard PostgreSQL row-level isolation and access controls.',
                ),
                _PolicySection(
                  title: '4. Data Sharing & Third Parties',
                  body:
                      'PlanPal does not sell, rent, or monetize your personal information or task data. Third-party integrations (such as cloud databases) are strictly utilized for operational hosting and authentication.',
                ),
                _PolicySection(
                  title: '5. Your Rights',
                  body:
                      'You have full control over your data. You may update your profile, export task data, or request account deletion at any time from the account settings.',
                ),
                _PolicySection(
                  title: '6. Contact Support',
                  body:
                      'If you have any questions or security disclosures, please reach out to privacy@planpal.app.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PolicySection extends StatelessWidget {
  const _PolicySection({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            body,
            style: TextStyle(
              fontSize: 13,
              height: 1.5,
              color: isDark
                  ? AppColors.darkOnSurfaceMuted
                  : AppColors.lightOnSurfaceMuted,
            ),
          ),
        ],
      ),
    );
  }
}
