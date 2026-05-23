import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../shared/widgets/confirm_dialog.dart';
import '../../../shared/widgets/top_toast.dart';
import '../../category/application/category_providers.dart';
import '../../category/domain/category.dart';
import '../../category/domain/category_presets.dart';
import '../application/goal_providers.dart';
import '../domain/goal.dart';

/// 目標作成・編集ボトムシート。
///
/// issue #100 で自由入力（種別 / 金額 / 期間）から、
/// 短期 / 中期 / 長期の 3 プリセット選択方式へ変更した。
class GoalEditSheet extends ConsumerStatefulWidget {
  const GoalEditSheet({super.key, this.initial});

  final Goal? initial;

  static Future<void> show(BuildContext context, {Goal? initial}) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (_) => GoalEditSheet(initial: initial),
    );
  }

  @override
  ConsumerState<GoalEditSheet> createState() => _GoalEditSheetState();
}

class _GoalEditSheetState extends ConsumerState<GoalEditSheet> {
  GoalPreset? _preset;
  String? _categoryId;
  bool _saving = false;
  bool _deleting = false;

  bool get _isEdit => widget.initial != null;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    if (initial != null) {
      _preset = GoalPreset.fromGoal(initial);
      _categoryId = initial.categoryId;
    }
  }

  static DateTime _todayMidnight() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  /// 現在の [_preset] と [_categoryId] から達成予定日を求める。
  /// 編集時は元の periodStart は引き継がず「今日」を起点に再計算する
  /// （プリセット変更 = 仕切り直しのため）。
  DateTime _computeDeadline(GoalPreset preset) {
    return _todayMidnight().add(Duration(days: preset.days));
  }

  int _computeTargetAmount(GoalPreset preset, List<Category> categories) {
    final category = _categoryFor(_categoryId, categories);
    return preset.targetAmountFor(category);
  }

  Category? _categoryFor(String? id, List<Category> categories) {
    if (id == null) return null;
    for (final c in categories) {
      if (c.id == id) return c;
    }
    return null;
  }

  Future<void> _save(List<Category> categories) async {
    final preset = _preset;
    if (preset == null) {
      TopToast.show(
        context,
        message: '目標を選択してください',
        isError: true,
      );
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() => _saving = true);
    final navigator = Navigator.of(context);
    final controller = ref.read(goalControllerProvider.notifier);
    final start = _todayMidnight();
    final end = start.add(Duration(days: preset.days));
    final amount = _computeTargetAmount(preset, categories);
    final initial = widget.initial;
    try {
      if (initial == null) {
        await controller.create(
          type: GoalType.period,
          targetAmount: amount,
          categoryId: _categoryId,
          periodStart: start,
          periodEnd: end,
        );
      } else {
        await controller.updateGoal(
          initial.copyWith(
            type: GoalType.period,
            targetAmount: amount,
            categoryId: _categoryId,
            clearCategoryId: _categoryId == null,
            periodStart: start,
            periodEnd: end,
            clearAchievedAt: true,
          ),
        );
      }
      if (mounted) {
        TopToast.show(
          context,
          message: _isEdit ? '目標を更新しました' : '目標を追加しました',
        );
        navigator.pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        TopToast.show(
          context,
          message: '保存に失敗しました: $e',
          isError: true,
        );
      }
    }
  }

  Future<void> _delete() async {
    final initial = widget.initial;
    if (initial == null) return;
    final ok = await showDeleteConfirmDialog(
      context: context,
      message: 'この目標を削除します。',
    );
    if (!ok || !mounted) return;
    final navigator = Navigator.of(context);
    setState(() => _deleting = true);
    try {
      await ref.read(goalControllerProvider.notifier).delete(initial.id);
      if (mounted) {
        TopToast.show(context, message: '目標を削除しました');
        navigator.pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _deleting = false);
        TopToast.show(
          context,
          message: '削除に失敗しました: $e',
          isError: true,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.of(context).viewInsets;
    final categoriesAsync = ref.watch(categoriesListProvider);
    return Padding(
      padding: EdgeInsets.only(bottom: viewInsets.bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              _isEdit ? '目標を編集' : '新規目標',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 20),
            categoriesAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: LinearProgressIndicator(),
              ),
              error: (e, _) => Text('カテゴリの読み込みに失敗: $e'),
              data: (categories) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _CategorySelectField(
                      categories: categories,
                      selectedId: _categoryId,
                      onChanged: (id) => setState(() => _categoryId = id),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      '目標を選ぶ',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 8),
                    for (final preset in GoalPreset.values)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: _PresetCard(
                          preset: preset,
                          selected: _preset == preset,
                          amount: _computeTargetAmount(preset, categories),
                          deadline: _computeDeadline(preset),
                          onTap: () => setState(() => _preset = preset),
                        ),
                      ),
                    const SizedBox(height: 24),
                    if (_isEdit)
                      Row(
                        children: [
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: (_saving || _deleting) ? null : _delete,
                              icon: _deleting
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2),
                                    )
                                  : const Icon(Icons.delete_outline),
                              label: const Text('削除'),
                              style: FilledButton.styleFrom(
                                backgroundColor:
                                    Theme.of(context).colorScheme.error,
                                foregroundColor:
                                    Theme.of(context).colorScheme.onError,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: FilledButton(
                              onPressed: (_saving ||
                                      _deleting ||
                                      _preset == null)
                                  ? null
                                  : () => _save(categories),
                              child: _saving
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2),
                                    )
                                  : const Text('保存'),
                            ),
                          ),
                        ],
                      )
                    else
                      FilledButton(
                        onPressed: (_saving || _preset == null)
                            ? null
                            : () => _save(categories),
                        child: _saving
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('保存'),
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _PresetCard extends StatelessWidget {
  const _PresetCard({
    required this.preset,
    required this.selected,
    required this.amount,
    required this.deadline,
    required this.onTap,
  });

  final GoalPreset preset;
  final bool selected;
  final int amount;
  final DateTime deadline;
  final VoidCallback onTap;

  static final _amountFormatter = NumberFormat('#,###');
  static final _dateFormatter = DateFormat('yyyy/M/d');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = theme.colorScheme.primary;
    final border = selected
        ? Border.all(color: accent, width: 2)
        : Border.all(color: theme.colorScheme.outlineVariant, width: 1);
    return Material(
      color: selected
          ? accent.withValues(alpha: 0.08)
          : theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            border: border,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                selected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                color: selected ? accent : theme.colorScheme.outline,
                size: 22,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      preset.label,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '達成予定: ${_dateFormatter.format(deadline)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${_amountFormatter.format(amount)} 円',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: accent,
                  fontWeight: FontWeight.w700,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategorySelectField extends StatelessWidget {
  const _CategorySelectField({
    required this.categories,
    required this.selectedId,
    required this.onChanged,
  });

  final List<Category> categories;
  final String? selectedId;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final selected = selectedId == null
        ? null
        : categories.where((c) => c.id == selectedId).firstOrNull;
    return InputDecorator(
      decoration: const InputDecoration(
        labelText: '対象カテゴリ',
        border: OutlineInputBorder(),
      ),
      child: InkWell(
        onTap: () async {
          final result = await showModalBottomSheet<String?>(
            context: context,
            showDragHandle: true,
            builder: (_) => _CategoryOptionSheet(
              categories: categories,
              selectedId: selectedId,
            ),
          );
          if (result != _Sentinel.unchanged) {
            onChanged(result == _Sentinel.none ? null : result);
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              if (selected != null) ...[
                CircleAvatar(
                  radius: 12,
                  backgroundColor:
                      CategoryPresets.colorFor(selected.colorCode),
                  foregroundColor: Colors.white,
                  child: Icon(
                    CategoryPresets.iconFor(selected.iconCode),
                    size: 14,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    selected.name,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ] else
                Expanded(
                  child: Text(
                    '全カテゴリ',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              const SizedBox(width: 8),
              const Icon(Icons.unfold_more, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _Sentinel {
  static const String unchanged = '__unchanged__';
  static const String none = '__none__';
}

class _CategoryOptionSheet extends StatelessWidget {
  const _CategoryOptionSheet({
    required this.categories,
    required this.selectedId,
  });

  final List<Category> categories;
  final String? selectedId;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.fromLTRB(8, 0, 8, 16),
        children: [
          ListTile(
            leading: const CircleAvatar(
              backgroundColor: Colors.grey,
              foregroundColor: Colors.white,
              child: Icon(Icons.apps),
            ),
            title: const Text('全カテゴリ'),
            trailing: selectedId == null ? const Icon(Icons.check) : null,
            onTap: () => Navigator.of(context).pop(_Sentinel.none),
          ),
          const Divider(),
          for (final c in categories)
            ListTile(
              leading: CircleAvatar(
                backgroundColor: CategoryPresets.colorFor(c.colorCode),
                foregroundColor: Colors.white,
                child: Icon(CategoryPresets.iconFor(c.iconCode)),
              ),
              title: Text(c.name),
              trailing:
                  selectedId == c.id ? const Icon(Icons.check) : null,
              onTap: () => Navigator.of(context).pop(c.id),
            ),
        ],
      ),
    );
  }
}
