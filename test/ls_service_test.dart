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
}
