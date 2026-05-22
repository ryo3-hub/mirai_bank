import 'package:flutter_test/flutter_test.dart';
import 'package:mirai_bank/features/timer/domain/timer_preset.dart';

void main() {
  group('TimerPreset.validateMinutes', () {
    test('null は不可', () {
      expect(TimerPreset.validateMinutes(null), isNotNull);
    });

    test('5 分未満は不可', () {
      expect(TimerPreset.validateMinutes(0), isNotNull);
      expect(TimerPreset.validateMinutes(4), isNotNull);
    });

    test('480 分超は不可', () {
      expect(TimerPreset.validateMinutes(481), isNotNull);
      expect(TimerPreset.validateMinutes(1000), isNotNull);
    });

    test('5 分単位でない値は不可', () {
      expect(TimerPreset.validateMinutes(7), isNotNull);
      expect(TimerPreset.validateMinutes(13), isNotNull);
    });

    test('5 分単位 / 範囲内なら OK', () {
      expect(TimerPreset.validateMinutes(5), isNull);
      expect(TimerPreset.validateMinutes(15), isNull);
      expect(TimerPreset.validateMinutes(30), isNull);
      expect(TimerPreset.validateMinutes(60), isNull);
      expect(TimerPreset.validateMinutes(480), isNull);
    });
  });

  test('durationSec = minutes * 60', () {
    final p = TimerPreset(
      id: 'x',
      minutes: 25,
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    );
    expect(p.durationSec, 25 * 60);
  });
}
