import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mirai_bank/features/goals/domain/goal.dart';
import 'package:mirai_bank/shared/achievement/achievement_event.dart';
import 'package:mirai_bank/shared/achievement/achievement_queue.dart';

Goal _goal() => Goal(
      id: 'g1',
      type: GoalType.cumulative,
      targetAmount: 10000,
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    );

void main() {
  group('AchievementQueue', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
      addTearDown(container.dispose);
    });

    test('starts empty', () {
      expect(container.read(achievementQueueProvider), isEmpty);
    });

    test('enqueue appends events in order', () {
      final notifier = container.read(achievementQueueProvider.notifier);
      notifier.enqueue(GoalAchievedEvent(goal: _goal()));
      notifier.enqueue(const StreakMilestoneEvent(days: 3));

      final state = container.read(achievementQueueProvider);
      expect(state, hasLength(2));
      expect(state[0], isA<GoalAchievedEvent>());
      expect(state[1], isA<StreakMilestoneEvent>());
    });

    test('enqueueAll appends multiple events at once', () {
      final notifier = container.read(achievementQueueProvider.notifier);
      notifier.enqueueAll([
        GoalAchievedEvent(goal: _goal()),
        const StreakMilestoneEvent(days: 7),
      ]);
      expect(container.read(achievementQueueProvider), hasLength(2));
    });

    test('enqueueAll with empty iterable is a no-op', () {
      final notifier = container.read(achievementQueueProvider.notifier);
      notifier.enqueueAll(const []);
      expect(container.read(achievementQueueProvider), isEmpty);
    });

    test('dequeueFirst removes the head', () {
      final notifier = container.read(achievementQueueProvider.notifier);
      notifier.enqueueAll([
        const StreakMilestoneEvent(days: 3),
        const StreakMilestoneEvent(days: 7),
      ]);
      notifier.dequeueFirst();
      final state = container.read(achievementQueueProvider);
      expect(state, hasLength(1));
      expect((state.single as StreakMilestoneEvent).days, 7);
    });

    test('dequeueFirst on empty queue is a no-op', () {
      final notifier = container.read(achievementQueueProvider.notifier);
      notifier.dequeueFirst();
      expect(container.read(achievementQueueProvider), isEmpty);
    });

    test('clear empties the queue', () {
      final notifier = container.read(achievementQueueProvider.notifier);
      notifier.enqueue(const StreakMilestoneEvent(days: 3));
      notifier.clear();
      expect(container.read(achievementQueueProvider), isEmpty);
    });
  });
}
