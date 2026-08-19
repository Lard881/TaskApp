part of 'message.dart';

/// Hive TypeAdapter for [Message]. typeId: 3
///
/// Field index map:
///   0  id
///   1  conversationId
///   2  senderId
///   3  text
///   4  sentAt   (int — millisecondsSinceEpoch)
///   5  isRead
class MessageAdapter extends TypeAdapter<Message> {
  @override
  final int typeId = 3;

  @override
  Message read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Message(
      id: fields[0] as String,
      conversationId: fields[1] as String,
      senderId: fields[2] as String,
      text: fields[3] as String,
      sentAt: DateTime.fromMillisecondsSinceEpoch(fields[4] as int),
      isRead: fields[5] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Message obj) {
    writer.writeByte(6);
    writer
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.conversationId)
      ..writeByte(2)
      ..write(obj.senderId)
      ..writeByte(3)
      ..write(obj.text)
      ..writeByte(4)
      ..write(obj.sentAt.millisecondsSinceEpoch)
      ..writeByte(5)
      ..write(obj.isRead);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MessageAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
