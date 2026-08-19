import 'dart:async';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:planpal/domain/models/task.dart';
import 'package:planpal/infrastructure/mock/mock_data.dart';
import 'package:planpal/infrastructure/repositories/task_repository.dart';

/// Hive-backed implementation of [TaskRepository].
/// Box name: 'tasks'
class HiveTaskRepository implements TaskRepository {
  HiveTaskRepository(this._box);

  final Box<Task> _box;

  // ── Seeding ───────────────────────────────────────────────────────────────

  /// Seeds the box with [MockData.tasks] if it is empty.
  Future<void> seedIfEmpty() async {
    if (_box.isEmpty) {
      for (final task in MockData.tasks) {
        await _box.put(task.id, task);
      }
    }
  }

  // ── TaskRepository ────────────────────────────────────────────────────────

  @override
  Future<List<Task>> getAll() async {
    return _box.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<Task?> getById(String id) async => _box.get(id);

  @override
  Future<void> save(Task task) => _box.put(task.id, task);

  @override
  Future<void> delete(String id) => _box.delete(id);

  @override
  Stream<List<Task>> watch() {
    // Emit the current list immediately, then emit on every change.
    final controller = StreamController<List<Task>>.broadcast();

    Future<void> emit() async {
      if (!controller.isClosed) {
        controller.add(await getAll());
      }
    }

    // Emit initial value
    emit();

    // Listen to box events
    final subscription = _box.watch().listen((_) => emit());

    controller.onCancel = () {
      subscription.cancel();
      controller.close();
    };

    return controller.stream;
  }
}
