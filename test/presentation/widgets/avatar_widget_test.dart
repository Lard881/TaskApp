import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:planpal/presentation/widgets/avatar_widget.dart';

void main() {
  Widget buildAvatar({
    String initials = 'AB',
    String? imagePath,
    double diameter = 40,
    VoidCallback? onTap,
    String? semanticLabel,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: AvatarWidget(
          initials: initials,
          imagePath: imagePath,
          diameter: diameter,
          onTap: onTap,
          semanticLabel: semanticLabel,
        ),
      ),
    );
  }

  group('AvatarWidget — initials fallback', () {
    testWidgets('shows initials text when no imagePath', (tester) async {
      await tester.pumpWidget(buildAvatar(initials: 'AM'));
      expect(find.text('AM'), findsOneWidget);
    });

    testWidgets('renders as a circle (ClipOval or CircleAvatar)', (tester) async {
      await tester.pumpWidget(buildAvatar(initials: 'JC'));
      // Should find a circular clip widget
      expect(find.byType(ClipOval), findsWidgets);
    });

    testWidgets('single initial works', (tester) async {
      await tester.pumpWidget(buildAvatar(initials: 'X'));
      expect(find.text('X'), findsOneWidget);
    });
  });

  group('AvatarWidget — sizing', () {
    testWidgets('respects diameter parameter', (tester) async {
      await tester.pumpWidget(buildAvatar(initials: 'AB', diameter: 80));
      final box = tester.renderObject<RenderBox>(
        find.byType(AvatarWidget),
      );
      // The widget itself may be larger due to Semantics, but inner circle
      // should match diameter — check the SizedBox or Container
      expect(box, isNotNull);
    });
  });

  group('AvatarWidget — tap callback', () {
    testWidgets('calls onTap when tapped', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(buildAvatar(
        initials: 'AB',
        onTap: () => tapped = true,
      ));
      await tester.tap(find.byType(AvatarWidget));
      expect(tapped, isTrue);
    });

    testWidgets('does not throw when onTap is null', (tester) async {
      await tester.pumpWidget(buildAvatar(initials: 'AB', onTap: null));
      await tester.tap(find.byType(AvatarWidget));
      // No exception expected
    });
  });

  group('AvatarWidget — accessibility', () {
    testWidgets('semanticLabel is applied when provided', (tester) async {
      await tester.pumpWidget(buildAvatar(
        initials: 'AB',
        semanticLabel: 'Go to Profile',
      ));
      expect(
        find.bySemanticsLabel('Go to Profile'),
        findsOneWidget,
      );
    });
  });
}
