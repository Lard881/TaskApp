import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:planpal/application/providers/supabase_providers.dart';
import 'package:planpal/domain/enums/activity_type.dart';
import 'package:planpal/domain/enums/task_status.dart';
import 'package:planpal/domain/models/activity_item.dart';
import 'package:planpal/domain/models/task.dart';
import 'package:planpal/infrastructure/repositories/conversation_repository.dart';
import 'package:planpal/infrastructure/repositories/task_repository.dart';
import 'package:uuid/uuid.dart';

/// Manages the full list of tasks for the active workspace.
/// Backed by [SupabaseTaskRepository] with Realtime updates.
class TaskNotifier extends AsyncNotifier<List<Task>> {
  late final TaskRepository _taskRepo;
  late final ConversationRepository _convRepo;
  static const _uuid = Uuid();

  @override
  Future<List<Task>> build() async {
    _taskRepo = ref.watch(taskRepositoryProvider);
    _convRepo = ref.watch(conversationRepositoryProvider);

    // Realtime stream — auto-updates state when DB changes
    _taskRepo.watch().listen((tasks) {
      if (state is! AsyncLoading) state = AsyncData(tasks);
    });

    return _taskRepo.getAll();
  }

  // ── CRUD ──────────────────────────────────────────────────────────────────

  Future<void> addTask(Task task) async {
    await _taskRepo.save(task);
    await _recordActivity(
        type: ActivityType.created,
        taskId: task.id,
        taskName: task.name);
  }

  Future<void> updateTask(Task task) async {
    final updated = task.copyWith(updatedAt: DateTime.now());
    await _taskRepo.save(updated);
    await _recordActivity(
        type: ActivityType.updated,
        taskId: task.id,
        taskName: task.name);
  }

  Future<void> deleteTask(String id) async {
    await _taskRepo.delete(id);
  }

  Future<void> markComplete(String id) async {
    final task = await _taskRepo.getById(id);
    if (task == null) return;
    final updated = task.copyWith(
        status: TaskStatus.completed, updatedAt: DateTime.now());
    await _taskRepo.save(updated);
    await _recordActivity(
        type: ActivityType.completed,
        taskId: task.id,
        taskName: task.name);
  }

  Future<void> reopenTask(String id) async {
    final task = await _taskRepo.getById(id);
    if (task == null) return;
    final updated = task.copyWith(
        status: TaskStatus.inProgress, updatedAt: DateTime.now());
    await _taskRepo.save(updated);
  }

  // ── Activity helper ───────────────────────────────────────────────────────

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

// ── Providers ─────────────────────────────────────────────────────────────────

final tasksProvider =
    AsyncNotifierProvider<TaskNotifier, List<Task>>(TaskNotifier.new);

/// Up to 5 tasks due today, sorted by due time.
final todayTasksProvider = Provider<List<Task>>((ref) {
  return ref.watch(tasksProvider).when(
    data: (tasks) {
      final today = tasks.where((t) => t.isDueToday).toList();
      today.sort((a, b) {
        final aHasTime = a.dueTime != null;
        final bHasTime = b.dueTime != null;
        if (aHasTime && bHasTime) {
          return (a.dueTime!.hour * 60 + a.dueTime!.minute)
              .compareTo(b.dueTime!.hour * 60 + b.dueTime!.minute);
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

/// Live performance metrics derived from all tasks.
final performanceProvider = Provider<PerformanceMetrics>((ref) {
  return ref.watch(tasksProvider).when(
    data: PerformanceMetrics.fromTasks,
    loading: () => const PerformanceMetrics(),
    error: (_, __) => const PerformanceMetrics(),
  );
});

// ── PerformanceMetrics ────────────────────────────────────────────────────────

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
  final int productivity;

  factory PerformanceMetrics.fromTasks(List<Task> tasks) {
    if (tasks.isEmpty) return const PerformanceMetrics();
    final completedCount =
        tasks.where((t) => t.status == TaskStatus.completed).length;
    final inProgressCount =
        tasks.where((t) => t.status == TaskStatus.inProgress).length;
    final overdueCount = tasks.where((t) => t.isOverdue).length;
    final productivity =
        ((completedCount / tasks.length) * 100).round();
    return PerformanceMetrics(
      completed: completedCount,
      inProgress: inProgressCount,
      overdue: overdueCount,
      productivity: productivity,
    );
  }
}
