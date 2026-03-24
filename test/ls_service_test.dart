import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:cologne_sanskrit_lexicon/core/ls_service.dart';

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;

    const channel = MethodChannel('plugins.flutter.io/path_provider');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      if (methodCall.method == 'getApplicationDocumentsDirectory') {
        final dir = Directory.current.path;
        return '$dir/test/data';
      }
      return null;
    });
  });

  group('LsService - Key Extraction', () {
    test('extractFirstKey extracts first word from simple abbreviation', () {
      expect(LsService.extractFirstKey('M.'), equals('M.'));
    });

    test('extractFirstKey extracts first word from reference with numbers', () {
      expect(LsService.extractFirstKey('RV. 1.2.3'), equals('RV.'));
    });

    test('extractFirstKey extracts first word from Panini reference', () {
      expect(LsService.extractFirstKey('Pāṇ. 1. 2. 3'), equals('Pāṇ.'));
    });

    test('extractFirstKey handles empty string', () {
      expect(LsService.extractFirstKey(''), isNull);
    });
  });

  group('LsService - Roman Numeral Conversion', () {
    test('romanInt converts lowercase i', () {
      expect(LsService.romanInt('i'), equals(1));
    });

    test('romanInt converts lowercase ii', () {
      expect(LsService.romanInt('ii'), equals(2));
    });

    test('romanInt converts lowercase x', () {
      expect(LsService.romanInt('x'), equals(10));
    });

    test('romanInt handles invalid roman numeral', () {
      expect(LsService.romanInt('abc'), equals(0));
    });

    test('romanInt converts uppercase I', () {
      expect(LsService.romanInt('I'), equals(1));
    });

    test('romanInt converts uppercase II', () {
      expect(LsService.romanInt('II'), equals(2));
    });

    test('romanInt converts uppercase V', () {
      expect(LsService.romanInt('V'), equals(5));
    });

    test('romanInt converts uppercase X', () {
      expect(LsService.romanInt('X'), equals(10));
    });

    test('romanInt converts iv (lowercase)', () {
      expect(LsService.romanInt('iv'), equals(4));
    });

    test('romanInt converts XII', () {
      expect(LsService.romanInt('XII'), equals(12));
    });
  });

  group('LsService - URL Generation with Roman Numerals', () {
    test('PWG: PAÑCAT. with Roman numeral I converts to 1', () {
      final result =
          LsService.generateHref('pwg', 'PAÑCAT.', null, 'PAÑCAT. I, 1');
      expect(
          result,
          equals(
              'https://sanskrit-lexicon-scans.github.io/pantankose/app1?1,1'));
    });

    test('PWG: PAÑCAT. with Roman numeral II converts to 2', () {
      final result =
          LsService.generateHref('pwg', 'PAÑCAT.', null, 'PAÑCAT. II, 3');
      expect(
          result,
          equals(
              'https://sanskrit-lexicon-scans.github.io/pantankose/app1?2,3'));
    });

    test('PWG: HIT. with Roman numeral I converts to 1', () {
      final result = LsService.generateHref('pwg', 'HIT.', null, 'HIT. I, 5');
      expect(
          result,
          equals(
              'https://sanskrit-lexicon-scans.github.io/hitopadesha/app1?1,5'));
    });

    test('MW: Pañcat. with Roman numeral I converts to 1', () {
      final result =
          LsService.generateHref('mw', 'Pañcat.', null, 'Pañcat. I, 1, 2');
      expect(
          result,
          equals(
              'https://sanskrit-lexicon-scans.github.io/pantankose/app1?1,1,2'));
    });
  });

  group('LsService - Prefix Resolution', () {
    test('getPrefix returns default prefix for MW dictionary', () {
      expect(LsService.getPrefix('mw', 'RV.'), equals('rv'));
    });

    test('getPrefix returns AP90-specific prefix', () {
      expect(LsService.getPrefix('ap90', 'Rv.'), equals('rv'));
    });

    test('getPrefix returns null for unknown key', () {
      expect(LsService.getPrefix('mw', 'UNKNOWN'), isNull);
    });
  });

  group('LsService - Rigveda Link Generation', () {
    test('hrefRvAv generates href for RV', () {
      final result = LsService.hrefRvAv('rv', 'RV. i, 1, 2', 'mw');
      expect(result, isNotNull);
      expect(result, contains('rvlinks'));
    });

    test('hrefRvAv generates href for AV', () {
      final result = LsService.hrefRvAv('av', 'AV. i, 1, 2', 'mw');
      expect(result, isNotNull);
      expect(result, contains('avlinks'));
    });

    test('hrefRvAv handles AP90 format', () {
      final result = LsService.hrefRvAv('rv', 'Rv. 1. 2. 3', 'ap90');
      expect(result, isNotNull);
      expect(result, contains('rvlinks'));
    });
  });

  group('LsService - Panini Link Generation', () {
    test('hrefPanini generates href for Panini', () {
      final result = LsService.hrefPanini('Pāṇ. i, 2, 3', 'mw');
      expect(result, equals('https://ashtadhyayi.com/sutraani/1/2/3'));
    });

    test('hrefPanini handles AP90 format', () {
      final result = LsService.hrefPanini('P. I. 2. 3', 'ap90');
      expect(result, equals('https://ashtadhyayi.com/sutraani/1/2/3'));
    });

    test('hrefPanini returns null for invalid format', () {
      expect(LsService.hrefPanini('invalid', 'mw'), isNull);
    });
  });

  group('LsService - Ramayana Link Generation', () {
    test('hrefRamayana generates href', () {
      final result = LsService.hrefRamayana('R. i, 1, 2', 'mw');
      expect(result, isNotNull);
      expect(result, contains('ramayana'));
    });

    test('hrefRamayanaBombay generates href', () {
      final result = LsService.hrefRamayanaBombay('R. (B.) vii, 1, 2');
      expect(result, isNotNull);
      expect(result, contains('ramayanabom'));
    });

    test('hrefRamayanaGorresio generates href', () {
      final result = LsService.hrefRamayanaGorresio('R. (ed. Gorr.) i, 1, 2');
      expect(result, isNotNull);
      expect(result, contains('ramayanagorr'));
    });
  });

  group('LsService - Mahabharata Link Generation', () {
    test('hrefMahabharata generates href for Calc edition', () {
      final result = LsService.hrefMahabharata('1, 2, 3', 'MBHC');
      expect(result, isNotNull);
      expect(result, contains('calc'));
    });

    test('hrefMahabharata generates href for Bomb edition', () {
      final result = LsService.hrefMahabharata('1, 2, 3', 'MBHB');
      expect(result, isNotNull);
      expect(result, contains('bomb'));
    });
  });

  group('LsService - Bhagavad Gita', () {
    test('hrefBhagavadGita generates href', () {
      final result = LsService.hrefBhagavadGita('1, 2');
      expect(result, isNotNull);
      expect(result, contains('bhagavadgita'));
    });
  });

  group('LsService - Manu Smriti', () {
    test('hrefManu generates href', () {
      final result = LsService.hrefManu('1, 2');
      expect(result, isNotNull);
      expect(result, contains('manusmriti'));
    });
  });

  group('LsService - Other Works', () {
    test('hrefPancatantra generates href', () {
      expect(LsService.hrefPancatantra('Pañcat. 1, 2'), isNotNull);
      expect(LsService.hrefPancatantra('Pañcat. 1, 2'), contains('pantankose'));
    });

    test('hrefMeghaduta generates href', () {
      expect(LsService.hrefMeghaduta('Megh. 1, 2'), isNotNull);
    });

    test('hrefHarivamsa generates href', () {
      expect(LsService.hrefHarivamsa('1, 2, 3'), isNotNull);
    });

    test('hrefBhagavataPurana generates href', () {
      expect(LsService.hrefBhagavataPurana('1, 2, 3'), isNotNull);
    });

    test('hrefVajasansamhita generates href', () {
      expect(LsService.hrefVajasansamhita('1, 2, 3'), isNotNull);
    });

    test('hrefTaittiriyaSamhita generates href', () {
      expect(LsService.hrefTaittiriyaSamhita('1, 2, 3'), isNotNull);
    });

    test('hrefSatapathaBrahmana generates href', () {
      expect(LsService.hrefSatapathaBrahmana('1, 2, 3'), isNotNull);
    });

    test('hrefNirukta generates href', () {
      expect(LsService.hrefNirukta('1, 2'), isNotNull);
    });

    test('hrefKumarasambhava generates href', () {
      expect(LsService.hrefKumarasambhava('1, 2, 3'), isNotNull);
    });

    test('hrefMalavikagnimitra generates href', () {
      expect(LsService.hrefMalavikagnimitra('1, 2'), isNotNull);
    });

    test('hrefVikramorvashiya generates href', () {
      expect(LsService.hrefVikramorvashiya('1, 2'), isNotNull);
    });
  });

  group('LsService - SCH-specific Works', () {
    test('hrefKathasaritsagara generates href', () {
      expect(LsService.hrefKathasaritsagara('Kathās. 1, 2'), isNotNull);
    });

    test('hrefSpruch generates href', () {
      expect(LsService.hrefSpruch('Spr. 123'), isNotNull);
    });

    test('hrefVerzOxf generates href', () {
      expect(LsService.hrefVerzOxf('Verz. d. Oxf. H. 123'), isNotNull);
    });
  });

  group('LsService - processLs', () {
    test('processLs handles empty content', () async {
      final result = await LsService.processLs(dictCode: 'mw', lsContent: '');
      expect(result, isNull);
    });

    test('processLs returns result with href', () async {
      final result = await LsService.processLs(
        dictCode: 'mw',
        lsContent: 'i, 1, 2',
        nAttribute: 'R.',
      );
      expect(result, isNotNull);
      expect(result!.href, isNotNull);
    });

    test('batchProcessLs handles empty list', () async {
      final results = await LsService.batchProcessLs(
        dictCode: 'mw',
        lsContents: [],
      );
      expect(results, isEmpty);
    });

    test('batchProcessLs processes entries', () async {
      final results = await LsService.batchProcessLs(
        dictCode: 'mw',
        lsContents: ['i, 1, 2'],
        nAttributes: ['R.'],
      );
      expect(results.length, equals(1));
    });
  });

  group('LsService - PWG Pattern Tests', () {
    test('PWG: Spr. pattern matches', () {
      final result = LsService.generateHref('pwg', 'Spr.', null, 'Spr. 123');
      expect(result,
          equals('https://sanskrit-lexicon-scans.github.io/boesp1/app1/?123'));
    });

    test('PWG: MBH. Bombay edition 3 params', () {
      final result = LsService.generateHref('pwg', 'MBH.', null, 'MBH. 1,2,3');
      expect(
          result,
          equals(
              'https://sanskrit-lexicon-scans.github.io/mbhbomb/app1?1,2,3'));
    });

    test('PWG: MBH. Calcutta edition 2 params', () {
      final result = LsService.generateHref('pwg', 'MBH.', null, 'MBH. 1,2');
      expect(result,
          equals('https://sanskrit-lexicon-scans.github.io/mbhcalc?1.2'));
    });

    test('PWG: HARIV. pattern', () {
      final result =
          LsService.generateHref('pwg', 'HARIV.', null, 'HARIV. 123');
      expect(
          result, equals('https://sanskrit-lexicon-scans.github.io/hariv?123'));
    });

    test('PWG: KATHĀS. pattern', () {
      final result =
          LsService.generateHref('pwg', 'KATHĀS.', null, 'KATHĀS. 1,2');
      expect(
          result,
          equals(
              'https://sanskrit-lexicon-scans.github.io/kss/index.html?1,2'));
    });

    test('PWG: VS. pattern', () {
      final result = LsService.generateHref('pwg', 'VS.', null, 'VS. 1,2');
      expect(result,
          equals('https://sanskrit-lexicon-scans.github.io/vajasasa/app1?1,2'));
    });

    test('PWG: RĀJAT. pattern', () {
      final result =
          LsService.generateHref('pwg', 'RĀJAT.', null, 'RĀJAT. 1,2');
      expect(result,
          equals('https://sanskrit-lexicon-scans.github.io/rajatar/app1?1,2'));
    });

    test('PWG: YĀJÑ. pattern', () {
      final result = LsService.generateHref('pwg', 'YĀJÑ.', null, 'YĀJÑ. 1,2');
      expect(
          result,
          equals(
              'https://sanskrit-lexicon-scans.github.io/yajnavalkya/app1?1,2'));
    });

    test('PWG: RAGH. ST pattern', () {
      final result = LsService.generateHref('pwg', 'RAGH.', null, 'RAGH. 1,2');
      expect(
          result,
          equals(
              'https://sanskrit-lexicon-scans.github.io/raghuvamsa/app1?1,2'));
    });

    test('PWG: MĀRK. P. pattern', () {
      final result =
          LsService.generateHref('pwg', 'MĀRK. P.', null, 'MĀRK. P. 1,2');
      expect(
          result,
          equals(
              'https://sanskrit-lexicon-scans.github.io/markandeyapurana/app1?1,2'));
    });

    test('PWG: BHAG. pattern', () {
      final result = LsService.generateHref('pwg', 'BHAG.', null, 'BHAG. 1,2');
      expect(
          result,
          equals(
              'https://sanskrit-lexicon-scans.github.io/bhagavadgita/app1?1,2'));
    });

    test('PWG: H. an. pattern', () {
      final result =
          LsService.generateHref('pwg', 'H. an.', null, 'H. an. 1,2');
      expect(
          result,
          equals(
              'https://sanskrit-lexicon-scans.github.io/anekarthasamgraha/app1?1,2'));
    });

    test('PWG: an. pattern', () {
      final result = LsService.generateHref('pwg', 'an.', null, 'an. 1,2');
      expect(
          result,
          equals(
              'https://sanskrit-lexicon-scans.github.io/anekarthasamgraha/app1?1,2'));
    });

    test('PWG: ŚĀK. pattern with 2 params', () {
      final result = LsService.generateHref('pwg', 'ŚĀK.', null, 'ŚĀK. 1');
      expect(result,
          equals('https://sanskrit-lexicon-scans.github.io/shakuntala/app1?1'));
    });

    test('PWG: AIT. BR. 2 param pattern', () {
      final result =
          LsService.generateHref('pwg', 'AIT. BR.', null, 'AIT. BR. 1,2');
      expect(result,
          equals('https://sanskrit-lexicon-scans.github.io/aitbr/app1?1,2'));
    });

    test('PWG: MĀLAV. 1 param pattern', () {
      final result = LsService.generateHref('pwg', 'MĀLAV.', null, 'MĀLAV. 1');
      expect(
          result,
          equals(
              'https://sanskrit-lexicon-scans.github.io/malavikagni/app1?1'));
    });

    test('PWG: PAÑCAT. roman numeral pattern', () {
      // Roman numeral "I" should be converted to 1
      final result =
          LsService.generateHref('pwg', 'PAÑCAT.', null, 'PAÑCAT. I, 1');
      expect(
          result,
          equals(
              'https://sanskrit-lexicon-scans.github.io/pantankose/app1?1,1'));
    });

    test('PWG: HIT. roman numeral pattern', () {
      // Roman numeral "I" should be converted to 1
      final result = LsService.generateHref('pwg', 'HIT.', null, 'HIT. I, 1');
      expect(
          result,
          equals(
              'https://sanskrit-lexicon-scans.github.io/hitopadesha/app1?1,1'));
    });

    test('PWG: AK. 3 param pattern', () {
      final result = LsService.generateHref('pwg', 'AK.', null, 'AK. 1,2,3');
      expect(
          result,
          equals(
              'https://sanskrit-lexicon-scans.github.io/amara_dlc/app1?1,2,3'));
    });

    test('PWG: AK. 4 param pattern', () {
      final result = LsService.generateHref('pwg', 'AK.', null, 'AK. 1,2,3,4');
      expect(
          result,
          equals(
              'https://sanskrit-lexicon-scans.github.io/amara_dlc/app1?1,2,3,4'));
    });

    test('PWG: NIR. pattern', () {
      final result = LsService.generateHref('pwg', 'NIR.', null, 'NIR. 1,2');
      expect(result,
          equals('https://sanskrit-lexicon-scans.github.io/nirukta/app1?1,2'));
    });

    test('PWG: VOP. pattern', () {
      final result = LsService.generateHref('pwg', 'VOP.', null, 'VOP. 1,2');
      expect(
          result,
          equals(
              'https://sanskrit-lexicon-scans.github.io/mugdhabodha/app1?1,2'));
    });

    test('PWG: BHAṬṬ. pattern', () {
      final result =
          LsService.generateHref('pwg', 'BHAṬṬ.', null, 'BHAṬṬ. 1,2');
      expect(
          result,
          equals(
              'https://sanskrit-lexicon-scans.github.io/bhattikavya/app1?1,2'));
    });

    test('PWG: KUMĀRAS. pattern', () {
      final result =
          LsService.generateHref('pwg', 'KUMĀRAS.', null, 'KUMĀRAS. 1,2');
      expect(result,
          equals('https://sanskrit-lexicon-scans.github.io/kumaras/app1?1,2'));
    });

    test('PWG: ŚAT. BR. pattern', () {
      final result =
          LsService.generateHref('pwg', 'ŚAT. BR.', null, 'ŚAT. BR. 1,2,3,4');
      expect(
          result,
          equals(
              'https://sanskrit-lexicon-scans.github.io/shatapathabr/app1?1,2,3,4'));
    });

    test('PWG: TS. pattern', () {
      final result = LsService.generateHref('pwg', 'TS.', null, 'TS. 1,2,3,4');
      expect(
          result,
          equals(
              'https://sanskrit-lexicon-scans.github.io/taittiriyas/app1?1,2,3,4'));
    });

    test('PWG: TBR. pattern', () {
      final result =
          LsService.generateHref('pwg', 'TBR.', null, 'TBR. 1,2,3,4');
      expect(
          result,
          equals(
              'https://sanskrit-lexicon-scans.github.io/taittiriyabr/app1?1,2,3,4'));
    });

    test('PWG: VIKR. pattern', () {
      final result = LsService.generateHref('pwg', 'VIKR.', null, 'VIKR. 1');
      expect(result,
          equals('https://sanskrit-lexicon-scans.github.io/vikramor/app1?1'));
    });

    test('PWG: MEGH. pattern', () {
      final result = LsService.generateHref('pwg', 'MEGH.', null, 'MEGH. 1');
      expect(result,
          equals('https://sanskrit-lexicon-scans.github.io/meghasrnga/app1?1'));
    });

    test('PWG: M. pattern (Manu)', () {
      final result = LsService.generateHref('pwg', 'M.', null, 'M. 1,2');
      expect(
          result,
          equals(
              'https://sanskrit-lexicon-scans.github.io/manu/index.html?1,2'));
    });

    test('PWG: MED. pattern', () {
      final result = LsService.generateHref('pwg', 'MED.', null, 'MED. k, 1');
      expect(result,
          equals('https://sanskrit-lexicon-scans.github.io/medini/app1?k,1'));
    });

    test('PWG: H. pattern', () {
      final result = LsService.generateHref('pwg', 'H.', null, 'H. 123');
      expect(result,
          equals('https://sanskrit-lexicon-scans.github.io/abch2/app1?123'));
    });

    test('PWG: CH. pattern (pw only)', () {
      final result = LsService.generateHref('pw', 'Chr.', null, 'Chr. 123');
      expect(
          result,
          equals(
              'https://sanskrit-lexicon-scans.github.io/bchrest2/index.html?123'));
    });
  });

  group('LsService - MW Pattern Tests', () {
    test('MW: RV. pattern with 3 params', () {
      final result = LsService.generateHref('mw', 'RV.', null, 'RV. i, 1, 2');
      expect(result, contains('sanskrit-lexicon.github.io/rvlinks'));
    });

    test('MW: R. (Bombay) pattern', () {
      // Real usage: <ls n="R.">vii, 1, 2</ls> → nAttribute='R.', data='vii, 1, 2'
      final result = LsService.generateHref('mw', 'R.', 'R.', 'vii, 1, 2');
      expect(result, contains('ramayanabom'));
    });

    test('MW: P. pattern (Panini)', () {
      final result = LsService.generateHref('mw', 'Pāṇ.', null, 'Pāṇ. i, 1, 2');
      expect(result, contains('ashtadhyayi.com/sutraani'));
    });

    test('MW: Mn. pattern (Manu)', () {
      final result = LsService.generateHref('mw', 'Mn.', null, 'Mn. 1,2');
      expect(
          result,
          equals(
              'https://sanskrit-lexicon-scans.github.io/manusmriti/app1?1,2'));
    });

    test('MW: BhP. pattern', () {
      final result = LsService.generateHref('mw', 'BhP.', null, 'BhP. 1,2,3');
      expect(
          result,
          equals(
              'https://sanskrit-lexicon-scans.github.io/bhagavatapurana/app1?1,2,3'));
    });

    test('MW: Bhag. pattern', () {
      final result = LsService.generateHref('mw', 'Bhag.', null, 'Bhag. 1,2');
      expect(
          result,
          equals(
              'https://sanskrit-lexicon-scans.github.io/bhagavadgita/app1?1,2'));
    });

    test('MW: Ragh. pattern', () {
      final result = LsService.generateHref('mw', 'Ragh.', null, 'Ragh. 1,2,3');
      expect(
          result,
          equals(
              'https://sanskrit-lexicon-scans.github.io/raghuvamsacalc/app1?1,2,3'));
    });

    test('MW: Megh. pattern', () {
      final result = LsService.generateHref('mw', 'Megh.', null, 'Megh. 1,2');
      expect(
          result,
          equals(
              'https://sanskrit-lexicon-scans.github.io/meghaduta/app1?1,2'));
    });

    test('MW: Kum. pattern', () {
      final result = LsService.generateHref('mw', 'Kum.', null, 'Kum. 1,2,3');
      expect(
          result,
          equals(
              'https://sanskrit-lexicon-scans.github.io/kumaras/app1?1,2,3'));
    });

    test('MW: Pañcat. pattern', () {
      final result =
          LsService.generateHref('mw', 'Pañcat.', null, 'Pañcat. I, 1, 2');
      // Roman numeral "I" should be converted to 1
      expect(
          result,
          equals(
              'https://sanskrit-lexicon-scans.github.io/pantankose/app1?1,1,2'));
    });
  });
}
