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

      if (mounted) {
        context.go('/onboarding/invite', extra: workspace.id);
      }
    } catch (e) {
      if (mounted) {
        AppSnackbar.show(context, 'Could not create workspace. Try again.',
            isError: true);
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F7FF),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(BootstrapIcons.arrow_left,
              color: Color(0xFF1A1D2E)),
          onPressed: () => context.pop(),
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
              _StepIndicator(current: 1, total: 2),
              const SizedBox(height: AppSizes.spaceL),

              // ── Headline ──────────────────────────────────────────────────
              const Text(
                'Name your workspace',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1A1D2E),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'This is the name your team will see.',
                style: TextStyle(
                    fontSize: AppSizes.fontBody, color: Colors.grey.shade500),
              ),
              const SizedBox(height: AppSizes.spaceXL),

              // ── Emoji picker ──────────────────────────────────────────────
              const Text(
                'Workspace icon',
                style: TextStyle(
                  fontSize: AppSizes.fontSmall,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1D2E),
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
                            ? AppColors.primary.withOpacity(0.1)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(AppSizes.radiusM),
                        border: Border.all(
                          color: selected
                              ? AppColors.primary
                              : AppColors.divider,
                          width: selected ? 2 : 1,
                        ),
                      ),
                      child: Center(
                          child: Text(e,
                              style: const TextStyle(fontSize: 22))),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: AppSizes.spaceL),

              // ── Name field ────────────────────────────────────────────────
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Workspace name',
                    style: TextStyle(
                      fontSize: AppSizes.fontSmall,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1D2E),
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _nameCtrl,
                    maxLength: 50,
                    onChanged: (_) => setState(() => _nameError = null),
                    decoration: InputDecoration(
                      hintText: 'e.g. Design Team, Marketing, My Startup',
                      errorText: _nameError,
                      filled: true,
                      fillColor: Colors.white,
                      prefixIcon: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(_selectedEmoji,
                            style: const TextStyle(fontSize: 20)),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppSizes.radiusM),
                        borderSide: const BorderSide(color: AppColors.divider),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppSizes.radiusM),
                        borderSide: BorderSide(
                          color: _nameError != null
                              ? AppColors.error
                              : AppColors.divider,
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
              color:
                  active ? AppColors.primary : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }
}
