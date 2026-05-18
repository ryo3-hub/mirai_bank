import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../category/application/category_providers.dart';
import '../../../category/domain/category.dart';
import '../../../category/domain/category_presets.dart';
import '../../../goals/application/goal_providers.dart';
import '../../../goals/domain/goal.dart';
import '../../../goals/domain/goal_progress.dart';

class DashboardGoalsSection extends ConsumerWidget {
  const DashboardGoalsSection({super.key});

  static const int _maxDisplay = 2;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressAsync = ref.watch(activeGoalsWithProgressProvider);
    final categoriesAsync = ref.watch(categoriesListProvider);
    final categories = categoriesAsync.value ?? const <Category>[];
    final categoryMap = {for (final c in categories) c.id: c};
    final progresses = progressAsync.value ?? const <GoalProgress>[];
    if (progresses.isEmpty) return const SizedBox.shrink();
    final visible = progresses.take(_maxDisplay).toList();
    final more = progresses.length - visible.length;

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(
                  Icons.flag,
                  size: 18,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 6),
                Text(
                  '目標',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => context.push('/settings/goals'),
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                  ),
                  child: Text(more > 0 ? '他 $more 件' : 'すべて見る'),
                ),
              ],
            ),
            const SizedBox(height: 4),
            for (final p in visible)
              _GoalProgressRow(
                progress: p,
                category: p.goal.categoryId == null
                    ? null
                    : categoryMap[p.goal.categoryId],
              ),
          ],
        ),
      ),
    );
  }
}

class _GoalProgressRow extends StatelessWidget {
  const _GoalProgressRow({required this.progress, required this.category});

  final GoalProgress progress;
  final Category? category;

  static final _formatter = NumberFormat('#,###');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final goal = progress.goal;
    final color = category != null
        ? CategoryPresets.colorFor(category!.colorCode)
        : theme.colorScheme.primary;
    final percent = (progress.ratio * 100).round();
    final label = category?.name ??
        (goal.type == GoalType.cumulative ? '累計目標' : '期間目標');
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '$percent%',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress.ratio,
              minHeight: 6,
              backgroundColor: color.withValues(alpha: 0.12),
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${_formatter.format(progress.currentAmount)} / '
            '${_formatter.format(goal.targetAmount)} 円',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
