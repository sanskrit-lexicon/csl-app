import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:cologne_sanskrit_lexicon/core/ls_service.dart';
import 'test_helpers.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
  });

  test('LS URL generation - AP90 dictionary full test', () async {
    final db =
        await openDbFromZip('ap90_lslinks.sqlite', 'ap90_lslinks.sqlite.zip');

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

      final key = LsService.extractFirstKey((nAttr != null && nAttr.isNotEmpty) ? '$nAttr$lsContent' : lsContent);
      final generatedUrl =
          LsService.generateHref('ap90', key ?? '', nAttr, lsContent);

      if (generatedUrl == null) {
        noPattern++;
        if (noPatternSamples.length < 30) {
          noPatternSamples.add({
            'ls_tag': lsTag,
            'expected': expectedUrl,
          });
        }
      } else if (generatedUrl == expectedUrl) {
        matched++;
      } else {
        mismatched++;
        if (mismatches.length < 20) {
          mismatches.add({
            'ls_tag': lsTag,
            'expected': expectedUrl,
            'generated': generatedUrl,
          });
        }
      }
    }

    print('\n========== STATISTICS (AP90 Dictionary) ==========');
    print('Total tested: $total');
    print(
        'Matched: $matched (${total > 0 ? (matched / total * 100).toStringAsFixed(2) : "0.00"}%)');
    print(
        'Mismatched: $mismatched (${total > 0 ? (mismatched / total * 100).toStringAsFixed(2) : "0.00"}%)');
    print(
        'No pattern found: $noPattern (${total > 0 ? (noPattern / total * 100).toStringAsFixed(2) : "0.00"}%)');
    print('');

    if (mismatches.isNotEmpty) {
      print('========== SAMPLE MISMATCHES ==========');
      for (final m in mismatches) {
        print('LS Tag: ${m['ls_tag']}');
        print('  Expected: ${m['expected']}');
        print('  Generated: ${m['generated']}');
        print('');
      }
    }

    if (noPatternSamples.isNotEmpty) {
      print('========== SAMPLES WITH NO PATTERN ==========');
      for (final m in noPatternSamples) {
        print('LS Tag: ${m['ls_tag']}');
        print('  Expected: ${m['expected']}');
        print('');
      }
    }

    expect(mismatched, 0, reason: 'There should be no mismatches');
    expect(noPattern, 0, reason: 'All patterns should be matched');
  });
}
