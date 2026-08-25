import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:planpal/domain/enums/task_priority.dart';
import 'package:planpal/domain/enums/task_status.dart';
import 'package:planpal/domain/models/task.dart';
import 'package:planpal/presentation/widgets/priority_badge.dart';
import 'package:planpal/presentation/widgets/task_list_item.dart';

Task makeTask({
  String id = 'task-1',
  String name = 'Test Task',
  TaskStatus status = TaskStatus.todo,
  TaskPriority priority = TaskPriority.medium,
  DateTime? dueDate,
}) {
  final now = DateTime.now();
  return Task(
    id: id,
    name: name,
    priority: priority,
    status: status,
    dueDate: dueDate,
    createdAt: now,
    updatedAt: now,
  );
}

Widget buildItem(Task task, {VoidCallback? onTap, VoidCallback? onLongPress}) {
  return ProviderScope(
    child: MaterialApp(
      home: Scaffold(
        body: TaskListItem(
          task: task,
          onTap: onTap ?? () {},
          onLongPress: onLongPress,
        ),
      ),
    ),
  );
}

void main() {
  group('TaskListItem — task name', () {
    testWidgets('displays task name', (tester) async {
      await tester.pumpWidget(buildItem(makeTask(name: 'Design mockup')));
      await tester.pump();
      expect(find.text('Design mockup'), findsOneWidget);
    });
  });

  group('TaskListItem — completed state', () {
    testWidgets('completed task has strikethrough style', (tester) async {
      await tester.pumpWidget(
        buildItem(makeTask(name: 'Done task', status: TaskStatus.completed)),
      );
      await tester.pump();

      final texts = tester.widgetList<Text>(find.byType(Text));
      final taskNameText = texts.firstWhere(
        (t) => t.data == 'Done task',
        orElse: () => texts.first,
      );
      expect(
        taskNameText.style?.decoration,
        TextDecoration.lineThrough,
      );
    });

    testWidgets('non-completed task has no strikethrough', (tester) async {
      await tester.pumpWidget(
        buildItem(makeTask(name: 'Pending task', status: TaskStatus.todo)),
      );
      await tester.pump();

      final texts = tester.widgetList<Text>(find.byType(Text));
      final taskNameText = texts.firstWhere(
        (t) => t.data == 'Pending task',
        orElse: () => texts.first,
      );
      expect(
        taskNameText.style?.decoration,
        isNot(TextDecoration.lineThrough),
      );
    });
  });

  group('TaskListItem — priority badge', () {
    testWidgets('shows PriorityBadge widget', (tester) async {
      await tester.pumpWidget(buildItem(makeTask()));
      await tester.pump();
      // PriorityBadge is in the leading slot
      expect(find.byType(PriorityBadge), findsOneWidget);
    });
  });

  group('TaskListItem — tap', () {
    testWidgets('fires onTap when tapped', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(
          buildItem(makeTask(), onTap: () => tapped = true));
      await tester.pump();
      await tester.tap(find.byType(TaskListItem));
      expect(tapped, isTrue);
    });
  });

  group('TaskListItem — long press', () {
    testWidgets('fires onLongPress when long-pressed', (tester) async {
      bool longPressed = false;
      await tester.pumpWidget(buildItem(
        makeTask(),
        onLongPress: () => longPressed = true,
      ));
      await tester.pump();
      await tester.longPress(find.byType(TaskListItem));
      expect(longPressed, isTrue);
    });
  });

  group('TaskListItem — due date display', () {
    testWidgets('shows due date text when dueDate is set', (tester) async {
      final date = DateTime(2024, 6, 15);
      await tester.pumpWidget(buildItem(makeTask(dueDate: date)));
      await tester.pump();
      // 'Jun 15' or similar should appear
      expect(find.textContaining('Jun'), findsOneWidget);
    });

    testWidgets('shows "All day" when no due date', (tester) async {
      await tester.pumpWidget(buildItem(makeTask()));
      await tester.pump();
      expect(find.text('All day'), findsOneWidget);
    });
  });
}
