import 'package:flutter_test/flutter_test.dart';
import 'package:cologne_sanskrit_lexicon/rendering/basic_adjust.dart';

void main() {
  group('BasicAdjust Tests', () {
    group('General Adjustments', () {
      test('replaces broken bar with space', () {
        const input = 'word1¦word2';
        final result = BasicAdjust.adjust(xmlData: input, dictCode: 'mw');
        expect(result, 'word1 word2');
      });

      test('converts [Page X] to pb tags', () {
        const input = 'text [Page 123] more text';
        final result = BasicAdjust.adjust(xmlData: input, dictCode: 'mw');
        expect(result, 'text <pb>Page 123</pb> more text');
      });

      test('converts pc Page tags', () {
        const input = '<pc>Page 456</pc>';
        final result = BasicAdjust.adjust(xmlData: input, dictCode: 'mw');
        expect(result, '<pc>456</pc>');
      });
    });

    group('MW-specific Adjustments', () {
      test('converts lang tags to ab tags', () {
        const input = '<lang n="greek">text</lang>';
        final result = BasicAdjust.adjust(xmlData: input, dictCode: 'mw');
        expect(result, '<ab n="greek">text</ab>');
      });

      test('converts s1 tags to ab tags', () {
        const input = '<s1 n="X">Y</s1>';
        final result = BasicAdjust.adjust(xmlData: input, dictCode: 'mw');
        expect(result, '<ab n="X">Y</ab>');
      });

      test('adds pref tags to page numbers', () {
        const input = '<ab>p.</ab> 1234';
        final result = BasicAdjust.adjust(xmlData: input, dictCode: 'mw');
        expect(result, '<ab>p.</ab> <pref>1234</pref>');
      });

      test('addscref tags to column numbers', () {
        const input = '<ab>col.</ab> 1';
        final result = BasicAdjust.adjust(xmlData: input, dictCode: 'mw');
        expect(result, '<ab>col.</ab> <cref>1</cref>');
      });

      test('bolds abbreviations after div vp', () {
        const input = '<div n="vp"/><ab>some</ab>';
        final result = BasicAdjust.adjust(xmlData: input, dictCode: 'mw');
        expect(result, contains('<b>'));
      });
    });

    group('PW Family Adjustments', () {
      test('pw converts lang tags to ab tags', () {
        const input = '<lang n="greek">text</lang>';
        final result = BasicAdjust.adjust(xmlData: input, dictCode: 'pw');
        expect(result, '<ab n="greek">text</ab>');
      });

      test('pwg converts lang tags to ab tags', () {
        const input = '<lang n="greek">text</lang>';
        final result = BasicAdjust.adjust(xmlData: input, dictCode: 'pwg');
        expect(result, '<ab n="greek">text</ab>');
      });

      test('pwkvn converts lang tags to ab tags', () {
        const input = '<lang n="greek">text</lang>';
        final result = BasicAdjust.adjust(xmlData: input, dictCode: 'pwkvn');
        expect(result, '<ab n="greek">text</ab>');
      });

      test('pw adds supplement info', () {
        const input = '<info n="sup_test"/>';
        final result = BasicAdjust.adjust(xmlData: input, dictCode: 'pw');
        expect(result, contains('supplement'));
      });
    });

    group('GRA, MD, AP Adjustments', () {
      test('gra converts per tags to ab tags', () {
        const input = '<per>text</per>';
        final result = BasicAdjust.adjust(xmlData: input, dictCode: 'gra');
        expect(result, '<ab>text</ab>');
      });

      test('gra converts lang tags to ab tags', () {
        const input = '<lang n="greek">text</lang>';
        final result = BasicAdjust.adjust(xmlData: input, dictCode: 'gra');
        expect(result, '<ab n="greek">text</ab>');
      });

      test('gra converts cl tags to ab tags', () {
        const input = '<cl>text</cl>';
        final result = BasicAdjust.adjust(xmlData: input, dictCode: 'gra');
        expect(result, '<ab>text</ab>');
      });

      test('md applies same adjustments as gra', () {
        const input = '<per>text</per>';
        final result = BasicAdjust.adjust(xmlData: input, dictCode: 'md');
        expect(result, '<ab>text</ab>');
      });

      test('ap applies same adjustments as gra', () {
        const input = '<per>text</per>';
        final result = BasicAdjust.adjust(xmlData: input, dictCode: 'ap');
        expect(result, '<ab>text</ab>');
      });
    });

    group('BHS Adjustments', () {
      test('converts lex tags to ab tags', () {
        const input = '<lex>m.</lex>';
        final result = BasicAdjust.adjust(xmlData: input, dictCode: 'bhs');
        expect(result, '<ab>m.</ab>');
      });

      test('converts lex tags with attributes', () {
        const input = '<lex n="T">m.</lex>';
        final result = BasicAdjust.adjust(xmlData: input, dictCode: 'bhs');
        expect(result, '<ab n="T">m.</ab>');
      });

      test('converts lang tags to ab tags', () {
        const input = '<lang>Greek</lang>';
        final result = BasicAdjust.adjust(xmlData: input, dictCode: 'bhs');
        expect(result, '<ab>Greek</ab>');
      });

      test('converts ed tags to ab tags', () {
        const input = '<ed>ed.</ed>';
        final result = BasicAdjust.adjust(xmlData: input, dictCode: 'bhs');
        expect(result, '<ab>ed.</ab>');
      });

      test('converts ms tags to ab tags', () {
        const input = '<ms>ms.</ms>';
        final result = BasicAdjust.adjust(xmlData: input, dictCode: 'bhs');
        expect(result, '<ab>ms.</ab>');
      });
    });

    group('AP90 Adjustments', () {
      test('removes hyphen followed by lb', () {
        const input = 'word-<lb/>';
        final result = BasicAdjust.adjust(xmlData: input, dictCode: 'ap90');
        expect(result, 'word');
      });

      test('removes hyphen between s and lb s', () {
        const input = '-</s> <lb/><s>word';
        final result = BasicAdjust.adjust(xmlData: input, dictCode: 'ap90');
        expect(result, 'word');
      });

      test('removes lb tags', () {
        const input = 'word<lb/>word';
        final result = BasicAdjust.adjust(xmlData: input, dictCode: 'ap90');
        expect(result, 'wordword');
      });
    });

    group('BEN Adjustments', () {
      test('converts double dash to em-dash', () {
        const input = 'word--word';
        final result = BasicAdjust.adjust(xmlData: input, dictCode: 'ben');
        expect(result, 'word—word');
      });

      test('converts g tags to lang', () {
        const input = '<g></g>';
        final result = BasicAdjust.adjust(xmlData: input, dictCode: 'ben');
        expect(result, '<lang n="greek"></lang>');
      });

      test('converts P tag to div', () {
        const input = '<P/>';
        final result = BasicAdjust.adjust(xmlData: input, dictCode: 'ben');
        expect(result, '<div n="P"/>');
      });
    });

    group('ACC Adjustments', () {
      test('adds superscript to caret patterns', () {
        const input = '^a ^b ^c';
        final result = BasicAdjust.adjust(xmlData: input, dictCode: 'acc');
        expect(result, contains('<sup>'));
        expect(result, contains('a</sup>'));
      });

      test('converts double dash to em-dash', () {
        const input = 'word--word';
        final result = BasicAdjust.adjust(xmlData: input, dictCode: 'acc');
        expect(result, 'word—word');
      });

      test('removes hyphen br combination', () {
        const input = 'word- <br/>';
        final result = BasicAdjust.adjust(xmlData: input, dictCode: 'acc');
        expect(result, 'word');
      });

      test('replaces br with space', () {
        const input = 'word<br/>word';
        final result = BasicAdjust.adjust(xmlData: input, dictCode: 'acc');
        expect(result, 'word word');
      });
    });

    group('SHS Adjustments', () {
      test('removes hyphen lb combination', () {
        const input = 'word- <lb/>';
        final result = BasicAdjust.adjust(xmlData: input, dictCode: 'shs');
        expect(result, 'word');
      });

      test('replaces lb with space', () {
        const input = 'word<lb/>word';
        final result = BasicAdjust.adjust(xmlData: input, dictCode: 'shs');
        expect(result, 'word word');
      });

      test('converts double dash to em-dash', () {
        const input = 'word--word';
        final result = BasicAdjust.adjust(xmlData: input, dictCode: 'shs');
        expect(result, 'word—word');
      });
    });

    group('YAT Adjustments', () {
      test('removes hyphen br combination', () {
        const input = 'word- <br/>';
        final result = BasicAdjust.adjust(xmlData: input, dictCode: 'yat');
        expect(result, 'word');
      });

      test('replaces br with space', () {
        const input = 'word<br/>word';
        final result = BasicAdjust.adjust(xmlData: input, dictCode: 'yat');
        expect(result, 'word word');
      });

      test('converts double dash to em-dash', () {
        const input = 'word--word';
        final result = BasicAdjust.adjust(xmlData: input, dictCode: 'yat');
        expect(result, 'word—word');
      });
    });

    group('BOR Adjustments', () {
      test('adds space before closing div', () {
        const input = '<div>text</div>';
        final result = BasicAdjust.adjust(xmlData: input, dictCode: 'bor');
        expect(result, contains('</div>'));
      });

      test('bolds first word in div n=1', () {
        const input = '<div n="1">text';
        final result = BasicAdjust.adjust(xmlData: input, dictCode: 'bor');
        expect(result, contains('<b>'));
      });

      test('bolds first word in div n=I', () {
        const input = '<div n="I">text';
        final result = BasicAdjust.adjust(xmlData: input, dictCode: 'bor');
        expect(result, contains('<b>'));
      });
    });

    group('Non-supported Dictionaries', () {
      test('ap90 returns input for unknown dictionary', () {
        const input = '<s>test</s>';
        final result = BasicAdjust.adjust(xmlData: input, dictCode: 'unknown');
        expect(result, input);
      });
    });
  });
}
