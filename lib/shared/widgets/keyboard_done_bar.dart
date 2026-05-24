import 'package:flutter/material.dart';

/// 数値キーボードなど「return（完了）」キーが無い IME を閉じるためのバー。
///
/// 親側で `MediaQuery.viewInsetsOf(context).bottom > 0` を見て、キーボードが
/// 表示されているときだけ `Positioned` でオーバーレイ表示する。
/// `onDone` には通常 `FocusScope.of(context).unfocus()` を渡す。
class KeyboardDoneBar extends StatelessWidget {
  const KeyboardDoneBar({super.key, required this.onDone});

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
