import '../../features/goals/domain/goal.dart';

sealed class AchievementEvent {
  const AchievementEvent();
}

class GoalAchievedEvent extends AchievementEvent {
  const GoalAchievedEvent({required this.goal, this.categoryName});

  final Goal goal;
  final String? categoryName;
}

class StreakMilestoneEvent extends AchievementEvent {
  const StreakMilestoneEvent({required this.days});

  final int days;
}
