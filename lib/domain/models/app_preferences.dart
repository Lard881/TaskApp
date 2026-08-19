import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'app_preferences_adapter.dart';

/// Persisted user preferences — theme, language, timezone, notifications.
/// Hive typeId: 5
///
/// A single instance is stored in the preferences box under the key 'prefs'.
class AppPreferences {
  const AppPreferences({
    required this.themeMode,
    required this.languageCode,
    required this.timeZoneId,
    required this.notifyTaskReminders,
    required this.notifyDueDateAlerts,
    required this.notifyChatMessages,
    required this.notifyWeeklySummary,
  });

  final ThemeMode themeMode;         // light | dark | system
  final String languageCode;          // BCP-47, e.g. "en"
  final String timeZoneId;            // IANA or "local"
  final bool notifyTaskReminders;
  final bool notifyDueDateAlerts;
  final bool notifyChatMessages;
  final bool notifyWeeklySummary;

  /// Default preferences for a fresh install (Req 24.4).
  static const AppPreferences defaults = AppPreferences(
    themeMode: ThemeMode.light,
    languageCode: 'en',
    timeZoneId: 'local',
    notifyTaskReminders: true,
    notifyDueDateAlerts: true,
    notifyChatMessages: true,
    notifyWeeklySummary: true,
  );

  AppPreferences copyWith({
    ThemeMode? themeMode,
    String? languageCode,
    String? timeZoneId,
    bool? notifyTaskReminders,
    bool? notifyDueDateAlerts,
    bool? notifyChatMessages,
    bool? notifyWeeklySummary,
  }) {
    return AppPreferences(
      themeMode: themeMode ?? this.themeMode,
      languageCode: languageCode ?? this.languageCode,
      timeZoneId: timeZoneId ?? this.timeZoneId,
      notifyTaskReminders: notifyTaskReminders ?? this.notifyTaskReminders,
      notifyDueDateAlerts: notifyDueDateAlerts ?? this.notifyDueDateAlerts,
      notifyChatMessages: notifyChatMessages ?? this.notifyChatMessages,
      notifyWeeklySummary: notifyWeeklySummary ?? this.notifyWeeklySummary,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppPreferences &&
          themeMode == other.themeMode &&
          languageCode == other.languageCode &&
          timeZoneId == other.timeZoneId &&
          notifyTaskReminders == other.notifyTaskReminders &&
          notifyDueDateAlerts == other.notifyDueDateAlerts &&
          notifyChatMessages == other.notifyChatMessages &&
          notifyWeeklySummary == other.notifyWeeklySummary;

  @override
  int get hashCode => Object.hash(
        themeMode,
        languageCode,
        timeZoneId,
        notifyTaskReminders,
        notifyDueDateAlerts,
        notifyChatMessages,
        notifyWeeklySummary,
      );
}
