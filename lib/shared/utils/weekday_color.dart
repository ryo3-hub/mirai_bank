import 'package:flutter/material.dart';

/// 土曜=青 / 日曜=赤 を表す色。平日は null。
/// カレンダー画面と日付ピッカーで共通利用。
Color? weekdayColor(BuildContext context, int weekday) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  if (weekday == DateTime.saturday) {
    return isDark ? const Color(0xFF64B5F6) : const Color(0xFF1976D2);
  }
  if (weekday == DateTime.sunday) {
    return isDark ? const Color(0xFFE57373) : const Color(0xFFD32F2F);
  }
  return null;
}
