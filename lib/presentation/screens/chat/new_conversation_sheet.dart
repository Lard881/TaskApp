import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:planpal/application/notifiers/conversation_notifier.dart';
import 'package:planpal/application/notifiers/workspace_notifier.dart';
import 'package:planpal/core/constants/app_colors.dart';
import 'package:planpal/core/constants/app_sizes.dart';
import 'package:planpal/core/constants/app_strings.dart';
import 'package:planpal/domain/models/workspace.dart';
import 'package:planpal/presentation/widgets/app_snackbar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Bottom sheet for starting a new conversation.
///
/// Contacts = members of the active workspace (excluding the current user).
/// Supports single and group conversations (up to 50 participants).
class NewConversationSheet extends ConsumerStatefulWidget {
  const NewConversationSheet({super.key});

  @override
  ConsumerState<NewConversationSheet> createState() =>
      _NewConversationSheetState();
}

class _NewConversationSheetState
    extends ConsumerState<NewConversationSheet> {
  final _searchController = TextEditingController();
  final Set<String> _selectedIds = {};
  String _query = '';
  String? _error;
  bool _loading = false;

  String get _currentUserId =>
      Supabase.instance.client.auth.currentUser?.id ?? '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Filter workspace members excluding the current user.
  List<WorkspaceMember> _filterContacts(List<WorkspaceMember> all) {
    final contacts =
        all.where((m) => m.userId != _currentUserId).toList();
    if (_query.isEmpty) return contacts;
    final q = _query.toLowerCase();
    return contacts
        .where((m) =>
            (m.profile?.fullName.toLowerCase().contains(q) ?? false) ||
            (m.profile?.email.toLowerCase().contains(q) ?? false))
        .toList();
  }

  Future<void> _start() async {
    if (_selectedIds.isEmpty) {
      setState(() => _error = AppStrings.selectParticipant);
      return;
    }
    if (_selectedIds.length > 50) {
      setState(() => _error = AppStrings.groupLimit);
      return;
    }

    setState(() {
      _error = null;
      _loading = true;
    });

    try {
      final conv = await ref
          .read(conversationsProvider.notifier)
          .startConversation(_selectedIds.toList());

      if (mounted) {
        Navigator.of(context).pop();
        context.go('/chat/${conv.id}');
      }
    } catch (e) {
      if (mounted) {
        AppSnackbar.show(
          context,
          'Could not start conversation. Please try again.',
          isError: true,
        );
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final membersAsync = ref.watch(activeMembersProvider);
    final allMembers = membersAsync.valueOrNull ?? [];
    final filtered = _filterContacts(allMembers);
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, scrollController) {
          return Column(
            children: [
              // ── Handle + header ──────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(
                    AppSizes.spaceM, AppSizes.spaceS, AppSizes.spaceS, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          Center(
                            child: Container(
                              width: 40,
                              height: 4,
                              margin: const EdgeInsets.only(
                                  bottom: AppSizes.spaceS),
                              decoration: BoxDecoration(
                                color: Colors.grey.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                          Text(
                            AppStrings.newConversation,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(BootstrapIcons.x_lg),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSizes.spaceS),

              // ── Search ───────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.spaceM),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: AppStrings.searchContacts,
                    prefixIcon: const Icon(BootstrapIcons.search),
                    suffixIcon: _query.isNotEmpty
                        ? IconButton(
                            icon: const Icon(BootstrapIcons.x_lg),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _query = '');
                            },
                          )
                        : null,
                  ),
                  onChanged: (v) => setState(() => _query = v.trim()),
                ),
              ),

              // ── Selected chips ───────────────────────────────────────
              if (_selectedIds.isNotEmpty) ...[
                const SizedBox(height: AppSizes.spaceS),
                SizedBox(
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.spaceM),
                    children: _selectedIds.map((id) {
                      final member = allMembers
                          .where((m) => m.userId == id)
                          .firstOrNull;
                      final name =
                          member?.profile?.firstName ?? id;
                      final initials =
                          member?.profile?.initials ?? '?';
                      return Padding(
                        padding: const EdgeInsets.only(
                            right: AppSizes.spaceS),
                        child: Chip(
                          avatar: CircleAvatar(
                            backgroundColor:
                                AppColors.primary.withOpacity(0.15),
                            child: Text(initials,
                                style: const TextStyle(
                                    fontSize: 10,
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w700)),
                          ),
                          label: Text(name,
                              style: const TextStyle(fontSize: 12)),
                          deleteIcon: const Icon(
                              BootstrapIcons.x_lg,
                              size: 14),
                          onDeleted: () =>
                              setState(() => _selectedIds.remove(id)),
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],

              // ── Error ────────────────────────────────────────────────
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                      AppSizes.spaceM, AppSizes.spaceXS,
                      AppSizes.spaceM, 0),
                  child: Row(
                    children: [
                      const Icon(BootstrapIcons.exclamation_circle,
                          size: 14, color: AppColors.error),
                      const SizedBox(width: AppSizes.spaceXS),
                      Expanded(
                        child: Text(_error!,
                            style: const TextStyle(
                                fontSize: AppSizes.fontSmall,
                                color: AppColors.error)),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: AppSizes.spaceS),

              // ── Contact list ─────────────────────────────────────────
              Expanded(
                child: membersAsync.when(
                  loading: () => const Center(
                      child: CircularProgressIndicator()),
                  error: (_, __) => const Center(
                      child: Text('Could not load contacts.')),
                  data: (_) {
                    if (filtered.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(BootstrapIcons.people,
                                size: 40,
                                color: Colors.grey.shade300),
                            const SizedBox(height: 12),
                            Text(
                              _query.isNotEmpty
                                  ? AppStrings.noContactsFound
                                  : 'No teammates yet.\nInvite people from Settings.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: AppSizes.fontBody,
                                  color: Colors.grey.shade400),
                            ),
                          ],
                        ),
                      );
                    }
                    return ListView.builder(
                      controller: scrollController,
                      itemCount: filtered.length,
                      itemBuilder: (_, i) {
                        final member = filtered[i];
                        final profile = member.profile;
                        final isSelected =
                            _selectedIds.contains(member.userId);
                        return ListTile(
                          leading: CircleAvatar(
                            radius: AppSizes.avatarSmall / 2,
                            backgroundColor:
                                AppColors.primary.withOpacity(0.15),
                            child: Text(
                              profile?.initials ?? '?',
                              style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w700),
                            ),
                          ),
                          title: Text(
                            profile?.fullName ?? member.userId,
                            style: const TextStyle(
                                fontSize: AppSizes.fontBody,
                                fontWeight: FontWeight.w500),
                          ),
                          subtitle: profile?.role != null
                              ? Text(profile!.role!,
                                  style: TextStyle(
                                      fontSize: AppSizes.fontSmall,
                                      color: Colors.grey.shade500))
                              : null,
                          trailing: isSelected
                              ? const Icon(
                                  BootstrapIcons.check_circle_fill,
                                  color: AppColors.primary)
                              : Icon(BootstrapIcons.circle,
                                  color: Colors.grey.shade300),
                          onTap: () {
                            setState(() {
                              if (isSelected) {
                                _selectedIds.remove(member.userId);
                              } else {
                                if (_selectedIds.length >= 50) {
                                  _error = AppStrings.groupLimit;
                                  return;
                                }
                                _selectedIds.add(member.userId);
                              }
                              _error = null;
                            });
                          },
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: AppSizes.spaceM,
                              vertical: AppSizes.spaceXS),
                        );
                      },
                    );
                  },
                ),
              ),

              // ── Actions ──────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(
                    AppSizes.spaceM,
                    AppSizes.spaceS,
                    AppSizes.spaceM,
                    AppSizes.spaceL),
                child: Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: _loading
                            ? null
                            : () => Navigator.of(context).pop(),
                        child: const Text(AppStrings.cancel),
                      ),
                    ),
                    const SizedBox(width: AppSizes.spaceS),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _start,
                        child: _loading
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white))
                            : Text(AppStrings.startConversation,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
