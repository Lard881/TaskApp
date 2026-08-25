import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:planpal/core/constants/app_colors.dart';
import 'package:planpal/domain/enums/task_priority.dart';
import 'package:planpal/presentation/widgets/priority_badge.dart';

Widget buildBadge({required TaskPriority priority, bool isCompleted = false}) {
  return MaterialApp(
    home: Scaffold(
      body: PriorityBadge(priority: priority, isCompleted: isCompleted),
    ),
  );
}

void main() {
  group('PriorityBadge — labels', () {
    testWidgets('shows "High" for high priority', (tester) async {
      await tester.pumpWidget(buildBadge(priority: TaskPriority.high));
      expect(find.textContaining('High'), findsOneWidget);
    });

    testWidgets('shows "Med" for medium priority', (tester) async {
      await tester.pumpWidget(buildBadge(priority: TaskPriority.medium));
      expect(find.textContaining('Med'), findsOneWidget);
    });

    testWidgets('shows "Low" for low priority', (tester) async {
      await tester.pumpWidget(buildBadge(priority: TaskPriority.low));
      expect(find.textContaining('Low'), findsOneWidget);
    });
  });

  group('PriorityBadge — completed state', () {
    testWidgets('shows an Icon (checkmark) when isCompleted = true',
        (tester) async {
      await tester.pumpWidget(
          buildBadge(priority: TaskPriority.high, isCompleted: true));
      // No text label — just an icon
      expect(find.byType(Icon), findsOneWidget);
      expect(find.textContaining('High'), findsNothing);
    });

    testWidgets('icon is green (success color) when completed', (tester) async {
      await tester.pumpWidget(
          buildBadge(priority: TaskPriority.low, isCompleted: true));
      final icon = tester.widget<Icon>(find.byType(Icon));
      expect(icon.color, AppColors.success);
    });

    testWidgets('shows badge (not icon) when isCompleted = false',
        (tester) async {
      await tester.pumpWidget(
          buildBadge(priority: TaskPriority.medium, isCompleted: false));
      expect(find.byType(Container), findsWidgets);
      expect(find.textContaining('Med'), findsOneWidget);
    });
  });

  group('PriorityBadge — colors', () {
    testWidgets('high priority uses red color family', (tester) async {
      await tester.pumpWidget(buildBadge(priority: TaskPriority.high));
      // Find a Text widget and check its color
      final texts = tester.widgetList<Text>(find.byType(Text));
      final priorityText = texts.firstWhere(
        (t) => t.data != null && t.data!.contains('High'),
      );
      final style = priorityText.style;
      expect(style?.color, AppColors.priorityHigh);
    });

    testWidgets('low priority uses green color family', (tester) async {
      await tester.pumpWidget(buildBadge(priority: TaskPriority.low));
      final texts = tester.widgetList<Text>(find.byType(Text));
      final priorityText = texts.firstWhere(
        (t) => t.data != null && t.data!.contains('Low'),
      );
      expect(priorityText.style?.color, AppColors.priorityLow);
    });
  });
}
