import 'package:flutter/material.dart';

/// カテゴリ管理 / 目標設定 / タイマープリセット管理など、「右下から追加する」
/// 系のページで共通利用する拡張 FAB（issue #123）。
///
/// 標準の円形 FAB + アイコンだけだと「何を追加するのか」が読めず、また
/// `SaveActionButton`（角丸 16 / primary 塗り / アイコン + ボールドラベル）
/// と比べてトーンが浮いていたので、Extended FAB に揃えた。
class AddActionFab extends StatelessWidget {
  const AddActionFab({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon = Icons.add,
  });

  /// ボタンに表示するラベル。例: 「カテゴリを追加」「目標を追加」。
  final String label;
  final VoidCallback onPressed;

  /// 表示するアイコン。デフォルトは [Icons.add]。
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return FloatingActionButton.extended(
      onPressed: onPressed,
      backgroundColor: cs.primary,
      foregroundColor: cs.onPrimary,
      elevation: 4,
      highlightElevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      icon: Icon(icon),
      label: Text(
        label,
        style: theme.textTheme.titleSmall?.copyWith(
          color: cs.onPrimary,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}
