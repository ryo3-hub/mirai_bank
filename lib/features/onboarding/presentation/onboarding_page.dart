import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../shared/widgets/top_toast.dart';
import '../../category/application/category_providers.dart';
import '../../category/domain/category_master.dart';
import '../../category/domain/category_presets.dart';
import '../../category/presentation/category_master_picker_sheet.dart';
import '../../category/presentation/widgets/category_form_widgets.dart';
import '../application/onboarding_state.dart';

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

  Future<void> _onStart() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _saving = true);
    try {
      await ref.read(categoryControllerProvider.notifier).create(
            name: _nameController.text.trim(),
            hourlyRate: int.parse(_rateController.text.trim()),
            colorCode: _colorCode,
            iconCode: _iconCode,
            masterKey: _masterKey,
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

  Future<void> _onSkip() async {
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final keyboardVisible = MediaQuery.viewInsetsOf(context).bottom > 0;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => FocusScope.of(context).unfocus(),
            child: SafeArea(
              child: SingleChildScrollView(
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
                          color: theme.colorScheme.primary
                              .withValues(alpha: 0.1),
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
                        'まず、カテゴリを 1 つ選びましょう。\n'
                        'プリセットから選ぶと推奨時給がセットされます。',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      _OnboardingPresetCard(
                        masterKey: _masterKey,
                        onTap: _pickFromMaster,
                        rateFormatter: _rateFormatter,
                      ),
                      const SizedBox(height: 20),
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
                      const CategoryFormSectionLabel(text: 'アイコン'),
                      const SizedBox(height: 8),
                      CategoryIconPicker(
                        selected: _iconCode,
                        color: CategoryPresets.colorFor(_colorCode),
                        onChanged: (code) =>
                            setState(() => _iconCode = code),
                      ),
                      const SizedBox(height: 24),
                      const CategoryFormSectionLabel(text: 'カラー'),
                      const SizedBox(height: 8),
                      CategoryColorPicker(
                        selected: _colorCode,
                        onChanged: (code) =>
                            setState(() => _colorCode = code),
                      ),
                      const SizedBox(height: 32),
                      FilledButton(
                        onPressed: _saving ? null : _onStart,
                        child: _saving
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('始める'),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: _saving ? null : _onSkip,
                        child: const Text('あとで設定する'),
                      ),
                    ],
                  ),
                ),
              ),
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
