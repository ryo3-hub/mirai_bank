import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'achievement_event.dart';

part 'achievement_queue.g.dart';

@Riverpod(keepAlive: true)
class AchievementQueue extends _$AchievementQueue {
  @override
  List<AchievementEvent> build() => const [];

  void enqueue(AchievementEvent event) {
    state = [...state, event];
  }

  void enqueueAll(Iterable<AchievementEvent> events) {
    if (events.isEmpty) return;
    state = [...state, ...events];
  }

  void dequeueFirst() {
    if (state.isEmpty) return;
    state = state.sublist(1);
  }

  void clear() {
    if (state.isEmpty) return;
    state = const [];
  }
}
