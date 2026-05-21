import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/widgets/reorder_proxy_decorator.dart';
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
          return _GoalListBody(
            active: active,
            achieved: achieved,
            categoryMap: categoryMap,
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => GoalEditSheet.show(context),
        tooltip: '目標を追加',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _GoalListBody extends ConsumerStatefulWidget {
  const _GoalListBody({
    required this.active,
    required this.achieved,
    required this.categoryMap,
  });

  final List<GoalProgress> active;
  final List<Goal> achieved;
  final Map<String, Category> categoryMap;

  @override
  ConsumerState<_GoalListBody> createState() => _GoalListBodyState();
}

/// 並び替え時のちらつきを抑えるため、ID の並び順だけローカル state で管理し、
/// 各 GoalProgress のデータは provider 経由で最新を参照する（issue #70）。
class _GoalListBodyState extends ConsumerState<_GoalListBody> {
  late List<String> _localOrder;

  @override
  void initState() {
    super.initState();
    _localOrder = widget.active.map((p) => p.goal.id).toList();
  }

  @override
  void didUpdateWidget(_GoalListBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    final newIds = widget.active.map((p) => p.goal.id).toSet();
    // 親から渡された一覧で消えた ID は削除、新しく増えた ID は末尾に追加。
    // それ以外は _localOrder の順序を維持して provider 更新によるちらつきを防ぐ。
    _localOrder.removeWhere((id) => !newIds.contains(id));
    for (final p in widget.active) {
      if (!_localOrder.contains(p.goal.id)) {
        _localOrder.add(p.goal.id);
      }
    }
  }

  Future<void> _onReorder(int oldIndex, int newIndex) {
    HapticFeedback.heavyImpact();
    // ReorderableListView の newIndex は「移動後の挿入先」を指すので、
    // 下方向への移動は -1 補正してリスト操作と整合させる。
    final adjustedNewIndex = newIndex > oldIndex ? newIndex - 1 : newIndex;
    setState(() {
      final id = _localOrder.removeAt(oldIndex);
      _localOrder.insert(adjustedNewIndex, id);
    });
    return ref
        .read(goalControllerProvider.notifier)
        .reorder(List<String>.from(_localOrder));
  }

  @override
  Widget build(BuildContext context) {
    final achieved = widget.achieved;
    final categoryMap = widget.categoryMap;
    final activeMap = {for (final p in widget.active) p.goal.id: p};
    final displayList = _localOrder
        .map((id) => activeMap[id])
        .whereType<GoalProgress>()
        .toList();

    if (displayList.isEmpty) {
      // 達成済みのみの場合は並び替え不要なので通常 ListView。
      return ListView(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 96),
        children: [
          _AchievedSection(goals: achieved, categoryMap: categoryMap),
        ],
      );
    }
    return ReorderableListView.builder(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 96),
      itemCount: displayList.length,
      proxyDecorator: roundedReorderProxy,
      onReorderStart: (_) => HapticFeedback.mediumImpact(),
      onReorder: _onReorder,
      header: _SectionLabel(label: 'アクティブ', count: displayList.length),
      footer: achieved.isEmpty
          ? null
          : Padding(
              padding: const EdgeInsets.only(top: 12),
              child: _AchievedSection(
                goals: achieved,
                categoryMap: categoryMap,
              ),
            ),
      itemBuilder: (context, index) {
        final progress = displayList[index];
        return Padding(
          key: ValueKey(progress.goal.id),
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: GoalCard(
            progress: progress,
            category: progress.goal.categoryId == null
                ? null
                : categoryMap[progress.goal.categoryId],
            onTap: () =>
                GoalEditSheet.show(context, initial: progress.goal),
          ),
        );
      },
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
          const Spacer(),
          Icon(
            Icons.drag_indicator,
            size: 16,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(width: 4),
          Text(
            '長押しで並び替え',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
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
