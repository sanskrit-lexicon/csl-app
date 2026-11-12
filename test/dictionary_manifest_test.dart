import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:cologne_sanskrit_lexicon/core/dictionary_manifest.dart';
import 'package:cologne_sanskrit_lexicon/core/dictionary_registry.dart';

Map<String, dynamic> manifest(List<Map<String, dynamic>> dicts,
        {int schema = 1}) =>
    {'schemaVersion': schema, 'dictionaries': dicts};

void main() {
  setUp(() {
    DictionaryRegistry.reset();
    SharedPreferences.setMockInitialValues({});
  });

  group('DictionaryRegistry.applyManifest', () {
    test('built-in list works with no manifest', () {
      expect(DictionaryRegistry.byCode('mw'), isNotNull);
      expect(DictionaryRegistry.isEnglishHeadwords('ae'), true);
      expect(DictionaryRegistry.isEnglishHeadwords('mw'), false);
      expect(DictionaryRegistry.renderProfile('nmmb'), 'abch');
      expect(DictionaryRegistry.renderProfile('mw'), 'default');
    });

    test('a dictionary unknown to the app appears', () {
      DictionaryRegistry.applyManifest(manifest([
        {
          'code': 'zzz',
          'name': 'Zed Dictionary',
          'authors': 'A. Author',
          'year': 1901,
          'group': 'Sanskrit-English',
          'hasDeva': true,
        }
      ]));
      final d = DictionaryRegistry.byCode('zzz')!;
      expect(d.codeUp, 'ZZZ');
      expect(d.title, 'Zed Dictionary 1901');
      expect(d.bibliographicEntry, 'A. Author (1901) Zed Dictionary.');
      expect(d.hasDevaTextOption, true);
      expect(d.downloadUrl, endsWith('/csl-sqlite/zzz.zip'));
      expect(DictionaryRegistry.all.any((x) => x.codeLo == 'zzz'), true);
    });

    test('manifest flags drive english headwords and render profile', () {
      DictionaryRegistry.applyManifest(manifest([
        {'code': 'newe', 'name': 'New E', 'englishHeadwords': true},
        {'code': 'newabch', 'name': 'New A', 'renderProfile': 'abch'},
      ]));
      expect(DictionaryRegistry.isEnglishHeadwords('newe'), true);
      expect(DictionaryRegistry.renderProfile('newabch'), 'abch');
    });

    test('built-in curated data is kept; classification is overridden', () {
      final before = DictionaryRegistry.byCode('mw')!;
      DictionaryRegistry.applyManifest(manifest([
        {'code': 'MW', 'name': 'Other Name', 'status': 'deprecated'}
      ]));
      final after = DictionaryRegistry.byCode('mw')!;
      expect(after.name, before.name);
      expect(after.bibliographicEntry, before.bibliographicEntry);
      expect(after.status, 'deprecated');
    });

    test('excluded dictionaries are hidden, even built-in ones', () {
      DictionaryRegistry.applyManifest(manifest([
        {'code': 'pd', 'name': 'PD', 'status': 'excluded'},
        {'code': 'lan', 'name': 'x', 'status': 'excluded'},
      ]));
      expect(DictionaryRegistry.byCode('pd'), isNull);
      expect(DictionaryRegistry.byCode('lan'), isNull);
    });

    test('built-ins absent from the manifest are kept', () {
      DictionaryRegistry.applyManifest(manifest([
        {'code': 'zzz', 'name': 'Z'}
      ]));
      expect(DictionaryRegistry.byCode('mw'), isNotNull);
    });

    test('malformed manifest is ignored', () {
      final n = DictionaryRegistry.all.length;
      DictionaryRegistry.applyManifest({'dictionaries': 'nope'});
      expect(DictionaryRegistry.all.length, n);
    });

    test('require() never returns null', () {
      final d = DictionaryRegistry.require('unknowncode');
      expect(d.codeUp, 'UNKNOWNCODE');
      expect(d.name, 'UNKNOWNCODE');
    });

    test('reapplying does not accumulate', () {
      final m = manifest([
        {'code': 'zzz', 'name': 'Z'}
      ]);
      DictionaryRegistry.applyManifest(m);
      final n = DictionaryRegistry.all.length;
      DictionaryRegistry.applyManifest(m);
      expect(DictionaryRegistry.all.length, n);
    });
  });

  group('DictionaryManifest.load', () {
    String body(String code, {int schema = 1}) =>
        jsonEncode(manifest([
          {'code': code, 'name': 'N $code'}
        ], schema: schema));

    test('fetches, applies and caches', () async {
      await DictionaryManifest.load(
          client: MockClient((_) async => http.Response(body('net1'), 200)));
      expect(DictionaryRegistry.byCode('net1'), isNotNull);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('dictionary_manifest_v1'), contains('net1'));
    });

    test('offline: falls back to the cached manifest', () async {
      await DictionaryManifest.load(
          client: MockClient((_) async => http.Response(body('cached1'), 200)));
      DictionaryRegistry.reset();
      await DictionaryManifest.load(
          client: MockClient((_) async => throw Exception('offline')));
      expect(DictionaryRegistry.byCode('cached1'), isNotNull);
    });

    test('offline with no cache: built-in list, no throw', () async {
      await DictionaryManifest.load(
          client: MockClient((_) async => throw Exception('offline')));
      expect(DictionaryRegistry.byCode('mw'), isNotNull);
    });

    test('404 (manifest not published yet) keeps built-in list', () async {
      await DictionaryManifest.load(
          client: MockClient((_) async => http.Response('nf', 404)));
      expect(DictionaryRegistry.all.length,
          DictionaryRegistry.builtIn.length);
    });

    test('invalid JSON and newer schema are ignored and not cached', () async {
      await DictionaryManifest.load(
          client: MockClient((_) async => http.Response('{not json', 200)));
      await DictionaryManifest.load(
          client: MockClient(
              (_) async => http.Response(body('future', schema: 99), 200)));
      expect(DictionaryRegistry.byCode('future'), isNull);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('dictionary_manifest_v1'), isNull);
    });

    test('slow network times out and keeps working', () async {
      await DictionaryManifest.load(
          timeout: const Duration(milliseconds: 50),
          client: MockClient((_) async {
            await Future.delayed(const Duration(seconds: 2));
            return http.Response(body('slow'), 200);
          }));
      expect(DictionaryRegistry.byCode('slow'), isNull);
      expect(DictionaryRegistry.byCode('mw'), isNotNull);
    });
  });
}
