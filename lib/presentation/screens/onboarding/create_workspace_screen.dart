import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:planpal/application/notifiers/workspace_notifier.dart';
import 'package:planpal/core/constants/app_colors.dart';
import 'package:planpal/core/constants/app_sizes.dart';
import 'package:planpal/presentation/widgets/app_snackbar.dart';

/// Onboarding screen 2 — lets the user name their team workspace.
class CreateWorkspaceScreen extends ConsumerStatefulWidget {
  const CreateWorkspaceScreen({super.key});

  @override
  ConsumerState<CreateWorkspaceScreen> createState() =>
      _CreateWorkspaceScreenState();
}

class _CreateWorkspaceScreenState
    extends ConsumerState<CreateWorkspaceScreen> {
  final _nameCtrl = TextEditingController();
  String _selectedEmoji = '🗂️';
  String? _nameError;
  bool _loading = false;

  static const _emojis = [
    '🗂️', '🚀', '💡', '🏆', '🎯', '🔥',
    '⚡', '🌟', '🛠️', '💼', '🧠', '🎨',
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      setState(() => _nameError = 'Workspace name is required.');
      return;
    }
    if (name.length > 50) {
      setState(() => _nameError = 'Name must be 50 characters or fewer.');
      return;
    }
    setState(() { _nameError = null; _loading = true; });

    try {
      final workspace = await ref
          .read(workspacesProvider.notifier)
          .createTeamWorkspace(name: name, emoji: _selectedEmoji);

      if (context.mounted) {
        context.go('/onboarding/invite', extra: workspace.id);
      }
    } catch (e) {
      if (context.mounted) {
        final raw = e.toString().replaceFirst('Exception: ', '');
        AppSnackbar.show(
          context,
          raw.isNotEmpty ? raw : 'Could not create workspace. Try again.',
          isError: true,
        );
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.darkBackground : const Color(0xFFF5F7FF);
    final cardColor = isDark ? AppColors.darkSurface : Colors.white;
    final titleColor = isDark ? AppColors.darkOnSurface : const Color(0xFF1A1D2E);
    final subtitleColor =
        isDark ? AppColors.darkOnSurfaceMuted : Colors.grey.shade500;
    final borderColor = isDark ? Colors.white12 : AppColors.divider;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            BootstrapIcons.arrow_left,
            color: titleColor,
          ),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/home');
            }
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(28, 0, 28, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),

              // ── Step indicator ────────────────────────────────────────────
              _StepIndicator(current: 1, total: 2, isDark: isDark),
              const SizedBox(height: AppSizes.spaceL),

              // ── Headline ──────────────────────────────────────────────────
              Text(
                'Name your workspace',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: titleColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'This is the name your team will see.',
                style: TextStyle(
                  fontSize: AppSizes.fontBody,
                  color: subtitleColor,
                ),
              ),
              const SizedBox(height: AppSizes.spaceXL),

              // ── Emoji picker ──────────────────────────────────────────────
              Text(
                'Workspace icon',
                style: TextStyle(
                  fontSize: AppSizes.fontSmall,
                  fontWeight: FontWeight.w600,
                  color: titleColor,
                ),
              ),
              const SizedBox(height: AppSizes.spaceS),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _emojis.map((e) {
                  final selected = e == _selectedEmoji;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedEmoji = e),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: selected
                            ? AppColors.primary.withValues(alpha: 0.15)
                            : cardColor,
                        borderRadius: BorderRadius.circular(AppSizes.radiusM),
                        border: Border.all(
                          color: selected ? AppColors.primary : borderColor,
                          width: selected ? 2 : 1,
                        ),
                      ),
                      child: Center(
                        child: Text(e, style: const TextStyle(fontSize: 22)),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: AppSizes.spaceL),

              // ── Name field ────────────────────────────────────────────────
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Workspace name',
                    style: TextStyle(
                      fontSize: AppSizes.fontSmall,
                      fontWeight: FontWeight.w600,
                      color: titleColor,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _nameCtrl,
                    maxLength: 50,
                    style: TextStyle(color: titleColor),
                    onChanged: (_) => setState(() => _nameError = null),
                    decoration: InputDecoration(
                      hintText: 'e.g. Design Team, Marketing, My Startup',
                      hintStyle: TextStyle(
                        color: isDark
                            ? AppColors.darkOnSurfaceMuted
                            : Colors.grey.shade400,
                      ),
                      errorText: _nameError,
                      filled: true,
                      fillColor: cardColor,
                      prefixIcon: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(_selectedEmoji,
                            style: const TextStyle(fontSize: 20)),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppSizes.radiusM),
                        borderSide: BorderSide(color: borderColor),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppSizes.radiusM),
                        borderSide: BorderSide(
                          color: _nameError != null
                              ? AppColors.error
                              : borderColor,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppSizes.radiusM),
                        borderSide: const BorderSide(
                            color: AppColors.primary, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.spaceXL),

              // ── Create button ─────────────────────────────────────────────
              SizedBox(
                height: 54,
                child: ElevatedButton(
                  onPressed: _loading ? null : _create,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusM),
                    ),
                    elevation: 0,
                  ),
                  child: _loading
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                              strokeWidth: 2.5, color: Colors.white),
                        )
                      : const Text('Create Workspace',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Step indicator ────────────────────────────────────────────────────────────

class _StepIndicator extends StatelessWidget {
  const _StepIndicator({
    required this.current,
    required this.total,
    this.isDark = false,
  });
  final int current;
  final int total;
  final bool isDark;

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
              color: active
                  ? AppColors.primary
                  : (isDark ? Colors.white12 : Colors.grey.shade200),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }
}
