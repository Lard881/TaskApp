import 'package:planpal/domain/models/task.dart';

/// Abstract contract for task persistence.
/// The Hive implementation and any fake (test) implementation both satisfy
/// this interface, making the application layer fully testable.
abstract class TaskRepository {
  /// Returns all tasks sorted by creation date descending.
  Future<List<Task>> getAll();

  /// Returns a single task by [id], or `null` if not found.
  Future<Task?> getById(String id);

  /// Persists a new task or overwrites an existing one with the same id.
  Future<void> save(Task task);

  /// Removes the task with [id]. No-op if not found.
  Future<void> delete(String id);

  /// Emits the full task list whenever any task changes.
  Stream<List<Task>> watch();
}
