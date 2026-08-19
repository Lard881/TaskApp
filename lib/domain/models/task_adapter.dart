part of 'task.dart';

/// Hive TypeAdapter for [Task]. typeId: 0
///
/// Field index map:
///   0  id
///   1  name
///   2  dueDate        (int? — millisecondsSinceEpoch)
///   3  dueHour        (int? — TimeOfDay.hour)
///   4  dueMinute      (int? — TimeOfDay.minute)
///   5  priority       (int — TaskPriority.index)
///   6  status         (int — TaskStatus.index)
///   7  assigneeId
///   8  description
///   9  createdAt      (int — millisecondsSinceEpoch)
///   10 updatedAt      (int — millisecondsSinceEpoch)
class TaskAdapter extends TypeAdapter<Task> {
  @override
  final int typeId = 0;

  @override
  Task read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Task(
      id: fields[0] as String,
      name: fields[1] as String,
      dueDate: fields[2] != null
          ? DateTime.fromMillisecondsSinceEpoch(fields[2] as int)
          : null,
      dueTime: fields[3] != null
          ? TimeOfDay(
              hour: fields[3] as int,
              minute: fields[4] as int,
            )
          : null,
      priority: TaskPriority.values[fields[5] as int],
      status: TaskStatus.values[fields[6] as int],
      assigneeId: fields[7] as String?,
      description: fields[8] as String?,
      createdAt:
          DateTime.fromMillisecondsSinceEpoch(fields[9] as int),
      updatedAt:
          DateTime.fromMillisecondsSinceEpoch(fields[10] as int),
    );
  }

  @override
  void write(BinaryWriter writer, Task obj) {
    writer.writeByte(11); // number of fields
    writer
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.dueDate?.millisecondsSinceEpoch)
      ..writeByte(3)
      ..write(obj.dueTime?.hour)
      ..writeByte(4)
      ..write(obj.dueTime?.minute)
      ..writeByte(5)
      ..write(obj.priority.index)
      ..writeByte(6)
      ..write(obj.status.index)
      ..writeByte(7)
      ..write(obj.assigneeId)
      ..writeByte(8)
      ..write(obj.description)
      ..writeByte(9)
      ..write(obj.createdAt.millisecondsSinceEpoch)
      ..writeByte(10)
      ..write(obj.updatedAt.millisecondsSinceEpoch);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
