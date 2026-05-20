import 'package:flutter_test/flutter_test.dart';
import 'package:mirai_bank/features/history/domain/work_session.dart';

void main() {
  group('WorkSession.validateMemo', () {
    test('accepts null', () {
      expect(WorkSession.validateMemo(null), isNull);
    });

    test('accepts empty string', () {
      expect(WorkSession.validateMemo(''), isNull);
    });

    test('accepts memo up to max length', () {
      final atLimit = 'あ' * WorkSession.memoMaxLength;
      expect(WorkSession.validateMemo(atLimit), isNull);
    });

    test('rejects memo over max length', () {
      final overLimit = 'あ' * (WorkSession.memoMaxLength + 1);
      final result = WorkSession.validateMemo(overLimit);
      expect(result, isNotNull);
      expect(result, contains('${WorkSession.memoMaxLength}文字'));
    });
  });
}
