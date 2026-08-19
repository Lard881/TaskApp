import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:planpal/application/providers/hive_providers.dart';
import 'package:planpal/domain/models/conversation.dart';
import 'package:planpal/domain/models/message.dart';
import 'package:planpal/infrastructure/mock/mock_data.dart';
import 'package:planpal/infrastructure/repositories/conversation_repository.dart';
import 'package:uuid/uuid.dart';

/// Manages the full conversation list and search state.
class ConversationNotifier extends AsyncNotifier<List<Conversation>> {
  late final ConversationRepository _repo;
  static const _uuid = Uuid();

  @override
  Future<List<Conversation>> build() async {
    _repo = ref.watch(conversationRepositoryProvider);

    _repo.watchConversations().listen((convs) {
      if (state is! AsyncLoading) {
        state = AsyncData(convs);
      }
    });

    return _repo.getAll();
  }

  /// Sends a message in [conversationId] from the current user.
  Future<void> sendMessage(String conversationId, String text) async {
    if (text.trim().isEmpty) return;
    final message = Message(
      id: _uuid.v4(),
      conversationId: conversationId,
      senderId: MockData.currentUserId,
      text: text.trim(),
      sentAt: DateTime.now(),
      isRead: true,
    );
    await _repo.saveMessage(message);
  }

  /// Marks all unread messages in [conversationId] as read.
  Future<void> markRead(String conversationId) async {
    await _repo.markAllRead(conversationId);
  }

  /// Creates a new conversation with [participantIds].
  /// If a conversation with exactly those participants already exists,
  /// returns the existing one instead of creating a duplicate (Req 15.4).
  Future<Conversation> startConversation(
      List<String> participantIds) async {
    final allParticipants = [MockData.currentUserId, ...participantIds]
        .toSet()
        .toList()
      ..sort();

    // Check for existing conversation with exactly the same participants
    final existing = (await _repo.getAll()).where((c) {
      final sorted = [...c.participantIds]..sort();
      return sorted.join(',') == allParticipants.join(',');
    }).firstOrNull;

    if (existing != null) return existing;

    // Create a new conversation
    final isGroup = allParticipants.length > 2;
    final name = isGroup
        ? 'Group (${allParticipants.length} members)'
        : participantIds.first; // will be resolved to name in UI

    final conv = Conversation(
      id: _uuid.v4(),
      name: name,
      participantIds: allParticipants,
      lastMessagePreview: '',
      lastMessageAt: DateTime.now(),
      unreadCount: 0,
      isGroup: isGroup,
    );
    await _repo.saveConversation(conv);
    return conv;
  }
}

/// The conversations list provider.
final conversationsProvider =
    AsyncNotifierProvider<ConversationNotifier, List<Conversation>>(
  ConversationNotifier.new,
);

/// The current search query on the Chat screen.
final chatSearchQueryProvider = StateProvider<String>((ref) => '');

/// Filtered conversations based on the search query (Req 13.2).
final filteredConversationsProvider = Provider<List<Conversation>>((ref) {
  final query = ref.watch(chatSearchQueryProvider).toLowerCase().trim();
  final convsAsync = ref.watch(conversationsProvider);

  return convsAsync.when(
    data: (convs) {
      if (query.isEmpty) return convs;
      return convs.where((c) {
        return c.name.toLowerCase().contains(query) ||
            c.lastMessagePreview.toLowerCase().contains(query);
      }).toList();
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

/// Messages for a specific conversation.
final messagesProvider =
    FutureProvider.family<List<Message>, String>((ref, conversationId) async {
  final repo = ref.watch(conversationRepositoryProvider);
  return repo.getMessages(conversationId);
});

/// Recent activity items for the Profile screen (Req 17).
final recentActivityProvider = FutureProvider((ref) async {
  final repo = ref.watch(conversationRepositoryProvider);
  return repo.getRecentActivity();
});
