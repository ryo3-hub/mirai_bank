import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../shared/achievement/amount_flash.dart';
import '../../../shared/utils/duration_formatter.dart';
import '../../category/application/category_providers.dart';
import '../../category/domain/category.dart';
import '../../category/domain/category_presets.dart';
import '../../category/presentation/category_picker_sheet.dart';
import '../../history/presentation/manual_record_sheet.dart';
import '../application/timer_providers.dart';
import '../domain/active_timer.dart';
import '../domain/amount_calculator.dart';
import 'widgets/dashboard_goals_section.dart';
import 'widgets/today_amount_card.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeTimerAsync = ref.watch(activeTimerProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('ホーム')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const TodayAmountCard(),
              const SizedBox(height: 12),
              const DashboardGoalsSection(),
              const SizedBox(height: 16),
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
              const SizedBox(height: 8),
              Center(
                child: TextButton.icon(
                  onPressed: () => ManualRecordSheet.show(context),
                  icon: const Icon(Icons.edit_note),
                  label: const Text('過去の記録を手動で追加'),
                ),
              ),
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

  Future<void> _start() async {
    final category = _selected;
    if (category == null) return;
    setState(() => _starting = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref
          .read(timerControllerProvider.notifier)
          .start(categoryId: category.id);
    } catch (e) {
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(content: Text('開始に失敗しました: $e')),
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
                  onPressed: _starting ? null : _start,
                  icon: _starting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.play_arrow),
                  label: const Text(
                    '計測を開始',
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
            'カテゴリがありません。\n設定画面から作成してください。',
            textAlign: TextAlign.center,
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
  late final TextEditingController _memoController;
  bool _stopping = false;

  @override
  void initState() {
    super.initState();
    _memoController =
        TextEditingController(text: widget.activeTimer.memo ?? '');
  }

  @override
  void dispose() {
    _memoController.dispose();
    super.dispose();
  }

  Future<void> _stop() async {
    setState(() => _stopping = true);
    FocusScope.of(context).unfocus();
    final messenger = ScaffoldMessenger.of(context);
    try {
      final session = await ref
          .read(timerControllerProvider.notifier)
          .stop(memo: _memoController.text);
      if (session != null && mounted) {
        AmountFlash.show(context, session.amount);
      }
    } catch (e) {
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(content: Text('停止に失敗しました: $e')),
        );
        setState(() => _stopping = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoryAsync =
        ref.watch(categoryByIdProvider(widget.activeTimer.categoryId));
    final elapsedAsync =
        ref.watch(elapsedSecondsProvider(widget.activeTimer.startTime));
    final elapsed = elapsedAsync.value ??
        DateTime.now()
            .difference(widget.activeTimer.startTime)
            .inSeconds;
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
                return _RunningCategoryHeader(category: category);
              },
            ),
            const SizedBox(height: 16),
            _ElapsedDisplay(seconds: elapsed),
            const SizedBox(height: 8),
            categoryAsync.when(
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
              data: (category) => _AmountDisplay(
                amount: AmountCalculator.calculate(
                  durationSec: elapsed,
                  hourlyRate: category?.hourlyRate ?? 0,
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _memoController,
              decoration: InputDecoration(
                labelText: 'メモ（任意）',
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: colorScheme.surface,
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _stopping ? null : _stop,
              icon: _stopping
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.stop),
              label: const Text(
                '計測を停止',
                style: TextStyle(fontSize: 16),
              ),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                backgroundColor: colorScheme.error,
                foregroundColor: colorScheme.onError,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RunningCategoryHeader extends StatelessWidget {
  const _RunningCategoryHeader({required this.category});

  final Category category;

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
              Icon(Icons.fiber_manual_record, size: 10, color: color),
              const SizedBox(width: 4),
              Text(
                '計測中',
                style: TextStyle(color: color, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ElapsedDisplay extends StatelessWidget {
  const _ElapsedDisplay({required this.seconds});

  final int seconds;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        DurationFormatter.hms(seconds),
        style: const TextStyle(
          fontSize: 48,
          fontWeight: FontWeight.w600,
          fontFeatures: [FontFeature.tabularFigures()],
        ),
      ),
    );
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
