import 'package:planpal/domain/models/app_preferences.dart';

/// Abstract contract for app preferences persistence.
abstract class PreferencesRepository {
  /// Returns the current preferences, or [AppPreferences.defaults] if
  /// no preferences have been saved yet.
  Future<AppPreferences> get();

  /// Persists the full preferences object.
  Future<void> save(AppPreferences preferences);

  /// Emits updated preferences whenever they change.
  Stream<AppPreferences> watch();
}
