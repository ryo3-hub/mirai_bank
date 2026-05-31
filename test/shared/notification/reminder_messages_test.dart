import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:mirai_bank/shared/notification/reminder_messages.dart';

void main() {
  group('ReminderMessages.all', () {
    test('has a reasonable variety of messages (>= 20)', () {
      expect(ReminderMessages.all.length, greaterThanOrEqualTo(20));
    });

    test('contains at least one weekday-only and one weekend-only message', () {
      final byTag = <ReminderTag, int>{};
      for (final m in ReminderMessages.all) {
        byTag[m.tag] = (byTag[m.tag] ?? 0) + 1;
      }
      expect(byTag[ReminderTag.weekday] ?? 0, greaterThan(0));
      expect(byTag[ReminderTag.weekend] ?? 0, greaterThan(0));
      expect(byTag[ReminderTag.any] ?? 0, greaterThan(0));
    });

    test('all messages have non-empty title and body', () {
      for (final m in ReminderMessages.all) {
        expect(m.title.isNotEmpty, isTrue, reason: 'title empty for "$m"');
        expect(m.body.isNotEmpty, isTrue, reason: 'body empty for "$m"');
      }
    });
  });

  group('ReminderMessages.randomFor', () {
    test('never returns a weekend-only message for weekdays (Mon..Fri)', () {
      // 決定論シードを変えながら、平日プールに `weekend` が混じらないか
      // 何度も確認する（プールは static なので必ず排他になるはず）。
      for (var weekday = 1; weekday <= 5; weekday++) {
        for (var seed = 0; seed < 50; seed++) {
          final picked =
              ReminderMessages.randomFor(weekday, random: Random(seed));
          expect(
            picked.tag,
            isNot(ReminderTag.weekend),
            reason:
                'weekday $weekday seed $seed: tag=${picked.tag} title="${picked.title}"',
          );
        }
      }
    });

    test('never returns a weekday-only message for weekends (Sat/Sun)', () {
      for (final weekday in [6, 7]) {
        for (var seed = 0; seed < 50; seed++) {
          final picked =
              ReminderMessages.randomFor(weekday, random: Random(seed));
          expect(
            picked.tag,
            isNot(ReminderTag.weekday),
            reason:
                'weekend $weekday seed $seed: tag=${picked.tag} title="${picked.title}"',
          );
        }
      }
    });

    test('exhausts more than one distinct message over many seeds (sanity)', () {
      // 純粋にプールが 1 件しかないとバリエーションが死ぬので、最低 5 種類は
      // 取れることを確認しておく（平日・休日それぞれ）。
      final mondaySet = <String>{};
      final saturdaySet = <String>{};
      for (var seed = 0; seed < 100; seed++) {
        mondaySet
            .add(ReminderMessages.randomFor(1, random: Random(seed)).title);
        saturdaySet
            .add(ReminderMessages.randomFor(6, random: Random(seed)).title);
      }
      expect(mondaySet.length, greaterThanOrEqualTo(5));
      expect(saturdaySet.length, greaterThanOrEqualTo(5));
    });
  });
}
