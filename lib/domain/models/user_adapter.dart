part of 'user.dart';

/// Hive TypeAdapter for [User]. typeId: 1
///
/// Field index map:
///   0  id
///   1  firstName
///   2  lastName
///   3  role
///   4  email
///   5  phone
///   6  avatarPath
class UserAdapter extends TypeAdapter<User> {
  @override
  final int typeId = 1;

  @override
  User read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return User(
      id: fields[0] as String,
      firstName: fields[1] as String,
      lastName: fields[2] as String,
      role: fields[3] as String?,
      email: fields[4] as String,
      phone: fields[5] as String?,
      avatarPath: fields[6] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, User obj) {
    writer.writeByte(7);
    writer
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.firstName)
      ..writeByte(2)
      ..write(obj.lastName)
      ..writeByte(3)
      ..write(obj.role)
      ..writeByte(4)
      ..write(obj.email)
      ..writeByte(5)
      ..write(obj.phone)
      ..writeByte(6)
      ..write(obj.avatarPath);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
