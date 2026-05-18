import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../category/application/category_providers.dart';
import '../../category/domain/category.dart';
import '../application/calendar_providers.dart';
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
    final dailyAmountAsync = ref.watch(dailyAmountMapProvider(monthStart));
    final dailyAmount = dailyAmountAsync.value ?? const <DateTime, int>{};
    final maxAmount = dailyAmount.values.isEmpty
        ? 0
        : dailyAmount.values.reduce(math.max);

    return Scaffold(
      appBar: AppBar(title: const Text('カレンダー')),
      body: Column(
        children: [
          _CalendarCard(
            focusedDay: _focusedDay,
            selectedDay: _selectedDay,
            dailyAmount: dailyAmount,
            maxAmount: maxAmount,
            onDaySelected: _onDaySelected,
            onPageChanged: _onPageChanged,
          ),
          const Divider(height: 1),
          Expanded(child: _DaySessionsView(date: _selectedDay)),
        ],
      ),
    );
  }
}

class _CalendarCard extends StatelessWidget {
  const _CalendarCard({
    required this.focusedDay,
    required this.selectedDay,
    required this.dailyAmount,
    required this.maxAmount,
    required this.onDaySelected,
    required this.onPageChanged,
  });

  final DateTime focusedDay;
  final DateTime selectedDay;
  final Map<DateTime, int> dailyAmount;
  final int maxAmount;
  final void Function(DateTime selected, DateTime focused) onDaySelected;
  final ValueChanged<DateTime> onPageChanged;

  DateTime _dateOnly(DateTime t) => DateTime(t.year, t.month, t.day);

  @override
  Widget build(BuildContext context) {
    return TableCalendar(
      firstDay: DateTime(2020, 1, 1),
      lastDay: DateTime(DateTime.now().year + 5, 12, 31),
      focusedDay: focusedDay,
      selectedDayPredicate: (day) => isSameDay(day, selectedDay),
      onDaySelected: onDaySelected,
      onPageChanged: onPageChanged,
      calendarFormat: CalendarFormat.month,
      availableCalendarFormats: const {CalendarFormat.month: 'Month'},
      locale: 'ja_JP',
      startingDayOfWeek: StartingDayOfWeek.monday,
      headerStyle: const HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
      ),
      rowHeight: 56,
      calendarBuilders: CalendarBuilders<dynamic>(
        dowBuilder: (context, day) {
          final label = DateFormat.E('ja').format(day);
          final color = _weekdayColor(context, day.weekday);
          return Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color ?? Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          );
        },
        defaultBuilder: (context, day, _) {
          return _DayCell(
            day: day,
            amount: dailyAmount[_dateOnly(day)] ?? 0,
            maxAmount: maxAmount,
            isToday: false,
            isSelected: false,
          );
        },
        todayBuilder: (context, day, _) {
          return _DayCell(
            day: day,
            amount: dailyAmount[_dateOnly(day)] ?? 0,
            maxAmount: maxAmount,
            isToday: true,
            isSelected: false,
          );
        },
        selectedBuilder: (context, day, _) {
          return _DayCell(
            day: day,
            amount: dailyAmount[_dateOnly(day)] ?? 0,
            maxAmount: maxAmount,
            isToday: isSameDay(day, DateTime.now()),
            isSelected: true,
          );
        },
        outsideBuilder: (context, day, _) {
          return _DayCell(
            day: day,
            amount: 0,
            maxAmount: maxAmount,
            isToday: false,
            isSelected: false,
            isOutside: true,
          );
        },
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.day,
    required this.amount,
    required this.maxAmount,
    required this.isToday,
    required this.isSelected,
    this.isOutside = false,
  });

  final DateTime day;
  final int amount;
  final int maxAmount;
  final bool isToday;
  final bool isSelected;
  final bool isOutside;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final intensity = (maxAmount == 0 || amount == 0)
        ? 0.0
        : (amount / maxAmount).clamp(0.0, 1.0);
    final bucket = _bucketFor(intensity);
    final bgAlpha = switch (bucket) {
      0 => 0.0,
      1 => 0.18,
      2 => 0.35,
      3 => 0.55,
      _ => 0.80,
    };
    final bgColor = bgAlpha == 0
        ? Colors.transparent
        : colorScheme.primary.withValues(alpha: bgAlpha);
    final weekendColor = _weekdayColor(context, day.weekday);
    final Color textColor;
    if (bucket >= 3) {
      textColor = colorScheme.onPrimary;
    } else if (isOutside) {
      textColor = (weekendColor ?? colorScheme.outline).withValues(alpha: 0.6);
    } else {
      textColor = weekendColor ?? colorScheme.onSurface;
    }
    final amountColor = bucket >= 3
        ? colorScheme.onPrimary.withValues(alpha: 0.9)
        : colorScheme.onSurfaceVariant;

    return Container(
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: isSelected
            ? Border.all(color: colorScheme.primary, width: 2)
            : isToday
                ? Border.all(color: colorScheme.outline, width: 1)
                : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${day.day}',
            style: TextStyle(
              fontSize: 13,
              fontWeight: isToday || isSelected ? FontWeight.w700 : null,
              color: textColor,
            ),
          ),
          if (amount > 0)
            Padding(
              padding: const EdgeInsets.only(top: 1),
              child: Text(
                _abbreviateAmount(amount),
                style: TextStyle(
                  fontSize: 9,
                  color: amountColor,
                  height: 1.1,
                ),
              ),
            ),
        ],
      ),
    );
  }

  static int _bucketFor(double intensity) {
    if (intensity <= 0) return 0;
    if (intensity < 0.25) return 1;
    if (intensity < 0.5) return 2;
    if (intensity < 0.75) return 3;
    return 4;
  }

  static String _abbreviateAmount(int amount) {
    if (amount < 1000) return '$amount';
    if (amount < 10000) {
      final v = amount / 1000;
      return '${v.toStringAsFixed(v < 10 ? 1 : 0)}k';
    }
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

Color? _weekdayColor(BuildContext context, int weekday) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  if (weekday == DateTime.saturday) {
    return isDark ? const Color(0xFF64B5F6) : const Color(0xFF1976D2);
  }
  if (weekday == DateTime.sunday) {
    return isDark ? const Color(0xFFE57373) : const Color(0xFFD32F2F);
  }
  return null;
}
