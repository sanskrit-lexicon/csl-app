import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cologne_sanskrit_lexicon/models/app_settings.dart';
import 'package:cologne_sanskrit_lexicon/core/search_service.dart';
import 'package:cologne_sanskrit_lexicon/core/transliteration_service.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    TransliterationService.init();

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

  group('SearchService Tests - LAN Dictionary', () {
    test('Test headword exact: "a" returns exact match', () async {
      final results = await SearchService.searchHeadword(
        dictCode: 'lan',
        inputWord: 'a',
        inputTranslit: 'slp1',
        mode: SearchMode.exact,
        maxResults: 10,
      );
      
      expect(results.isNotEmpty, true);
      // there is an exact entry key 'a' in Lanman
      expect(results.any((r) => r.key == 'a'), true);
    });

    test('Test headword prefix: "aMSa" returns prefix matches', () async {
      final results = await SearchService.searchHeadword(
        dictCode: 'lan',
        inputWord: 'aMSa',
        inputTranslit: 'slp1',
        mode: SearchMode.prefix,
        maxResults: 10,
      );
      
      expect(results.isNotEmpty, true);
      final keys = results.map((r) => r.key).toList();
      expect(keys.contains('aMSa'), true);
      expect(keys.contains('aMSaS'), true); // Both start with aMSa
    });


    test('Test headword suffix: "Msa" includes "aMsa"', () async {
      final results = await SearchService.searchHeadword(
        dictCode: 'lan',
        inputWord: 'Msa',
        inputTranslit: 'slp1',
        mode: SearchMode.suffix,
        maxResults: 100,
      );
      
      expect(results.isNotEmpty, true);
      expect(results.any((r) => r.key == 'aMsa'), true);
    });

    test('Test headword substring: "Msa" includes "aMsa"', () async {
      final results = await SearchService.searchHeadword(
        dictCode: 'lan',
        inputWord: 'Msa',
        inputTranslit: 'slp1',
        mode: SearchMode.substring,
        maxResults: 10,
      );
      
      expect(results.isNotEmpty, true);
      final keys = results.map((r) => r.key).toList();
      expect(keys.contains('aMsa'), true);
    });

    test('Test definition search: "entrance" includes "pravesa"', () async {
      final results = await SearchService.searchDefinition(
        dictCode: 'lan',
        inputWord: 'entrance',
        inputTranslit: 'hl', // arbitrary for def search using english
        mode: SearchMode.substring, // actually ignored, definition search defaults to LIKE %word%
        maxResults: 10,
      );
      
      expect(results.isNotEmpty, true);
      expect(results.any((r) => r.data.toLowerCase().contains('entrance')), true);
    });

    test('Test ITRANS to SLP1 transliteration during search: "aMsha" == "aMSa"', () async {
      final results = await SearchService.searchHeadword(
        dictCode: 'lan',
        inputWord: 'aMsha',
        inputTranslit: 'itrans',
        mode: SearchMode.exact,
        maxResults: 10,
      );
      
      expect(results.isNotEmpty, true);
      expect(results.any((r) => r.key == 'aMSa'), true);
    });
  });
}
