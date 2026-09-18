part of 'app_preferences.dart';

/// Hive TypeAdapter for [AppPreferences]. typeId: 5
///
/// Field index map:
///   0  themeMode              (int — ThemeMode.index)
///   1  languageCode
///   2  timeZoneId
///   3  notifyTaskReminders
///   4  notifyDueDateAlerts
///   5  notifyChatMessages
///   6  notifyWeeklySummary
class AppPreferencesAdapter extends TypeAdapter<AppPreferences> {
  @override
  final int typeId = 5;

  @override
  AppPreferences read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AppPreferences(
      themeMode: ThemeMode.values[fields[0] as int],
      languageCode: fields[1] as String,
      timeZoneId: fields[2] as String,
      notifyTaskReminders: fields[3] as bool,
      notifyDueDateAlerts: fields[4] as bool,
      notifyChatMessages: fields[5] as bool,
      notifyWeeklySummary: fields[6] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, AppPreferences obj) {
    writer.writeByte(7);
    writer
      ..writeByte(0)
      ..write(obj.themeMode.index)
      ..writeByte(1)
      ..write(obj.languageCode)
      ..writeByte(2)
      ..write(obj.timeZoneId)
      ..writeByte(3)
      ..write(obj.notifyTaskReminders)
      ..writeByte(4)
      ..write(obj.notifyDueDateAlerts)
      ..writeByte(5)
      ..write(obj.notifyChatMessages)
      ..writeByte(6)
      ..write(obj.notifyWeeklySummary);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppPreferencesAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
