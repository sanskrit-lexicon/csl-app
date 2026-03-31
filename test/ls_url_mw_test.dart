import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:cologne_sanskrit_lexicon/core/ls_service.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
  });

  test('LS URL generation - MW dictionary full test', () async {
    final db = await databaseFactoryFfi
        .openDatabase('/tmp/mw_lslinks_db/sqlite/mw_lslinks.sqlite');

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
          LsService.generateHref('mw', key ?? '', nAttr, lsContent);

      if (generatedUrl == null) {
        noPattern++;
        if (noPatternSamples.length < 30) {
          noPatternSamples.add({
            'ls_tag': lsTag,
            'content': content,
            'expected': expectedUrl,
            'generated': generatedUrl ?? 'NULL',
          });
        }
      } else if (generatedUrl == expectedUrl) {
        matched++;
      } else {
        mismatched++;
        if (mismatches.length < 20) {
          mismatches.add({
            'ls_tag': lsTag,
            'content': content,
            'expected': expectedUrl,
            'generated': generatedUrl,
          });
        }
      }
    }

    print('\n========== STATISTICS (MW Dictionary) ==========');
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

    print(
        'Matched + No Pattern: ${matched + noPattern} (${total - mismatched})');
    print('');
    print(
        'NOTE: MW dictionary has ${mismatched} mismatches and ${noPattern} no-pattern cases.');
    print('This is expected as MW uses different conventions.');

    expect(matched + noPattern + mismatched, total);
    expect(mismatched <= 1, true);
    expect(noPattern = 0, true);
  });
}
