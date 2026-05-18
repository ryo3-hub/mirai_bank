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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final goal = progress.goal;
    final color = category != null
        ? CategoryPresets.colorFor(category!.colorCode)
        : theme.colorScheme.primary;
    final percent = (progress.ratio * 100).round();

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
                      goal.type == GoalType.cumulative ? '累計' : '期間',
                      style: TextStyle(
                        color: color,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (category != null)
                    Row(
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
                        Text(
                          category!.name,
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    )
                  else
                    Text(
                      '全カテゴリ',
                      style: theme.textTheme.bodySmall,
                    ),
                  const Spacer(),
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
              if (goal.type == GoalType.period && goal.periodStart != null) ...[
                const SizedBox(height: 6),
                Text(
                  '${DateFormat('M/d').format(goal.periodStart!)} 〜 '
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
