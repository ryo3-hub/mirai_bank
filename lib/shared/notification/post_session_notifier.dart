import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/category/application/category_providers.dart';
import '../../features/goals/application/goal_providers.dart';
import '../../features/goals/domain/goal.dart';
import '../../features/history/application/work_session_providers.dart';
import '../../features/history/domain/streak_calculator.dart';
import '../../features/settings/application/setting_providers.dart';
import '../achievement/achievement_event.dart';
import '../achievement/achievement_queue.dart';
import 'notification_service.dart';

part 'post_session_notifier.g.dart';

class PostSessionNotifier {
  PostSessionNotifier(this._ref);

  final Ref _ref;
  static final _amountFormatter = NumberFormat('#,###');

  Future<void> runAfterSessionSave() async {
    final achievedIds =
        await _ref.read(goalAchievementCheckerProvider).checkAndMark();
    final setting = await _ref.read(settingRepositoryProvider).fetch();
    // 「達成通知」設定はプッシュ通知の ON/OFF のみを制御する。アプリ内の
    // 達成ダイアログ・節目演出は設定に関係なく常に出す。OFF のときに演出
    // までスキップすると、達成マークだけ付いて演出が永久に失われるため
    // （issue #197）。
    final pushEnabled = setting.achievementNotificationEnabled;

    final events = <AchievementEvent>[];

    if (achievedIds.isNotEmpty) {
      final goalRepo = _ref.read(goalRepositoryProvider);
      final categoryRepo = _ref.read(categoryRepositoryProvider);
      for (var i = 0; i < achievedIds.length; i++) {
        final goal = await goalRepo.findById(achievedIds[i]);
        if (goal == null) continue;
        final categoryName = goal.categoryId == null
            ? null
            : (await categoryRepo.findById(goal.categoryId!))?.name;
        events.add(GoalAchievedEvent(
          goal: goal,
          categoryName: categoryName,
        ));
        if (pushEnabled) {
          await NotificationService.instance.showAchievement(
            title: '🎉 目標達成！',
            body: _achievementBody(goal, categoryName),
            idOffset: i,
          );
        }
      }
    }

    final sessions =
        await _ref.read(workSessionRepositoryProvider).fetchAll();
    final milestone = StreakCalculator.milestoneIfFirstToday(sessions);
    if (milestone != null) {
      events.add(StreakMilestoneEvent(days: milestone));
      if (pushEnabled) {
        await NotificationService.instance.showStreak(milestone);
      }
    }

    if (events.isNotEmpty) {
      _ref.read(achievementQueueProvider.notifier).enqueueAll(events);
    }
  }

  String _achievementBody(Goal goal, String? categoryName) {
    final amount = _amountFormatter.format(goal.targetAmount);
    final scope = categoryName ?? '全カテゴリ';
    final preset = GoalPreset.fromGoal(goal);
    if (preset != null) {
      return '$scope の${preset.label} $amount円 を達成しました';
    }
    if (goal.type == GoalType.cumulative) {
      return '$scope の累計 $amount円目標を達成しました';
    }
    return '$scope の期間目標 $amount円 を達成しました';
  }
}

@Riverpod(keepAlive: true)
PostSessionNotifier postSessionNotifier(Ref ref) {
  return PostSessionNotifier(ref);
}
