import 'package:flutter_test/flutter_test.dart';
import 'package:sanskrit_lexicon/rendering/entry_parser.dart';

void main() {
  group('EntryParser Tests', () {
    test('parse correctly extracts fields from valid XML entry', () {
      const xml = '<H1><h><key1>aMSa</key1><key2>a/MSa</key2></h>'
          '<body><b>áṃśa,</b> <i><ab>m.</ab></i> portion, part.'
          '[<b>√1aś,</b> <ls n="wg,502">502.</ls>]</body>'
          '<tail><L>3</L><pc>111-a</pc></tail>'
          '</H1>';
      final entry = EntryParser.parse(xml, 3.0);
      expect(entry.key1Slp1, 'aMSa');
      expect(entry.key2Slp1, 'a/MSa');
      expect(entry.lnum, 3);
      expect(entry.pageCol, '111-a');
      expect(entry.bodyHtml.contains('portion, part'), true);
    });

    test('extractAbbreviations gets all ab tag contents from body html', () {
      const body = '<b>áṃśa,</b> <i><ab>m.</ab></i> portion, part. <ab>abl.</ab>';
      final abbrs = EntryParser.extractAbbreviations(body);
      expect(abbrs.length, 2);
      expect(abbrs.contains('m.'), true);
      expect(abbrs.contains('abl.'), true);
    });
  });
}
