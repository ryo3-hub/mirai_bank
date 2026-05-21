import 'dart:ui';

import 'package:flutter/material.dart';

/// `ReorderableListView.proxyDecorator` 用の共通実装。
///
/// 標準の proxy は角丸無しの Material で包んでしまうため、`Card` ベースの
/// アイテムが持ち上げ中に矩形になってしまう（issue #83）。これを 16px の
/// 角丸 + transparent な背景の Material で置き換えて見た目を維持する。
Widget roundedReorderProxy(
  Widget child,
  int index,
  Animation<double> animation,
) {
  return AnimatedBuilder(
    animation: animation,
    builder: (context, _) {
      final t = Curves.easeInOut.transform(animation.value);
      final elevation = lerpDouble(0, 6, t)!;
      return Material(
        elevation: elevation,
        color: Colors.transparent,
        shadowColor: Colors.black54,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: child,
      );
    },
    child: child,
  );
}
