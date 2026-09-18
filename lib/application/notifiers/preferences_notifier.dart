import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:planpal/application/providers/supabase_providers.dart';
import 'package:planpal/domain/models/app_preferences.dart';
import 'package:planpal/infrastructure/repositories/preferences_repository.dart';

/// Manages app-wide preferences: theme, language, timezone, notifications.
class PreferencesNotifier extends AsyncNotifier<AppPreferences> {
  late final PreferencesRepository _repo;

  @override
  Future<AppPreferences> build() async {
    _repo = ref.watch(preferencesRepositoryProvider);

    // Live updates via Supabase Realtime
    _repo.watch().listen((prefs) {
      if (state is! AsyncLoading) state = AsyncData(prefs);
    });

    return _repo.get();
  }

  // ── Setters ───────────────────────────────────────────────────────────────

  Future<void> setTheme(ThemeMode mode) => _update(
        (p) => p.copyWith(themeMode: mode),
      );

  Future<void> setLanguage(String languageCode) => _update(
        (p) => p.copyWith(languageCode: languageCode),
      );

  Future<void> setTimeZone(String timeZoneId) => _update(
        (p) => p.copyWith(timeZoneId: timeZoneId),
      );

  Future<void> setTaskReminders(bool value) => _update(
        (p) => p.copyWith(notifyTaskReminders: value),
      );

  Future<void> setDueDateAlerts(bool value) => _update(
        (p) => p.copyWith(notifyDueDateAlerts: value),
      );

  Future<void> setChatMessages(bool value) => _update(
        (p) => p.copyWith(notifyChatMessages: value),
      );

  Future<void> setWeeklySummary(bool value) => _update(
        (p) => p.copyWith(notifyWeeklySummary: value),
      );

  // ── Helper ────────────────────────────────────────────────────────────────

  Future<void> _update(AppPreferences Function(AppPreferences) updater) async {
    final current = state.valueOrNull ?? AppPreferences.defaults;
    final updated = updater(current);
    await _repo.save(updated);
    // State will update via the Hive stream listener, but set optimistically
    state = AsyncData(updated);
  }
}

/// The preferences provider — watched by MaterialApp for theme changes.
final preferencesProvider =
    AsyncNotifierProvider<PreferencesNotifier, AppPreferences>(
  PreferencesNotifier.new,
);

/// Convenience: just the ThemeMode — MaterialApp watches this selector
/// so only the root rebuilds on theme change (Req 21.5).
final themeModeProvider = Provider<ThemeMode>((ref) {
  return ref
      .watch(preferencesProvider)
      .whenData((p) => p.themeMode)
      .valueOrNull ?? ThemeMode.light;
});

/// Convenience: just the language code.
final languageCodeProvider = Provider<String>((ref) {
  return ref
      .watch(preferencesProvider)
      .whenData((p) => p.languageCode)
      .valueOrNull ?? 'en';
});
