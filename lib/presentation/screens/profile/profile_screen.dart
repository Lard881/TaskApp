import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:planpal/application/notifiers/conversation_notifier.dart';
import 'package:planpal/application/notifiers/task_notifier.dart';
import 'package:planpal/application/notifiers/user_notifier.dart';
import 'package:planpal/application/notifiers/workspace_notifier.dart';
import 'package:planpal/core/constants/app_colors.dart';
import 'package:planpal/core/constants/app_sizes.dart';
import 'package:planpal/core/constants/app_strings.dart';
import 'package:planpal/presentation/screens/profile/modals/edit_profile_sheet.dart';
import 'package:planpal/presentation/widgets/activity_item_widget.dart';
import 'package:planpal/presentation/widgets/app_snackbar.dart';
import 'package:planpal/presentation/widgets/avatar_widget.dart';
import 'package:planpal/presentation/widgets/empty_state_widget.dart';
import 'package:planpal/presentation/widgets/notifications_sheet.dart';
import 'package:planpal/presentation/widgets/skeleton_loader.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);
    final activityAsync = ref.watch(recentActivityProvider);
    final metrics = ref.watch(performanceProvider);
    final workspaces = ref.watch(workspacesProvider).valueOrNull ?? [];
    final members = ref.watch(activeMembersProvider).valueOrNull ?? [];
    final user = userAsync.valueOrNull;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: userAsync.when(
          loading: () => const SkeletonProfileView(),
          error: (_, _) =>
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
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'P',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'PlanPal',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                          color: isDark ? AppColors.darkOnSurface : AppColors.lightOnSurface,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(BootstrapIcons.bell),
                        onPressed: () => NotificationsSheet.show(context),
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
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(
                            BootstrapIcons.pencil,
                            color: Colors.white,
                            size: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Name
                Text(
                  user?.fullName ?? '',
                  style: TextStyle(
                    fontSize: AppSizes.fontHeading,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.darkOnSurface : AppColors.lightOnSurface,
                  ),
                ),

                if (user?.role != null && user!.role!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    user.role!,
                    style: TextStyle(
                      fontSize: AppSizes.fontBody,
                      color: isDark ? AppColors.darkOnSurfaceMuted : Colors.grey.shade500,
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
                      Expanded(
                        child: _StatCard(
                          value: '${workspaces.length}',
                          label: 'Workspaces',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          value: '${members.isNotEmpty ? members.length : 1}',
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
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppColors.darkOnSurface : AppColors.lightOnSurface,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                activityAsync.when(
                  loading: () => const Shimmer(
                    child: Column(
                      children: [
                        SkeletonActivityTile(),
                        SkeletonActivityTile(),
                        SkeletonActivityTile(),
                      ],
                    ),
                  ),
                  error: (_, _) => const Text('Could not load activity.'),
                  data: (items) => items.isEmpty
                      ? const EmptyStateWidget(
                          message: AppStrings.noRecentActivity,
                          icon: BootstrapIcons.clock_history,
                        )
                      : Column(
                          children: items
                              .map((a) => ActivityItemWidget(activity: a))
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
                      icon: const Icon(BootstrapIcons.gear, size: 18),
                      label: const Text(AppStrings.editProfileSettings),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark ? AppColors.primary : const Color(0xFF1A1D2E),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: user == null
                          ? null
                          : () => showModalBottomSheet<void>(
                              context: context,
                              isScrollControlled: true,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(20),
                                ),
                              ),
                              builder: (_) => EditProfileSheet(user: user),
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

  Future<void> _pickAvatar(BuildContext context, WidgetRef ref) async {
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(source: ImageSource.gallery);
      if (image == null) return;
      await ref.read(currentUserProvider.notifier).updateAvatar(image.path);
    } catch (_) {
      if (context.mounted) {
        AppSnackbar.show(context, AppStrings.avatarUpdateFailed, isError: true);
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: isDark ? Border.all(color: Colors.white.withValues(alpha: 0.08)) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: isDark ? AppColors.darkOnSurface : AppColors.lightOnSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10,
              color: isDark ? AppColors.darkOnSurfaceMuted : Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
}
