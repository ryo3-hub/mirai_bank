import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../shared/widgets/top_toast.dart';
import '../application/category_providers.dart';
import '../domain/category.dart';
import '../domain/category_master.dart';
import '../domain/category_presets.dart';
import 'category_master_picker_sheet.dart';
import 'widgets/category_form_widgets.dart';

enum _EditMode { preset, custom }

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
  late _EditMode _mode;
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
        ? _EditMode.preset
        : (initial.masterKey != null ? _EditMode.preset : _EditMode.custom);
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
    if (_mode == _EditMode.preset && _masterKey == null) {
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
    if (_mode == _EditMode.custom &&
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
    final masterKey = _mode == _EditMode.preset ? _masterKey : null;
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
              const SizedBox(height: 16),
              _ModeSelector(
                mode: _mode,
                onChanged: (m) {
                  setState(() {
                    _mode = m;
                    // custom に切り替えたら master 紐付けを外す
                    if (m == _EditMode.custom) {
                      _masterKey = null;
                    }
                  });
                },
              ),
              const SizedBox(height: 20),
              if (_mode == _EditMode.preset) ...[
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
              FilledButton(
                onPressed: _saving ? null : _onSave,
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
      ),
    );
  }
}

class _ModeSelector extends StatelessWidget {
  const _ModeSelector({required this.mode, required this.onChanged});

  final _EditMode mode;
  final ValueChanged<_EditMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<_EditMode>(
      segments: const [
        ButtonSegment(
          value: _EditMode.preset,
          label: Text('プリセットから選ぶ'),
          icon: Icon(Icons.auto_awesome_outlined),
        ),
        ButtonSegment(
          value: _EditMode.custom,
          label: Text('自分で設定'),
          icon: Icon(Icons.edit_outlined),
        ),
      ],
      selected: {mode},
      showSelectedIcon: false,
      onSelectionChanged: (set) => onChanged(set.first),
      style: ButtonStyle(
        visualDensity: VisualDensity.compact,
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
