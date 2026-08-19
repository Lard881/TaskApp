import 'package:hive/hive.dart';

part 'message_adapter.dart';

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
  });

  final String id;
  final String conversationId; // references Conversation.id
  final String senderId;       // references User.id
  final String text;
  final DateTime sentAt;
  final bool isRead;

  Message copyWith({
    String? id,
    String? conversationId,
    String? senderId,
    String? text,
    DateTime? sentAt,
    bool? isRead,
  }) {
    return Message(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      senderId: senderId ?? this.senderId,
      text: text ?? this.text,
      sentAt: sentAt ?? this.sentAt,
      isRead: isRead ?? this.isRead,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Message && other.id == id);

  @override
  int get hashCode => id.hashCode;
}
