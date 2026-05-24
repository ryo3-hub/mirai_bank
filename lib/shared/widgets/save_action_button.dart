import 'package:flutter/material.dart';

/// シート保存ボタンの共通ウィジェット（issue #114）。
///
/// `FilledButton` だけのシンプルな保存ボタンを刷新し、アイコン + ラベルの
/// 統一されたデザインに揃える。
///
/// - 高さ 52px（タップしやすく見た目もどっしり）
/// - 角丸 14px、横幅一杯
/// - アイコン + ラベル
/// - `loading=true` で右側に `CircularProgressIndicator` を表示し非活性化
class SaveActionButton extends StatelessWidget {
  const SaveActionButton({
    super.key,
    required this.onPressed,
    required this.label,
    this.loading = false,
    this.icon = Icons.check_circle_outline,
  });

  final VoidCallback? onPressed;
  final String label;
  final bool loading;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final enabled = onPressed != null && !loading;
    return SizedBox(
      height: 52,
      width: double.infinity,
      child: FilledButton(
        onPressed: enabled ? onPressed : null,
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        child: loading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 20),
                  const SizedBox(width: 8),
                  Text(label),
                ],
              ),
      ),
    );
  }
}
