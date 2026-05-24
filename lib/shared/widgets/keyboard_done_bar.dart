import 'package:flutter/material.dart';

/// キーボード上部に貼り付ける「完了」バー（issue #114）。
///
/// number キーボードには return / done が無く、フォーム外タップで閉じる UI が
/// 機能しない場合があるため、画面下部にこのバーを overlay として表示してタップで
/// unfocus する。
///
/// 単独で使うことは少なく、通常は [KeyboardDoneOverlay] で wrap する。
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

/// キーボード表示中のみ、root overlay に [KeyboardDoneBar] を表示するラッパ。
///
/// モーダルボトムシート内など、自身の Scaffold が body 高さを伸ばせない
/// レイアウトでも、`OverlayPortal` で root overlay に直接描画するため
/// キーボード直上に確実に配置できる。issue #114 の続きでこの方式に変更。
class KeyboardDoneOverlay extends StatefulWidget {
  const KeyboardDoneOverlay({super.key, required this.child});

  final Widget child;

  @override
  State<KeyboardDoneOverlay> createState() => _KeyboardDoneOverlayState();
}

class _KeyboardDoneOverlayState extends State<KeyboardDoneOverlay>
    with WidgetsBindingObserver {
  final _controller = OverlayPortalController();
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    // 端末のキーボード表示変化を購読し、bar を出し入れする。
    if (!mounted) return;
    final inset = MediaQuery.viewInsetsOf(context).bottom;
    final shouldShow = inset > 0;
    if (shouldShow == _visible) return;
    _visible = shouldShow;
    if (shouldShow) {
      _controller.show();
    } else {
      _controller.hide();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 初期表示時にもキーボード状態を反映する。
    final inset = MediaQuery.viewInsetsOf(context).bottom;
    final shouldShow = inset > 0;
    if (shouldShow != _visible) {
      _visible = shouldShow;
      if (shouldShow) {
        _controller.show();
      } else {
        _controller.hide();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return OverlayPortal(
      controller: _controller,
      overlayChildBuilder: (overlayContext) {
        final inset = MediaQuery.viewInsetsOf(overlayContext).bottom;
        return Positioned(
          left: 0,
          right: 0,
          bottom: inset,
          child: KeyboardDoneBar(
            onDone: () => FocusScope.of(context).unfocus(),
          ),
        );
      },
      child: widget.child,
    );
  }
}
