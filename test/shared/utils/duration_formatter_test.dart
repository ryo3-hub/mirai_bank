import 'package:flutter_test/flutter_test.dart';
import 'package:mirai_bank/shared/utils/duration_formatter.dart';

void main() {
  group('DurationFormatter.hms', () {
    test('formats zero', () {
      expect(DurationFormatter.hms(0), '00:00:00');
    });

    test('formats seconds only', () {
      expect(DurationFormatter.hms(45), '00:00:45');
    });

    test('formats minutes and seconds', () {
      expect(DurationFormatter.hms(125), '00:02:05');
    });

    test('formats full HH:MM:SS', () {
      expect(DurationFormatter.hms(3661), '01:01:01');
    });

    test('handles long durations', () {
      expect(DurationFormatter.hms(36000), '10:00:00');
    });

    test('clamps negative to zero', () {
      expect(DurationFormatter.hms(-5), '00:00:00');
    });
  });

  group('DurationFormatter.hourMinute', () {
    test('returns "0分" for zero', () {
      expect(DurationFormatter.hourMinute(0), '0分');
    });

    test('returns minutes only when under one hour', () {
      expect(DurationFormatter.hourMinute(45 * 60), '45分');
      expect(DurationFormatter.hourMinute(1), '0分'); // floors seconds
    });

    test('returns hours only when zero minutes', () {
      expect(DurationFormatter.hourMinute(2 * 3600), '2時間');
    });

    test('combines hours and minutes', () {
      expect(DurationFormatter.hourMinute(2 * 3600 + 30 * 60), '2時間30分');
    });

    test('clamps negative to zero', () {
      expect(DurationFormatter.hourMinute(-5), '0分');
    });
  });

  group('DurationFormatter.hourMinuteSecond', () {
    test('returns "0秒" for zero', () {
      expect(DurationFormatter.hourMinuteSecond(0), '0秒');
    });

    test('seconds only', () {
      expect(DurationFormatter.hourMinuteSecond(45), '45秒');
    });

    test('minutes and seconds', () {
      expect(DurationFormatter.hourMinuteSecond(65), '1分5秒');
    });

    test('minutes only when seconds are zero', () {
      expect(DurationFormatter.hourMinuteSecond(60), '1分');
    });

    test('hours only when minutes and seconds are zero', () {
      expect(DurationFormatter.hourMinuteSecond(3600), '1時間');
    });

    test('hours and seconds skipping zero minutes', () {
      expect(DurationFormatter.hourMinuteSecond(3605), '1時間5秒');
    });

    test('full H/M/S combination', () {
      expect(DurationFormatter.hourMinuteSecond(3665), '1時間1分5秒');
    });

    test('clamps negative to zero', () {
      expect(DurationFormatter.hourMinuteSecond(-5), '0秒');
    });
  });
}
