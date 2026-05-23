import 'dart:math' as math;

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../features/goals/domain/goal.dart';

class GoalAchievementDialog extends StatefulWidget {
  const GoalAchievementDialog({
    super.key,
    required this.goal,
    this.categoryName,
  });

  final Goal goal;
  final String? categoryName;

  static Future<void> show(
    BuildContext context, {
    required Goal goal,
    String? categoryName,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (_) => GoalAchievementDialog(
        goal: goal,
        categoryName: categoryName,
      ),
    );
  }

  @override
  State<GoalAchievementDialog> createState() => _GoalAchievementDialogState();
}

class _GoalAchievementDialogState extends State<GoalAchievementDialog>
    with TickerProviderStateMixin {
  static final _amountFormatter = NumberFormat('#,###');

  late final ConfettiController _confetti;
  late final AnimationController _scale;

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(seconds: 2));
    _scale = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _confetti.play();
    _scale.forward();
  }

  @override
  void dispose() {
    _confetti.dispose();
    _scale.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final goal = widget.goal;
    final scope = widget.categoryName ?? '全カテゴリ';
    final preset = GoalPreset.fromGoal(goal);
    final typeLabel = preset?.label ??
        (goal.type == GoalType.cumulative ? '累計目標' : '期間目標');

    return Stack(
      alignment: Alignment.center,
      children: [
        Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          insetPadding: const EdgeInsets.symmetric(horizontal: 32),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ScaleTransition(
                  scale: CurvedAnimation(
                    parent: _scale,
                    curve: Curves.elasticOut,
                  ),
                  child: Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.emoji_events,
                      color: Colors.amber,
                      size: 64,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                FadeTransition(
                  opacity: _scale,
                  child: Text(
                    '達成！',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  '$scope の$typeLabel',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  '${_amountFormatter.format(goal.targetAmount)} 円',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _close,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('閉じる'),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Confetti は IgnorePointer で包んでヒットテストを通過させる。
        // 包まないと topCenter の Align が画面全体を覆い、barrier タップや
        // 「閉じる」周辺の入力を吸ってしまい、pop 後に黒幕が残ったように
        // 見える事象が出る（issue #49）。
        Positioned.fill(
          child: IgnorePointer(
            child: Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confetti,
                blastDirection: math.pi / 2,
                blastDirectionality: BlastDirectionality.explosive,
                shouldLoop: false,
                numberOfParticles: 30,
                emissionFrequency: 0.05,
                maxBlastForce: 22,
                minBlastForce: 8,
                gravity: 0.4,
                colors: const [
                  Colors.amber,
                  Colors.pinkAccent,
                  Colors.lightBlueAccent,
                  Colors.lightGreen,
                  Colors.deepOrangeAccent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _close() {
    Navigator.of(context, rootNavigator: true).pop();
  }
}
