import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../app/router.dart';
import '../../../shared/achievement/amount_flash.dart';
import '../../../shared/widgets/confirm_dialog.dart';
import '../../../shared/widgets/top_toast.dart';
import '../../category/application/category_providers.dart';
import '../../category/domain/category.dart';
import '../../category/domain/category_presets.dart';
import '../../category/presentation/category_picker_sheet.dart';
import '../application/manual_record_providers.dart';
import '../domain/work_session.dart';

class ManualRecordSheet extends ConsumerStatefulWidget {
  const ManualRecordSheet({super.key, this.initial});

  final WorkSession? initial;

  static Future<void> show(BuildContext context, {WorkSession? initial}) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (_) => ManualRecordSheet(initial: initial),
    );
  }

  @override
  ConsumerState<ManualRecordSheet> createState() => _ManualRecordSheetState();
}

class _ManualRecordSheetState extends ConsumerState<ManualRecordSheet> {
  Category? _selectedCategory;
  late DateTime _selectedDate;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;
  late final TextEditingController _memoController;
  String? _categoryError;
  String? _timeRangeError;
  bool _saving = false;
  bool _deleting = false;

  bool get _isEdit => widget.initial != null;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    if (initial != null) {
      _selectedDate = DateTime(
        initial.endTime.year,
        initial.endTime.month,
        initial.endTime.day,
      );
      _startTime = TimeOfDay.fromDateTime(initial.startTime);
      _endTime = TimeOfDay.fromDateTime(initial.endTime);
      _memoController = TextEditingController(text: initial.memo ?? '');
    } else {
      final now = DateTime.now();
      _selectedDate = DateTime(now.year, now.month, now.day);
      // Default: 1-hour window ending at the previous full hour.
      final end = now.hour;
      _startTime = TimeOfDay(hour: (end - 1).clamp(0, 23), minute: 0);
      _endTime = TimeOfDay(hour: end.clamp(0, 23), minute: 0);
      _memoController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _memoController.dispose();
    super.dispose();
  }

  Future<void> _pickCategory(List<Category> categories) async {
    final result = await CategoryPickerSheet.show(
      context,
      categories: categories,
      selectedId: _selectedCategory?.id,
    );
    if (result != null) {
      setState(() {
        _selectedCategory = result;
        _categoryError = null;
      });
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: today,
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickStartTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _startTime,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
        child: child ?? const SizedBox.shrink(),
      ),
    );
    if (picked != null) {
      setState(() {
        _startTime = picked;
        _timeRangeError = null;
      });
    }
  }

  Future<void> _pickEndTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _endTime,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
        child: child ?? const SizedBox.shrink(),
      ),
    );
    if (picked != null) {
      setState(() {
        _endTime = picked;
        _timeRangeError = null;
      });
    }
  }

  int _toMinutes(TimeOfDay t) => t.hour * 60 + t.minute;

  int? _computeDurationSec() {
    final diff = _toMinutes(_endTime) - _toMinutes(_startTime);
    if (diff <= 0) return null;
    return diff * 60;
  }

  bool _validate() {
    var ok = true;
    if (_selectedCategory == null) {
      setState(() => _categoryError = 'カテゴリを選択してください');
      ok = false;
    } else {
      setState(() => _categoryError = null);
    }
    final duration = _computeDurationSec();
    if (duration == null) {
      setState(() => _timeRangeError = '終了時刻は開始時刻より後にしてください');
      ok = false;
    } else {
      setState(() => _timeRangeError = null);
    }
    return ok;
  }

  DateTime _combineDateTime(DateTime date, TimeOfDay time) {
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  Future<void> _save() async {
    if (!_validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _saving = true);
    final navigator = Navigator.of(context);
    final controller = ref.read(manualRecordControllerProvider.notifier);
    final categoryId = _selectedCategory!.id;
    final startTime = _combineDateTime(_selectedDate, _startTime);
    final endTime = _combineDateTime(_selectedDate, _endTime);
    final memo = _memoController.text;
    try {
      int? createdAmount;
      if (_isEdit) {
        await controller.updateRecord(
          session: widget.initial!,
          categoryId: categoryId,
          startTime: startTime,
          endTime: endTime,
          memo: memo,
        );
      } else {
        final session = await controller.create(
          categoryId: categoryId,
          startTime: startTime,
          endTime: endTime,
          memo: memo,
        );
        createdAmount = session.amount;
      }
      if (mounted) {
        if (createdAmount != null) {
          final ctx = AppRouter.rootNavigatorKey.currentContext;
          if (ctx != null) {
            // ignore: use_build_context_synchronously
            AmountFlash.show(ctx, createdAmount);
          }
          TopToast.show(context, message: '記録を追加しました');
        } else {
          TopToast.show(context, message: '記録を更新しました');
        }
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
      message: 'この記録を削除します。',
    );
    if (!ok || !mounted) return;
    final navigator = Navigator.of(context);
    setState(() => _deleting = true);
    try {
      await ref
          .read(manualRecordControllerProvider.notifier)
          .delete(initial.id);
      if (mounted) {
        TopToast.show(context, message: '記録を削除しました');
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
    final categoriesAsync = ref.watch(categoriesListProvider);
    final initialCategoryId = widget.initial?.categoryId;
    final viewInsets = MediaQuery.of(context).viewInsets;
    return Padding(
      padding: EdgeInsets.only(bottom: viewInsets.bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              _isEdit ? '記録を編集' : '手動で記録',
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
                if (_selectedCategory == null) {
                  final initialId =
                      initialCategoryId ?? categories.firstOrNull?.id;
                  final c = initialId == null
                      ? null
                      : categories.where((x) => x.id == initialId).firstOrNull;
                  if (c != null) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted && _selectedCategory == null) {
                        setState(() => _selectedCategory = c);
                      }
                    });
                  }
                }
                return _CategoryField(
                  category: _selectedCategory,
                  errorText: _categoryError,
                  onTap: categories.isEmpty
                      ? null
                      : () => _pickCategory(categories),
                );
              },
            ),
            const SizedBox(height: 16),
            _DateField(
              date: _selectedDate,
              onTap: _pickDate,
            ),
            const SizedBox(height: 16),
            _TimeRangeField(
              startTime: _startTime,
              endTime: _endTime,
              errorText: _timeRangeError,
              onPickStart: _pickStartTime,
              onPickEnd: _pickEndTime,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _memoController,
              decoration: const InputDecoration(
                labelText: 'メモ（任意）',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 24),
            if (_isEdit)
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed:
                          (_saving || _deleting) ? null : _delete,
                      icon: _deleting
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
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
              )
            else
              FilledButton(
                onPressed: (_saving || _deleting) ? null : _save,
                child: _saving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('保存'),
              ),
          ],
        ),
      ),
    );
  }
}

class _CategoryField extends StatelessWidget {
  const _CategoryField({
    required this.category,
    required this.onTap,
    this.errorText,
  });

  final Category? category;
  final VoidCallback? onTap;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InputDecorator(
      decoration: InputDecoration(
        labelText: 'カテゴリ',
        border: const OutlineInputBorder(),
        errorText: errorText,
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              if (category != null) ...[
                CircleAvatar(
                  radius: 14,
                  backgroundColor:
                      CategoryPresets.colorFor(category!.colorCode),
                  foregroundColor: Colors.white,
                  child: Icon(
                    CategoryPresets.iconFor(category!.iconCode),
                    size: 16,
                  ),
                ),
                const SizedBox(width: 12),
                Text(category!.name),
              ] else
                Text(
                  '選択してください',
                  style: TextStyle(color: theme.colorScheme.outline),
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

class _DateField extends StatelessWidget {
  const _DateField({required this.date, required this.onTap});

  final DateTime date;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final formatted = DateFormat('yyyy年M月d日 (E)', 'ja').format(date);
    return InputDecorator(
      decoration: const InputDecoration(
        labelText: '日付',
        border: OutlineInputBorder(),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              Text(formatted),
              const Spacer(),
              const Icon(Icons.calendar_today, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}

class _TimeRangeField extends StatelessWidget {
  const _TimeRangeField({
    required this.startTime,
    required this.endTime,
    required this.onPickStart,
    required this.onPickEnd,
    this.errorText,
  });

  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final VoidCallback onPickStart;
  final VoidCallback onPickEnd;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '時間帯',
          style: theme.textTheme.labelLarge,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _TimeButton(
                label: '開始',
                time: startTime,
                onTap: onPickStart,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _TimeButton(
                label: '終了',
                time: endTime,
                onTap: onPickEnd,
              ),
            ),
          ],
        ),
        if (errorText != null) ...[
          const SizedBox(height: 6),
          Text(
            errorText!,
            style: TextStyle(
              color: theme.colorScheme.error,
              fontSize: 12,
            ),
          ),
        ],
      ],
    );
  }
}

class _TimeButton extends StatelessWidget {
  const _TimeButton({
    required this.label,
    required this.time,
    required this.onTap,
  });

  final String label;
  final TimeOfDay time;
  final VoidCallback onTap;

  String _format(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
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
              Text(
                _format(time),
                style: const TextStyle(
                  fontSize: 16,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
              const Spacer(),
              const Icon(Icons.access_time, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}
