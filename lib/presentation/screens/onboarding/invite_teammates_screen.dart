import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:planpal/application/notifiers/auth_notifier.dart';
import 'package:planpal/application/notifiers/workspace_notifier.dart';
import 'package:planpal/core/constants/app_colors.dart';
import 'package:planpal/core/constants/app_sizes.dart';
import 'package:planpal/infrastructure/repositories/workspace_repository.dart';
import 'package:planpal/presentation/widgets/app_snackbar.dart';

/// Onboarding screen 3 — invite teammates via link or email.
class InviteTeammatesScreen extends ConsumerStatefulWidget {
  const InviteTeammatesScreen({super.key, required this.workspaceId});
  final String workspaceId;

  @override
  ConsumerState<InviteTeammatesScreen> createState() =>
      _InviteTeammatesScreenState();
}

class _InviteTeammatesScreenState
    extends ConsumerState<InviteTeammatesScreen> {
  String? _inviteCode;
  bool _loadingCode = false;
  bool _finishing = false;

  @override
  void initState() {
    super.initState();
    _generateInviteLink();
  }

  Future<void> _generateInviteLink() async {
    setState(() => _loadingCode = true);
    try {
      final repo = ref.read(workspaceRepositoryProvider);
      final code = await repo.createInvite(
          workspaceId: widget.workspaceId);
      if (mounted) setState(() { _inviteCode = code; _loadingCode = false; });
    } catch (_) {
      if (mounted) setState(() => _loadingCode = false);
    }
  }

  String get _inviteLink =>
      'https://planpal.app/join/$_inviteCode';

  void _copyLink() {
    if (_inviteCode == null) return;
    Clipboard.setData(ClipboardData(text: _inviteLink));
    AppSnackbar.show(context, 'Invite link copied!');
  }

  void _finish() {
    setState(() => _finishing = true);
    ref.read(authProvider.notifier).markOnboardingComplete();
    // Router redirects to /home automatically
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FF),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 24, 28, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Step indicator ────────────────────────────────────────────
              _StepIndicator(current: 2, total: 2),
              const SizedBox(height: AppSizes.spaceXL),

              // ── Headline ──────────────────────────────────────────────────
              const Text(
                'Invite your team',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1A1D2E),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Share the link below with your teammates.',
                style: TextStyle(
                    fontSize: AppSizes.fontBody,
                    color: Colors.grey.shade500),
              ),
              const SizedBox(height: AppSizes.spaceXL),

              // ── Invite link card ──────────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(AppSizes.spaceM),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppSizes.radiusM),
                  border: Border.all(color: AppColors.divider),
                ),
                child: _loadingCode
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(8),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(BootstrapIcons.link_45deg,
                                  size: 18, color: AppColors.primary),
                              const SizedBox(width: 8),
                              const Text(
                                'Invite Link',
                                style: TextStyle(
                                  fontSize: AppSizes.fontSmall,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1A1D2E),
                                ),
                              ),
                              const Spacer(),
                              Text(
                                'Expires in 7 days',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade400,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF5F7FF),
                              borderRadius:
                                  BorderRadius.circular(AppSizes.radiusS),
                            ),
                            child: Text(
                              _inviteCode != null
                                  ? _inviteLink
                                  : 'Generating link…',
                              style: TextStyle(
                                fontSize: AppSizes.fontSmall,
                                color: Colors.grey.shade600,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            height: 44,
                            child: OutlinedButton.icon(
                              icon: const Icon(
                                  BootstrapIcons.clipboard,
                                  size: 16),
                              label: const Text('Copy Link'),
                              onPressed:
                                  _inviteCode == null ? null : _copyLink,
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                    color: AppColors.primary),
                                foregroundColor: AppColors.primary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      AppSizes.radiusS),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
              ),

              const SizedBox(height: AppSizes.spaceM),

              // ── Info note ─────────────────────────────────────────────────
              Row(
                children: [
                  const Icon(BootstrapIcons.info_circle,
                      size: 14, color: AppColors.primary),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Anyone with this link can join your workspace. '
                      'You can revoke it anytime from Settings.',
                      style: TextStyle(
                        fontSize: AppSizes.fontSmall,
                        color: Colors.grey.shade500,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),

              const Spacer(),

              // ── Done button ───────────────────────────────────────────────
              SizedBox(
                height: 54,
                child: ElevatedButton(
                  onPressed: _finishing ? null : _finish,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusM),
                    ),
                    elevation: 0,
                  ),
                  child: _finishing
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                              strokeWidth: 2.5, color: Colors.white),
                        )
                      : const Text(
                          "Done — Let's go!",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w700),
                        ),
                ),
              ),
              const SizedBox(height: AppSizes.spaceM),

              // ── Skip ──────────────────────────────────────────────────────
              TextButton(
                onPressed: _finishing ? null : _finish,
                child: Text(
                  'Skip for now',
                  style: TextStyle(
                      fontSize: AppSizes.fontBody,
                      color: Colors.grey.shade500),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Step indicator (shared with CreateWorkspaceScreen) ────────────────────────

class _StepIndicator extends StatelessWidget {
  const _StepIndicator({required this.current, required this.total});
  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(total, (i) {
        final active = i < current;
        return Expanded(
          child: Container(
            height: 4,
            margin: EdgeInsets.only(right: i < total - 1 ? 6 : 0),
            decoration: BoxDecoration(
              color: active ? AppColors.primary : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }
}
