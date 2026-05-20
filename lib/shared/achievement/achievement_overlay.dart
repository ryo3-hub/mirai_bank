import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/router.dart';
import 'achievement_event.dart';
import 'achievement_queue.dart';
import 'widgets/goal_achievement_dialog.dart';
import 'widgets/streak_celebration_dialog.dart';

class AchievementOverlay extends ConsumerStatefulWidget {
  const AchievementOverlay({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<AchievementOverlay> createState() =>
      _AchievementOverlayState();
}

class _AchievementOverlayState extends ConsumerState<AchievementOverlay> {
  bool _presenting = false;

  Future<void> _processQueue() async {
    if (_presenting) return;
    _presenting = true;
    try {
      while (mounted) {
        final queue = ref.read(achievementQueueProvider);
        if (queue.isEmpty) break;
        final navContext = AppRouter.rootNavigatorKey.currentContext;
        if (navContext == null) break;
        // navContext is sourced from a global navigator key, so it remains
        // valid across awaits as long as the app is alive.
        // ignore: use_build_context_synchronously
        await _present(navContext, queue.first);
        if (!mounted) break;
        ref.read(achievementQueueProvider.notifier).dequeueFirst();
        await Future<void>.delayed(const Duration(milliseconds: 200));
      }
    } finally {
      _presenting = false;
    }
  }

  Future<void> _present(BuildContext context, AchievementEvent event) {
    switch (event) {
      case GoalAchievedEvent(:final goal, :final categoryName):
        return GoalAchievementDialog.show(
          context,
          goal: goal,
          categoryName: categoryName,
        );
      case StreakMilestoneEvent(:final days):
        return StreakCelebrationDialog.show(context, days: days);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<List<AchievementEvent>>(achievementQueueProvider,
        (previous, next) {
      final prevLen = previous?.length ?? 0;
      if (next.length > prevLen) {
        _processQueue();
      }
    });
    return widget.child;
  }
}
