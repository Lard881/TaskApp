import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:planpal/application/notifiers/conversation_notifier.dart';
import 'package:planpal/application/notifiers/user_notifier.dart';
import 'package:planpal/core/constants/app_sizes.dart';
import 'package:planpal/core/constants/app_strings.dart';
import 'package:planpal/infrastructure/mock/mock_data.dart';
import 'package:planpal/presentation/widgets/message_bubble.dart';

class ConversationDetailScreen extends ConsumerStatefulWidget {
  const ConversationDetailScreen(
      {super.key, required this.conversationId});
  final String conversationId;

  @override
  ConsumerState<ConversationDetailScreen> createState() =>
      _ConversationDetailScreenState();
}

class _ConversationDetailScreenState
    extends ConsumerState<ConversationDetailScreen> {
  final _inputController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Mark all messages as read when opening (Req 14.10)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(conversationsProvider.notifier)
          .markRead(widget.conversationId);
    });
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _send() async {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;
    _inputController.clear();
    await ref
        .read(conversationsProvider.notifier)
        .sendMessage(widget.conversationId, text);
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final convsAsync = ref.watch(conversationsProvider);
    final conv = convsAsync.valueOrNull?.firstWhere(
      (c) => c.id == widget.conversationId,
      orElse: () => throw StateError('Not found'),
    );

    final messagesAsync =
        ref.watch(messagesProvider(widget.conversationId));
    final allUsersAsync = ref.watch(allUsersProvider);
    final allUsers = allUsersAsync.valueOrNull ?? [];
    final isGroup = conv?.isGroup ?? false;

    return Scaffold(
      appBar: AppBar(
        title: Text(conv?.name ?? 'Conversation'),
        leading: const BackButton(),
      ),
      body: Column(
        children: [
          // Message list
          Expanded(
            child: messagesAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (_, __) => const Center(
                  child: Text('Could not load messages.')),
              data: (messages) {
                _scrollToBottom();
                if (messages.isEmpty) {
                  return const Center(
                      child: Text('No messages yet. Say hi!'));
                }
                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(
                      vertical: AppSizes.spaceS),
                  itemCount: messages.length,
                  itemBuilder: (_, i) {
                    final msg = messages[i];
                    final isOwn =
                        msg.senderId == MockData.currentUserId;
                    final sender = allUsers
                        .where((u) => u.id == msg.senderId)
                        .firstOrNull;
                    return MessageBubble(
                      message: msg,
                      isOwn: isOwn,
                      sender: sender,
                      showSenderName: isGroup && !isOwn,
                    );
                  },
                );
              },
            ),
          ),

          // Input bar
          Container(
            padding: EdgeInsets.only(
              left: AppSizes.spaceM,
              right: AppSizes.spaceS,
              top: AppSizes.spaceS,
              bottom: AppSizes.spaceM +
                  MediaQuery.of(context).viewInsets.bottom,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _inputController,
                    textCapitalization:
                        TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      hintText: AppStrings.typeAMessage,
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    onSubmitted: (_) => _send(),
                  ),
                ),
                Semantics(
                  label: 'Send message',
                  button: true,
                  child: IconButton(
                    icon: const Icon(Icons.send_rounded),
                    onPressed: _send,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
