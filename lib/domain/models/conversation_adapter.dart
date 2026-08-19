part of 'conversation.dart';

/// Hive TypeAdapter for [Conversation]. typeId: 2
///
/// Field index map:
///   0  id
///   1  name
///   2  participantIds  (List<String>)
///   3  avatarPath
///   4  lastMessagePreview
///   5  lastMessageAt   (int — millisecondsSinceEpoch)
///   6  unreadCount
///   7  isGroup
class ConversationAdapter extends TypeAdapter<Conversation> {
  @override
  final int typeId = 2;

  @override
  Conversation read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Conversation(
      id: fields[0] as String,
      name: fields[1] as String,
      participantIds: (fields[2] as List).cast<String>(),
      avatarPath: fields[3] as String?,
      lastMessagePreview: fields[4] as String,
      lastMessageAt:
          DateTime.fromMillisecondsSinceEpoch(fields[5] as int),
      unreadCount: fields[6] as int,
      isGroup: fields[7] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Conversation obj) {
    writer.writeByte(8);
    writer
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.participantIds)
      ..writeByte(3)
      ..write(obj.avatarPath)
      ..writeByte(4)
      ..write(obj.lastMessagePreview)
      ..writeByte(5)
      ..write(obj.lastMessageAt.millisecondsSinceEpoch)
      ..writeByte(6)
      ..write(obj.unreadCount)
      ..writeByte(7)
      ..write(obj.isGroup);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConversationAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
