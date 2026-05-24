import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../shared/widgets/keyboard_done_bar.dart';
import '../../../shared/widgets/save_action_button.dart';
import '../../../shared/widgets/top_toast.dart';
import '../application/category_providers.dart';
import '../domain/category.dart';
import '../domain/category_master.dart';
import '../domain/category_presets.dart';
import 'category_master_picker_sheet.dart';
import 'widgets/category_edit_mode_selector.dart';
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
  static final _rateFormatter = NumberFormat('#,###');

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _rateController;
  late String _iconCode;
  late String _colorCode;
  late CategoryEditMode _mode;
  String? _masterKey;
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
    _masterKey = initial?.masterKey;
    // 新規はプリセット、編集は既存値を尊重して「自分で設定」をデフォルトに。
    // ただし masterKey が残っている編集は「プリセット」のままに。
    _mode = initial == null
        ? CategoryEditMode.preset
        : (initial.masterKey != null ? CategoryEditMode.preset : CategoryEditMode.custom);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _rateController.dispose();
    super.dispose();
  }

  Future<void> _pickFromMaster() async {
    final initialMajor = CategoryMaster.findMinor(_masterKey)?.majorKey;
    final minor = await CategoryMasterPickerSheet.show(
      context,
      initialMajorKey: initialMajor,
    );
    if (minor == null || !mounted) return;
    final major = CategoryMaster.findMajor(minor.majorKey);
    setState(() {
      _masterKey = minor.key;
      _nameController.text = minor.name;
      _rateController.text = minor.recommendedRate.toString();
      if (major != null) {
        _iconCode = major.iconCode;
        _colorCode = major.colorCode;
      }
    });
  }

  Future<void> _onSave() async {
    // プリセットモードで master 未選択のときはガード
    if (_mode == CategoryEditMode.preset && _masterKey == null) {
      TopToast.show(
        context,
        message: 'プリセットを選んでください',
        isError: true,
      );
      return;
    }
    // custom モードのときだけフォームのバリデーションを走らせる
    // （プリセットモードは name/rate フィールドが画面に無く Form に
    // 登録されていないため）。
    if (_mode == CategoryEditMode.custom &&
        !_formKey.currentState!.validate()) {
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() => _saving = true);
    final controller = ref.read(categoryControllerProvider.notifier);
    final navigator = Navigator.of(context);
    final name = _nameController.text.trim();
    final rate = int.parse(_rateController.text.trim());
    // custom モードで保存するときは master 由来情報を捨てる。
    final masterKey = _mode == CategoryEditMode.preset ? _masterKey : null;
    final initial = widget.initial;
    try {
      if (initial == null) {
        await controller.create(
          name: name,
          hourlyRate: rate,
          colorCode: _colorCode,
          iconCode: _iconCode,
          masterKey: masterKey,
        );
      } else {
        await controller.updateCategory(
          initial.copyWith(
            name: name,
            hourlyRate: rate,
            colorCode: _colorCode,
            iconCode: _iconCode,
            masterKey: masterKey,
            clearMasterKey: masterKey == null,
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
    final viewInsets = MediaQuery.of(context).viewInsets;
    final keyboardVisible = viewInsets.bottom > 0;
    final isEdit = widget.initial != null;
    return Padding(
      padding: EdgeInsets.only(bottom: viewInsets.bottom),
      child: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CategoryEditModeSelector(
                    mode: _mode,
                    onChanged: (m) {
                      setState(() {
                        _mode = m;
                        // custom に切り替えたら master 紐付けを外す
                        if (m == CategoryEditMode.custom) {
                          _masterKey = null;
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  if (_mode == CategoryEditMode.preset) ...[
                    _PresetSummaryCard(
                      masterKey: _masterKey,
                      onTap: _pickFromMaster,
                      rateFormatter: _rateFormatter,
                    ),
                    const SizedBox(height: 20),
                  ] else ...[
                    CategoryNameField(controller: _nameController),
                    const SizedBox(height: 8),
                    CategoryHourlyRateField(controller: _rateController),
                    const SizedBox(height: 24),
                  ],
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
                  SaveActionButton(
                    onPressed: _onSave,
                    loading: _saving,
                    label: isEdit ? 'カテゴリを更新' : 'カテゴリを追加',
                  ),
                ],
              ),
            ),
          ),
          if (keyboardVisible)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: KeyboardDoneBar(
                onDone: () => FocusScope.of(context).unfocus(),
              ),
            ),
        ],
      ),
    );
  }
}

class _PresetSummaryCard extends StatelessWidget {
  const _PresetSummaryCard({
    required this.masterKey,
    required this.onTap,
    required this.rateFormatter,
  });

  final String? masterKey;
  final VoidCallback onTap;
  final NumberFormat rateFormatter;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final minor = CategoryMaster.findMinor(masterKey);
    final major = minor == null ? null : CategoryMaster.findMajor(minor.majorKey);
    final isSelected = minor != null;
    final accent = major == null
        ? theme.colorScheme.primary
        : CategoryPresets.colorFor(major.colorCode);
    return Material(
      color: isSelected
          ? accent.withValues(alpha: 0.08)
          : theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? accent : theme.colorScheme.outlineVariant,
          width: isSelected ? 1.5 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: accent,
                foregroundColor: Colors.white,
                child: Icon(
                  major == null
                      ? Icons.auto_awesome_outlined
                      : CategoryPresets.iconFor(major.iconCode),
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isSelected
                          ? '${major?.name ?? ''} / ${minor.name}'
                          : 'カテゴリを選ぶ',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isSelected
                          ? '推奨時給 ${rateFormatter.format(minor.recommendedRate)} 円/h'
                          : '14 種類の大カテゴリから選択できます',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                isSelected ? Icons.swap_horiz : Icons.chevron_right,
                color: theme.colorScheme.outline,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
