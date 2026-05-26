import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../shared/widgets/keyboard_done_bar.dart';
import '../../../shared/widgets/mirai_date_picker_sheet.dart';
import '../../../shared/widgets/save_action_button.dart';
import '../../../shared/widgets/top_toast.dart';
import '../../category/application/category_providers.dart';
import '../../category/domain/category.dart';
import '../../category/domain/category_presets.dart';
import '../application/goal_providers.dart';
import '../domain/goal.dart';

/// 新規目標作成ボトムシート。
///
/// issue #100 で自由入力（種別 / 金額 / 期間）から、短期 / 中期 / 長期の
/// 3 プリセット選択方式へ変更。issue #110 で「カスタムで設定」カードを追加。
/// 編集機能は廃止し、削除のみ GoalCard の削除アイコンから行う。
class GoalEditSheet extends ConsumerStatefulWidget {
  const GoalEditSheet({super.key});

  static Future<void> show(BuildContext context) {
    // issue #117: AppShell の Scaffold (resizeToAvoidBottomInset: true) が
    // viewInsets.bottom を消費してしまい、シート内では常に 0 になる。
    // useRootNavigator: true でルート Navigator に push し、消費前の
    // viewInsets を MediaQuery 経由で受け取れるようにする。
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      useRootNavigator: true,
      builder: (_) => const GoalEditSheet(),
    );
  }

  @override
  ConsumerState<GoalEditSheet> createState() => _GoalEditSheetState();
}

class _GoalEditSheetState extends ConsumerState<GoalEditSheet> {
  GoalPreset? _preset;
  bool _isCustom = false;
  String? _categoryId;
  bool _saving = false;

  // カスタム入力 (issue #110)
  final _customAmountController = TextEditingController();
  DateTime? _customDeadline;
  String? _customAmountError;
  String? _customDeadlineError;

  /// カスタム目標金額の許容範囲: 1,000 円 〜 1,000 万円
  static const int _customAmountMin = 1000;
  static const int _customAmountMax = 10000000;

  /// カスタム達成予定日の最大: 今日 +10 年
  static const int _customDeadlineMaxYears = 10;

  @override
  void dispose() {
    _customAmountController.dispose();
    super.dispose();
  }

  static DateTime _todayMidnight() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

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

  void _selectPreset(GoalPreset preset) {
    setState(() {
      _preset = preset;
      _isCustom = false;
      _customAmountError = null;
      _customDeadlineError = null;
    });
  }

  void _selectCustom() {
    setState(() {
      _preset = null;
      _isCustom = true;
    });
  }

  Future<void> _pickCustomDeadline() async {
    final today = _todayMidnight();
    final firstSelectable = today.add(const Duration(days: 1));
    final lastSelectable = DateTime(
      today.year + _customDeadlineMaxYears,
      today.month,
      today.day,
    );
    final picked = await MiraiDatePickerSheet.show(
      context,
      initialDate: _customDeadline ?? today.add(const Duration(days: 30)),
      firstDate: firstSelectable,
      lastDate: lastSelectable,
      title: '達成予定日を選択',
    );
    if (picked != null) {
      setState(() {
        _customDeadline = picked;
        _customDeadlineError = null;
      });
    }
  }

  String? _validateCustomAmount() {
    final text = _customAmountController.text.trim();
    if (text.isEmpty) return '目標金額を入力してください';
    final parsed = int.tryParse(text);
    if (parsed == null) return '数値を入力してください';
    if (parsed < _customAmountMin) return '1,000 円以上を入力してください';
    if (parsed > _customAmountMax) return '1,000 万円以下で入力してください';
    return null;
  }

  String? _validateCustomDeadline() {
    final d = _customDeadline;
    if (d == null) return '達成予定日を選択してください';
    final today = _todayMidnight();
    if (!d.isAfter(today)) return '明日以降の日付を選択してください';
    final maxDate = DateTime(
      today.year + _customDeadlineMaxYears,
      today.month,
      today.day,
    );
    if (d.isAfter(maxDate)) return '10 年以内の日付を選択してください';
    return null;
  }

  Future<void> _save(List<Category> categories) async {
    FocusScope.of(context).unfocus();
    final start = _todayMidnight();
    final int amount;
    final DateTime end;

    if (_isCustom) {
      final amtErr = _validateCustomAmount();
      final dateErr = _validateCustomDeadline();
      if (amtErr != null || dateErr != null) {
        setState(() {
          _customAmountError = amtErr;
          _customDeadlineError = dateErr;
        });
        return;
      }
      amount = int.parse(_customAmountController.text.trim());
      end = _customDeadline!;
    } else {
      final preset = _preset;
      if (preset == null) {
        TopToast.show(
          context,
          message: '目標を選択してください',
          isError: true,
        );
        return;
      }
      amount = _computeTargetAmount(preset, categories);
      end = start.add(Duration(days: preset.days));
    }

    setState(() => _saving = true);
    final navigator = Navigator.of(context);
    final controller = ref.read(goalControllerProvider.notifier);
    try {
      await controller.create(
        type: GoalType.period,
        targetAmount: amount,
        categoryId: _categoryId,
        periodStart: start,
        periodEnd: end,
      );
      if (mounted) {
        TopToast.show(context, message: '目標を追加しました');
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

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.of(context).viewInsets;
    final categoriesAsync = ref.watch(categoriesListProvider);
    return Padding(
      padding: EdgeInsets.only(bottom: viewInsets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  categoriesAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: LinearProgressIndicator(),
              ),
              error: (e, _) => Text('カテゴリの読み込みに失敗: $e'),
              data: (categories) {
                final canSave = _preset != null || _isCustom;
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
                          onTap: () => _selectPreset(preset),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: _CustomCard(
                        selected: _isCustom,
                        amountController: _customAmountController,
                        amountError: _customAmountError,
                        deadline: _customDeadline,
                        deadlineError: _customDeadlineError,
                        onTap: _selectCustom,
                        onPickDate: _pickCustomDeadline,
                        onAmountChanged: () {
                          if (_customAmountError != null) {
                            setState(() => _customAmountError = null);
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                    SaveActionButton(
                      label: '目標を追加',
                      icon: Icons.add_circle_outline,
                      loading: _saving,
                      onPressed:
                          canSave ? () => _save(categories) : null,
                    ),
                  ],
                );
              },
            ),
                ],
              ),
            ),
          ),
          KeyboardDoneBar(
            onDone: () => FocusScope.of(context).unfocus(),
          ),
        ],
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
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          preset.label,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '(${preset.days}日間)',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
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

/// issue #110: 「カスタムで設定」カード。
///
/// 折りたたみ時はラベル + 編集アイコン。タップで選択状態になりフォームが
/// inline 展開される。フォームは目標金額（円）+ 達成予定日。
class _CustomCard extends StatelessWidget {
  const _CustomCard({
    required this.selected,
    required this.amountController,
    required this.amountError,
    required this.deadline,
    required this.deadlineError,
    required this.onTap,
    required this.onPickDate,
    required this.onAmountChanged,
  });

  final bool selected;
  final TextEditingController amountController;
  final String? amountError;
  final DateTime? deadline;
  final String? deadlineError;
  final VoidCallback onTap;
  final VoidCallback onPickDate;
  final VoidCallback onAmountChanged;

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
        child: AnimatedSize(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              border: border,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Icon(
                      selected
                          ? Icons.radio_button_checked
                          : Icons.radio_button_unchecked,
                      color:
                          selected ? accent : theme.colorScheme.outline,
                      size: 22,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'カスタムで設定',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.edit_outlined,
                      size: 18,
                      color: theme.colorScheme.outline,
                    ),
                  ],
                ),
                if (selected) ...[
                  const SizedBox(height: 16),
                  TextField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                      labelText: '目標金額',
                      border: const OutlineInputBorder(),
                      suffixText: '円',
                      errorText: amountError,
                      // issue #134: エラー時にラベル文字色まで赤になるのを抑止。
                      // floating / not-floating 両方に明示的なスタイルを指定して、
                      // errorText が立っているときも onSurfaceVariant のまま保つ。
                      labelStyle: TextStyle(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      floatingLabelStyle: TextStyle(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    onChanged: (_) => onAmountChanged(),
                  ),
                  const SizedBox(height: 12),
                  InputDecorator(
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      errorText: deadlineError,
                    ),
                    child: InkWell(
                      onTap: onPickDate,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                deadline == null
                                    ? '達成予定日を選択'
                                    : _dateFormatter.format(deadline!),
                                style: TextStyle(
                                  color: deadline == null
                                      ? theme
                                          .colorScheme.onSurfaceVariant
                                      : null,
                                ),
                              ),
                            ),
                            const Icon(Icons.calendar_today, size: 16),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
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
