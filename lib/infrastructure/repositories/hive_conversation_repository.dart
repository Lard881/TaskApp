import 'dart:async';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:planpal/domain/models/activity_item.dart';
import 'package:planpal/domain/models/conversation.dart';
import 'package:planpal/domain/models/message.dart';
import 'package:planpal/infrastructure/mock/mock_data.dart';
import 'package:planpal/infrastructure/repositories/conversation_repository.dart';

/// Hive-backed implementation of [ConversationRepository].
/// Boxes: 'conversations', 'messages', 'activity'
class HiveConversationRepository implements ConversationRepository {
  HiveConversationRepository({
    required Box<Conversation> conversationBox,
    required Box<Message> messageBox,
    required Box<ActivityItem> activityBox,
  })  : _conversationBox = conversationBox,
        _messageBox = messageBox,
        _activityBox = activityBox;

  final Box<Conversation> _conversationBox;
  final Box<Message> _messageBox;
  final Box<ActivityItem> _activityBox;

  // ── Seeding ───────────────────────────────────────────────────────────────

  Future<void> seedIfEmpty() async {
    if (_conversationBox.isEmpty) {
      for (final c in MockData.conversations) {
        await _conversationBox.put(c.id, c);
      }
    }
    if (_messageBox.isEmpty) {
      for (final m in MockData.messages) {
        await _messageBox.put(m.id, m);
      }
    }
    if (_activityBox.isEmpty) {
      for (final a in MockData.activityItems) {
        await _activityBox.put(a.id, a);
      }
    }
  }

  // ── Conversations ─────────────────────────────────────────────────────────

  @override
  Future<List<Conversation>> getAll() async {
    return _conversationBox.values.toList()
      ..sort((a, b) => b.lastMessageAt.compareTo(a.lastMessageAt));
  }

  @override
  Future<Conversation?> getById(String id) async =>
      _conversationBox.get(id);

  @override
  Future<void> saveConversation(Conversation conversation) =>
      _conversationBox.put(conversation.id, conversation);

  @override
  Stream<List<Conversation>> watchConversations() {
    final controller = StreamController<List<Conversation>>.broadcast();

    Future<void> emit() async {
      if (!controller.isClosed) controller.add(await getAll());
    }

    emit();

    final subscription = _conversationBox.watch().listen((_) => emit());

    controller.onCancel = () {
      subscription.cancel();
      controller.close();
    };

    return controller.stream;
  }

  // ── Messages ──────────────────────────────────────────────────────────────

  @override
  Future<List<Message>> getMessages(String conversationId) async {
    return _messageBox.values
        .where((m) => m.conversationId == conversationId)
        .toList()
      ..sort((a, b) => a.sentAt.compareTo(b.sentAt));
  }

  @override
  Future<void> saveMessage(Message message) async {
    await _messageBox.put(message.id, message);

    // Update the parent conversation's preview and timestamp
    final conv = _conversationBox.get(message.conversationId);
    if (conv != null) {
      await _conversationBox.put(
        conv.id,
        conv.copyWith(
          lastMessagePreview: message.text,
          lastMessageAt: message.sentAt,
        ),
      );
    }
  }

  @override
  Future<void> deleteConversation(String conversationId) async {
    // Delete all messages belonging to this conversation
    final messageKeys = _messageBox.values
        .where((m) => m.conversationId == conversationId)
        .map((m) => m.id)
        .toList();
    for (final key in messageKeys) {
      await _messageBox.delete(key);
    }
    // Delete the conversation itself
    await _conversationBox.delete(conversationId);
  }

  @override
  Future<void> markAllRead(String conversationId) async {
    // Mark all messages as read
    final toUpdate = _messageBox.values
        .where((m) => m.conversationId == conversationId && !m.isRead)
        .toList();
    for (final m in toUpdate) {
      await _messageBox.put(m.id, m.copyWith(isRead: true));
    }

    // Reset unread count on the conversation
    final conv = _conversationBox.get(conversationId);
    if (conv != null) {
      await _conversationBox.put(
        conv.id,
        conv.copyWith(unreadCount: 0),
      );
    }
  }

  @override
  Stream<List<Message>> watchMessages(String conversationId) {
    final controller = StreamController<List<Message>>.broadcast();

    Future<void> emit() async {
      if (!controller.isClosed) {
        controller.add(await getMessages(conversationId));
      }
    }

    emit();

    final subscription = _messageBox.watch().listen((_) => emit());

    controller.onCancel = () {
      subscription.cancel();
      controller.close();
    };

    return controller.stream;
  }

  // ── Activity feed ─────────────────────────────────────────────────────────

  @override
  Future<List<ActivityItem>> getRecentActivity() async {
    final items = _activityBox.values.toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return items.take(10).toList();
  }

  @override
  Future<void> addActivity(ActivityItem item) async {
    await _activityBox.put(item.id, item);
    // Trim to 50 entries to keep the box from growing unbounded
    if (_activityBox.length > 50) {
      final sorted = _activityBox.values.toList()
        ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
      final toDelete = sorted.take(_activityBox.length - 50);
      for (final a in toDelete) {
        await _activityBox.delete(a.id);
      }
    }
  }
}
