import 'package:flutter_test/flutter_test.dart';
import 'package:mirai_bank/features/category/domain/category.dart';

void main() {
  group('Category.validateName', () {
    test('rejects null and empty', () {
      expect(Category.validateName(null), isNotNull);
      expect(Category.validateName(''), isNotNull);
      expect(Category.validateName('   '), isNotNull);
    });

    test('rejects names longer than max length', () {
      final long = 'あ' * (Category.nameMaxLength + 1);
      expect(Category.validateName(long), isNotNull);
    });

    test('accepts valid names', () {
      expect(Category.validateName('プログラミング'), isNull);
      expect(Category.validateName('a' * Category.nameMaxLength), isNull);
    });
  });

  group('Category.validateHourlyRate', () {
    test('rejects null, empty, non-numeric', () {
      expect(Category.validateHourlyRate(null), isNotNull);
      expect(Category.validateHourlyRate(''), isNotNull);
      expect(Category.validateHourlyRate('abc'), isNotNull);
    });

    test('rejects values below minimum', () {
      expect(Category.validateHourlyRate('0'), isNotNull);
      expect(Category.validateHourlyRate('-100'), isNotNull);
      expect(
        Category.validateHourlyRate((Category.hourlyRateMin - 1).toString()),
        isNotNull,
      );
    });

    test('rejects values above maximum', () {
      expect(
        Category.validateHourlyRate((Category.hourlyRateMax + 1).toString()),
        isNotNull,
      );
    });

    test('accepts valid rates', () {
      expect(
        Category.validateHourlyRate(Category.hourlyRateMin.toString()),
        isNull,
      );
      expect(Category.validateHourlyRate('2000'), isNull);
      expect(
        Category.validateHourlyRate(Category.hourlyRateMax.toString()),
        isNull,
      );
    });
  });

  group('Category.copyWith', () {
    final base = Category(
      id: 'id-1',
      name: '元名前',
      hourlyRate: 1000,
      colorCode: '#000000',
      iconCode: 'school',
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    );

    test('overrides specified fields and keeps the rest', () {
      final updated = base.copyWith(name: '新名前', hourlyRate: 3000);
      expect(updated.id, base.id);
      expect(updated.name, '新名前');
      expect(updated.hourlyRate, 3000);
      expect(updated.colorCode, base.colorCode);
      expect(updated.createdAt, base.createdAt);
    });
  });
}
