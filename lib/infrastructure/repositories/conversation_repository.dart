import 'package:planpal/domain/models/activity_item.dart';
import 'package:planpal/domain/models/conversation.dart';
import 'package:planpal/domain/models/message.dart';

/// Abstract contract for conversation and message persistence.
abstract class ConversationRepository {
  /// Returns all conversations ordered by [lastMessageAt] descending.
  Future<List<Conversation>> getAll();

  /// Returns a single conversation by [id], or `null` if not found.
  Future<Conversation?> getById(String id);

  /// Persists a conversation record (create or update).
  Future<void> saveConversation(Conversation conversation);

  /// Returns all messages for [conversationId] in chronological order.
  Future<List<Message>> getMessages(String conversationId);

  /// Persists a new message and updates the parent conversation's
  /// [lastMessagePreview] and [lastMessageAt].
  Future<void> saveMessage(Message message);

  /// Sets [unreadCount] to 0 for the conversation with [conversationId].
  Future<void> markAllRead(String conversationId);

  /// Permanently deletes a conversation and all its messages.
  Future<void> deleteConversation(String conversationId);

  /// Emits the full conversation list whenever any conversation changes.
  Stream<List<Conversation>> watchConversations();

  /// Emits the message list for [conversationId] whenever it changes.
  Stream<List<Message>> watchMessages(String conversationId);

  // ── Activity feed ─────────────────────────────────────────────────────────

  /// Returns up to 10 most recent activity items ordered newest first.
  Future<List<ActivityItem>> getRecentActivity();

  /// Appends a new activity item. Trims the list to 50 entries max.
  Future<void> addActivity(ActivityItem item);
}
