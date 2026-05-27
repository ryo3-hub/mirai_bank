import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:mirai_bank/features/timer/domain/streak_messages.dart';

void main() {
  group('pickRandomEncouragement', () {
    test('returns non-empty even when days == 0 (tier0)', () {
      // 0 日でもティア 0 から励まし文言が返る（issue: 0 日目でも表示）
      final msg = pickRandomEncouragement(0, random: Random(42));
      expect(msg, isNotEmpty);
    });

    test('returns non-empty for various streak values', () {
      final r = Random(42);
      for (final days in [0, 1, 3, 7, 30, 100, 365, 1000]) {
        expect(
          pickRandomEncouragement(days, random: r),
          isNotEmpty,
          reason: 'days=$days should yield a message',
        );
      }
    });

    test('same Random seed yields same message', () {
      final a = pickRandomEncouragement(5, random: Random(123));
      final b = pickRandomEncouragement(5, random: Random(123));
      expect(a, equals(b));
    });

    test('different seeds (likely) yield different messages', () {
      // 100 回ループで複数種類が出ることを確認（ランダム性のチェック）
      final messages = <String>{};
      for (var seed = 0; seed < 100; seed++) {
        messages.add(pickRandomEncouragement(5, random: Random(seed)));
      }
      expect(messages.length, greaterThan(1));
    });

    test('crossing tier boundary switches pool', () {
      // tier0 と tier6 では明らかに違うプールから選ばれる
      final tier0Pool = <String>{};
      final tier6Pool = <String>{};
      for (var seed = 0; seed < 100; seed++) {
        tier0Pool.add(pickRandomEncouragement(0, random: Random(seed)));
        tier6Pool.add(pickRandomEncouragement(365, random: Random(seed)));
      }
      // 2 つの集合に重なりが無い（または極めて少ない）
      expect(tier0Pool.intersection(tier6Pool), isEmpty);
    });
  });

  group('pickStreakMessage (legacy date-based)', () {
    test('returns empty when days <= 0', () {
      expect(pickStreakMessage(0), isEmpty);
      expect(pickStreakMessage(-5), isEmpty);
    });

    test('returns non-empty for days >= 1', () {
      expect(pickStreakMessage(1, now: DateTime(2026, 5, 25)), isNotEmpty);
      expect(pickStreakMessage(7, now: DateTime(2026, 5, 25)), isNotEmpty);
      expect(pickStreakMessage(365, now: DateTime(2026, 5, 25)), isNotEmpty);
    });

    test('same day + same days yields same message', () {
      final today = DateTime(2026, 5, 25);
      final a = pickStreakMessage(5, now: today);
      final b = pickStreakMessage(5, now: today);
      expect(a, equals(b));
    });

    test('different day yields different message (most of the time)', () {
      // 30 連続日ぶん回すと最低 1 回は文言が変わるはず。
      // （プールは tier ごとに 30 件なのでサイクル）
      final messages = <String>{};
      for (var i = 0; i < 30; i++) {
        final day = DateTime(2026, 5, 1).add(Duration(days: i));
        messages.add(pickStreakMessage(5, now: day));
      }
      // 1 種類しか見えない＝ピッカーが壊れている、を検出する。
      expect(messages.length, greaterThan(1));
    });

    test('crossing tier boundary switches pool', () {
      final today = DateTime(2026, 5, 25);
      // 同日でも tier が違えば異なるメッセージプールから選ばれる。
      // 同じインデックスでも文言が異なる可能性が極めて高い。
      final t1 = pickStreakMessage(2, now: today); // tier 1
      final t2 = pickStreakMessage(7, now: today); // tier 3
      final t3 = pickStreakMessage(365, now: today); // tier 6
      // 3 ティアすべてで同じになる確率は無視できるほど低い
      expect({t1, t2, t3}.length, greaterThan(1));
    });

    test('time-of-day does not affect the picked message', () {
      // 同じローカル日付なら時刻が違っても同じ文言になること。
      final morning = DateTime(2026, 5, 25, 8, 0);
      final night = DateTime(2026, 5, 25, 23, 59);
      expect(
        pickStreakMessage(15, now: morning),
        equals(pickStreakMessage(15, now: night)),
      );
    });
  });
}
