import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:planpal/application/notifiers/conversation_notifier.dart';
import 'package:planpal/core/constants/app_sizes.dart';
import 'package:planpal/core/constants/app_strings.dart';
import 'package:planpal/presentation/widgets/app_snackbar.dart';
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
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'New conversation',
              onPressed: () =>
                  AppSnackbar.show(context, AppStrings.comingSoon),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(AppSizes.spaceM),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: AppStrings.searchConversations,
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close),
                        tooltip: 'Clear search',
                        onPressed: () {
                          _searchController.clear();
                          ref
                              .read(
                                  chatSearchQueryProvider.notifier)
                              .state = '';
                        },
                      )
                    : null,
              ),
              onChanged: (v) => ref
                  .read(chatSearchQueryProvider.notifier)
                  .state = v,
            ),
          ),

          // Conversation list
          Expanded(
            child: conversations.isEmpty
                ? EmptyStateWidget(
                    message: query.isNotEmpty
                        ? AppStrings.noResults
                        : AppStrings.noConversations,
                    icon: Icons.chat_bubble_outline_rounded,
                  )
                : ListView.separated(
                    itemCount: conversations.length,
                    separatorBuilder: (_, __) =>
                        const Divider(height: 1, indent: 72),
                    itemBuilder: (_, i) {
                      final conv = conversations[i];
                      return ConversationItem(
                        conversation: conv,
                        onTap: () =>
                            context.go('/chat/${conv.id}'),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
