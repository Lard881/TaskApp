import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:planpal/domain/models/app_preferences.dart';
import 'package:planpal/infrastructure/repositories/preferences_repository.dart';

/// Supabase-backed implementation of [PreferencesRepository].
///
/// Upserts a single row keyed on user_id in the `preferences` table.
class SupabasePreferencesRepository implements PreferencesRepository {
  SupabasePreferencesRepository(this._client);

  final SupabaseClient _client;

  String get _uid => _client.auth.currentUser!.id;

  // ── Helpers ───────────────────────────────────────────────────────────────

  AppPreferences _fromRow(Map<String, dynamic> row) => AppPreferences(
        themeMode: _parseTheme(row['theme_mode'] as String? ?? 'light'),
        languageCode: row['language_code'] as String? ?? 'en',
        timeZoneId: row['timezone_id'] as String? ?? 'UTC',
        notifyTaskReminders:
            row['notify_task_reminders'] as bool? ?? true,
        notifyDueDateAlerts:
            row['notify_due_date_alerts'] as bool? ?? true,
        notifyChatMessages:
            row['notify_chat_messages'] as bool? ?? true,
        notifyWeeklySummary:
            row['notify_weekly_summary'] as bool? ?? false,
      );

  Map<String, dynamic> _toRow(AppPreferences prefs) => {
        'user_id': _uid,
        'theme_mode': prefs.themeMode.name,
        'language_code': prefs.languageCode,
        'timezone_id': prefs.timeZoneId,
        'notify_task_reminders': prefs.notifyTaskReminders,
        'notify_due_date_alerts': prefs.notifyDueDateAlerts,
        'notify_chat_messages': prefs.notifyChatMessages,
        'notify_weekly_summary': prefs.notifyWeeklySummary,
        'updated_at': DateTime.now().toIso8601String(),
      };

  ThemeMode _parseTheme(String s) => switch (s) {
        'dark' => ThemeMode.dark,
        'system' => ThemeMode.system,
        _ => ThemeMode.light,
      };

  // ── Read ──────────────────────────────────────────────────────────────────

  @override
  Future<AppPreferences> get() async {
    final row = await _client
        .from('preferences')
        .select()
        .eq('user_id', _uid)
        .maybeSingle();

    if (row == null) return AppPreferences.defaults;
    return _fromRow(row as Map<String, dynamic>);
  }

  // ── Write ─────────────────────────────────────────────────────────────────

  @override
  Future<void> save(AppPreferences prefs) async {
    await _client.from('preferences').upsert(_toRow(prefs));
  }

  // ── Stream ────────────────────────────────────────────────────────────────

  @override
  Stream<AppPreferences> watch() {
    final controller = StreamController<AppPreferences>.broadcast();

    Future<void> emit() async {
      if (!controller.isClosed) controller.add(await get());
    }

    emit();

    final channel = _client
        .channel('preferences_$_uid')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'preferences',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: _uid,
          ),
          callback: (_) => emit(),
        )
        .subscribe();

    controller.onCancel = () {
      _client.removeChannel(channel);
      controller.close();
    };

    return controller.stream;
  }
}
