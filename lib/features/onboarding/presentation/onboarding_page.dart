import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../shared/widgets/keyboard_done_bar.dart';
import '../../../shared/widgets/save_action_button.dart';
import '../../../shared/widgets/top_toast.dart';
import '../../../shared/widgets/weekday_picker.dart';
import '../../category/application/category_providers.dart';
import '../../category/domain/category.dart';
import '../../category/domain/category_master.dart';
import '../../category/domain/category_presets.dart';
import '../../category/presentation/category_master_picker_sheet.dart';
import '../../category/presentation/widgets/category_edit_mode_selector.dart';
import '../../category/presentation/widgets/category_form_widgets.dart';
import '../../goals/application/goal_providers.dart';
import '../../goals/domain/goal.dart';
import '../../settings/application/setting_providers.dart';
import '../../settings/domain/app_setting.dart';
import '../application/onboarding_state.dart';
import '../domain/goal_questionnaire.dart';

/// オンボーディングのステップ。
///
/// issue #102: カテゴリを実際に作成したユーザーには、続けて目標設定もさせる
/// 2 ステップ構成。issue #108 で目標ステップを 3 問の質問票化（Q1→Q2→Q3→結果）。
/// issue #121 で目標設定後にリマインダー曜日選択ステップを追加。
enum _OnboardingStep { category, goal, reminder }

/// 目標ステップ内の小ステップ。issue #108 で導入。
enum _GoalSubStep { q1Frequency, q2SessionLength, q3Period, result }

class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  static final _rateFormatter = NumberFormat('#,###');
  static final _amountFormatter = NumberFormat('#,###');
  static final _dateFormatter = DateFormat('yyyy/M/d');

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _rateController = TextEditingController(text: '1000');
  final _rateFocus = FocusNode();
  String _iconCode = CategoryPresets.defaultIcon;
  String _colorCode = CategoryPresets.defaultColor;
  String? _masterKey;
  CategoryEditMode _mode = CategoryEditMode.preset;

  _OnboardingStep _step = _OnboardingStep.category;
  _GoalSubStep _goalSubStep = _GoalSubStep.q1Frequency;
  Category? _createdCategory;
  LearningFrequency? _ansFrequency;
  LearningSessionLength? _ansSessionLength;
  LearningPeriod? _ansPeriod;

  /// リマインダーで通知する曜日（issue #121）。デフォルトは全 7 曜日。
  /// DateTime.weekday 形式（1=月 .. 7=日）。
  final Set<int> _selectedWeekdays = AppSetting.allWeekdays.toSet();

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
        _goalSubStep = _GoalSubStep.q1Frequency;
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

  /// 結果画面の「この目標で設定する」。質問票の回答から計算した金額で目標を
  /// 作成し、リマインダーステップへ遷移する（issue #121）。オンボーディング完了
  /// フラグはリマインダーステップで立てる。
  Future<void> _onGoalSave() async {
    final category = _createdCategory;
    final freq = _ansFrequency;
    final length = _ansSessionLength;
    final period = _ansPeriod;
    if (category == null || freq == null || length == null || period == null) {
      return;
    }
    setState(() => _saving = true);
    final result = GoalQuestionnaireResult(
      frequency: freq,
      sessionLength: length,
      period: period,
    );
    final start = _todayMidnight();
    final end = start.add(Duration(days: period.days));
    final amount = result.cumulativeTargetAmount(category.hourlyRate);
    try {
      await ref.read(goalControllerProvider.notifier).create(
            type: GoalType.period,
            targetAmount: amount,
            categoryId: category.id,
            periodStart: start,
            periodEnd: end,
          );
      if (!mounted) return;
      setState(() {
        _step = _OnboardingStep.reminder;
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

  /// リマインダーステップの「設定する」。選んだ曜日を保存しリマインダーを
  /// 有効化する。通知許可が拒否された場合もオンボーディングは完了させる
  /// （設定画面からあとで再設定できるため）。
  Future<void> _onReminderSave() async {
    if (_selectedWeekdays.isEmpty) {
      TopToast.show(
        context,
        message: '曜日を 1 つ以上選んでください',
        isError: true,
      );
      return;
    }
    setState(() => _saving = true);
    final controller = ref.read(settingControllerProvider.notifier);
    try {
      // 先に曜日を保存（reminderEnabled が false でも DB には残る）
      await controller.setReminderWeekdays(_selectedWeekdays);
      // リマインダー有効化（通知許可が拒否されると StateError がスロー
      // される。catch してオンボーディングは続行）
      try {
        await controller.setReminderEnabled(
          enabled: true,
          time: AppSetting.defaults.reminderTimeOfDay,
          weekdays: _selectedWeekdays,
        );
      } catch (e) {
        if (mounted) {
          TopToast.show(
            context,
            message:
                '通知の許可が得られなかったため、リマインダーはオフのままです。設定画面からあとで有効化できます。',
            isError: true,
          );
        }
      }
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

  /// リマインダーステップの「あとで設定する」。設定変更はせずオンボーディング
  /// 完了フラグだけを立てる。
  Future<void> _onReminderSkip() async {
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

  /// リマインダーステップの戻る → 結果画面へ。
  void _onReminderBack() {
    setState(() {
      _step = _OnboardingStep.goal;
      _goalSubStep = _GoalSubStep.result;
    });
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

  /// 質問票の戻る。
  ///
  /// - Q1 の戻る: 直前に作成したカテゴリをソフトデリートしてカテゴリステップへ
  ///   復帰（issue #106 案 B: ロールバック）
  /// - Q2 / Q3 / 結果 の戻る: 直前の質問へ
  Future<void> _onGoalBack() async {
    switch (_goalSubStep) {
      case _GoalSubStep.q1Frequency:
        final created = _createdCategory;
        if (created == null) return;
        setState(() => _saving = true);
        try {
          await ref.read(categoryControllerProvider.notifier).delete(created.id);
          if (!mounted) return;
          setState(() {
            _createdCategory = null;
            _ansFrequency = null;
            _ansSessionLength = null;
            _ansPeriod = null;
            _step = _OnboardingStep.category;
            _saving = false;
          });
        } catch (e) {
          if (mounted) {
            setState(() => _saving = false);
            TopToast.show(
              context,
              message: '戻る処理に失敗しました: $e',
              isError: true,
            );
          }
        }
      case _GoalSubStep.q2SessionLength:
        setState(() => _goalSubStep = _GoalSubStep.q1Frequency);
      case _GoalSubStep.q3Period:
        setState(() => _goalSubStep = _GoalSubStep.q2SessionLength);
      case _GoalSubStep.result:
        setState(() => _goalSubStep = _GoalSubStep.q3Period);
    }
  }

  static DateTime _todayMidnight() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => FocusScope.of(context).unfocus(),
            child: SafeArea(
              child: switch (_step) {
                _OnboardingStep.category => _buildCategoryStep(context),
                _OnboardingStep.goal => _buildGoalStep(context),
                _OnboardingStep.reminder => _buildReminderStep(context),
              },
            ),
          ),
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

  /// issue #121: リマインダーで通知する曜日を選ぶステップ。
  /// デフォルトは全曜日選択 + リマインダー時刻 21:00（[AppSetting.defaults]）。
  /// 「設定する」で `reminderWeekdays` を保存しリマインダーを有効化、
  /// 「あとで設定する」でスキップ。
  Widget _buildReminderStep(BuildContext context) {
    final theme = Theme.of(context);
    final defaultTime = AppSetting.defaults.reminderTimeOfDay;
    final timeLabel =
        '${defaultTime.hour.toString().padLeft(2, '0')}:'
        '${defaultTime.minute.toString().padLeft(2, '0')}';
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 4, 16, 0),
            child: Row(
              children: [
                IconButton(
                  onPressed: _saving ? null : _onReminderBack,
                  icon: const Icon(Icons.arrow_back),
                  tooltip: '戻る',
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
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
                    Icons.notifications_active_outlined,
                    size: 32,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  '学習する曜日は？',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  '選んだ曜日の $timeLabel に\nリマインダー通知をお届けします。',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                WeekdayPicker(
                  selected: _selectedWeekdays,
                  onToggle: (w) {
                    setState(() {
                      if (_selectedWeekdays.contains(w)) {
                        _selectedWeekdays.remove(w);
                      } else {
                        _selectedWeekdays.add(w);
                      }
                    });
                  },
                ),
                const SizedBox(height: 12),
                Text(
                  '時刻と通知の有無は設定画面からあとで変更できます。',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                SaveActionButton(
                  label: 'リマインダーを設定する',
                  icon: Icons.notifications_active_outlined,
                  loading: _saving,
                  onPressed: _onReminderSave,
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: _saving ? null : _onReminderSkip,
                  child: const Text('あとで設定する'),
                ),
              ],
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
            SaveActionButton(
              label: '始める',
              icon: Icons.play_circle_outline,
              loading: _saving,
              onPressed: _onCategoryStart,
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
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 4, 16, 0),
            child: Row(
              children: [
                IconButton(
                  onPressed: _saving ? null : _onGoalBack,
                  icon: const Icon(Icons.arrow_back),
                  tooltip: '戻る',
                ),
                const Spacer(),
                if (_goalSubStep != _GoalSubStep.result)
                  _StepIndicator(currentStep: _goalSubStep),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
            child: _buildGoalSubStepBody(context),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalSubStepBody(BuildContext context) {
    final category = _createdCategory;
    switch (_goalSubStep) {
      case _GoalSubStep.q1Frequency:
        return _QuestionView<LearningFrequency>(
          headline: 'どんなペースで\n取り組みたいですか？',
          subhead: 'カテゴリ：${category?.name ?? ''}',
          options: LearningFrequency.values,
          labelOf: (e) => e.label,
          emojiOf: (e) => e.emoji,
          subOf: (e) => e.sub,
          recommendedOf: (e) => e.isRecommended,
          selected: _ansFrequency,
          onTap: (e) {
            setState(() {
              _ansFrequency = e;
              _goalSubStep = _GoalSubStep.q2SessionLength;
            });
          },
          onSkip: _saving ? null : _onGoalSkip,
        );
      case _GoalSubStep.q2SessionLength:
        return _QuestionView<LearningSessionLength>(
          headline: '1回あたり\nどれくらい取り組みたいですか？',
          subhead: null,
          options: LearningSessionLength.values,
          labelOf: (e) => e.label,
          emojiOf: (e) => e.emoji,
          subOf: (e) => e.sub,
          recommendedOf: (e) => e.isRecommended,
          selected: _ansSessionLength,
          onTap: (e) {
            setState(() {
              _ansSessionLength = e;
              _goalSubStep = _GoalSubStep.q3Period;
            });
          },
          onSkip: _saving ? null : _onGoalSkip,
        );
      case _GoalSubStep.q3Period:
        return _QuestionView<LearningPeriod>(
          headline: 'どれくらいの期間\n続けたいですか？',
          subhead: null,
          options: LearningPeriod.values,
          labelOf: (e) => e.label,
          emojiOf: (e) => e.emoji,
          subOf: (e) => e.sub,
          recommendedOf: (e) => e.isRecommended,
          selected: _ansPeriod,
          onTap: (e) {
            setState(() {
              _ansPeriod = e;
              _goalSubStep = _GoalSubStep.result;
            });
          },
          onSkip: _saving ? null : _onGoalSkip,
        );
      case _GoalSubStep.result:
        return _buildResultBody(context);
    }
  }

  Widget _buildResultBody(BuildContext context) {
    final theme = Theme.of(context);
    final category = _createdCategory;
    final freq = _ansFrequency;
    final length = _ansSessionLength;
    final period = _ansPeriod;
    if (category == null || freq == null || length == null || period == null) {
      // 通常ここには来ないが、ガード
      return const SizedBox.shrink();
    }
    final result = GoalQuestionnaireResult(
      frequency: freq,
      sessionLength: length,
      period: period,
    );
    final cumulative = result.cumulativeTargetAmount(category.hourlyRate);
    final monthly = result.monthlyTargetAmount(category.hourlyRate);
    final deadline = _todayMidnight().add(Duration(days: period.days));
    final isHard = result.isHardCombo;
    final annualMan =
        (result.annualTargetAmount(category.hourlyRate) / 10000).round();
    return Column(
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
          'おすすめの目標',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: _CategoryChip(category: category),
        ),
        const SizedBox(height: 16),
        Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  '${period.sub}コース',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  '達成予定: ${_dateFormatter.format(deadline)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  '${_amountFormatter.format(cumulative)} 円',
                  style: theme.textTheme.displaySmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w800,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  '月あたり ${_amountFormatter.format(monthly)} 円',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Divider(
                  color: theme.colorScheme.outlineVariant,
                  height: 1,
                ),
                const SizedBox(height: 12),
                _ResultDetailRow(
                  label: 'ペース',
                  value: '${freq.emoji} ${freq.label}',
                ),
                const SizedBox(height: 6),
                _ResultDetailRow(
                  label: '1 回あたり',
                  value: '${length.emoji} ${length.label}',
                ),
                const SizedBox(height: 6),
                _ResultDetailRow(
                  label: '期間',
                  value: '${period.emoji} ${period.label}',
                ),
              ],
            ),
          ),
        ),
        if (isHard) ...[
          const SizedBox(height: 16),
          _HardComboHintCard(
            hoursPerDay: length.hoursPerDay,
            freqPhrase: freq.phrase,
            periodPhrase: period.phrase,
            annualMan: annualMan,
          ),
        ],
        const SizedBox(height: 24),
        SaveActionButton(
          label: 'この目標で設定する',
          icon: Icons.check_circle_outline,
          loading: _saving,
          onPressed: _onGoalSave,
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: _saving ? null : _onGoalSkip,
          child: const Text('あとで設定する'),
        ),
      ],
    );
  }
}

/// 質問の進捗インジケータ（1/3, 2/3, 3/3）。
class _StepIndicator extends StatelessWidget {
  const _StepIndicator({required this.currentStep});

  final _GoalSubStep currentStep;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final index = switch (currentStep) {
      _GoalSubStep.q1Frequency => 1,
      _GoalSubStep.q2SessionLength => 2,
      _GoalSubStep.q3Period => 3,
      _GoalSubStep.result => 3,
    };
    return Text(
      '$index / 3',
      style: theme.textTheme.bodyMedium?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

/// 質問 1 枚分のビュー。4 つの選択肢カードを縦並びで表示する。
class _QuestionView<T> extends StatelessWidget {
  const _QuestionView({
    required this.headline,
    required this.subhead,
    required this.options,
    required this.labelOf,
    required this.emojiOf,
    required this.subOf,
    required this.recommendedOf,
    required this.selected,
    required this.onTap,
    required this.onSkip,
  });

  final String headline;
  final String? subhead;
  final List<T> options;
  final String Function(T) labelOf;
  final String Function(T) emojiOf;
  final String Function(T) subOf;
  final bool Function(T) recommendedOf;
  final T? selected;
  final ValueChanged<T> onTap;
  final VoidCallback? onSkip;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          headline,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
            height: 1.3,
          ),
          textAlign: TextAlign.center,
        ),
        if (subhead != null) ...[
          const SizedBox(height: 8),
          Text(
            subhead!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
        const SizedBox(height: 24),
        for (final opt in options)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: _QuestionOptionCard(
              label: labelOf(opt),
              emoji: emojiOf(opt),
              sub: subOf(opt),
              recommended: recommendedOf(opt),
              selected: opt == selected,
              onTap: () => onTap(opt),
            ),
          ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: onSkip,
          child: const Text('あとで設定する'),
        ),
      ],
    );
  }
}

class _QuestionOptionCard extends StatelessWidget {
  const _QuestionOptionCard({
    required this.label,
    required this.emoji,
    required this.sub,
    required this.recommended,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String emoji;
  final String sub;
  final bool recommended;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = theme.colorScheme.primary;
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
            border: Border.all(
              color: selected ? accent : theme.colorScheme.outlineVariant,
              width: selected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Text(
                emoji,
                style: const TextStyle(fontSize: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Text(
                            label,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        if (recommended) ...[
                          const SizedBox(width: 6),
                          const _RecommendedBadge(),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      sub,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: theme.colorScheme.outline,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 続けやすい選択肢につける小さな「おすすめ」バッジ。
class _RecommendedBadge extends StatelessWidget {
  const _RecommendedBadge();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = Colors.green.shade700;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: accent.withValues(alpha: 0.4), width: 1),
      ),
      child: Text(
        'おすすめ',
        style: theme.textTheme.labelSmall?.copyWith(
          color: accent,
          fontWeight: FontWeight.w700,
          fontSize: 10,
          height: 1.2,
        ),
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
    return Center(
      child: Container(
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
      ),
    );
  }
}

/// 飛ばしすぎ警告カード。issue #108 の継続支援メッセージ。
///
/// 高頻度 × 高強度 × 長期 の組み合わせを選んだときだけ表示される。
class _HardComboHintCard extends StatelessWidget {
  const _HardComboHintCard({
    required this.hoursPerDay,
    required this.freqPhrase,
    required this.periodPhrase,
    required this.annualMan,
  });

  final double hoursPerDay;
  final String freqPhrase;
  final String periodPhrase;
  final int annualMan;

  String _formatHours(double hours) {
    // 2.5 → "2.5", 1.5 → "1.5"。小数点以下が 0 なら整数表記。
    if (hours == hours.roundToDouble()) {
      return hours.toInt().toString();
    }
    return hours.toString();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = Colors.orange.shade700;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accent.withValues(alpha: 0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.tips_and_updates_outlined,
            color: accent,
            size: 22,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '1日${_formatHours(hoursPerDay)}時間 × $freqPhrase × $periodPhraseは、'
                  '年間累計 約$annualMan万円分 のすごい自己投資ペースです。',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'ただ、最初から飛ばしすぎると続かなくなることも。\n'
                  '7割くらいの目標から始めて、慣れてきたら上げていくのもおすすめですよ。',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultDetailRow extends StatelessWidget {
  const _ResultDetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
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

