import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  static const _destinations = <_Destination>[
    _Destination(icon: Icons.home_outlined, label: 'ホーム'),
    _Destination(icon: Icons.calendar_month_outlined, label: 'カレンダー'),
    _Destination(icon: Icons.bar_chart_outlined, label: '統計'),
    _Destination(icon: Icons.settings_outlined, label: '設定'),
  ];

  /// 設定タブの index。タブを押したときに毎回ルートを初期位置にリセットする
  /// タブを表す（issue #69）。
  static const _resetOnTapIndices = <int>{3};

  void _onTap(int index) {
    final isSameTab = index == navigationShell.currentIndex;
    final shouldReset = isSameTab || _resetOnTapIndices.contains(index);
    navigationShell.goBranch(
      index,
      initialLocation: shouldReset,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: _onTap,
        destinations: [
          for (final d in _destinations)
            NavigationDestination(
              icon: Icon(d.icon),
              label: d.label,
            ),
        ],
      ),
    );
  }
}

class _Destination {
  const _Destination({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;
}
