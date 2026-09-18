import 'dart:async';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:planpal/domain/models/user.dart';
import 'package:planpal/infrastructure/repositories/user_repository.dart';
/// Hive-backed implementation of [UserRepository].
/// Box name: 'users'
class HiveUserRepository implements UserRepository {
  HiveUserRepository(this._box);

  static const String currentUserIdKey = 'current_user';
  final Box<User> _box;

  // ── UserRepository ────────────────────────────────────────────────────────

  @override
  Future<User?> getCurrentUser() async =>
      _box.get(currentUserIdKey) ?? _box.values.firstOrNull;

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
        .watch(key: currentUserIdKey)
        .listen((_) => emit());

    controller.onCancel = () {
      subscription.cancel();
      controller.close();
    };

    return controller.stream;
  }
}
