import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:planpal/domain/enums/filter_tab.dart';
import 'package:planpal/domain/enums/sort_option.dart';
import 'package:planpal/domain/models/task.dart';

/// Holds the currently active [FilterTab] on the Tasks screen.
/// Defaults to [FilterTab.all] (Req 6.3).
class TaskFilterNotifier extends StateNotifier<FilterTab> {
  TaskFilterNotifier() : super(FilterTab.all);

  void setFilter(FilterTab tab) => state = tab;
  void reset() => state = FilterTab.all;
}

final taskFilterProvider =
    StateNotifierProvider<TaskFilterNotifier, FilterTab>(
  (ref) => TaskFilterNotifier(),
);

// ─────────────────────────────────────────────────────────────────────────────

/// Holds the currently active [SortOption] on the Tasks screen.
/// Defaults to [SortOption.dueDateAsc] (Req 8.4).
/// Resets to default when the notifier is disposed (navigating away — Req 8.8).
class TaskSortNotifier extends StateNotifier<SortOption> {
  TaskSortNotifier() : super(SortOption.dueDateAsc);

  void setSort(SortOption option) => state = option;
  void reset() => state = SortOption.dueDateAsc;
}

final taskSortProvider =
    StateNotifierProvider<TaskSortNotifier, SortOption>(
  (ref) => TaskSortNotifier(),
);

// ─────────────────────────────────────────────────────────────────────────────
// Pure filter and sort functions — no side effects, easily unit-tested.
// ─────────────────────────────────────────────────────────────────────────────

/// Filters [tasks] according to [tab].
List<Task> filterTasks(List<Task> tasks, FilterTab tab) {
  switch (tab) {
    case FilterTab.all:
      return tasks;
    case FilterTab.today:
      return tasks.where((t) => t.isDueToday).toList();
    case FilterTab.upcoming:
      return tasks
          .where((t) =>
              t.dueDate != null &&
              t.dueDate!.isAfter(
                DateTime(
                  DateTime.now().year,
                  DateTime.now().month,
                  DateTime.now().day,
                ),
              ) &&
              t.status != TaskStatus.completed)
          .toList();
    case FilterTab.completed:
      return tasks.where((t) => t.status == TaskStatus.completed).toList();
  }
}

/// Sorts [tasks] according to [option].
/// Null due-dates always go to the end for date-based sorts (Req 8.7).
/// Null priorities always go to the end for priority-based sorts (Req 8.6).
List<Task> sortTasks(List<Task> tasks, SortOption option) {
  final copy = List<Task>.from(tasks);
  switch (option) {
    case SortOption.dueDateAsc:
      copy.sort((a, b) {
        if (a.dueDate == null && b.dueDate == null) return 0;
        if (a.dueDate == null) return 1;
        if (b.dueDate == null) return -1;
        return a.dueDate!.compareTo(b.dueDate!);
      });
    case SortOption.dueDateDesc:
      copy.sort((a, b) {
        if (a.dueDate == null && b.dueDate == null) return 0;
        if (a.dueDate == null) return 1;
        if (b.dueDate == null) return -1;
        return b.dueDate!.compareTo(a.dueDate!);
      });
    case SortOption.priorityHighToLow:
      copy.sort(
          (a, b) => a.priority.sortWeight.compareTo(b.priority.sortWeight));
    case SortOption.priorityLowToHigh:
      copy.sort(
          (a, b) => b.priority.sortWeight.compareTo(a.priority.sortWeight));
    case SortOption.nameAZ:
      copy.sort((a, b) =>
          a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    case SortOption.nameZA:
      copy.sort((a, b) =>
          b.name.toLowerCase().compareTo(a.name.toLowerCase()));
  }
  return copy;
}
