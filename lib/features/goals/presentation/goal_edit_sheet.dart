import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../shared/widgets/confirm_dialog.dart';
import '../../../shared/widgets/mirai_date_picker_sheet.dart';
import '../../../shared/widgets/top_toast.dart';
import '../../category/application/category_providers.dart';
import '../../category/domain/category.dart';
import '../../category/domain/category_presets.dart';
import '../application/goal_providers.dart';
import '../domain/goal.dart';

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
  final _formKey = GlobalKey<FormState>();
  late GoalType _type;
  late final TextEditingController _amountController;
  String? _categoryId;
  late DateTime _periodStart;
  late DateTime _periodEnd;
  String? _periodError;
  bool _saving = false;
  bool _deleting = false;

  bool get _isEdit => widget.initial != null;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    if (initial != null) {
      _type = initial.type;
      _amountController =
          TextEditingController(text: initial.targetAmount.toString());
      _categoryId = initial.categoryId;
      _periodStart =
          initial.periodStart ?? _todayMidnight();
      _periodEnd = initial.periodEnd ??
          _todayMidnight().add(const Duration(days: 30));
    } else {
      _type = GoalType.cumulative;
      _amountController = TextEditingController(text: '30000');
      _categoryId = null;
      _periodStart = _todayMidnight();
      _periodEnd = _todayMidnight().add(const Duration(days: 30));
    }
  }

  static DateTime _todayMidnight() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _pickStart() async {
    final picked = await MiraiDatePickerSheet.show(
      context,
      initialDate: _periodStart,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      title: '開始日を選択',
    );
    if (picked != null) {
      setState(() {
        _periodStart = picked;
        if (_periodEnd.isBefore(picked)) {
          _periodEnd = picked;
        }
        _periodError = null;
      });
    }
  }

  Future<void> _pickEnd() async {
    final picked = await MiraiDatePickerSheet.show(
      context,
      initialDate: _periodEnd,
      firstDate: _periodStart,
      lastDate: DateTime(2100),
      title: '終了日を選択',
    );
    if (picked != null) {
      setState(() {
        _periodEnd = picked;
        _periodError = null;
      });
    }
  }

  bool _validate() {
    if (!_formKey.currentState!.validate()) return false;
    final err = Goal.validatePeriod(
      type: _type,
      start: _periodStart,
      end: _periodEnd,
    );
    setState(() => _periodError = err);
    return err == null;
  }

  Future<void> _save() async {
    if (!_validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _saving = true);
    final navigator = Navigator.of(context);
    final controller = ref.read(goalControllerProvider.notifier);
    final amount = int.parse(_amountController.text.trim());
    final initial = widget.initial;
    try {
      if (initial == null) {
        await controller.create(
          type: _type,
          targetAmount: amount,
          categoryId: _categoryId,
          periodStart: _type == GoalType.period ? _periodStart : null,
          periodEnd: _type == GoalType.period ? _periodEnd : null,
        );
      } else {
        await controller.updateGoal(
          initial.copyWith(
            type: _type,
            targetAmount: amount,
            categoryId: _categoryId,
            clearCategoryId: _categoryId == null,
            periodStart: _type == GoalType.period ? _periodStart : null,
            periodEnd: _type == GoalType.period ? _periodEnd : null,
            clearPeriod: _type == GoalType.cumulative,
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
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                _isEdit ? '目標を編集' : '新規目標',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 20),
              SegmentedButton<GoalType>(
                segments: const [
                  ButtonSegment(
                    value: GoalType.cumulative,
                    label: Text('累計'),
                  ),
                  ButtonSegment(
                    value: GoalType.period,
                    label: Text('期間'),
                  ),
                ],
                selected: {_type},
                showSelectedIcon: false,
                onSelectionChanged: (set) =>
                    setState(() => _type = set.first),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: '目標金額',
                  border: OutlineInputBorder(),
                  suffixText: '円',
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: Goal.validateTargetAmount,
              ),
              const SizedBox(height: 16),
              categoriesAsync.when(
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: LinearProgressIndicator(),
                ),
                error: (e, _) => Text('カテゴリの読み込みに失敗: $e'),
                data: (categories) => _CategorySelectField(
                  categories: categories,
                  selectedId: _categoryId,
                  onChanged: (id) => setState(() => _categoryId = id),
                ),
              ),
              if (_type == GoalType.period) ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _DateField(
                        label: '開始',
                        date: _periodStart,
                        onTap: _pickStart,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _DateField(
                        label: '終了',
                        date: _periodEnd,
                        onTap: _pickEnd,
                      ),
                    ),
                  ],
                ),
                if (_periodError != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    _periodError!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
              const SizedBox(height: 24),
              Row(
                children: [
                  if (_isEdit) ...[
                    Expanded(
                      child: FilledButton.icon(
                        onPressed:
                            (_saving || _deleting) ? null : _delete,
                        icon: _deleting
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
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
                  ],
                  Expanded(
                    child: OutlinedButton(
                      onPressed: (_saving || _deleting)
                          ? null
                          : () => Navigator.of(context).pop(),
                      child: const Text('キャンセル'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed:
                          (_saving || _deleting) ? null : _save,
                      child: _saving
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('保存'),
                    ),
                  ),
                ],
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
                Text(selected.name),
              ] else
                Text(
                  '全カテゴリ',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              const Spacer(),
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

class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.date,
    required this.onTap,
  });

  final String label;
  final DateTime date;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final formatted = DateFormat('yyyy/M/d').format(date);
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              Text(formatted),
              const Spacer(),
              const Icon(Icons.calendar_today, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
