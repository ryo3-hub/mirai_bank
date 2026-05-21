import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mirai_bank/features/goals/domain/goal.dart';
import 'package:mirai_bank/shared/achievement/widgets/goal_achievement_dialog.dart';

Goal _goal() => Goal(
      id: 'g1',
      type: GoalType.cumulative,
      targetAmount: 10000,
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    );

void main() {
  group('GoalAchievementDialog', () {
    testWidgets('closes cleanly with no leftover barrier when 「閉じる」 tapped',
        (tester) async {
      var underlyingTapCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextButton(
                      key: const Key('underlying'),
                      onPressed: () => underlyingTapCount++,
                      child: const Text('underlying button'),
                    ),
                    TextButton(
                      key: const Key('open'),
                      onPressed: () => GoalAchievementDialog.show(
                        context,
                        goal: _goal(),
                      ),
                      child: const Text('open'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byKey(const Key('open')));
      await tester.pump();
      // Dialog is shown.
      expect(find.text('達成！'), findsOneWidget);
      expect(find.text('閉じる'), findsOneWidget);

      // Close the dialog.
      await tester.tap(find.text('閉じる'));
      // Allow dialog dismiss animation + confetti controller cleanup to settle.
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Dialog gone.
      expect(find.text('達成！'), findsNothing);
      expect(find.text('閉じる'), findsNothing);

      // No barrier left: underlying button must be tappable.
      await tester.tap(find.byKey(const Key('underlying')));
      await tester.pump();
      expect(underlyingTapCount, 1);
    });

    testWidgets('barrierDismissible: tapping outside also closes the dialog',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => Center(
                child: TextButton(
                  onPressed: () => GoalAchievementDialog.show(
                    context,
                    goal: _goal(),
                    categoryName: 'プログラミング',
                  ),
                  child: const Text('open'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pump();
      expect(find.text('達成！'), findsOneWidget);
      expect(find.text('プログラミング の累計目標'), findsOneWidget);

      // Tap the modal barrier (top-left corner is outside any dialog content).
      await tester.tapAt(const Offset(5, 5));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      expect(find.text('達成！'), findsNothing);
    });
  });
}
