import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/widgets/top_toast.dart';
import '../application/timer_preset_providers.dart';
import '../domain/timer_preset.dart';

/// プリセット追加用のボトムシート。
/// 時間は 5 分刻みの Cupertino ピッカー、ラベルは TextField。
class TimerPresetEditSheet extends ConsumerStatefulWidget {
  const TimerPresetEditSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (_) => const TimerPresetEditSheet(),
    );
  }

  @override
  ConsumerState<TimerPresetEditSheet> createState() =>
      _TimerPresetEditSheetState();
}

class _TimerPresetEditSheetState
    extends ConsumerState<TimerPresetEditSheet> {
  static const _initialMinutes = 25;
  late int _minutes;
  late final FixedExtentScrollController _controller;
  final _labelController = TextEditingController();
  bool _saving = false;

  List<int> get _options {
    final list = <int>[];
    for (var m = TimerPreset.minutesMin;
        m <= TimerPreset.minutesMax;
        m += TimerPreset.minutesStep) {
      list.add(m);
    }
    return list;
  }

  @override
  void initState() {
    super.initState();
    _minutes = _initialMinutes;
    final initialIndex = _options.indexOf(_minutes);
    _controller = FixedExtentScrollController(
      initialItem: initialIndex < 0 ? 0 : initialIndex,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _labelController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final errorText = TimerPreset.validateMinutes(_minutes);
    if (errorText != null) {
      TopToast.show(context, message: errorText, isError: true);
      return;
    }
    setState(() => _saving = true);
    final navigator = Navigator.of(context);
    try {
      await ref.read(timerPresetControllerProvider.notifier).create(
            minutes: _minutes,
            label: _labelController.text,
          );
      if (mounted) {
        TopToast.show(context, message: 'プリセットを追加しました');
        navigator.pop();
      }
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('プリセットを追加', style: theme.textTheme.titleLarge),
            const SizedBox(height: 16),
            Text(
              '時間 (5 分刻み)',
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            SizedBox(
              height: 180,
              child: CupertinoTheme(
                data: CupertinoThemeData(
                  textTheme: CupertinoTextThemeData(
                    dateTimePickerTextStyle: TextStyle(
                      fontSize: 24,
                      color: theme.colorScheme.onSurface,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
                child: CupertinoPicker(
                  scrollController: _controller,
                  itemExtent: 40,
                  useMagnifier: true,
                  magnification: 1.1,
                  squeeze: 1.2,
                  onSelectedItemChanged: (i) {
                    setState(() => _minutes = _options[i]);
                  },
                  children: [
                    for (final m in _options)
                      Center(child: Text('$m 分')),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _labelController,
              decoration: const InputDecoration(
                labelText: '説明（任意）',
                hintText: '例: 集中する / コード書く',
                border: OutlineInputBorder(),
                floatingLabelBehavior: FloatingLabelBehavior.always,
              ),
              maxLength: 30,
              inputFormatters: [
                LengthLimitingTextInputFormatter(30),
              ],
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _saving ? null : _save,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: _saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('追加', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
