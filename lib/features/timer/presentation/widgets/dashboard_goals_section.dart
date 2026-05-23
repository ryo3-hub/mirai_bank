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
import '../../../goals/presentation/goal_edit_sheet.dart';

class DashboardGoalsSection extends ConsumerWidget {
  const DashboardGoalsSection({super.key});

  static const int _maxDisplay = 5;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressAsync = ref.watch(activeGoalsWithProgressProvider);
    final categoriesAsync = ref.watch(categoriesListProvider);
    final categories = categoriesAsync.value ?? const <Category>[];
    final categoryMap = {for (final c in categories) c.id: c};
    final progresses = progressAsync.value ?? const <GoalProgress>[];
    // issue #102: 目標が 0 件のときはホームから直接追加できる導線を出す。
    if (progresses.isEmpty) return const _AddGoalCard();
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

class _AddGoalCard extends StatelessWidget {
  const _AddGoalCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => GoalEditSheet.show(context),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.flag_outlined,
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '目標を追加',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '短期 / 中期 / 長期から選んで設定',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.add_circle,
                size: 28,
                color: theme.colorScheme.primary,
              ),
            ],
          ),
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
  static final _dateFormatter = DateFormat('M/d');

  String _periodLabel(Goal goal) {
    if (goal.type == GoalType.cumulative) return '累計';
    final preset = GoalPreset.fromGoal(goal);
    final end = goal.periodEnd;
    if (preset != null && end != null) {
      return '〜 ${_dateFormatter.format(end)}';
    }
    final start = goal.periodStart;
    if (start == null || end == null) return '期間';
    return '${_dateFormatter.format(start)} 〜 ${_dateFormatter.format(end)}';
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
    final label = category?.name ??
        preset?.label ??
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
          Row(
            children: [
              Expanded(
                child: Text(
                  '${_formatter.format(progress.currentAmount)} / '
                  '${_formatter.format(goal.targetAmount)} 円',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _periodLabel(goal),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
