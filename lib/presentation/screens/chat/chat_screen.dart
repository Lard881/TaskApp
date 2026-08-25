import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:planpal/application/notifiers/conversation_notifier.dart';
import 'package:planpal/core/constants/app_colors.dart';
import 'package:planpal/core/constants/app_sizes.dart';
import 'package:planpal/core/constants/app_strings.dart';
import 'package:planpal/domain/models/conversation.dart';
import 'package:planpal/presentation/screens/chat/new_conversation_sheet.dart';
import 'package:planpal/presentation/widgets/app_snackbar.dart';
import 'package:planpal/presentation/widgets/confirmation_dialog.dart';
import 'package:planpal/presentation/widgets/conversation_item.dart';
import 'package:planpal/presentation/widgets/empty_state_widget.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ── Delete helpers ────────────────────────────────────────────────────────

  void _confirmDelete(Conversation conv) {
    ConfirmationDialog.show(
      context: context,
      title: 'Delete conversation?',
      body:
          'This will permanently delete the conversation with ${conv.name} and all its messages. This cannot be undone.',
      confirmLabel: AppStrings.delete,
      isDestructive: true,
      onConfirm: () async {
        await ref
            .read(conversationsProvider.notifier)
            .deleteConversation(conv.id);
        if (mounted) {
          AppSnackbar.show(context, 'Conversation deleted.');
        }
      },
    );
  }

  void _showConvOptions(Conversation conv) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Handle ────────────────────────────────────────────────────
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // ── Open ──────────────────────────────────────────────────────
            ListTile(
              leading: const Icon(BootstrapIcons.chat_text,
                  color: AppColors.primary),
              title: const Text('Open conversation'),
              onTap: () {
                Navigator.of(context).pop();
                context.go('/chat/${conv.id}');
              },
            ),

            // ── Delete ────────────────────────────────────────────────────
            ListTile(
              leading:
                  const Icon(BootstrapIcons.trash, color: Colors.red),
              title: const Text(
                'Delete conversation',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () {
                Navigator.of(context).pop();
                _confirmDelete(conv);
              },
            ),

            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final query = ref.watch(chatSearchQueryProvider);
    final conversations = ref.watch(filteredConversationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.conversations),
        actions: [
          Semantics(
            label: 'New conversation',
            button: true,
            child: IconButton(
              icon: const Icon(BootstrapIcons.pencil_square),
              tooltip: 'New conversation',
              onPressed: () => showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => const NewConversationSheet(),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Search bar ────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(AppSizes.spaceM),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: AppStrings.searchConversations,
                prefixIcon: const Icon(BootstrapIcons.search),
                suffixIcon: query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(BootstrapIcons.x_lg),
                        tooltip: 'Clear search',
                        onPressed: () {
                          _searchController.clear();
                          ref
                              .read(chatSearchQueryProvider.notifier)
                              .state = '';
                        },
                      )
                    : null,
              ),
              onChanged: (v) =>
                  ref.read(chatSearchQueryProvider.notifier).state = v,
            ),
          ),

          // ── Conversation list ─────────────────────────────────────────────
          Expanded(
            child: conversations.isEmpty
                ? EmptyStateWidget(
                    message: query.isNotEmpty
                        ? AppStrings.noResults
                        : AppStrings.noConversations,
                    icon: BootstrapIcons.chat_square,
                  )
                : ListView.separated(
                    itemCount: conversations.length,
                    separatorBuilder: (_, __) =>
                        const Divider(height: 1, indent: 72),
                    itemBuilder: (_, i) {
                      final conv = conversations[i];

                      // Swipe left → delete
                      return Dismissible(
                        key: ValueKey(conv.id),
                        direction: DismissDirection.endToStart,
                        confirmDismiss: (_) async {
                          _confirmDelete(conv);
                          // Return false — we handle deletion manually
                          // inside the dialog so the item doesn't
                          // disappear before confirmation.
                          return false;
                        },
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(
                              right: AppSizes.spaceL),
                          margin: const EdgeInsets.only(bottom: 1),
                          color: Colors.red.shade400,
                          child: const Icon(BootstrapIcons.trash,
                              color: Colors.white),
                        ),
                        child: ConversationItem(
                          conversation: conv,
                          onTap: () => context.go('/chat/${conv.id}'),
                          // Long press → options bottom sheet
                          onLongPress: () => _showConvOptions(conv),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
