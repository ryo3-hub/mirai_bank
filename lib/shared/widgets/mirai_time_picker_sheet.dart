import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// アプリ共通のドラムロール（Cupertino）スタイル時刻ピッカー。
/// 24 時間表記、1 分刻み。MiraiDatePickerSheet と同じくモーダル
/// ボトムシートで表示し、選択された `TimeOfDay` を返す（キャンセル時は null）。
class MiraiTimePickerSheet extends StatefulWidget {
  const MiraiTimePickerSheet({
    super.key,
    required this.initialTime,
    this.title,
  });

  final TimeOfDay initialTime;
  final String? title;

  static Future<TimeOfDay?> show(
    BuildContext context, {
    required TimeOfDay initialTime,
    String? title,
  }) {
    return showModalBottomSheet<TimeOfDay>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (_) => MiraiTimePickerSheet(
        initialTime: initialTime,
        title: title,
      ),
    );
  }

  @override
  State<MiraiTimePickerSheet> createState() => _MiraiTimePickerSheetState();
}

class _MiraiTimePickerSheetState extends State<MiraiTimePickerSheet> {
  late TimeOfDay _current;

  @override
  void initState() {
    super.initState();
    _current = widget.initialTime;
  }

  void _onTimeChanged(DateTime dt) {
    _current = TimeOfDay(hour: dt.hour, minute: dt.minute);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Cupertino picker は DateTime ベースなので、ダミーの日付に
    // 初期時刻を埋め込んで渡す。
    final initial = DateTime(2000, 1, 1, _current.hour, _current.minute);
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.title != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
              child: Text(
                widget.title!,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          SizedBox(
            height: 216,
            child: CupertinoTheme(
              data: CupertinoThemeData(
                textTheme: CupertinoTextThemeData(
                  dateTimePickerTextStyle: TextStyle(
                    fontSize: 22,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.time,
                use24hFormat: true,
                initialDateTime: initial,
                minuteInterval: 1,
                onDateTimeChanged: _onTimeChanged,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.of(context).pop(_current),
                child: const Text('決定'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
