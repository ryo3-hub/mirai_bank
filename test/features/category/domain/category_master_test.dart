import 'package:flutter_test/flutter_test.dart';
import 'package:mirai_bank/features/category/domain/category_master.dart';
import 'package:mirai_bank/features/category/domain/category_presets.dart';

void main() {
  group('CategoryMaster.majors', () {
    test('contains exactly 14 majors', () {
      expect(CategoryMaster.majors, hasLength(14));
    });

    test('major keys are unique', () {
      final keys = CategoryMaster.majors.map((m) => m.key).toList();
      expect(keys.toSet().length, keys.length);
    });

    test('majors are sorted by kana (五十音順)', () {
      final kanas = CategoryMaster.majors.map((m) => m.kana).toList();
      final sorted = [...kanas]..sort();
      expect(kanas, sorted);
    });

    test('every major has a registered icon and color', () {
      for (final m in CategoryMaster.majors) {
        expect(
          CategoryPresets.icons.containsKey(m.iconCode),
          isTrue,
          reason: 'iconCode "${m.iconCode}" of ${m.key} is not registered',
        );
        expect(
          CategoryPresets.colors.contains(m.colorCode),
          isTrue,
          reason: 'colorCode "${m.colorCode}" of ${m.key} is not registered',
        );
      }
    });
  });

  group('CategoryMaster.minors', () {
    test('contains exactly 55 entries (CSV と同数)', () {
      expect(CategoryMaster.minors, hasLength(55));
    });

    test('minor keys are unique across the whole list', () {
      final keys = CategoryMaster.minors.map((m) => m.key).toList();
      expect(keys.toSet().length, keys.length);
    });

    test('every minor has a recommended rate within Category.* range', () {
      for (final m in CategoryMaster.minors) {
        // 推奨時給は最低 600 円、最大 1800 円の範囲（CSV から）
        expect(m.recommendedRate, greaterThanOrEqualTo(100));
        expect(m.recommendedRate, lessThanOrEqualTo(10000));
      }
    });

    test('every minor references an existing major', () {
      final majorKeys = CategoryMaster.majors.map((m) => m.key).toSet();
      for (final m in CategoryMaster.minors) {
        expect(majorKeys.contains(m.majorKey), isTrue,
            reason: 'minor "${m.key}" references missing major "${m.majorKey}"');
      }
    });
  });

  group('CategoryMaster.minorsFor', () {
    test('returns minors sorted by kana within major', () {
      for (final major in CategoryMaster.majors) {
        final minors = CategoryMaster.minorsFor(major.key);
        final kanas = minors.map((m) => m.kana).toList();
        final sorted = [...kanas]..sort();
        expect(kanas, sorted, reason: 'minors in ${major.key} not sorted');
      }
    });

    test('unknown major returns empty list', () {
      expect(CategoryMaster.minorsFor('nonexistent'), isEmpty);
    });
  });

  group('CategoryMaster.findMinor / findMajor', () {
    test('findMinor returns the entry for a known key', () {
      final english = CategoryMaster.findMinor('english');
      expect(english, isNotNull);
      expect(english!.name, '英語');
      expect(english.recommendedRate, 1000);
    });

    test('findMinor returns null for unknown or null', () {
      expect(CategoryMaster.findMinor(null), isNull);
      expect(CategoryMaster.findMinor('does-not-exist'), isNull);
    });

    test('findMajor returns the entry for a known key', () {
      final lang = CategoryMaster.findMajor('language');
      expect(lang, isNotNull);
      expect(lang!.name, '語学学習');
    });
  });
}
