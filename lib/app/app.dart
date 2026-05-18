import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../shared/achievement/achievement_overlay.dart';
import '../shared/theme/app_theme.dart';
import 'router.dart';

class MiraiBankApp extends ConsumerWidget {
  const MiraiBankApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'mirai_bank',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      routerConfig: AppRouter.router,
      debugShowCheckedModeBanner: false,
      builder: (context, child) =>
          AchievementOverlay(child: child ?? const SizedBox.shrink()),
    );
  }
}
