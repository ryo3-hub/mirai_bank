import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/widgets/top_toast.dart';
import '../application/category_providers.dart';
import '../domain/category.dart';
import '../domain/category_presets.dart';
import 'widgets/category_form_widgets.dart';

class CategoryEditSheet extends ConsumerStatefulWidget {
  const CategoryEditSheet({super.key, this.initial});

  final Category? initial;

  static Future<void> show(BuildContext context, {Category? initial}) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (_) => CategoryEditSheet(initial: initial),
    );
  }

  @override
  ConsumerState<CategoryEditSheet> createState() => _CategoryEditSheetState();
}

class _CategoryEditSheetState extends ConsumerState<CategoryEditSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _rateController;
  late String _iconCode;
  late String _colorCode;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    _nameController = TextEditingController(text: initial?.name ?? '');
    _rateController =
        TextEditingController(text: initial?.hourlyRate.toString() ?? '1000');
    _iconCode = initial?.iconCode ?? CategoryPresets.defaultIcon;
    _colorCode = initial?.colorCode ?? CategoryPresets.defaultColor;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _rateController.dispose();
    super.dispose();
  }

  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _saving = true);
    final controller = ref.read(categoryControllerProvider.notifier);
    final navigator = Navigator.of(context);
    final name = _nameController.text.trim();
    final rate = int.parse(_rateController.text.trim());
    final initial = widget.initial;
    try {
      if (initial == null) {
        await controller.create(
          name: name,
          hourlyRate: rate,
          colorCode: _colorCode,
          iconCode: _iconCode,
        );
      } else {
        await controller.updateCategory(
          initial.copyWith(
            name: name,
            hourlyRate: rate,
            colorCode: _colorCode,
            iconCode: _iconCode,
          ),
        );
      }
      if (mounted) {
        TopToast.show(
          context,
          message: initial == null ? 'カテゴリを追加しました' : 'カテゴリを更新しました',
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

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.initial != null;
    final viewInsets = MediaQuery.of(context).viewInsets;
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
                isEdit ? 'カテゴリを編集' : '新規カテゴリ',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 20),
              CategoryNameField(controller: _nameController),
              const SizedBox(height: 8),
              CategoryHourlyRateField(controller: _rateController),
              const SizedBox(height: 24),
              const CategoryFormSectionLabel(text: 'アイコン'),
              const SizedBox(height: 8),
              CategoryIconPicker(
                selected: _iconCode,
                color: CategoryPresets.colorFor(_colorCode),
                onChanged: (code) => setState(() => _iconCode = code),
              ),
              const SizedBox(height: 24),
              const CategoryFormSectionLabel(text: 'カラー'),
              const SizedBox(height: 8),
              CategoryColorPicker(
                selected: _colorCode,
                onChanged: (code) => setState(() => _colorCode = code),
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed:
                          _saving ? null : () => Navigator.of(context).pop(),
                      child: const Text('キャンセル'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: _saving ? null : _onSave,
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
