import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:planpal/application/notifiers/auth_notifier.dart';
import 'package:planpal/application/providers/supabase_providers.dart';
import 'package:planpal/domain/models/conversation.dart';
import 'package:planpal/domain/models/message.dart';
import 'package:planpal/infrastructure/repositories/conversation_repository.dart';
import 'package:uuid/uuid.dart';

class ConversationNotifier extends AsyncNotifier<List<Conversation>> {
  late final ConversationRepository _repo;
  static const _uuid = Uuid();

  @override
  Future<List<Conversation>> build() async {
    _repo = ref.watch(conversationRepositoryProvider);

    // Live conversation updates via Realtime
    _repo.watchConversations().listen((convs) {
      if (state is! AsyncLoading) state = AsyncData(convs);
    });

    return _repo.getAll();
  }

  // ── Current user id ───────────────────────────────────────────────────────

  String get _currentUserId =>
      Supabase.instance.client.auth.currentUser?.id ?? '';

  // ── Delete ────────────────────────────────────────────────────────────────

  Future<void> deleteConversation(String conversationId) async {
    await _repo.deleteConversation(conversationId);
    final updated = (state.valueOrNull ?? [])
        .where((c) => c.id != conversationId)
        .toList();
    state = AsyncData(updated);
  }

  // ── Send message ──────────────────────────────────────────────────────────

  /// Sends a message in [conversationId] from the current user.
  Future<void> sendMessage(String conversationId, String text) async {
    if (text.trim().isEmpty) return;
    final message = Message(
      id: _uuid.v4(),
      conversationId: conversationId,
      senderId: _currentUserId,
      text: text.trim(),
      sentAt: DateTime.now(),
      isRead: true,
    );
    await _repo.saveMessage(message);
    // Realtime listener handles state update automatically
  }

  // ── Mark read ─────────────────────────────────────────────────────────────

  Future<void> markRead(String conversationId) async {
    await _repo.markAllRead(conversationId);
  }

  // ── Start conversation ────────────────────────────────────────────────────

  /// Creates a new conversation or returns an existing one with
  /// the same set of participants (deduplication).
  Future<Conversation> startConversation(List<String> participantIds) async {
    final allParticipants = [_currentUserId, ...participantIds]
        .toSet()
        .toList()
      ..sort();

    // Check for existing conversation with exact same participants
    final existing = (await _repo.getAll()).where((c) {
      final sorted = [...c.participantIds]..sort();
      return sorted.join(',') == allParticipants.join(',');
    }).firstOrNull;

    if (existing != null) return existing;

    final isGroup = allParticipants.length > 2;
    final name = isGroup
        ? 'Group (${allParticipants.length} members)'
        : participantIds.first;

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

// ── Providers ─────────────────────────────────────────────────────────────────

final conversationsProvider =
    AsyncNotifierProvider<ConversationNotifier, List<Conversation>>(
  ConversationNotifier.new,
);

final chatSearchQueryProvider = StateProvider<String>((ref) => '');

final filteredConversationsProvider = Provider<List<Conversation>>((ref) {
  final query = ref.watch(chatSearchQueryProvider).toLowerCase().trim();
  final convsAsync = ref.watch(conversationsProvider);
  return convsAsync.when(
    data: (convs) {
      if (query.isEmpty) return convs;
      return convs
          .where((c) =>
              c.name.toLowerCase().contains(query) ||
              c.lastMessagePreview.toLowerCase().contains(query))
          .toList();
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

/// Live message stream for a specific conversation.
final messagesProvider =
    StreamProvider.family<List<Message>, String>((ref, conversationId) {
  final repo = ref.watch(conversationRepositoryProvider);
  return repo.watchMessages(conversationId);
});

/// Recent activity for the profile screen.
final recentActivityProvider = FutureProvider((ref) async {
  final repo = ref.watch(conversationRepositoryProvider);
  return repo.getRecentActivity();
});
