import 'package:flutter/material.dart';

/// キーボード上部に貼り付ける「完了」バー。
///
/// number キーボードには return / done が無く、フォーム外タップで閉じる UI が
/// 機能しない場合があるため、画面下部にこのバーを Stack overlay として
/// 表示してタップで unfocus する。
///
/// issue #114 でオンボーディングから共有ウィジェット化。
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

/// キーボード表示中のみ、画面下部に [KeyboardDoneBar] を Stack overlay する
/// ヘルパー。`Scaffold > body: KeyboardDoneOverlay(child: ...)` の形で使う。
class KeyboardDoneOverlay extends StatelessWidget {
  const KeyboardDoneOverlay({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final keyboardVisible = MediaQuery.viewInsetsOf(context).bottom > 0;
    return Stack(
      children: [
        child,
        if (keyboardVisible)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: KeyboardDoneBar(
              onDone: () => FocusScope.of(context).unfocus(),
            ),
          ),
      ],
    );
  }
}
