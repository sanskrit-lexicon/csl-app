import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:cologne_sanskrit_lexicon/core/ls_service.dart';
import 'package:archive/archive.dart';
import 'package:path/path.dart' as path;

const _zipBasePath = '../csl-lslink/zip';

Future<Database> _openDbFromZip(String dbName, String zipFileName) async {
  final zipPath = path.join(_zipBasePath, zipFileName);
  final zipFile = File(zipPath);

  if (!zipFile.existsSync()) {
    fail('Zip file not found: $zipPath');
  }

  final bytes = zipFile.readAsBytesSync();
  final archive = ZipDecoder().decodeBytes(bytes);

  final dbFileName = dbName;
  final archiveFile = archive.files.firstWhere(
    (f) => f.name.endsWith('.sqlite'),
    orElse: () => throw Exception('No sqlite file found in $zipFileName'),
  );

  final tempDir = Directory.systemTemp.createTempSync('csl_test_');
  final dbPath = path.join(tempDir.path, dbFileName);

  final outputFile = File(dbPath);
  outputFile.writeAsBytesSync(archiveFile.content as List<int>);

  return databaseFactoryFfi.openDatabase(dbPath);
}

String? parseLsTag(String lsTag) {
  final match = RegExp(r'<ls(?:\s+n="([^"]*)")?>(.*?)</ls>').firstMatch(lsTag);
  if (match == null) return null;
  final nAttr = match.group(1);
  final content = match.group(2);
  if (nAttr != null && nAttr.isNotEmpty) {
    return '$nAttr$content';
  }
  return content;
}

void main() {
  setUpAll(() {
    sqfliteFfiInit();
  });

  test('LS URL generation - test against SQLite database', () async {
    final db =
        await _openDbFromZip('pwg_lslinks.sqlite', 'pwg_lslinks.sqlite.zip');

    final result = await db.rawQuery('SELECT key, data FROM keydoc_glob1');
    await db.close();

    int matched = 0;
    int mismatched = 0;
    int noPattern = 0;
    int total = result.length;

    final mismatches = <Map<String, String>>[];
    final noPatternSamples = <Map<String, String>>[];

    for (final row in result) {
      final lsTag = row['key'] as String;
      final expectedUrl = row['data'] as String;

      final match =
          RegExp(r'<ls(?:\s+n="([^"]*)")?>(.*?)</ls>').firstMatch(lsTag);
      if (match == null) {
        noPattern++;
        continue;
      }
      final nAttr = match.group(1);
      final lsContent = match.group(2) ?? '';
      final content =
          (nAttr != null && nAttr.isNotEmpty) ? '$nAttr$lsContent' : lsContent;

      final key = LsService.extractFirstKey(content);
      final generatedUrl =
          LsService.generateHref('pwg', key ?? '', nAttr, lsContent);

      if (generatedUrl == null) {
        noPattern++;
        if (noPatternSamples.length < 15) {
          noPatternSamples.add({
            'ls_tag': lsTag,
            'content': content,
            'expected': expectedUrl,
          });
        }
      } else if (generatedUrl == expectedUrl) {
        matched++;
      } else {
        mismatched++;
        if (mismatches.length < 15) {
          mismatches.add({
            'ls_tag': lsTag,
            'content': content,
            'expected': expectedUrl,
            'generated': generatedUrl,
          });
        }
      }
    }

    print('\n========== STATISTICS (PWG Dictionary) ==========');
    print('Total tested: $total');
    print(
        'Matched: $matched (${total > 0 ? (matched / total * 100).toStringAsFixed(2) : "0.00"}%)');
    print(
        'Mismatched: $mismatched (${total > 0 ? (mismatched / total * 100).toStringAsFixed(2) : "0.00"}%)');
    print(
        'No pattern found: $noPattern (${total > 0 ? (noPattern / total * 100).toStringAsFixed(2) : "0.00"}%)');
    print('');
    print('========== SAMPLE MISMATCHES ==========');
    for (final m in mismatches) {
      print('LS Tag: ${m['ls_tag']}');
      print('  Content: ${m['content']}');
      print('  Expected: ${m['expected']}');
      print('  Generated: ${m['generated']}');
      print('');
    }
    print('');
    print('========== SAMPLES WITH NO PATTERN ==========');
    for (final m in noPatternSamples) {
      print('LS Tag: ${m['ls_tag']}');
      print('  Content: ${m['content']}');
      print('  Expected: ${m['expected']}');
      print('');
    }

    expect(matched + noPattern, total);
    expect(mismatched, 0);
    expect(noPattern, 0);
  });
}
