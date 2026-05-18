import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../app/router.dart';
import '../../../shared/achievement/amount_flash.dart';
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
  late final TextEditingController _hourController;
  late final TextEditingController _minuteController;
  late final TextEditingController _memoController;
  String? _categoryError;
  String? _durationError;
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
      final h = initial.durationSec ~/ 3600;
      final m = (initial.durationSec % 3600) ~/ 60;
      _hourController = TextEditingController(text: h.toString());
      _minuteController = TextEditingController(text: m.toString());
      _memoController = TextEditingController(text: initial.memo ?? '');
    } else {
      final now = DateTime.now();
      _selectedDate = DateTime(now.year, now.month, now.day);
      _hourController = TextEditingController(text: '1');
      _minuteController = TextEditingController(text: '0');
      _memoController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _hourController.dispose();
    _minuteController.dispose();
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

  int? _parseDurationSec() {
    final h = int.tryParse(_hourController.text.trim());
    final m = int.tryParse(_minuteController.text.trim());
    if (h == null && m == null) return null;
    final hours = h ?? 0;
    final minutes = m ?? 0;
    if (hours < 0 || minutes < 0 || minutes >= 60) return null;
    return hours * 3600 + minutes * 60;
  }

  bool _validate() {
    var ok = true;
    if (_selectedCategory == null) {
      setState(() => _categoryError = 'カテゴリを選択してください');
      ok = false;
    } else {
      setState(() => _categoryError = null);
    }
    final duration = _parseDurationSec();
    if (duration == null || duration <= 0) {
      setState(() => _durationError = '1分以上の時間を入力してください');
      ok = false;
    } else {
      setState(() => _durationError = null);
    }
    return ok;
  }

  Future<void> _save() async {
    if (!_validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _saving = true);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final controller = ref.read(manualRecordControllerProvider.notifier);
    final categoryId = _selectedCategory!.id;
    final durationSec = _parseDurationSec()!;
    final memo = _memoController.text;
    try {
      int? createdAmount;
      if (_isEdit) {
        await controller.updateRecord(
          session: widget.initial!,
          categoryId: categoryId,
          date: _selectedDate,
          durationSec: durationSec,
          memo: memo,
        );
      } else {
        final session = await controller.create(
          categoryId: categoryId,
          date: _selectedDate,
          durationSec: durationSec,
          memo: memo,
        );
        createdAmount = session.amount;
      }
      if (mounted) {
        navigator.pop();
        if (createdAmount != null) {
          final ctx = AppRouter.rootNavigatorKey.currentContext;
          if (ctx != null) {
            // ignore: use_build_context_synchronously
            AmountFlash.show(ctx, createdAmount);
          }
        } else {
          messenger.showSnackBar(
            const SnackBar(content: Text('記録を更新しました')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        messenger.showSnackBar(
          SnackBar(content: Text('保存に失敗しました: $e')),
        );
      }
    }
  }

  Future<void> _delete() async {
    final initial = widget.initial;
    if (initial == null) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('削除しますか？'),
        content: const Text('この記録を削除します。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('キャンセル'),
          ),
          FilledButton.tonal(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('削除'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    setState(() => _deleting = true);
    try {
      await ref
          .read(manualRecordControllerProvider.notifier)
          .delete(initial.id);
      if (mounted) {
        navigator.pop();
        messenger.showSnackBar(
          const SnackBar(content: Text('記録を削除しました')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _deleting = false);
        messenger.showSnackBar(
          SnackBar(content: Text('削除に失敗しました: $e')),
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
            _DurationField(
              hourController: _hourController,
              minuteController: _minuteController,
              errorText: _durationError,
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
            Row(
              children: [
                if (_isEdit) ...[
                  Expanded(
                    child: OutlinedButton.icon(
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
                      style: OutlinedButton.styleFrom(
                        foregroundColor:
                            Theme.of(context).colorScheme.error,
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

class _DurationField extends StatelessWidget {
  const _DurationField({
    required this.hourController,
    required this.minuteController,
    this.errorText,
  });

  final TextEditingController hourController;
  final TextEditingController minuteController;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '作業時間',
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: hourController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  labelText: '時',
                  border: OutlineInputBorder(),
                  suffixText: 'h',
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: minuteController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  labelText: '分',
                  border: OutlineInputBorder(),
                  suffixText: 'm',
                ),
              ),
            ),
          ],
        ),
        if (errorText != null) ...[
          const SizedBox(height: 6),
          Text(
            errorText!,
            style: TextStyle(
              color: Theme.of(context).colorScheme.error,
              fontSize: 12,
            ),
          ),
        ],
      ],
    );
  }
}
