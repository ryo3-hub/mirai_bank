import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../application/category_providers.dart';
import '../domain/category.dart';
import '../domain/category_presets.dart';
import '../../../shared/widgets/confirm_dialog.dart';
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
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: categories.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final category = categories[index];
              return _CategoryCard(category: category);
            },
          );
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
    if (ok) {
      await ref.read(categoryControllerProvider.notifier).delete(category.id);
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
