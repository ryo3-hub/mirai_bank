import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../utils/weekday_color.dart';

/// アプリ全体で共通のフラットな日付ピッカー。
/// カレンダー画面と同じトーン（週始まり=日曜、土青/日赤、淡い primary 選択背景）
/// を保ちつつ、金額表示は含まない。
class MiraiDatePickerSheet extends StatefulWidget {
  const MiraiDatePickerSheet({
    super.key,
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
    this.title,
  });

  final DateTime initialDate;
  final DateTime firstDate;
  final DateTime lastDate;
  final String? title;

  /// モーダルボトムシートとして表示し、選択日付を返す。
  /// ユーザーがシート外タップやスワイプで閉じた場合は null を返す。
  static Future<DateTime?> show(
    BuildContext context, {
    required DateTime initialDate,
    DateTime? firstDate,
    DateTime? lastDate,
    String? title,
  }) {
    return showModalBottomSheet<DateTime>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (_) => MiraiDatePickerSheet(
        initialDate: initialDate,
        firstDate: firstDate ?? DateTime(2020, 1, 1),
        lastDate: lastDate ?? DateTime(DateTime.now().year + 5, 12, 31),
        title: title,
      ),
    );
  }

  @override
  State<MiraiDatePickerSheet> createState() => _MiraiDatePickerSheetState();
}

class _MiraiDatePickerSheetState extends State<MiraiDatePickerSheet> {
  late DateTime _focusedDay;
  late DateTime _selectedDay;

  @override
  void initState() {
    super.initState();
    _focusedDay = _dateOnly(widget.initialDate);
    _selectedDay = _focusedDay;
  }

  DateTime _dateOnly(DateTime t) => DateTime(t.year, t.month, t.day);

  void _onDaySelected(DateTime selected, DateTime focused) {
    setState(() {
      _selectedDay = _dateOnly(selected);
      _focusedDay = focused;
    });
  }

  void _onPageChanged(DateTime focused) {
    setState(() => _focusedDay = _clampToRange(focused));
  }

  /// `focusedDay` を `firstDate` 〜 `lastDate` の範囲内に強制する。
  ///
  /// table_calendar は `focusedDay < firstDay` で assertion failure を起こす。
  /// 前月ボタンが「前月の 1 日」を渡すケースで、firstDate が月の途中
  /// （例: 翌日 = 月の中頃）だと assertion を踏むため、`firstDate` 以前は
  /// `firstDate` に丸める（次月側も同様）。
  DateTime _clampToRange(DateTime d) {
    final first = _dateOnly(widget.firstDate);
    final last = _dateOnly(widget.lastDate);
    if (d.isBefore(first)) return first;
    if (d.isAfter(last)) return last;
    return d;
  }

  bool get _canGoPrev {
    final first = _dateOnly(widget.firstDate);
    final prevMonthFirstDay =
        DateTime(_focusedDay.year, _focusedDay.month - 1, 1);
    final firstMonthFirstDay = DateTime(first.year, first.month, 1);
    return !prevMonthFirstDay.isBefore(firstMonthFirstDay);
  }

  bool get _canGoNext {
    final last = _dateOnly(widget.lastDate);
    final nextMonthFirstDay =
        DateTime(_focusedDay.year, _focusedDay.month + 1, 1);
    final lastMonthFirstDay = DateTime(last.year, last.month, 1);
    return !nextMonthFirstDay.isAfter(lastMonthFirstDay);
  }

  void _confirm() {
    Navigator.of(context).pop(_selectedDay);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.title != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
              child: Text(
                widget.title!,
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
            ),
          _PickerHeader(
            month: _focusedDay,
            onPrev: _canGoPrev
                ? () => _onPageChanged(
                      DateTime(
                        _focusedDay.year,
                        _focusedDay.month - 1,
                        1,
                      ),
                    )
                : null,
            onNext: _canGoNext
                ? () => _onPageChanged(
                      DateTime(
                        _focusedDay.year,
                        _focusedDay.month + 1,
                        1,
                      ),
                    )
                : null,
          ),
          TableCalendar<dynamic>(
            firstDay: widget.firstDate,
            lastDay: widget.lastDate,
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
            onDaySelected: _onDaySelected,
            onPageChanged: _onPageChanged,
            calendarFormat: CalendarFormat.month,
            availableCalendarFormats: const {CalendarFormat.month: 'Month'},
            locale: 'ja_JP',
            startingDayOfWeek: StartingDayOfWeek.sunday,
            headerVisible: false,
            rowHeight: 48,
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
              defaultBuilder: (context, day, _) => _PickerDayCell(
                day: day,
                isToday: false,
                isSelected: false,
              ),
              todayBuilder: (context, day, _) => _PickerDayCell(
                day: day,
                isToday: true,
                isSelected: false,
              ),
              selectedBuilder: (context, day, _) => _PickerDayCell(
                day: day,
                isToday: isSameDay(day, DateTime.now()),
                isSelected: true,
              ),
              outsideBuilder: (context, day, _) => _PickerDayCell(
                day: day,
                isToday: false,
                isSelected: false,
                isOutside: true,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: FilledButton(
              onPressed: _confirm,
              child: const Text('決定'),
            ),
          ),
        ],
      ),
    );
  }
}

class _PickerHeader extends StatelessWidget {
  const _PickerHeader({
    required this.month,
    required this.onPrev,
    required this.onNext,
  });

  final DateTime month;

  /// 範囲端では null（ボタンが disabled になる）。
  final VoidCallback? onPrev;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final title = '${month.year}年${month.month}月';
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 4, 4, 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: onPrev,
            tooltip: '前の月',
          ),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
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

class _PickerDayCell extends StatelessWidget {
  const _PickerDayCell({
    required this.day,
    required this.isToday,
    required this.isSelected,
    this.isOutside = false,
  });

  final DateTime day;
  final bool isToday;
  final bool isSelected;
  final bool isOutside;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final weekend = weekdayColor(context, day.weekday);

    final Color textColor;
    if (isOutside) {
      textColor = (weekend ?? colorScheme.outline).withValues(alpha: 0.4);
    } else {
      textColor = weekend ?? colorScheme.onSurface;
    }

    final bgColor = isSelected
        ? colorScheme.primary.withValues(alpha: 0.10)
        : Colors.transparent;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: SizedBox.expand(
          child: Center(
            child: Text(
              '${day.day}',
              style: TextStyle(
                fontSize: 15,
                fontWeight: (isToday || isSelected)
                    ? FontWeight.w700
                    : FontWeight.w500,
                color: textColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
