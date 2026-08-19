import 'dart:async';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:planpal/domain/models/user.dart';
import 'package:planpal/infrastructure/mock/mock_data.dart';
import 'package:planpal/infrastructure/repositories/user_repository.dart';

/// Hive-backed implementation of [UserRepository].
/// Box name: 'users'
///
/// The current user is always stored under the key [MockData.currentUserId].
class HiveUserRepository implements UserRepository {
  HiveUserRepository(this._box);

  final Box<User> _box;

  // ── Seeding ───────────────────────────────────────────────────────────────

  Future<void> seedIfEmpty() async {
    if (_box.isEmpty) {
      for (final user in MockData.users) {
        await _box.put(user.id, user);
      }
    }
  }

  // ── UserRepository ────────────────────────────────────────────────────────

  @override
  Future<User?> getCurrentUser() async =>
      _box.get(MockData.currentUserId);

  @override
  Future<List<User>> getAll() async => _box.values.toList();

  @override
  Future<User?> getById(String id) async => _box.get(id);

  @override
  Future<void> save(User user) => _box.put(user.id, user);

  @override
  Stream<User?> watchCurrentUser() {
    final controller = StreamController<User?>.broadcast();

    Future<void> emit() async {
      if (!controller.isClosed) {
        controller.add(await getCurrentUser());
      }
    }

    emit();

    final subscription = _box
        .watch(key: MockData.currentUserId)
        .listen((_) => emit());

    controller.onCancel = () {
      subscription.cancel();
      controller.close();
    };

    return controller.stream;
  }
}
