import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../shared/utils/duration_formatter.dart';
import '../../category/application/category_providers.dart';
import '../../category/domain/category.dart';
import '../application/manual_record_providers.dart';
import '../application/session_list_providers.dart';
import '../domain/day_session_group.dart';
import 'manual_record_sheet.dart';
import '../../../shared/widgets/confirm_dialog.dart';
import '../../../shared/widgets/top_toast.dart';
import 'widgets/session_card.dart';

class HistoryPage extends ConsumerWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupsAsync = ref.watch(groupedSessionListProvider);
    final categoriesAsync = ref.watch(categoriesListProvider);
    final categories = categoriesAsync.value ?? const <Category>[];
    final categoryMap = {for (final c in categories) c.id: c};

    return Scaffold(
      appBar: AppBar(title: const Text('履歴')),
      body: groupsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('読み込みに失敗しました: $e')),
        data: (data) {
          if (data.groups.isEmpty) return const _EmptyState();
          return _GroupedSessionList(
            groups: data.groups,
            categoryMap: categoryMap,
            isTruncated: data.isTruncated,
            totalCount: data.totalCount,
            displayedCount: data.displayedCount,
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => ManualRecordSheet.show(context),
        tooltip: '手動で記録',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _GroupedSessionList extends ConsumerWidget {
  const _GroupedSessionList({
    required this.groups,
    required this.categoryMap,
    required this.isTruncated,
    required this.totalCount,
    required this.displayedCount,
  });

  final List<DaySessionGroup> groups;
  final Map<String, Category> categoryMap;
  final bool isTruncated;
  final int totalCount;
  final int displayedCount;

  Future<bool> _confirmDelete(BuildContext context) {
    return showDeleteConfirmDialog(
      context: context,
      message: 'この記録を削除します。',
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CustomScrollView(
      slivers: [
        for (final group in groups) ...[
          SliverPersistentHeader(
            pinned: true,
            delegate: _DateHeaderDelegate(group: group),
          ),
          SliverList.separated(
            itemCount: group.sessions.length,
            separatorBuilder: (_, __) => const SizedBox(height: 4),
            itemBuilder: (context, index) {
              final session = group.sessions[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Dismissible(
                  key: ValueKey(session.id),
                  direction: DismissDirection.endToStart,
                  background: _DismissBackground(),
                  confirmDismiss: (_) => _confirmDelete(context),
                  onDismissed: (_) async {
                    try {
                      await ref
                          .read(manualRecordControllerProvider.notifier)
                          .delete(session.id);
                      if (context.mounted) {
                        TopToast.show(context, message: '記録を削除しました');
                      }
                    } catch (e) {
                      if (context.mounted) {
                        TopToast.show(
                          context,
                          message: '削除に失敗しました: $e',
                          isError: true,
                        );
                      }
                    }
                  },
                  child: SessionCard(
                    session: session,
                    category: categoryMap[session.categoryId],
                    onTap: () => ManualRecordSheet.show(
                      context,
                      initial: session,
                    ),
                  ),
                ),
              );
            },
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 8)),
        ],
        if (isTruncated)
          SliverToBoxAdapter(
            child: _TruncationNotice(
              totalCount: totalCount,
              displayedCount: displayedCount,
            ),
          ),
        const SliverToBoxAdapter(child: SizedBox(height: 80)),
      ],
    );
  }
}

class _TruncationNotice extends StatelessWidget {
  const _TruncationNotice({
    required this.totalCount,
    required this.displayedCount,
  });

  final int totalCount;
  final int displayedCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
      child: Column(
        children: [
          Icon(
            Icons.history,
            size: 20,
            color: theme.colorScheme.outline,
          ),
          const SizedBox(height: 6),
          Text(
            '直近 $displayedCount 件を表示中（全 $totalCount 件）',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'それ以前の記録はカレンダー・統計から確認できます',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _DateHeaderDelegate extends SliverPersistentHeaderDelegate {
  _DateHeaderDelegate({required this.group});

  final DaySessionGroup group;

  static final _amountFormatter = NumberFormat('#,###');

  @override
  double get minExtent => 44;

  @override
  double get maxExtent => 44;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final theme = Theme.of(context);
    return Container(
      color: theme.colorScheme.surface,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      alignment: Alignment.center,
      child: Row(
        children: [
          Text(
            _headerLabel(group.date),
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          Text(
            DurationFormatter.hourMinute(group.totalDurationSec),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '${_amountFormatter.format(group.totalAmount)} 円',
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(_DateHeaderDelegate old) =>
      old.group.date != group.date ||
      old.group.totalAmount != group.totalAmount ||
      old.group.totalDurationSec != group.totalDurationSec;

  static String _headerLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    if (date == today) return '今日';
    if (date == yesterday) return '昨日';
    if (date.year == today.year) {
      return DateFormat('M月d日 (E)', 'ja').format(date);
    }
    return DateFormat('yyyy年M月d日 (E)', 'ja').format(date);
  }
}

class _DismissBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.error,
        borderRadius: BorderRadius.circular(16),
      ),
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 24),
      child: const Icon(Icons.delete, color: Colors.white),
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
                Icons.history_edu_outlined,
                size: 48,
                color: theme.colorScheme.outline,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'まだ記録がありません',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'タイマーで計測するか、\n右下のボタンから手動で記録できます',
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
