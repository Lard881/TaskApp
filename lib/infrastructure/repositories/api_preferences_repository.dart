import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:planpal/domain/models/app_preferences.dart';
import 'package:planpal/infrastructure/repositories/preferences_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiPreferencesRepository implements PreferencesRepository {
  static const _prefsKey = 'planpal_preferences';

  @override
  Future<AppPreferences> get() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_prefsKey);
    if (json == null || json.isEmpty) return AppPreferences.defaults;

    final decoded = jsonDecode(json) as Map<String, dynamic>;
    return AppPreferences(
      themeMode: switch (decoded['themeMode'] as String? ?? 'light') {
        'dark' => ThemeMode.dark,
        'system' => ThemeMode.system,
        _ => ThemeMode.light,
      },
      languageCode: decoded['languageCode'] as String? ?? 'en',
      timeZoneId: decoded['timeZoneId'] as String? ?? 'local',
      notifyTaskReminders: decoded['notifyTaskReminders'] as bool? ?? true,
      notifyDueDateAlerts: decoded['notifyDueDateAlerts'] as bool? ?? true,
      notifyChatMessages: decoded['notifyChatMessages'] as bool? ?? true,
      notifyWeeklySummary: decoded['notifyWeeklySummary'] as bool? ?? true,
    );
  }

  @override
  Future<void> save(AppPreferences preferences) async {
    final prefs = await SharedPreferences.getInstance();
    final payload = {
      'themeMode': preferences.themeMode.name,
      'languageCode': preferences.languageCode,
      'timeZoneId': preferences.timeZoneId,
      'notifyTaskReminders': preferences.notifyTaskReminders,
      'notifyDueDateAlerts': preferences.notifyDueDateAlerts,
      'notifyChatMessages': preferences.notifyChatMessages,
      'notifyWeeklySummary': preferences.notifyWeeklySummary,
    };
    await prefs.setString(_prefsKey, jsonEncode(payload));
  }

  @override
  Stream<AppPreferences> watch() => const Stream.empty();
}