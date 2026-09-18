import 'package:hive/hive.dart';

part 'message_adapter.dart';

/// Message type enum
enum MessageType {
  text,
  image,
  document, // PDF, DOCX, etc.
  file,     // Other files
}

/// A single chat message within a conversation.
/// Hive typeId: 3
class Message {
  const Message({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.text,
    required this.sentAt,
    required this.isRead,
    this.type = MessageType.text,
    this.mediaUrl,
    this.mediaName,
    this.thumbnailUrl,
  });

  final String id;
  final String conversationId; // references Conversation.id
  final String senderId;       // references User.id
  final String text;           // message text or caption for media
  final DateTime sentAt;
  final bool isRead;
  final MessageType type;      // text, image, document, file
  final String? mediaUrl;      // URL to media file in Supabase Storage
  final String? mediaName;     // Original filename
  final String? thumbnailUrl;  // Thumbnail for images/documents

  Message copyWith({
    String? id,
    String? conversationId,
    String? senderId,
    String? text,
    DateTime? sentAt,
    bool? isRead,
    MessageType? type,
    String? mediaUrl,
    String? mediaName,
    String? thumbnailUrl,
  }) {
    return Message(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      senderId: senderId ?? this.senderId,
      text: text ?? this.text,
      sentAt: sentAt ?? this.sentAt,
      isRead: isRead ?? this.isRead,
      type: type ?? this.type,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      mediaName: mediaName ?? this.mediaName,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Message && other.id == id);

  @override
  int get hashCode => id.hashCode;
}
