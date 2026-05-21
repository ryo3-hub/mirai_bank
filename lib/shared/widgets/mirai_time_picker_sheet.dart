import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// アプリ共通のドラムロール（Cupertino）スタイル時刻ピッカー。
///
/// `CupertinoDatePicker` だと時/分の間隔やフォントサイズの細かい
/// 制御ができないため、`CupertinoPicker` を 2 つ並べた独自レイアウトに
/// している（issue #84）。24 時間表記、1 分刻み。
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
  late int _hour;
  late int _minute;
  late final FixedExtentScrollController _hourController;
  late final FixedExtentScrollController _minuteController;

  static const double _pickerHeight = 240;
  static const double _itemExtent = 44;
  static const double _numberFontSize = 30;

  @override
  void initState() {
    super.initState();
    _hour = widget.initialTime.hour;
    _minute = widget.initialTime.minute;
    _hourController = FixedExtentScrollController(initialItem: _hour);
    _minuteController = FixedExtentScrollController(initialItem: _minute);
  }

  @override
  void dispose() {
    _hourController.dispose();
    _minuteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.colorScheme.onSurface;
    final labelColor = theme.colorScheme.onSurfaceVariant;
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
            height: _pickerHeight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _NumberWheel(
                  controller: _hourController,
                  itemCount: 24,
                  itemExtent: _itemExtent,
                  textColor: textColor,
                  numberFontSize: _numberFontSize,
                  onChanged: (v) => _hour = v,
                ),
                _Unit(label: '時', color: labelColor),
                const SizedBox(width: 32),
                _NumberWheel(
                  controller: _minuteController,
                  itemCount: 60,
                  itemExtent: _itemExtent,
                  textColor: textColor,
                  numberFontSize: _numberFontSize,
                  onChanged: (v) => _minute = v,
                ),
                _Unit(label: '分', color: labelColor),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.of(context).pop(
                  TimeOfDay(hour: _hour, minute: _minute),
                ),
                child: const Text('決定'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NumberWheel extends StatelessWidget {
  const _NumberWheel({
    required this.controller,
    required this.itemCount,
    required this.itemExtent,
    required this.textColor,
    required this.numberFontSize,
    required this.onChanged,
  });

  final FixedExtentScrollController controller;
  final int itemCount;
  final double itemExtent;
  final Color textColor;
  final double numberFontSize;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 80,
      child: CupertinoPicker(
        scrollController: controller,
        itemExtent: itemExtent,
        useMagnifier: true,
        magnification: 1.1,
        squeeze: 1.2,
        onSelectedItemChanged: onChanged,
        children: [
          for (var i = 0; i < itemCount; i++)
            Center(
              child: Text(
                i.toString().padLeft(2, '0'),
                style: TextStyle(
                  fontSize: numberFontSize,
                  color: textColor,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Unit extends StatelessWidget {
  const _Unit({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 6),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 16,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
