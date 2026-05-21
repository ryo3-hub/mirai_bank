import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../shared/widgets/confirm_dialog.dart';
import '../../../shared/widgets/top_toast.dart';
import '../application/category_providers.dart';
import '../domain/category.dart';
import '../domain/category_presets.dart';
import 'category_edit_sheet.dart';

class CategoryListPage extends ConsumerWidget {
  const CategoryListPage({super.key});

  static final _rateFormatter = NumberFormat('#,###');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesListProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('カテゴリ管理')),
      body: categoriesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('読み込みに失敗しました: $e')),
        data: (categories) {
          if (categories.isEmpty) {
            return const _EmptyState();
          }
          return _CategoryReorderableList(categories: categories);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => CategoryEditSheet.show(context),
        tooltip: '追加',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _CategoryReorderableList extends ConsumerStatefulWidget {
  const _CategoryReorderableList({required this.categories});

  final List<Category> categories;

  @override
  ConsumerState<_CategoryReorderableList> createState() =>
      _CategoryReorderableListState();
}

/// 並び替え時のちらつきを抑えるため、ID 順序だけローカル state で管理する
/// （issue #70）。Category データそのものは widget.categories から最新を参照。
class _CategoryReorderableListState
    extends ConsumerState<_CategoryReorderableList> {
  late List<String> _localOrder;

  @override
  void initState() {
    super.initState();
    _localOrder = widget.categories.map((c) => c.id).toList();
  }

  @override
  void didUpdateWidget(_CategoryReorderableList oldWidget) {
    super.didUpdateWidget(oldWidget);
    final newIds = widget.categories.map((c) => c.id).toSet();
    _localOrder.removeWhere((id) => !newIds.contains(id));
    for (final c in widget.categories) {
      if (!_localOrder.contains(c.id)) {
        _localOrder.add(c.id);
      }
    }
  }

  Future<void> _onReorder(int oldIndex, int newIndex) {
    HapticFeedback.lightImpact();
    // ReorderableListView の newIndex は「移動後の挿入先」を指すので、
    // 下方向への移動は -1 補正してリスト操作と整合させる。
    final adjustedNewIndex = newIndex > oldIndex ? newIndex - 1 : newIndex;
    setState(() {
      final id = _localOrder.removeAt(oldIndex);
      _localOrder.insert(adjustedNewIndex, id);
    });
    return ref
        .read(categoryControllerProvider.notifier)
        .reorder(List<String>.from(_localOrder));
  }

  @override
  Widget build(BuildContext context) {
    final byId = {for (final c in widget.categories) c.id: c};
    final displayList = _localOrder
        .map((id) => byId[id])
        .whereType<Category>()
        .toList();
    return ReorderableListView.builder(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 96),
      itemCount: displayList.length,
      onReorderStart: (_) => HapticFeedback.selectionClick(),
      onReorder: _onReorder,
      header: _SectionLabel(count: displayList.length),
      itemBuilder: (context, index) {
        final category = displayList[index];
        return Padding(
          key: ValueKey(category.id),
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: _CategoryCard(category: category),
        );
      },
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
      child: Row(
        children: [
          Text(
            'カテゴリ',
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

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.category_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 12),
          const Text('カテゴリがありません'),
        ],
      ),
    );
  }
}

class _CategoryCard extends ConsumerWidget {
  const _CategoryCard({required this.category});

  final Category category;

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final ok = await showDeleteConfirmDialog(
      context: context,
      message: '「${category.name}」を削除します。\n過去の記録は残ります。',
    );
    if (!ok) return;
    try {
      await ref.read(categoryControllerProvider.notifier).delete(category.id);
      if (context.mounted) {
        TopToast.show(context, message: 'カテゴリを削除しました');
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
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = CategoryPresets.colorFor(category.colorCode);
    final icon = CategoryPresets.iconFor(category.iconCode);
    return Card(
      child: ListTile(
        onTap: () => CategoryEditSheet.show(context, initial: category),
        leading: CircleAvatar(
          backgroundColor: color,
          foregroundColor: Colors.white,
          child: Icon(icon),
        ),
        title: Text(category.name),
        subtitle: Text(
          '${CategoryListPage._rateFormatter.format(category.hourlyRate)} 円/h',
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline),
          tooltip: '削除',
          onPressed: () => _confirmDelete(context, ref),
        ),
      ),
    );
  }
}
