import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:cologne_sanskrit_lexicon/core/ls_service.dart';
import 'test_helpers.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
  });

  test('LS URL generation - GRA dictionary full test', () async {
    final db =
        await openDbFromZip('gra_lslinks.sqlite', 'gra_lslinks.sqlite.zip');

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

      String? nAttr;
      String? content;
      String? key;

      final lsMatch =
          RegExp(r'<ls(?:\s+n="([^"]*)")?>(.*?)</ls>').firstMatch(lsTag);
      if (lsMatch != null) {
        nAttr = lsMatch.group(1);
        content = lsMatch.group(2)!;
        key = nAttr ?? LsService.extractFirstKey(content);
      } else if (lsTag.trim().startsWith('{') && lsTag.trim().endsWith('}')) {
        content = lsTag;
        key = '{'; // Dummy key for braced refs
      }

      if (key == null || content == null) {
        noPattern++;
        if (noPatternSamples.length < 50) {
          noPatternSamples
              .add({'tag': lsTag, 'content': lsTag, 'expected': expectedUrl});
        }
        continue;
      }

      final generatedUrl = LsService.generateHref('gra', key, nAttr, content);

      if (generatedUrl == null) {
        noPattern++;
        if (noPatternSamples.length < 50) {
          noPatternSamples
              .add({'tag': lsTag, 'content': content, 'expected': expectedUrl});
        }
      } else if (generatedUrl != expectedUrl) {
        mismatched++;
        if (mismatches.length < 50) {
          mismatches.add({
            'tag': lsTag,
            'content': content,
            'expected': expectedUrl,
            'generated': generatedUrl
          });
        }
      } else {
        matched++;
      }
    }

    print('\n========== STATISTICS (GRA Dictionary) ==========');
    print('Total tested: $total');
    print('Matched: $matched (${(matched / total * 100).toStringAsFixed(2)}%)');
    print(
        'Mismatched: $mismatched (${(mismatched / total * 100).toStringAsFixed(2)}%)');
    print(
        'No pattern found: $noPattern (${(noPattern / total * 100).toStringAsFixed(2)}%)');

    if (mismatches.isNotEmpty) {
      print('\n========== SAMPLE MISMATCHES ==========');
      for (final m in mismatches) {
        print('LS Tag: ${m['tag']}');
        print('  Content: ${m['content']}');
        print('  Expected: ${m['expected']}');
        print('  Generated: ${m['generated']}');
        print('');
      }
    }

    if (noPatternSamples.isNotEmpty) {
      print('\n========== SAMPLES WITH NO PATTERN ==========');
      for (final s in noPatternSamples) {
        print('LS Tag: ${s['tag']}');
        print('  Content: ${s['content']}');
        print('  Expected: ${s['expected']}');
        print('');
      }
    }

    expect(mismatched + noPattern, 0,
        reason: 'Some URLs were not generated correctly');
  });
}
