import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:cologne_sanskrit_lexicon/core/ls_patterns.dart';
import 'package:cologne_sanskrit_lexicon/core/ls_service.dart';

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
    final db = await databaseFactoryFfi
        .openDatabase('/tmp/pwg_lslinks_db/sqlite/pwg_lslinks.sqlite');

    final result =
        await db.rawQuery('SELECT key, data FROM keydoc_glob1 LIMIT 50000');
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

      final content = parseLsTag(lsTag);
      if (content == null) {
        noPattern++;
        continue;
      }

      final key = LsService.extractFirstKey(content);
      var generatedUrl =
          LsService.generateHref('pwg', key ?? '', null, content);

      // Debug AV patterns
      if (content.startsWith('AV. 12') && generatedUrl == null) {
        print('DEBUG AV: key="$key", content="$content"');
        var patterns = LsPatterns.getPatternsForDict('pwg');
        print('DEBUG AV: found ${patterns.length} pwg patterns');

        // Test the AV regex manually
        var regex = RegExp(r'^(AV[.]) *([0-9]+), *([0-9]+), *([0-9]+)');
        var match = regex.firstMatch(content);
        print('DEBUG AV: regex match = $match');
      }

      if (generatedUrl == null) {
        noPattern++;
        // Debug some no-pattern cases
        if (noPatternSamples.length < 3 &&
            (content.startsWith('AV.') || content.startsWith('ṚV.'))) {
          print(
              'DEBUG NO PATTERN: content="$content", expected="$expectedUrl"');
        }
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
        // Debug Ramayana
        if (content.startsWith('R. ') && mismatches.length < 5) {
          print(
              'DEBUG RAMAYANA: key=$key, content=$content, generated=$generatedUrl, expected=$expectedUrl');
        }
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

    // Assert near 100% match rate
    final matchRate = total > 0 ? matched / total * 100 : 0.0;
    expect(matchRate, greaterThan(99.0),
        reason:
            'Expected >99% match rate but got ${matchRate.toStringAsFixed(2)}%');
  });
}
