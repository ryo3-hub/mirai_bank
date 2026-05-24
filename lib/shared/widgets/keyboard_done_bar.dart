import 'package:flutter/material.dart';

/// 数値キーボードなど「return（完了）」キーが無い IME を閉じるためのバー。
///
/// 表示判定は内部で `FocusManager.instance.primaryFocus` を見ており、
/// テキスト入力にフォーカスが当たっているときだけ実体を描画する。
/// `onDone` をタップ → 親で `FocusScope.of(context).unfocus()` を呼ぶと、
/// primary focus が外れた瞬間にバーが消え、IME のスライドダウン中に右下に
/// 残らない（issue #117 の追従修正）。
///
/// 呼び出し側は `if (keyboardVisible) ...` のような外側判定をせず、
/// 常にこのウィジェットをツリーに含めておけば良い。フォーカスが無いときは
/// `SizedBox.shrink()` を返すので Column の最下段にあってもレイアウトに
/// 影響しない。
class KeyboardDoneBar extends StatefulWidget {
  const KeyboardDoneBar({super.key, required this.onDone});

  final VoidCallback onDone;

  @override
  State<KeyboardDoneBar> createState() => _KeyboardDoneBarState();
}

class _KeyboardDoneBarState extends State<KeyboardDoneBar> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    _visible = _hasTextFieldFocus();
    FocusManager.instance.addListener(_handleFocusChange);
  }

  @override
  void dispose() {
    FocusManager.instance.removeListener(_handleFocusChange);
    super.dispose();
  }

  /// primary focus がテキスト入力（EditableText）にあるかを判定する。
  /// FocusScopeNode / フォーカス可能だけど IME を出さないノードは除外する。
  bool _hasTextFieldFocus() {
    final primary = FocusManager.instance.primaryFocus;
    if (primary == null) return false;
    final ctx = primary.context;
    if (ctx == null) return false;
    EditableText? editable;
    ctx.visitAncestorElements((element) {
      if (element.widget is EditableText) {
        editable = element.widget as EditableText;
        return false;
      }
      return true;
    });
    return editable != null;
  }

  void _handleFocusChange() {
    if (!mounted) return;
    final next = _hasTextFieldFocus();
    if (next != _visible) {
      setState(() => _visible = next);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_visible) return const SizedBox.shrink();
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surfaceContainerHigh,
      child: SizedBox(
        height: 44,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: widget.onDone,
              child: const Text('完了'),
            ),
            const SizedBox(width: 4),
          ],
        ),
      ),
    );
  }
}
