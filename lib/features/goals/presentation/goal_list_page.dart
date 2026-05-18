import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../category/application/category_providers.dart';
import '../../category/domain/category.dart';
import '../application/goal_providers.dart';
import '../domain/goal.dart';
import '../domain/goal_progress.dart';
import 'goal_edit_sheet.dart';
import 'widgets/goal_card.dart';

class GoalListPage extends ConsumerWidget {
  const GoalListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeAsync = ref.watch(activeGoalsWithProgressProvider);
    final achievedAsync = ref.watch(achievedGoalsProvider);
    final categoriesAsync = ref.watch(categoriesListProvider);
    final categories = categoriesAsync.value ?? const <Category>[];
    final categoryMap = {for (final c in categories) c.id: c};

    return Scaffold(
      appBar: AppBar(title: const Text('目標')),
      body: activeAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('読み込みに失敗しました: $e')),
        data: (active) {
          final achieved = achievedAsync.value ?? const <Goal>[];
          if (active.isEmpty && achieved.isEmpty) {
            return const _EmptyState();
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 96),
            children: [
              if (active.isNotEmpty) ...[
                _SectionLabel(label: 'アクティブ', count: active.length),
                const SizedBox(height: 4),
                for (final progress in active)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: GoalCard(
                      progress: progress,
                      category: progress.goal.categoryId == null
                          ? null
                          : categoryMap[progress.goal.categoryId],
                      onTap: () => GoalEditSheet.show(
                        context,
                        initial: progress.goal,
                      ),
                    ),
                  ),
              ],
              if (achieved.isNotEmpty) ...[
                const SizedBox(height: 12),
                _AchievedSection(
                  goals: achieved,
                  categoryMap: categoryMap,
                ),
              ],
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => GoalEditSheet.show(context),
        icon: const Icon(Icons.add),
        label: const Text('目標を追加'),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label, required this.count});

  final String label;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
      child: Row(
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(width: 8),
          Text(
            '$count件',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}

class _AchievedSection extends StatelessWidget {
  const _AchievedSection({
    required this.goals,
    required this.categoryMap,
  });

  final List<Goal> goals;
  final Map<String, Category> categoryMap;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        dividerColor: Colors.transparent,
      ),
      child: Card(
        child: ExpansionTile(
          title: Row(
            children: [
              Icon(
                Icons.emoji_events,
                size: 18,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                '達成済み (${goals.length})',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
          tilePadding: const EdgeInsets.symmetric(horizontal: 16),
          childrenPadding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
          children: [
            for (final goal in goals)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: GoalCard(
                  progress: GoalProgress(
                    goal: goal,
                    currentAmount: goal.targetAmount,
                  ),
                  category: goal.categoryId == null
                      ? null
                      : categoryMap[goal.categoryId],
                  onTap: () => GoalEditSheet.show(context, initial: goal),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.flag_outlined,
                size: 48,
                color: theme.colorScheme.outline,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'まだ目標がありません',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              '右下のボタンから\n累計・期間の目標を設定できます',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
