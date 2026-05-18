import 'package:flutter/material.dart';

class CategoryPresets {
  const CategoryPresets._();

  static const Map<String, IconData> icons = {
    'school': Icons.school,
    'code': Icons.code,
    'language': Icons.language,
    'menu_book': Icons.menu_book,
    'fitness_center': Icons.fitness_center,
    'music_note': Icons.music_note,
    'palette': Icons.palette,
    'biotech': Icons.biotech,
    'calculate': Icons.calculate,
    'translate': Icons.translate,
    'work': Icons.work,
    'self_improvement': Icons.self_improvement,
  };

  static const List<String> colors = [
    '#2E7D5B',
    '#1976D2',
    '#D32F2F',
    '#F57C00',
    '#7B1FA2',
    '#0097A7',
    '#5D4037',
    '#455A64',
  ];

  static IconData iconFor(String code) =>
      icons[code] ?? icons['school']!;

  static Color colorFor(String hex) {
    final cleaned = hex.replaceFirst('#', '');
    return Color(int.parse('FF$cleaned', radix: 16));
  }

  static String get defaultIcon => 'school';
  static String get defaultColor => colors.first;
}
