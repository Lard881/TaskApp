import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:planpal/domain/models/activity_item.dart';
import 'package:planpal/domain/models/conversation.dart';
import 'package:planpal/domain/models/message.dart';
import 'package:planpal/infrastructure/repositories/api_client.dart';
import 'package:planpal/infrastructure/repositories/conversation_repository.dart';

class ApiConversationRepository implements ConversationRepository {
  ApiConversationRepository({required this.workspaceId});

  final String workspaceId;

  Conversation _conversationFromJson(Map<String, dynamic> json) => Conversation(
        id: json['id'] as String,
        name: json['name'] as String? ?? '',
        participantIds: (json['participant_ids'] as List<dynamic>? ?? [])
            .map((e) => e.toString())
            .toList(),
        lastMessagePreview: json['last_message_preview'] as String? ?? '',
        lastMessageAt: DateTime.parse(json['last_message_at'] as String),
        unreadCount: json['unread_count'] as int? ?? 0,
        isGroup: json['is_group'] as bool? ?? false,
      );

  Message _messageFromJson(Map<String, dynamic> json) {
    // Parse message type
    MessageType type = MessageType.text;
    final typeStr = json['type'] as String?;
    if (typeStr != null) {
      switch (typeStr) {
        case 'image':
          type = MessageType.image;
          break;
        case 'document':
          type = MessageType.document;
          break;
        case 'file':
          type = MessageType.file;
          break;
        default:
          type = MessageType.text;
      }
    }

    return Message(
      id: json['id'] as String,
      conversationId: json['conversation_id'] as String,
      senderId: json['sender_id'] as String,
      text: json['text'] as String,
      sentAt: DateTime.parse(json['sent_at'] as String),
      isRead: json['is_read'] as bool? ?? false,
      type: type,
      mediaUrl: json['media_url'] as String?,
      mediaName: json['media_name'] as String?,
      thumbnailUrl: json['thumbnail_url'] as String?,
    );
  }

  @override
  Future<List<Conversation>> getAll() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/conversations/$workspaceId'),
      headers: await ApiConfig.headers(),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Unable to load conversations.');
    }

    final list = jsonDecode(response.body) as List<dynamic>;
    return list
        .map((item) => _conversationFromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<Conversation?> getById(String id) async =>
      (await getAll()).where((c) => c.id == id).firstOrNull;

  @override
  Future<void> saveConversation(Conversation conversation) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/conversations'),
      headers: await ApiConfig.headers(),
      body: jsonEncode({
        'workspaceId': workspaceId,
        'id': conversation.id,
        'name': conversation.name,
        'participantIds': conversation.participantIds,
        'lastMessagePreview': conversation.lastMessagePreview,
        'lastMessageAt': conversation.lastMessageAt.toIso8601String(),
        'unreadCount': conversation.unreadCount,
        'isGroup': conversation.isGroup,
      }),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Unable to save conversation.');
    }
  }

  @override
  Future<List<Message>> getMessages(String conversationId) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/conversations/$conversationId/messages'),
      headers: await ApiConfig.headers(),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Unable to load messages.');
    }

    final list = jsonDecode(response.body) as List<dynamic>;
    return list.map((item) => _messageFromJson(item as Map<String, dynamic>)).toList();
  }

  @override
  Future<void> saveMessage(Message message) async {
    // Convert MessageType enum to string
    String messageType = 'text';
    switch (message.type) {
      case MessageType.image:
        messageType = 'image';
        break;
      case MessageType.document:
        messageType = 'document';
        break;
      case MessageType.file:
        messageType = 'file';
        break;
      default:
        messageType = 'text';
    }

    final body = {
      'text': message.text,
      'type': messageType,
    };

    // Add media fields if present
    if (message.mediaUrl != null) body['mediaUrl'] = message.mediaUrl;
    if (message.mediaName != null) body['mediaName'] = message.mediaName;
    if (message.thumbnailUrl != null) body['thumbnailUrl'] = message.thumbnailUrl;

    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/conversations/${message.conversationId}/messages'),
      headers: await ApiConfig.headers(),
      body: jsonEncode(body),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Unable to send message.');
    }
  }

  @override
  Future<void> markAllRead(String conversationId) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/conversations/$conversationId/read'),
      headers: await ApiConfig.headers(),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Unable to mark messages as read.');
    }
  }

  @override
  Future<void> deleteConversation(String conversationId) async {
    final response = await http.delete(
      Uri.parse('${ApiConfig.baseUrl}/conversations/$conversationId'),
      headers: await ApiConfig.headers(),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Unable to delete conversation.');
    }
  }

  @override
  Stream<List<Conversation>> watchConversations() {
    // Poll every 3 seconds for new messages
    return Stream.periodic(const Duration(seconds: 3))
        .asyncMap((_) => getAll())
        .handleError((error) {
      return <Conversation>[];
    });
  }

  @override
  Stream<List<Message>> watchMessages(String conversationId) {
    // Poll every 2 seconds for new messages in active conversation
    return Stream.periodic(const Duration(seconds: 2))
        .asyncMap((_) => getMessages(conversationId))
        .handleError((error) {
      return <Message>[];
    });
  }

  @override
  Future<List<ActivityItem>> getRecentActivity() async => const <ActivityItem>[];

  @override
  Future<void> addActivity(ActivityItem item) async {}

  /// Upload media file to Supabase Storage and return the public URL
  Future<String> uploadMedia({
    required File file,
    required String conversationId,
    required String fileName,
  }) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConfig.baseUrl}/conversations/$conversationId/upload'),
      );

      // Add headers
      final headers = await ApiConfig.headers();
      request.headers.addAll(headers);

      // Add file
      request.files.add(
        await http.MultipartFile.fromPath('file', file.path, filename: fileName),
      );

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('Failed to upload media: $responseBody');
      }

      final jsonResponse = jsonDecode(responseBody) as Map<String, dynamic>;
      return jsonResponse['url'] as String;
    } catch (e) {
      throw Exception('Error uploading media: $e');
    }
  }
}