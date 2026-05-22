import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../shared/achievement/amount_flash.dart';
import '../../../shared/utils/duration_formatter.dart';
import '../../../shared/widgets/top_toast.dart';
import '../../category/application/category_providers.dart';
import '../../category/domain/category.dart';
import '../../category/domain/category_presets.dart';
import '../../category/presentation/category_edit_sheet.dart';
import '../../category/presentation/category_picker_sheet.dart';
import '../../history/domain/work_session.dart';
import '../application/timer_providers.dart';
import '../domain/active_timer.dart';
import '../domain/amount_calculator.dart';
import 'timer_preset_picker_sheet.dart';
import 'widgets/dashboard_goals_section.dart';
import 'widgets/streak_badge.dart';
import 'widgets/today_amount_card.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeTimerAsync = ref.watch(activeTimerProvider);
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const StreakBadge(),
              const TodayAmountCard(),
              const SizedBox(height: 12),
              activeTimerAsync.when(
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (e, _) => Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text('タイマーの読み込みに失敗しました: $e'),
                  ),
                ),
                data: (activeTimer) => activeTimer == null
                    ? const _TimerIdleCard()
                    : _TimerRunningCard(activeTimer: activeTimer),
              ),
              const SizedBox(height: 12),
              const DashboardGoalsSection(),
            ],
          ),
        ),
      ),
    );
  }
}

class _TimerIdleCard extends ConsumerStatefulWidget {
  const _TimerIdleCard();

  @override
  ConsumerState<_TimerIdleCard> createState() => _TimerIdleCardState();
}

class _TimerIdleCardState extends ConsumerState<_TimerIdleCard> {
  Category? _selected;
  bool _starting = false;

  Future<void> _pickCategory(List<Category> categories) async {
    final result = await CategoryPickerSheet.show(
      context,
      categories: categories,
      selectedId: _selected?.id,
    );
    if (result != null) {
      setState(() => _selected = result);
    }
  }

  Future<void> _pickPresetAndStart() async {
    final category = _selected;
    if (category == null) return;
    final preset = await TimerPresetPickerSheet.show(context);
    if (preset == null || !mounted) return;
    setState(() => _starting = true);
    try {
      await ref.read(timerControllerProvider.notifier).start(
            categoryId: category.id,
            targetDurationSec: preset.durationSec,
          );
    } catch (e) {
      if (mounted) {
        TopToast.show(
          context,
          message: '開始に失敗しました: $e',
          isError: true,
        );
      }
    } finally {
      if (mounted) setState(() => _starting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesListProvider);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: categoriesAsync.when(
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (e, _) => Text('カテゴリの読み込みに失敗: $e'),
          data: (categories) {
            if (categories.isEmpty) {
              return const _NoCategoryView();
            }
            final selected = _selected ?? categories.first;
            if (_selected == null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted && _selected == null) {
                  setState(() => _selected = categories.first);
                }
              });
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'タイマーで学習を始める',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                _CategorySelector(
                  category: selected,
                  onTap: () => _pickCategory(categories),
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: _starting ? null : _pickPresetAndStart,
                  icon: _starting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.play_arrow),
                  label: const Text(
                    'プリセットを選んで開始',
                    style: TextStyle(fontSize: 16),
                  ),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _NoCategoryView extends StatelessWidget {
  const _NoCategoryView();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Icon(
            Icons.category_outlined,
            size: 48,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 12),
          const Text(
            'カテゴリがありません',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: () => CategoryEditSheet.show(context),
            icon: const Icon(Icons.add),
            label: const Text('カテゴリを追加'),
          ),
        ],
      ),
    );
  }
}

class _CategorySelector extends StatelessWidget {
  const _CategorySelector({required this.category, required this.onTap});

  final Category category;
  final VoidCallback onTap;

  static final _rateFormatter = NumberFormat('#,###');

  @override
  Widget build(BuildContext context) {
    final color = CategoryPresets.colorFor(category.colorCode);
    final icon = CategoryPresets.iconFor(category.iconCode);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border: Border.all(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color,
              foregroundColor: Colors.white,
              radius: 20,
              child: Icon(icon, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category.name,
                    style: Theme.of(context).textTheme.titleMedium,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  Text(
                    '${_rateFormatter.format(category.hourlyRate)} 円/h',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const Icon(Icons.unfold_more),
          ],
        ),
      ),
    );
  }
}

class _TimerRunningCard extends ConsumerStatefulWidget {
  const _TimerRunningCard({required this.activeTimer});

  final ActiveTimer activeTimer;

  @override
  ConsumerState<_TimerRunningCard> createState() => _TimerRunningCardState();
}

class _TimerRunningCardState extends ConsumerState<_TimerRunningCard> {
  late TextEditingController _memoController;
  bool _busy = false;
  bool _autoStopTriggered = false;
  String? _lastTimerId;

  @override
  void initState() {
    super.initState();
    _memoController = TextEditingController(text: widget.activeTimer.memo ?? '');
    _lastTimerId = _timerKey(widget.activeTimer);
  }

  @override
  void didUpdateWidget(_TimerRunningCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    final newKey = _timerKey(widget.activeTimer);
    if (newKey != _lastTimerId) {
      _lastTimerId = newKey;
      _memoController.text = widget.activeTimer.memo ?? '';
      _autoStopTriggered = false;
    }
  }

  @override
  void dispose() {
    _memoController.dispose();
    super.dispose();
  }

  String _timerKey(ActiveTimer t) =>
      '${t.startTime.millisecondsSinceEpoch}-${t.categoryId}';

  Future<void> _stop({bool auto = false}) async {
    if (_busy) return;
    setState(() => _busy = true);
    FocusScope.of(context).unfocus();
    try {
      // 入力されたメモを保存してから停止する
      await ref
          .read(timerControllerProvider.notifier)
          .updateMemo(_memoController.text);
      final session = await ref
          .read(timerControllerProvider.notifier)
          .stop(memo: _memoController.text);
      if (!mounted) return;
      if (session != null) {
        AmountFlash.show(context, session.amount);
      } else if (!auto) {
        TopToast.show(context, message: '15 分未満だったので記録しませんでした');
      }
    } catch (e) {
      if (mounted) {
        TopToast.show(
          context,
          message: '停止に失敗しました: $e',
          isError: true,
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _togglePause() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      if (widget.activeTimer.isPaused) {
        await ref.read(timerControllerProvider.notifier).resume();
      } else {
        // 一時停止前に最新メモを保存
        await ref
            .read(timerControllerProvider.notifier)
            .updateMemo(_memoController.text);
        await ref.read(timerControllerProvider.notifier).pause();
      }
    } catch (e) {
      if (mounted) {
        TopToast.show(
          context,
          message: '操作に失敗しました: $e',
          isError: true,
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final timer = widget.activeTimer;
    final categoryAsync = ref.watch(categoryByIdProvider(timer.categoryId));
    final elapsedAsync = ref.watch(timerElapsedProvider);
    final elapsed = elapsedAsync.value ??
        timer.elapsedSecondsAt(DateTime.now());
    final remaining = (timer.targetDurationSec - elapsed).clamp(0, 1 << 30);
    final progress = timer.targetDurationSec == 0
        ? 0.0
        : (elapsed / timer.targetDurationSec).clamp(0.0, 1.0);
    final isCompleted = remaining == 0 && timer.targetDurationSec > 0;

    // 完了したら 1 度だけ自動停止
    if (isCompleted && !_autoStopTriggered && !_busy) {
      _autoStopTriggered = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _stop(auto: true);
      });
    }

    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      color: colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            categoryAsync.when(
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
              data: (category) {
                if (category == null) return const SizedBox.shrink();
                return _RunningCategoryHeader(
                  category: category,
                  isPaused: timer.isPaused,
                );
              },
            ),
            const SizedBox(height: 16),
            _CountdownDisplay(
              remainingSec: remaining,
              progress: progress,
              isPaused: timer.isPaused,
            ),
            const SizedBox(height: 8),
            categoryAsync.when(
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
              data: (category) => _AmountDisplay(
                amount: AmountCalculator.calculatePaid(
                  workedSec: elapsed,
                  hourlyRate: category?.hourlyRate ?? 0,
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _memoController,
              decoration: InputDecoration(
                labelText: 'メモ（スキルアップ内容など）',
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: colorScheme.surface,
              ),
              maxLines: 2,
              maxLength: WorkSession.memoMaxLength,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: FilledButton.tonalIcon(
                    onPressed: _busy ? null : _togglePause,
                    icon: Icon(
                      timer.isPaused
                          ? Icons.play_arrow
                          : Icons.pause,
                    ),
                    label: Text(timer.isPaused ? '再開' : '一時停止'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _busy ? null : () => _stop(),
                    icon: _busy
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.stop),
                    label: const Text('停止'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: colorScheme.error,
                      foregroundColor: colorScheme.onError,
                    ),
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

class _RunningCategoryHeader extends StatelessWidget {
  const _RunningCategoryHeader({
    required this.category,
    required this.isPaused,
  });

  final Category category;
  final bool isPaused;

  @override
  Widget build(BuildContext context) {
    final color = CategoryPresets.colorFor(category.colorCode);
    return Row(
      children: [
        CircleAvatar(
          backgroundColor: color,
          foregroundColor: Colors.white,
          radius: 18,
          child: Icon(CategoryPresets.iconFor(category.iconCode), size: 18),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            category.name,
            style: Theme.of(context).textTheme.titleMedium,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isPaused
                    ? Icons.pause_circle_filled
                    : Icons.fiber_manual_record,
                size: 12,
                color: color,
              ),
              const SizedBox(width: 4),
              Text(
                isPaused ? '一時停止中' : '集中中',
                style: TextStyle(color: color, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CountdownDisplay extends StatelessWidget {
  const _CountdownDisplay({
    required this.remainingSec,
    required this.progress,
    required this.isPaused,
  });

  final int remainingSec;
  final double progress;
  final bool isPaused;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          _formatRemaining(remainingSec),
          style: TextStyle(
            fontSize: 56,
            fontWeight: FontWeight.w700,
            color: isPaused
                ? theme.colorScheme.onSurfaceVariant
                : theme.colorScheme.onSurface,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 6,
            backgroundColor: theme.colorScheme.surface,
            valueColor: AlwaysStoppedAnimation(
              isPaused
                  ? theme.colorScheme.onSurfaceVariant
                  : theme.colorScheme.primary,
            ),
          ),
        ),
      ],
    );
  }

  static String _formatRemaining(int seconds) {
    final s = seconds < 0 ? 0 : seconds;
    final m = s ~/ 60;
    final r = s % 60;
    return '${m.toString().padLeft(2, '0')}:${r.toString().padLeft(2, '0')}';
  }
}

class _AmountDisplay extends StatelessWidget {
  const _AmountDisplay({required this.amount});

  final int amount;

  static final _formatter = NumberFormat('#,###');

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        '${_formatter.format(amount)} 円',
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}

// 旧ストップウォッチ用フォーマッタが他から参照されないように、
// DurationFormatter は他画面でも引き続き使うので import は残す。
// （未使用警告を避けるため `void` 関数で参照を保つ）
// ignore: unused_element
void _retain() => DurationFormatter.hms(0);
