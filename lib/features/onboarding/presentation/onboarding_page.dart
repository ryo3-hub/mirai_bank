import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../shared/widgets/top_toast.dart';
import '../../category/application/category_providers.dart';
import '../../category/domain/category.dart';
import '../../category/domain/category_master.dart';
import '../../category/domain/category_presets.dart';
import '../../category/presentation/category_master_picker_sheet.dart';
import '../../category/presentation/widgets/category_edit_mode_selector.dart';
import '../../category/presentation/widgets/category_form_widgets.dart';
import '../../goals/application/goal_providers.dart';
import '../../goals/domain/goal.dart';
import '../application/onboarding_state.dart';

/// オンボーディングのステップ。
///
/// issue #102: カテゴリを実際に作成したユーザーには、続けて目標プリセットも
/// 選ばせる 2 ステップ構成。カテゴリをスキップした場合は目標ステップを出さない。
enum _OnboardingStep { category, goal }

class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  static final _rateFormatter = NumberFormat('#,###');

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _rateController = TextEditingController(text: '1000');
  final _rateFocus = FocusNode();
  String _iconCode = CategoryPresets.defaultIcon;
  String _colorCode = CategoryPresets.defaultColor;
  String? _masterKey;
  CategoryEditMode _mode = CategoryEditMode.preset;

  _OnboardingStep _step = _OnboardingStep.category;
  Category? _createdCategory;
  GoalPreset? _selectedPreset;

  bool _saving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _rateController.dispose();
    _rateFocus.dispose();
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

  Future<void> _onCategoryStart() async {
    // プリセットモードで master 未選択のときはガード
    if (_mode == CategoryEditMode.preset && _masterKey == null) {
      TopToast.show(
        context,
        message: 'プリセットを選んでください',
        isError: true,
      );
      return;
    }
    // custom モードのときだけ Form のバリデーションを走らせる
    if (_mode == CategoryEditMode.custom &&
        !_formKey.currentState!.validate()) {
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() => _saving = true);
    try {
      final masterKey = _mode == CategoryEditMode.preset ? _masterKey : null;
      final created =
          await ref.read(categoryControllerProvider.notifier).create(
                name: _nameController.text.trim(),
                hourlyRate: int.parse(_rateController.text.trim()),
                colorCode: _colorCode,
                iconCode: _iconCode,
                masterKey: masterKey,
              );
      if (!mounted) return;
      setState(() {
        _createdCategory = created;
        _step = _OnboardingStep.goal;
        _saving = false;
      });
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

  Future<void> _onCategorySkip() async {
    FocusScope.of(context).unfocus();
    setState(() => _saving = true);
    try {
      await ref.read(onboardingStateProvider.notifier).markCompleted();
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        TopToast.show(
          context,
          message: '初期化に失敗しました: $e',
          isError: true,
        );
      }
    }
  }

  Future<void> _onGoalSave() async {
    final preset = _selectedPreset;
    final category = _createdCategory;
    if (preset == null || category == null) return;
    setState(() => _saving = true);
    final start = _todayMidnight();
    final end = start.add(Duration(days: preset.days));
    final amount = preset.targetAmountFor(category);
    try {
      await ref.read(goalControllerProvider.notifier).create(
            type: GoalType.period,
            targetAmount: amount,
            categoryId: category.id,
            periodStart: start,
            periodEnd: end,
          );
      await ref.read(onboardingStateProvider.notifier).markCompleted();
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

  Future<void> _onGoalSkip() async {
    setState(() => _saving = true);
    try {
      await ref.read(onboardingStateProvider.notifier).markCompleted();
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        TopToast.show(
          context,
          message: '初期化に失敗しました: $e',
          isError: true,
        );
      }
    }
  }

  static DateTime _todayMidnight() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  @override
  Widget build(BuildContext context) {
    final keyboardVisible = MediaQuery.viewInsetsOf(context).bottom > 0;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => FocusScope.of(context).unfocus(),
            child: SafeArea(
              child: _step == _OnboardingStep.category
                  ? _buildCategoryStep(context)
                  : _buildGoalStep(context),
            ),
          ),
          if (keyboardVisible)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _KeyboardDoneBar(
                onDone: () => FocusScope.of(context).unfocus(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCategoryStep(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color:
                    theme.colorScheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.savings_outlined,
                size: 32,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'ようこそ',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'まず、カテゴリを 1 つ設定しましょう。\n'
              'あとから自由に変更できます。',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            CategoryEditModeSelector(
              mode: _mode,
              onChanged: (m) {
                setState(() {
                  _mode = m;
                  if (m == CategoryEditMode.custom) {
                    _masterKey = null;
                  }
                });
              },
            ),
            const SizedBox(height: 20),
            if (_mode == CategoryEditMode.preset) ...[
              _OnboardingPresetCard(
                masterKey: _masterKey,
                onTap: _pickFromMaster,
                rateFormatter: _rateFormatter,
              ),
              const SizedBox(height: 24),
            ] else ...[
              CategoryNameField(
                controller: _nameController,
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) => _rateFocus.requestFocus(),
              ),
              const SizedBox(height: 8),
              CategoryHourlyRateField(
                controller: _rateController,
                focusNode: _rateFocus,
                helperText: '将来の自分にとっての時間価値を入力',
              ),
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
            const SizedBox(height: 32),
            FilledButton(
              onPressed: _saving ? null : _onCategoryStart,
              child: _saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('始める'),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _saving ? null : _onCategorySkip,
              child: const Text('あとで設定する'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalStep(BuildContext context) {
    final theme = Theme.of(context);
    final category = _createdCategory;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.flag_outlined,
              size: 32,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            '目標を選びましょう',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            '達成予定日と金額の目安を表示します。\n'
            'あとから自由に変更できます。',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          if (category != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _CategoryChip(category: category),
            ),
          for (final preset in GoalPreset.values)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: _GoalPresetCard(
                preset: preset,
                selected: _selectedPreset == preset,
                amount: preset.targetAmountFor(category),
                deadline: _todayMidnight().add(Duration(days: preset.days)),
                onTap: () => setState(() => _selectedPreset = preset),
              ),
            ),
          const SizedBox(height: 32),
          FilledButton(
            onPressed: (_saving || _selectedPreset == null)
                ? null
                : _onGoalSave,
            child: _saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('設定する'),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: _saving ? null : _onGoalSkip,
            child: const Text('あとで設定する'),
          ),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({required this.category});

  final Category category;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = CategoryPresets.colorFor(category.colorCode);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor: color,
            foregroundColor: Colors.white,
            child: Icon(
              CategoryPresets.iconFor(category.iconCode),
              size: 14,
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              category.name,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _GoalPresetCard extends StatelessWidget {
  const _GoalPresetCard({
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

class _OnboardingPresetCard extends StatelessWidget {
  const _OnboardingPresetCard({
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
    final selected = minor != null;
    final accent = major == null
        ? theme.colorScheme.primary
        : CategoryPresets.colorFor(major.colorCode);
    return Material(
      color: selected
          ? accent.withValues(alpha: 0.08)
          : theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: selected ? accent : theme.colorScheme.outlineVariant,
          width: selected ? 1.5 : 1,
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
                      selected
                          ? '${major?.name ?? ''} / ${minor.name}'
                          : 'プリセットから選ぶ',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      selected
                          ? '推奨時給 ${rateFormatter.format(minor.recommendedRate)} 円/h'
                          : '時給の相場がわからなくても OK',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                selected ? Icons.swap_horiz : Icons.chevron_right,
                color: theme.colorScheme.outline,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _KeyboardDoneBar extends StatelessWidget {
  const _KeyboardDoneBar({required this.onDone});

  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surfaceContainerHigh,
      child: SizedBox(
        height: 44,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: onDone,
              child: const Text('完了'),
            ),
            const SizedBox(width: 4),
          ],
        ),
      ),
    );
  }
}
