import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../infrastructure/database/database_provider.dart';
import '../../history/application/work_session_providers.dart';
import '../../history/domain/work_session.dart';
import '../domain/goal.dart';
import '../domain/goal_progress.dart';
import '../infrastructure/goal_repository.dart';
import '../infrastructure/goal_repository_impl.dart';
import 'goal_achievement_checker.dart';

part 'goal_providers.g.dart';

@Riverpod(keepAlive: true)
GoalRepository goalRepository(Ref ref) {
  return GoalRepositoryImpl(ref.watch(appDatabaseProvider));
}

@Riverpod(keepAlive: true)
GoalAchievementChecker goalAchievementChecker(Ref ref) {
  return GoalAchievementChecker(
    ref.watch(goalRepositoryProvider),
    ref.watch(workSessionRepositoryProvider),
  );
}

@riverpod
Stream<List<GoalProgress>> activeGoalsWithProgress(Ref ref) {
  final goalRepo = ref.watch(goalRepositoryProvider);
  final sessionRepo = ref.watch(workSessionRepositoryProvider);
  return _combineLatest2<List<Goal>, List<WorkSession>, List<GoalProgress>>(
    goalRepo.watchActive(),
    sessionRepo.watchAll(),
    (goals, sessions) => [
      for (final goal in goals)
        GoalProgress(
          goal: goal,
          currentAmount: GoalAggregator.calculateCurrentAmount(
            goal: goal,
            sessions: sessions,
          ),
        ),
    ],
  );
}

Stream<R> _combineLatest2<A, B, R>(
  Stream<A> a,
  Stream<B> b,
  R Function(A, B) combine,
) {
  late StreamController<R> controller;
  StreamSubscription<A>? subA;
  StreamSubscription<B>? subB;
  A? latestA;
  B? latestB;
  var hasA = false;
  var hasB = false;

  void emit() {
    if (hasA && hasB) {
      controller.add(combine(latestA as A, latestB as B));
    }
  }

  controller = StreamController<R>(
    onListen: () {
      subA = a.listen(
        (v) {
          latestA = v;
          hasA = true;
          emit();
        },
        onError: controller.addError,
      );
      subB = b.listen(
        (v) {
          latestB = v;
          hasB = true;
          emit();
        },
        onError: controller.addError,
      );
    },
    onCancel: () async {
      await subA?.cancel();
      await subB?.cancel();
    },
  );
  return controller.stream;
}

@riverpod
Stream<List<Goal>> achievedGoals(Ref ref) {
  return ref.watch(goalRepositoryProvider).watchAchieved();
}

@riverpod
class GoalController extends _$GoalController {
  @override
  void build() {}

  Future<void> create({
    required GoalType type,
    required int targetAmount,
    String? categoryId,
    DateTime? periodStart,
    DateTime? periodEnd,
  }) async {
    await ref.read(goalRepositoryProvider).create(
          type: type,
          targetAmount: targetAmount,
          categoryId: categoryId,
          periodStart: periodStart,
          periodEnd: periodEnd,
        );
    await ref.read(goalAchievementCheckerProvider).checkAndMark();
  }

  Future<void> updateGoal(Goal goal) async {
    await ref.read(goalRepositoryProvider).update(goal);
    await ref.read(goalAchievementCheckerProvider).checkAndMark();
  }

  Future<void> delete(String id) {
    return ref.read(goalRepositoryProvider).delete(id);
  }
}
