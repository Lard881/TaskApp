import 'dart:async';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:planpal/domain/models/app_preferences.dart';
import 'package:planpal/infrastructure/repositories/preferences_repository.dart';

/// Hive-backed implementation of [PreferencesRepository].
/// Box name: 'preferences'
///
/// A single [AppPreferences] object is stored under the key 'prefs'.
class HivePreferencesRepository implements PreferencesRepository {
  HivePreferencesRepository(this._box);

  final Box<AppPreferences> _box;

  static const String _key = 'prefs';

  // ── Seeding ───────────────────────────────────────────────────────────────

  Future<void> seedIfEmpty() async {
    if (_box.isEmpty) {
      await _box.put(_key, AppPreferences.defaults);
    }
  }

  // ── PreferencesRepository ─────────────────────────────────────────────────

  @override
  Future<AppPreferences> get() async =>
      _box.get(_key) ?? AppPreferences.defaults;

  @override
  Future<void> save(AppPreferences preferences) =>
      _box.put(_key, preferences);

  @override
  Stream<AppPreferences> watch() {
    final controller = StreamController<AppPreferences>.broadcast();

    Future<void> emit() async {
      if (!controller.isClosed) controller.add(await get());
    }

    emit();

    final subscription = _box.watch(key: _key).listen((_) => emit());

    controller.onCancel = () {
      subscription.cancel();
      controller.close();
    };

    return controller.stream;
  }
}
