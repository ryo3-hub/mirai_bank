import 'package:flutter_test/flutter_test.dart';
import 'package:mirai_bank/features/category/domain/category_master.dart';
import 'package:mirai_bank/features/category/domain/category_presets.dart';

void main() {
  group('CategoryMaster.majors', () {
    test('contains exactly 14 majors (issue #169)', () {
      expect(CategoryMaster.majors, hasLength(14));
    });

    test('major keys are unique', () {
      final keys = CategoryMaster.majors.map((m) => m.key).toList();
      expect(keys.toSet().length, keys.length);
    });

    test('majors are declared in `docs/category_master.csv` order', () {
      // 五十音順ソートは廃止（issue #169）。CSV の登場順を期待する。
      final keys = CategoryMaster.majors.map((m) => m.key).toList();
      expect(keys, [
        'language',
        'programming',
        'qualification',
        'academic',
        'reading',
        'work',
        'sidejob',
        'investment',
        'creative',
        'exercise',
        'self_dev',
        'communication',
        'home_life',
        'hobby',
      ]);
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
    test('contains exactly 65 entries (CSV と同数, issue #169)', () {
      expect(CategoryMaster.minors, hasLength(65));
    });

    test('minor keys are unique across the whole list', () {
      final keys = CategoryMaster.minors.map((m) => m.key).toList();
      expect(keys.toSet().length, keys.length);
    });

    test('every minor has a recommended rate within Category.* range', () {
      for (final m in CategoryMaster.minors) {
        // CategoryHourlyRateField の範囲（100..10000）に収まること
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

    test('new home_life major has its 4 minors (issue #169)', () {
      final keys = CategoryMaster.minorsFor('home_life').map((m) => m.key);
      expect(keys, ['cooking_home', 'cleaning', 'housekeeping', 'parenting']);
    });

    test('removed legacy minors are gone (issue #169)', () {
      // 既存 minor で削除されたものは findMinor が null を返す
      expect(CategoryMaster.findMinor('news'), isNull);
      expect(CategoryMaster.findMinor('aerobic'), isNull);
      expect(CategoryMaster.findMinor('cooking_hobby'), isNull);
      expect(CategoryMaster.findMinor('cooking_health'), isNull);
      expect(CategoryMaster.findMinor('sleep'), isNull);
      expect(CategoryMaster.findMinor('meditation'), isNull);
    });
  });

  group('CategoryMaster.minorsFor', () {
    test('preserves declared CSV order within a major (issue #169)', () {
      // 五十音ソートは廃止。`minors` リストの登場順をフィルタしただけの
      // ものが返ってくることを期待する。
      for (final major in CategoryMaster.majors) {
        final filtered = CategoryMaster.minorsFor(major.key);
        final expected = CategoryMaster.minors
            .where((m) => m.majorKey == major.key)
            .toList(growable: false);
        expect(
          filtered.map((m) => m.key).toList(),
          expected.map((m) => m.key).toList(),
          reason: 'minors in ${major.key} do not preserve declared order',
        );
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
      // CSV の推奨時給（issue #169 で 1000 → 1200 に更新）
      expect(english.recommendedRate, 1200);
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

    test('findMajor returns the entry for the new home_life key', () {
      final home = CategoryMaster.findMajor('home_life');
      expect(home, isNotNull);
      expect(home!.name, '家事・生活');
    });
  });
}
