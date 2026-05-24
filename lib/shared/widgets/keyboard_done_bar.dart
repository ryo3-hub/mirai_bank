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
/// モーダルボトムシート内や Scaffold(resizeToAvoidBottomInset: true) 配下では
/// `MediaQuery.viewInsetsOf(context).bottom` が 0 に上書きされ得るため、
/// `View.of(context)` から window 直接の viewInsets を読み取って判定する。
/// 表示自体は `OverlayPortal` で root overlay に直接配置するため、自身のレイアウトに
/// 依存せずキーボード直上に表示できる。
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

  /// Scaffold 等で上書きされない window 直接の bottom viewInsets（論理 px）を返す。
  double _rawBottomInset(BuildContext context) {
    final view = View.of(context);
    return view.viewInsets.bottom / view.devicePixelRatio;
  }

  void _syncVisibility() {
    if (!mounted) return;
    final shouldShow = _rawBottomInset(context) > 0;
    if (shouldShow == _visible) return;
    _visible = shouldShow;
    if (shouldShow) {
      _controller.show();
    } else {
      _controller.hide();
    }
  }

  @override
  void didChangeMetrics() {
    _syncVisibility();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncVisibility();
  }

  @override
  Widget build(BuildContext context) {
    return OverlayPortal(
      controller: _controller,
      overlayChildBuilder: (overlayContext) {
        final bottom = _rawBottomInset(overlayContext);
        return Positioned(
          left: 0,
          right: 0,
          bottom: bottom,
          child: KeyboardDoneBar(
            onDone: () => FocusScope.of(context).unfocus(),
          ),
        );
      },
      child: widget.child,
    );
  }
}
