part of 'activity_item.dart';

/// Hive TypeAdapter for [ActivityItem]. typeId: 4
///
/// Field index map:
///   0  id
///   1  type       (int — ActivityType.index)
///   2  taskId
///   3  taskName
///   4  timestamp  (int — millisecondsSinceEpoch)
class ActivityItemAdapter extends TypeAdapter<ActivityItem> {
  @override
  final int typeId = 4;

  @override
  ActivityItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ActivityItem(
      id: fields[0] as String,
      type: ActivityType.values[fields[1] as int],
      taskId: fields[2] as String?,
      taskName: fields[3] as String,
      timestamp: DateTime.fromMillisecondsSinceEpoch(fields[4] as int),
    );
  }

  @override
  void write(BinaryWriter writer, ActivityItem obj) {
    writer.writeByte(5);
    writer
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.type.index)
      ..writeByte(2)
      ..write(obj.taskId)
      ..writeByte(3)
      ..write(obj.taskName)
      ..writeByte(4)
      ..write(obj.timestamp.millisecondsSinceEpoch);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ActivityItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
