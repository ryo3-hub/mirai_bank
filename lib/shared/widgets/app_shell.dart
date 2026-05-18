import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  static const _destinations = <_Destination>[
    _Destination(icon: Icons.home_outlined, selectedIcon: Icons.home, label: 'ホーム'),
    _Destination(
      icon: Icons.calendar_month_outlined,
      selectedIcon: Icons.calendar_month,
      label: 'カレンダー',
    ),
    _Destination(
      icon: Icons.bar_chart_outlined,
      selectedIcon: Icons.bar_chart,
      label: '統計',
    ),
    _Destination(
      icon: Icons.history_outlined,
      selectedIcon: Icons.history,
      label: '履歴',
    ),
    _Destination(
      icon: Icons.settings_outlined,
      selectedIcon: Icons.settings,
      label: '設定',
    ),
  ];

  void _onTap(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
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
              selectedIcon: Icon(d.selectedIcon),
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
    required this.selectedIcon,
    required this.label,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
}
