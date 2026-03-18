import 'package:flutter_test/flutter_test.dart';
import 'package:sanslex/core/transliteration_service.dart';

void main() {
  setUpAll(() {
    TransliterationService.init();
  });

  group('TransliterationService Tests', () {
    test('toSlp1 correctly converts HK "aMza" to "aMSa"', () {
      final result = TransliterationService.toSlp1('aMza', 'hk');
      expect(result, 'aMSa');
    });

    test('toSlp1 correctly converts ITRANS "aMsha" to "aMSa"', () {
      final result = TransliterationService.toSlp1('aMsha', 'itrans');
      expect(result, 'aMSa');
    });

    test('fromSlp1 correctly converts "aMSa" to Devanagari', () {
      final result = TransliterationService.fromSlp1('aMSa', 'devanagari');
      expect(result, 'अंश'); // devanagari script for amsha
    });

    test('stripSLP1Accents cleanly removes / accent markers', () {
      final result = TransliterationService.stripSLP1Accents('a/MSa');
      expect(result, 'aMSa');
    });
  });
}
