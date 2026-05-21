import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../shared/utils/weekday_color.dart';
import '../../category/application/category_providers.dart';
import '../../category/domain/category.dart';
import '../../category/domain/category_presets.dart';
import '../application/calendar_providers.dart';
import '../domain/daily_stats.dart';
import '../domain/work_session.dart';
import 'manual_record_sheet.dart';
import 'widgets/session_card.dart';

class CalendarPage extends ConsumerStatefulWidget {
  const CalendarPage({super.key});

  @override
  ConsumerState<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends ConsumerState<CalendarPage> {
  late DateTime _focusedDay;
  late DateTime _selectedDay;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _focusedDay = DateTime(now.year, now.month, now.day);
    _selectedDay = _focusedDay;
  }

  void _onDaySelected(DateTime selected, DateTime focused) {
    setState(() {
      _selectedDay = DateTime(selected.year, selected.month, selected.day);
      _focusedDay = focused;
    });
  }

  void _onPageChanged(DateTime focused) {
    setState(() => _focusedDay = focused);
  }

  @override
  Widget build(BuildContext context) {
    final monthStart = DateTime(_focusedDay.year, _focusedDay.month, 1);
    final dailyStatsAsync = ref.watch(dailyStatsMapProvider(monthStart));
    final dailyStats =
        dailyStatsAsync.value ?? const <DateTime, DailyStats>{};
    final categoriesAsync = ref.watch(categoriesListProvider);
    final categoryColors = <String, String>{
      for (final c in categoriesAsync.value ?? const <Category>[])
        c.id: c.colorCode,
    };
    final maxAmount = dailyStats.values
        .fold<int>(0, (m, s) => s.amount > m ? s.amount : m);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _CalendarCard(
              focusedDay: _focusedDay,
              selectedDay: _selectedDay,
              dailyStats: dailyStats,
              categoryColors: categoryColors,
              maxAmount: maxAmount,
              onDaySelected: _onDaySelected,
              onPageChanged: _onPageChanged,
            ),
            const Divider(height: 1),
            Expanded(child: _DaySessionsView(date: _selectedDay)),
          ],
        ),
      ),
    );
  }
}

class _CalendarCard extends StatelessWidget {
  const _CalendarCard({
    required this.focusedDay,
    required this.selectedDay,
    required this.dailyStats,
    required this.categoryColors,
    required this.maxAmount,
    required this.onDaySelected,
    required this.onPageChanged,
  });

  final DateTime focusedDay;
  final DateTime selectedDay;
  final Map<DateTime, DailyStats> dailyStats;

  /// categoryId -> hex color code (`#RRGGBB`)
  final Map<String, String> categoryColors;

  /// 月内の最大金額。ヒートマップ濃度の正規化に使う。0 のときは色なし。
  final int maxAmount;
  final void Function(DateTime selected, DateTime focused) onDaySelected;
  final ValueChanged<DateTime> onPageChanged;

  DateTime _dateOnly(DateTime t) => DateTime(t.year, t.month, t.day);

  Color? _dominantColorFor(DateTime day) {
    final stats = dailyStats[_dateOnly(day)];
    if (stats == null) return null;
    final hex = categoryColors[stats.dominantCategoryId];
    if (hex == null) return null;
    return CategoryPresets.colorFor(hex);
  }

  /// amount を 0.10〜0.25 の alpha に正規化（ヒートマップ濃度）。
  double _alphaFor(int amount) {
    if (maxAmount <= 0 || amount <= 0) return 0;
    final ratio = (amount / maxAmount).clamp(0.0, 1.0);
    return 0.10 + ratio * 0.15;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _CalendarHeader(
          month: focusedDay,
          onPrev: () => onPageChanged(
            DateTime(focusedDay.year, focusedDay.month - 1, 1),
          ),
          onNext: () => onPageChanged(
            DateTime(focusedDay.year, focusedDay.month + 1, 1),
          ),
        ),
        TableCalendar(
          firstDay: DateTime(2020, 1, 1),
          lastDay: DateTime(DateTime.now().year + 5, 12, 31),
          focusedDay: focusedDay,
          selectedDayPredicate: (day) => isSameDay(day, selectedDay),
          onDaySelected: onDaySelected,
          onPageChanged: onPageChanged,
          calendarFormat: CalendarFormat.month,
          availableCalendarFormats: const {CalendarFormat.month: 'Month'},
          locale: 'ja_JP',
          startingDayOfWeek: StartingDayOfWeek.sunday,
          headerVisible: false,
          rowHeight: 56,
          daysOfWeekHeight: 28,
          calendarBuilders: CalendarBuilders<dynamic>(
            dowBuilder: (context, day) {
              final label = DateFormat.E('ja').format(day);
              final color = weekdayColor(context, day.weekday);
              return Center(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: color ??
                        Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              );
            },
            defaultBuilder: (context, day, _) {
              final stats = dailyStats[_dateOnly(day)];
              return _DayCell(
                day: day,
                amount: stats?.amount ?? 0,
                dominantColor: _dominantColorFor(day),
                bgAlpha: _alphaFor(stats?.amount ?? 0),
                isToday: false,
                isSelected: false,
              );
            },
            todayBuilder: (context, day, _) {
              final stats = dailyStats[_dateOnly(day)];
              return _DayCell(
                day: day,
                amount: stats?.amount ?? 0,
                dominantColor: _dominantColorFor(day),
                bgAlpha: _alphaFor(stats?.amount ?? 0),
                isToday: true,
                isSelected: false,
              );
            },
            selectedBuilder: (context, day, _) {
              final stats = dailyStats[_dateOnly(day)];
              return _DayCell(
                day: day,
                amount: stats?.amount ?? 0,
                dominantColor: _dominantColorFor(day),
                bgAlpha: _alphaFor(stats?.amount ?? 0),
                isToday: isSameDay(day, DateTime.now()),
                isSelected: true,
              );
            },
            outsideBuilder: (context, day, _) {
              return _DayCell(
                day: day,
                amount: 0,
                dominantColor: null,
                bgAlpha: 0,
                isToday: false,
                isSelected: false,
                isOutside: true,
              );
            },
          ),
        ),
      ],
    );
  }
}

class _CalendarHeader extends StatelessWidget {
  const _CalendarHeader({
    required this.month,
    required this.onPrev,
    required this.onNext,
  });

  final DateTime month;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lastDay = DateTime(month.year, month.month + 1, 0).day;
    final title = '${month.year}年${month.month}月';
    final range = '${month.month}月1日〜${month.month}月$lastDay日';
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: onPrev,
            tooltip: '前の月',
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  range,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: onNext,
            tooltip: '次の月',
          ),
        ],
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.day,
    required this.amount,
    required this.dominantColor,
    required this.bgAlpha,
    required this.isToday,
    required this.isSelected,
    this.isOutside = false,
  });

  final DateTime day;
  final int amount;

  /// その日の主カテゴリ色（金額 0 のとき / outside のときは null）
  final Color? dominantColor;

  /// 背景に適用する alpha（ヒートマップ濃度）。0 のとき塗らない。
  final double bgAlpha;
  final bool isToday;
  final bool isSelected;
  final bool isOutside;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final weekendColor = weekdayColor(context, day.weekday);

    final Color dayNumberColor;
    if (isOutside) {
      dayNumberColor =
          (weekendColor ?? colorScheme.outline).withValues(alpha: 0.4);
    } else {
      dayNumberColor = weekendColor ?? colorScheme.onSurface;
    }

    final hasCategoryBg =
        dominantColor != null && bgAlpha > 0 && !isOutside;
    final bgColor = hasCategoryBg
        ? dominantColor!.withValues(alpha: bgAlpha)
        : Colors.transparent;

    // 選択日はカテゴリ色背景と区別するため primary の枠線で囲む。
    final border = isSelected
        ? Border.all(color: colorScheme.primary, width: 1.5)
        : null;

    final showAmount = amount > 0 && !isOutside;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
          border: border,
        ),
        child: SizedBox.expand(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${day.day}',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: (isToday || isSelected)
                      ? FontWeight.w700
                      : FontWeight.w500,
                  color: dayNumberColor,
                ),
              ),
              const SizedBox(height: 2),
              // Reserve the amount slot regardless of whether an amount
              // is displayed, so the day number stays vertically centered
              // at the same position across all cells.
              SizedBox(
                height: 13,
                child: showAmount
                    ? Text(
                        _abbreviateAmount(amount),
                        style: TextStyle(
                          fontSize: 10,
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w500,
                          height: 1.1,
                        ),
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  static final _formatter = NumberFormat('#,###');

  static String _abbreviateAmount(int amount) {
    if (amount < 10000) return _formatter.format(amount);
    final v = amount / 10000;
    return '${v.toStringAsFixed(v < 10 ? 1 : 0)}万';
  }
}

class _DaySessionsView extends ConsumerWidget {
  const _DaySessionsView({required this.date});

  final DateTime date;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionsAsync = ref.watch(sessionsOnDayProvider(date));
    final categoriesAsync = ref.watch(categoriesListProvider);
    final categories = categoriesAsync.value ?? const <Category>[];
    final categoryMap = {for (final c in categories) c.id: c};
    final dateLabel = DateFormat('M月d日 (E)', 'ja').format(date);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
          child: Row(
            children: [
              Text(
                dateLabel,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const Spacer(),
              sessionsAsync.when(
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
                data: (sessions) {
                  if (sessions.isEmpty) return const SizedBox.shrink();
                  final total = sessions.fold<int>(
                    0,
                    (sum, s) => sum + s.amount,
                  );
                  return Text(
                    '合計 ${NumberFormat('#,###').format(total)} 円',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  );
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: sessionsAsync.when(
            loading: () =>
                const Center(child: CircularProgressIndicator()),
            error: (e, _) =>
                Center(child: Text('読み込みに失敗しました: $e')),
            data: (sessions) {
              if (sessions.isEmpty) return const _EmptyDayView();
              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
                itemCount: sessions.length,
                separatorBuilder: (_, __) => const SizedBox(height: 4),
                itemBuilder: (context, index) {
                  final session = sessions[index];
                  return SessionCard(
                    session: session,
                    category: categoryMap[session.categoryId],
                    onTap: () => _editSession(context, session),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  void _editSession(BuildContext context, WorkSession session) {
    ManualRecordSheet.show(context, initial: session);
  }
}

class _EmptyDayView extends StatelessWidget {
  const _EmptyDayView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.event_busy_outlined,
              size: 48,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 8),
            const Text('この日の記録はありません'),
          ],
        ),
      ),
    );
  }
}

