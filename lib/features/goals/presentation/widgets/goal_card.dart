import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../category/domain/category.dart';
import '../../../category/domain/category_presets.dart';
import '../../domain/goal.dart';
import '../../domain/goal_progress.dart';

class GoalCard extends StatelessWidget {
  const GoalCard({
    super.key,
    required this.progress,
    required this.category,
    this.onTap,
  });

  final GoalProgress progress;
  final Category? category;
  final VoidCallback? onTap;

  static final _amountFormatter = NumberFormat('#,###');

  static String _typeLabel(Goal goal) {
    final preset = GoalPreset.fromGoal(goal);
    if (preset != null) return preset.label.replaceAll('目標', '');
    return goal.type == GoalType.cumulative ? '累計' : '期間';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final goal = progress.goal;
    final color = category != null
        ? CategoryPresets.colorFor(category!.colorCode)
        : theme.colorScheme.primary;
    final percent = (progress.ratio * 100).round();
    final preset = GoalPreset.fromGoal(goal);

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _typeLabel(goal),
                      style: TextStyle(
                        color: color,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Category cluster wrapped in Expanded so a long name
                  // ellipsizes instead of pushing the 達成 badge off-screen.
                  Expanded(
                    child: category != null
                        ? Row(
                            children: [
                              CircleAvatar(
                                radius: 9,
                                backgroundColor: color,
                                foregroundColor: Colors.white,
                                child: Icon(
                                  CategoryPresets.iconFor(category!.iconCode),
                                  size: 10,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  category!.name,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: theme.textTheme.bodySmall,
                                ),
                              ),
                            ],
                          )
                        : Text(
                            '全カテゴリ',
                            style: theme.textTheme.bodySmall,
                          ),
                  ),
                  if (goal.isAchieved)
                    Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          size: 14,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '達成',
                          style: TextStyle(
                            color: theme.colorScheme.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              if (goal.type == GoalType.period && goal.periodEnd != null) ...[
                const SizedBox(height: 6),
                Text(
                  preset != null
                      ? '達成予定: ${DateFormat('yyyy/M/d').format(goal.periodEnd!)}'
                      : '${DateFormat('M/d').format(goal.periodStart!)} 〜 '
                          '${DateFormat('M/d').format(goal.periodEnd!)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    _amountFormatter.format(progress.currentAmount),
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w700,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                  Text(
                    ' / ${_amountFormatter.format(goal.targetAmount)} 円',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '$percent%',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: progress.ratio,
                  minHeight: 8,
                  backgroundColor: color.withValues(alpha: 0.12),
                  valueColor: AlwaysStoppedAnimation(color),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
