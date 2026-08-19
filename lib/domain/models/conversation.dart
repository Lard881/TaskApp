import 'package:hive/hive.dart';

part 'conversation_adapter.dart';

/// Chat conversation metadata — either a direct message or a group chat.
/// Hive typeId: 2
class Conversation {
  const Conversation({
    required this.id,
    required this.name,
    required this.participantIds,
    required this.lastMessagePreview,
    required this.lastMessageAt,
    required this.unreadCount,
    required this.isGroup,
    this.avatarPath,
  });

  final String id;
  final String name;                    // group name or participant name
  final List<String> participantIds;    // list of User.id values
  final String? avatarPath;            // local path or null
  final String lastMessagePreview;     // single-line preview of last message
  final DateTime lastMessageAt;        // timestamp of last message
  final int unreadCount;               // 0 when all messages are read
  final bool isGroup;                  // true = group chat

  Conversation copyWith({
    String? id,
    String? name,
    List<String>? participantIds,
    String? avatarPath,
    String? lastMessagePreview,
    DateTime? lastMessageAt,
    int? unreadCount,
    bool? isGroup,
    bool clearAvatarPath = false,
  }) {
    return Conversation(
      id: id ?? this.id,
      name: name ?? this.name,
      participantIds: participantIds ?? this.participantIds,
      avatarPath: clearAvatarPath ? null : (avatarPath ?? this.avatarPath),
      lastMessagePreview: lastMessagePreview ?? this.lastMessagePreview,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      unreadCount: unreadCount ?? this.unreadCount,
      isGroup: isGroup ?? this.isGroup,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Conversation && other.id == id);

  @override
  int get hashCode => id.hashCode;
}
