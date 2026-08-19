import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:planpal/application/providers/hive_providers.dart';
import 'package:planpal/domain/enums/activity_type.dart';
import 'package:planpal/domain/enums/task_status.dart';
import 'package:planpal/domain/models/activity_item.dart';
import 'package:planpal/domain/models/task.dart';
import 'package:planpal/infrastructure/repositories/conversation_repository.dart';
import 'package:planpal/infrastructure/repositories/task_repository.dart';
import 'package:uuid/uuid.dart';

/// Manages the full list of tasks and exposes mutation methods.
/// Rebuilds whenever the underlying Hive box changes (via stream).
class TaskNotifier extends AsyncNotifier<List<Task>> {
  late final TaskRepository _taskRepo;
  late final ConversationRepository _convRepo;
  static const _uuid = Uuid();

  @override
  Future<List<Task>> build() async {
    _taskRepo = ref.watch(taskRepositoryProvider);
    _convRepo = ref.watch(conversationRepositoryProvider);

    // Keep state in sync with the Hive stream
    final stream = _taskRepo.watch();
    ref.listenSelf((_, __) {});
    ref.onDispose(() {});

    // Subscribe to the stream and update state on each emission
    stream.listen((tasks) {
      if (state is! AsyncLoading) {
        state = AsyncData(tasks);
      }
    });

    return _taskRepo.getAll();
  }

  // ── Mutations ─────────────────────────────────────────────────────────────

  /// Adds a new task and records a 'created' activity item.
  Future<void> addTask(Task task) async {
    await _taskRepo.save(task);
    await _recordActivity(
      type: ActivityType.created,
      taskId: task.id,
      taskName: task.name,
    );
  }

  /// Updates an existing task and records an 'updated' activity item.
  Future<void> updateTask(Task task) async {
    final updated = task.copyWith(updatedAt: DateTime.now());
    await _taskRepo.save(updated);
    await _recordActivity(
      type: ActivityType.updated,
      taskId: task.id,
      taskName: task.name,
    );
  }

  /// Deletes a task by [id].
  Future<void> deleteTask(String id) async {
    await _taskRepo.delete(id);
  }

  /// Marks a task as completed and records a 'completed' activity item.
  Future<void> markComplete(String id) async {
    final task = await _taskRepo.getById(id);
    if (task == null) return;
    final updated = task.copyWith(
      status: TaskStatus.completed,
      updatedAt: DateTime.now(),
    );
    await _taskRepo.save(updated);
    await _recordActivity(
      type: ActivityType.completed,
      taskId: task.id,
      taskName: task.name,
    );
  }

  /// Reopens a completed task by setting its status to [TaskStatus.inProgress].
  Future<void> reopenTask(String id) async {
    final task = await _taskRepo.getById(id);
    if (task == null) return;
    final updated = task.copyWith(
      status: TaskStatus.inProgress,
      updatedAt: DateTime.now(),
    );
    await _taskRepo.save(updated);
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  Future<void> _recordActivity({
    required ActivityType type,
    required String taskId,
    required String taskName,
  }) async {
    final item = ActivityItem(
      id: _uuid.v4(),
      type: type,
      taskId: taskId,
      taskName: taskName,
      timestamp: DateTime.now(),
    );
    await _convRepo.addActivity(item);
  }
}

/// The main tasks provider — async because Hive reads are async.
final tasksProvider =
    AsyncNotifierProvider<TaskNotifier, List<Task>>(TaskNotifier.new);

/// Derived provider: today's tasks, ordered and capped at 5 (Req 3.1).
final todayTasksProvider = Provider<List<Task>>((ref) {
  final tasksAsync = ref.watch(tasksProvider);
  return tasksAsync.when(
    data: (tasks) {
      final today = tasks.where((t) => t.isDueToday).toList();
      // Sort: timed tasks first by dueTime, then no-time by createdAt
      today.sort((a, b) {
        final aHasTime = a.dueTime != null;
        final bHasTime = b.dueTime != null;
        if (aHasTime && bHasTime) {
          final aMinutes = a.dueTime!.hour * 60 + a.dueTime!.minute;
          final bMinutes = b.dueTime!.hour * 60 + b.dueTime!.minute;
          return aMinutes.compareTo(bMinutes);
        }
        if (aHasTime) return -1;
        if (bHasTime) return 1;
        return a.createdAt.compareTo(b.createdAt);
      });
      return today.take(5).toList();
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

/// Derived provider: performance overview metrics (Req 5).
final performanceProvider = Provider<PerformanceMetrics>((ref) {
  final tasksAsync = ref.watch(tasksProvider);
  return tasksAsync.when(
    data: PerformanceMetrics.fromTasks,
    loading: () => const PerformanceMetrics(),
    error: (_, __) => const PerformanceMetrics(),
  );
});

/// Holds the four computed metrics shown in the Performance Overview widget.
class PerformanceMetrics {
  const PerformanceMetrics({
    this.completed = 0,
    this.inProgress = 0,
    this.overdue = 0,
    this.productivity = 0,
  });

  final int completed;
  final int inProgress;
  final int overdue;
  final int productivity; // percentage 0–100

  factory PerformanceMetrics.fromTasks(List<Task> tasks) {
    if (tasks.isEmpty) return const PerformanceMetrics();
    final completedCount =
        tasks.where((t) => t.status == TaskStatus.completed).length;
    final inProgressCount =
        tasks.where((t) => t.status == TaskStatus.inProgress).length;
    final overdueCount = tasks.where((t) => t.isOverdue).length;
    final productivity = ((completedCount / tasks.length) * 100).round();
    return PerformanceMetrics(
      completed: completedCount,
      inProgress: inProgressCount,
      overdue: overdueCount,
      productivity: productivity,
    );
  }
}
