import 'package:flutter_test/flutter_test.dart';
import 'package:sanskrit_lexicon/core/transliteration_service.dart';

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

    test('fromSlp1 handles Vedic accents in Devanagari', () {
      // General Devanagari fallback logic
      final result1 = TransliterationService.fromSlp1('a/ni/', 'devanagari', useAccented: true);
      expect(result1, 'अ꣡नि꣡'); // slp1 / -> devanagari udatta (꣡) from indic_transliteration

      final result2 = TransliterationService.fromSlp1('a^ni', 'devanagari', useAccented: true);
      expect(result2, 'अ᳙नि'); // slp1 ^ -> svarita fallback
    });

    test('fromSlp1 handles PWG specific accent overrides', () {
      // dictionary specific overrides: ꣡ -> ꣫, ᳙ -> ॑
      final result = TransliterationService.fromSlp1('a/ni^', 'devanagari', useAccented: true, dictCode: 'pwg');
      // expect 'अ꣫नि॑'
      // a/ -> अ + ꣫ (mapped from ꣡ or /)
      // i^ -> ि + ॑ (mapped from ᳙ or ^)
      expect(result, 'अ꣫नि॑');
    });
  });
}


