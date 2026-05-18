import 'package:flutter_test/flutter_test.dart';
import 'package:mirai_bank/features/history/domain/day_session_group.dart';
import 'package:mirai_bank/features/history/domain/work_session.dart';

WorkSession _session({
  required String id,
  required DateTime endTime,
  int amount = 1000,
  int durationSec = 3600,
}) {
  return WorkSession(
    id: id,
    categoryId: 'cat-1',
    startTime: endTime.subtract(Duration(seconds: durationSec)),
    endTime: endTime,
    durationSec: durationSec,
    amount: amount,
    inputMethod: WorkSessionInputMethod.manual,
    createdAt: endTime,
    updatedAt: endTime,
  );
}

void main() {
  group('DaySessionGroup.groupByDay', () {
    test('empty list returns empty groups', () {
      expect(DaySessionGroup.groupByDay(const []), isEmpty);
    });

    test('groups sessions sharing the same end-time date', () {
      final groups = DaySessionGroup.groupByDay([
        _session(id: 'a', endTime: DateTime(2026, 5, 17, 9)),
        _session(id: 'b', endTime: DateTime(2026, 5, 17, 18)),
        _session(id: 'c', endTime: DateTime(2026, 5, 16, 12)),
      ]);
      expect(groups.length, 2);
      expect(groups[0].date, DateTime(2026, 5, 17));
      expect(groups[0].sessions.length, 2);
      expect(groups[1].date, DateTime(2026, 5, 16));
      expect(groups[1].sessions.length, 1);
    });

    test('groups are sorted by date desc; sessions within group by endTime desc',
        () {
      final groups = DaySessionGroup.groupByDay([
        _session(id: 'old', endTime: DateTime(2026, 5, 10, 12)),
        _session(id: 'newer', endTime: DateTime(2026, 5, 17, 9)),
        _session(id: 'newest', endTime: DateTime(2026, 5, 17, 22)),
      ]);
      expect(groups[0].date, DateTime(2026, 5, 17));
      expect(groups[0].sessions.first.id, 'newest');
      expect(groups[0].sessions.last.id, 'newer');
      expect(groups[1].date, DateTime(2026, 5, 10));
    });

    test('totalAmount / totalDurationSec aggregate group sessions', () {
      final groups = DaySessionGroup.groupByDay([
        _session(
          id: 'a',
          endTime: DateTime(2026, 5, 17, 9),
          amount: 1500,
          durationSec: 1800,
        ),
        _session(
          id: 'b',
          endTime: DateTime(2026, 5, 17, 21),
          amount: 500,
          durationSec: 600,
        ),
      ]);
      expect(groups.single.totalAmount, 2000);
      expect(groups.single.totalDurationSec, 2400);
    });

    test('sessions crossing midnight are bucketed by endTime date', () {
      final groups = DaySessionGroup.groupByDay([
        WorkSession(
          id: 'cross',
          categoryId: 'cat',
          startTime: DateTime(2026, 5, 16, 23),
          endTime: DateTime(2026, 5, 17, 1),
          durationSec: 7200,
          amount: 1000,
          inputMethod: WorkSessionInputMethod.timer,
          createdAt: DateTime(2026, 5, 17, 1),
          updatedAt: DateTime(2026, 5, 17, 1),
        ),
      ]);
      expect(groups.single.date, DateTime(2026, 5, 17));
    });
  });
}
