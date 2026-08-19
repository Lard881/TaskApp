import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:planpal/application/notifiers/conversation_notifier.dart';
import 'package:planpal/application/notifiers/task_notifier.dart';
import 'package:planpal/application/notifiers/user_notifier.dart';
import 'package:planpal/core/constants/app_colors.dart';
import 'package:planpal/core/constants/app_sizes.dart';
import 'package:planpal/core/constants/app_strings.dart';
import 'package:planpal/presentation/screens/profile/modals/edit_profile_sheet.dart';
import 'package:planpal/presentation/widgets/activity_item_widget.dart';
import 'package:planpal/presentation/widgets/app_snackbar.dart';
import 'package:planpal/presentation/widgets/avatar_widget.dart';
import 'package:planpal/presentation/widgets/empty_state_widget.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);
    final activityAsync = ref.watch(recentActivityProvider);
    final metrics = ref.watch(performanceProvider);
    final user = userAsync.valueOrNull;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FF),
      body: SafeArea(
        child: userAsync.when(
          loading: () =>
              const Center(child: CircularProgressIndicator()),
          error: (_, __) =>
              const Center(child: Text('Could not load profile.')),
          data: (_) => SingleChildScrollView(
            child: Column(
              children: [
                // ── Top bar ──────────────────────────────────────────────
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
                              fontWeight: FontWeight.w800,
                              fontSize: 18)),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.notifications_outlined),
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

                const SizedBox(height: 24),

                // ── Avatar with edit badge ────────────────────────────────
                Stack(
                  children: [
                    AvatarWidget(
                      initials: user?.initials ?? 'U',
                      imagePath: user?.avatarPath,
                      diameter: AppSizes.avatarLarge,
                      semanticLabel: 'Change avatar',
                      onTap: () => _pickAvatar(context, ref),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () => _pickAvatar(context, ref),
                        child: Container(
                          width: 26,
                          height: 26,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: Colors.white, width: 2),
                          ),
                          child: const Icon(Icons.edit,
                              color: Colors.white, size: 12),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Name
                Text(
                  user?.fullName ?? '',
                  style: const TextStyle(
                    fontSize: AppSizes.fontHeading,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1D2E),
                  ),
                ),

                if (user?.role != null && user!.role!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    user.role!,
                    style: TextStyle(
                      fontSize: AppSizes.fontBody,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],

                const SizedBox(height: 24),

                // ── Stats row ─────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          value: '${metrics.completed}',
                          label: AppStrings.tasksCompleted,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: _StatCard(
                          value: '6',
                          label: AppStrings.activeProjects,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: _StatCard(
                          value: '14',
                          label: AppStrings.teamMembers,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // ── Recent activity ───────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      AppStrings.recentActivity,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1D2E),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                activityAsync.when(
                  loading: () =>
                      const CircularProgressIndicator(),
                  error: (_, __) =>
                      const Text('Could not load activity.'),
                  data: (items) => items.isEmpty
                      ? const EmptyStateWidget(
                          message: AppStrings.noRecentActivity,
                          icon: Icons.history_rounded,
                        )
                      : Column(
                          children: items
                              .map((a) =>
                                  ActivityItemWidget(activity: a))
                              .toList(),
                        ),
                ),

                const SizedBox(height: 24),

                // ── Edit profile button ───────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                  child: SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.settings_outlined,
                          size: 18),
                      label: const Text(
                          AppStrings.editProfileSettings),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color(0xFF1A1D2E),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: user == null
                          ? null
                          : () => showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(20)),
                                ),
                                builder: (_) =>
                                    EditProfileSheet(user: user),
                              ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickAvatar(
      BuildContext context, WidgetRef ref) async {
    try {
      final picker = ImagePicker();
      final image =
          await picker.pickImage(source: ImageSource.gallery);
      if (image == null) return;
      await ref
          .read(currentUserProvider.notifier)
          .updateAvatar(image.path);
    } catch (_) {
      if (context.mounted) {
        AppSnackbar.show(
            context, AppStrings.avatarUpdateFailed,
            isError: true);
      }
    }
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
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
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1A1D2E),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
}
