import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:planpal/domain/enums/activity_type.dart';
import 'package:planpal/domain/models/activity_item.dart';
import 'package:planpal/domain/models/conversation.dart';
import 'package:planpal/domain/models/message.dart';
import 'package:planpal/infrastructure/repositories/conversation_repository.dart';

/// Supabase-backed implementation of [ConversationRepository].
///
/// Uses Supabase Realtime for live message and conversation updates.
class SupabaseConversationRepository implements ConversationRepository {
  SupabaseConversationRepository(this._client, this.workspaceId);

  final SupabaseClient _client;
  final String workspaceId;

  String get _uid => _client.auth.currentUser!.id;

  // ── Helpers ───────────────────────────────────────────────────────────────

  Conversation _convFromRow(Map<String, dynamic> r) => Conversation(
        id: r['id'] as String,
        name: r['name'] as String? ?? '',
        participantIds: List<String>.from(r['participant_ids'] as List),
        lastMessagePreview: r['last_message_preview'] as String? ?? '',
        lastMessageAt: DateTime.parse(r['last_message_at'] as String),
        unreadCount: r['unread_count'] as int? ?? 0,
        isGroup: r['is_group'] as bool? ?? false,
      );

  Message _msgFromRow(Map<String, dynamic> r) => Message(
        id: r['id'] as String,
        conversationId: r['conversation_id'] as String,
        senderId: r['sender_id'] as String,
        text: r['text'] as String,
        sentAt: DateTime.parse(r['sent_at'] as String),
        isRead: r['is_read'] as bool? ?? false,
      );

  // ── Conversations ─────────────────────────────────────────────────────────

  @override
  Future<List<Conversation>> getAll() async {
    final rows = await _client
        .from('conversations')
        .select()
        .eq('workspace_id', workspaceId)
        .contains('participant_ids', [_uid])
        .order('last_message_at', ascending: false);

    return (rows as List)
        .map((r) => _convFromRow(r as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<Conversation?> getById(String id) async {
    final row = await _client
        .from('conversations')
        .select()
        .eq('id', id)
        .maybeSingle();
    if (row == null) return null;
    return _convFromRow(row as Map<String, dynamic>);
  }

  @override
  Future<void> saveConversation(Conversation conv) async {
    await _client.from('conversations').upsert({
      'id': conv.id,
      'workspace_id': workspaceId,
      'name': conv.name,
      'is_group': conv.isGroup,
      'participant_ids': conv.participantIds,
      'last_message_preview': conv.lastMessagePreview,
      'last_message_at': conv.lastMessageAt.toIso8601String(),
      'unread_count': conv.unreadCount,
    });
  }

  @override
  Future<void> deleteConversation(String conversationId) async {
    // Messages cascade-deleted by FK constraint
    await _client.from('conversations').delete().eq('id', conversationId);
  }

  @override
  Future<void> markAllRead(String conversationId) async {
    await _client
        .from('messages')
        .update({'is_read': true})
        .eq('conversation_id', conversationId)
        .eq('is_read', false);

    await _client
        .from('conversations')
        .update({'unread_count': 0})
        .eq('id', conversationId);
  }

  // ── Messages ──────────────────────────────────────────────────────────────

  @override
  Future<List<Message>> getMessages(String conversationId) async {
    final rows = await _client
        .from('messages')
        .select()
        .eq('conversation_id', conversationId)
        .order('sent_at', ascending: true);

    return (rows as List)
        .map((r) => _msgFromRow(r as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> saveMessage(Message message) async {
    await _client.from('messages').insert({
      'id': message.id,
      'conversation_id': message.conversationId,
      'sender_id': message.senderId,
      'text': message.text,
      'sent_at': message.sentAt.toIso8601String(),
      'is_read': message.isRead,
    });
    // DB trigger updates conversation preview automatically
  }

  // ── Activity ──────────────────────────────────────────────────────────────

  @override
  Future<List<ActivityItem>> getRecentActivity() async {
    final rows = await _client
        .from('activity_items')
        .select()
        .eq('user_id', _uid)
        .order('timestamp', ascending: false)
        .limit(10);

    return (rows as List).map((r) {
      final row = r as Map<String, dynamic>;
      return ActivityItem(
        id: row['id'] as String,
        type: _parseActivityType(row['type'] as String),
        taskId: row['task_id'] as String?,
        taskName: row['task_name'] as String,
        timestamp: DateTime.parse(row['timestamp'] as String),
      );
    }).toList();
  }

  @override
  Future<void> addActivity(ActivityItem item) async {
    await _client.from('activity_items').insert({
      'id': item.id,
      'user_id': _uid,
      'type': item.type.name,
      'task_id': item.taskId,
      'task_name': item.taskName,
      'timestamp': item.timestamp.toIso8601String(),
    });
  }

  // ── Realtime streams ──────────────────────────────────────────────────────

  @override
  Stream<List<Conversation>> watchConversations() {
    final controller = StreamController<List<Conversation>>.broadcast();

    Future<void> emit() async {
      if (!controller.isClosed) controller.add(await getAll());
    }

    emit();

    final channel = _client
        .channel('conversations_${workspaceId}_$_uid')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'conversations',
          callback: (_) => emit(),
        )
        .subscribe();

    controller.onCancel = () {
      _client.removeChannel(channel);
      controller.close();
    };

    return controller.stream;
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

    final channel = _client
        .channel('messages_$conversationId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'messages',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'conversation_id',
            value: conversationId,
          ),
          callback: (_) => emit(),
        )
        .subscribe();

    controller.onCancel = () {
      _client.removeChannel(channel);
      controller.close();
    };

    return controller.stream;
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  ActivityType _parseActivityType(String s) => switch (s) {
        'updated' => ActivityType.updated,
        'completed' => ActivityType.completed,
        _ => ActivityType.created,
      };
}
