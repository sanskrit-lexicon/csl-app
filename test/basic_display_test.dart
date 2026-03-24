import 'package:flutter_test/flutter_test.dart';
import 'package:cologne_sanskrit_lexicon/rendering/basic_display.dart';

void main() {
  group('BasicDisplay Tests', () {
    group('Element Transformations', () {
      test('removes hom tags', () {
        const input = '<hom>1</hom><body>text</body>';
        final result = BasicDisplay.processHtml(
          html: input,
          dictCode: 'mw',
        );
        expect(result, isNot(contains('<hom>')));
      });

      test('transforms s tags to span with sanskrit class', () {
        const input = '<s>agni</s>';
        final result = BasicDisplay.processHtml(
          html: input,
          dictCode: 'mw',
        );
        expect(result, contains('class="sanskrit"'));
        expect(result, contains('agni'));
      });

      test('transforms SA tags to span with sanskrit class', () {
        const input = '<SA>agni</SA>';
        final result = BasicDisplay.processHtml(
          html: input,
          dictCode: 'mw',
        );
        expect(result, contains('class="sanskrit"'));
      });

      test('transforms F tags to small footnote', () {
        const input = '<F>Footnote text</F>';
        final result = BasicDisplay.processHtml(
          html: input,
          dictCode: 'mw',
        );
        expect(result, contains('footnote'));
        expect(result, contains('Footnote text'));
      });

      test('transforms sup tags', () {
        const input = '<sup>1</sup>';
        final result = BasicDisplay.processHtml(
          html: input,
          dictCode: 'mw',
        );
        expect(result, contains('<sup>'));
      });

      test('transforms alt tags', () {
        const input = '<alt>alternate</alt>';
        final result = BasicDisplay.processHtml(
          html: input,
          dictCode: 'mw',
        );
        expect(result, contains('class="alt"'));
        expect(result, contains('alternate'));
      });

      test('transforms C tags', () {
        const input = '<C n="1">text</C>';
        final result = BasicDisplay.processHtml(
          html: input,
          dictCode: 'mw',
        );
        expect(result, contains('<strong>'));
        expect(result, contains('(C1)'));
      });
    });

    group('LS Elements', () {
      test('transforms ls with n attribute', () {
        const input = '<ls n="wg,502">text</ls>';
        final result = BasicDisplay.processHtml(
          html: input,
          dictCode: 'mw',
        );
        expect(result, contains('class="ls"'));
        expect(result, contains('title="wg,502"'));
      });

      test('transforms self-closing ls', () {
        const input = '<ls n="wg,502"/>';
        final result = BasicDisplay.processHtml(
          html: input,
          dictCode: 'mw',
        );
        expect(result, contains('[ref]'));
      });

      test('transforms ls without n attribute', () {
        const input = '<ls>RV. 1.1</ls>';
        final result = BasicDisplay.processHtml(
          html: input,
          dictCode: 'mw',
        );
        expect(result, contains('class="ls"'));
      });
    });

    group('Page Break Handling', () {
      test('MW hides pb elements', () {
        const input = '<pb>Page 123</pb>';
        final result = BasicDisplay.processHtml(
          html: input,
          dictCode: 'mw',
        );
        expect(result, isNot(contains('Page 123')));
      });

      test('BUR hides pb elements', () {
        const input = '<pb>Page 123</pb>';
        final result = BasicDisplay.processHtml(
          html: input,
          dictCode: 'bur',
        );
        expect(result, isNot(contains('Page 123')));
      });

      test('STC hides pb elements', () {
        const input = '<pb>Page 123</pb>';
        final result = BasicDisplay.processHtml(
          html: input,
          dictCode: 'stc',
        );
        expect(result, isNot(contains('Page 123')));
      });

      test('PWG hides pb elements', () {
        const input = '<pb>Page 123</pb>';
        final result = BasicDisplay.processHtml(
          html: input,
          dictCode: 'pwg',
        );
        expect(result, isNot(contains('Page 123')));
      });

      test('GRA shows pb elements', () {
        const input = '<pb>Page 123</pb>';
        final result = BasicDisplay.processHtml(
          html: input,
          dictCode: 'gra',
        );
        expect(result, contains('page-break'));
      });
    });

    group('Line Break Handling', () {
      test('ap90 replaces lb with space', () {
        const input = 'word<lb/>word';
        final result = BasicDisplay.processHtml(
          html: input,
          dictCode: 'ap90',
        );
        expect(result, contains('word word'));
      });

      test('shs replaces lb with space', () {
        const input = 'word<lb/>word';
        final result = BasicDisplay.processHtml(
          html: input,
          dictCode: 'shs',
        );
        expect(result, contains('word word'));
      });

      test('yat replaces lb with space', () {
        const input = 'word<lb/>word';
        final result = BasicDisplay.processHtml(
          html: input,
          dictCode: 'yat',
        );
        expect(result, contains('word word'));
      });

      test('default uses br for lb', () {
        const input = 'word<lb/>word';
        final result = BasicDisplay.processHtml(
          html: input,
          dictCode: 'mw',
        );
        expect(result, contains('<br>'));
      });
    });

    group('Div Indentation', () {
      test('GRA H indent', () {
        const input = '<div n="H">text</div>';
        final result = BasicDisplay.processHtml(
          html: input,
          dictCode: 'gra',
        );
        expect(result, contains('padding-left:1.0em'));
      });

      test('GRA P indent', () {
        const input = '<div n="P">text</div>';
        final result = BasicDisplay.processHtml(
          html: input,
          dictCode: 'gra',
        );
        expect(result, contains('padding-left:2.0em'));
      });

      test('GRA P1 indent', () {
        const input = '<div n="P1">text</div>';
        final result = BasicDisplay.processHtml(
          html: input,
          dictCode: 'gra',
        );
        expect(result, contains('padding-left:3.0em'));
      });

      test('BUR n=2 indent', () {
        const input = '<div n="2">text</div>';
        final result = BasicDisplay.processHtml(
          html: input,
          dictCode: 'bur',
        );
        expect(result, contains('padding-left:1.0em'));
      });

      test('BUR n=3 indent', () {
        const input = '<div n="3">text</div>';
        final result = BasicDisplay.processHtml(
          html: input,
          dictCode: 'bur',
        );
        expect(result, contains('padding-left:2.0em'));
      });

      test('STC P indent', () {
        const input = '<div n="P">text</div>';
        final result = BasicDisplay.processHtml(
          html: input,
          dictCode: 'stc',
        );
        expect(result, contains('padding-left:1.5em'));
      });

      test('PWG n=1 indent', () {
        const input = '<div n="1">text</div>';
        final result = BasicDisplay.processHtml(
          html: input,
          dictCode: 'pwg',
        );
        expect(result, contains('padding-left:1.0em'));
      });

      test('PW n=1 indent', () {
        const input = '<div n="1">text</div>';
        final result = BasicDisplay.processHtml(
          html: input,
          dictCode: 'pw',
        );
        expect(result, contains('padding-left:1.5em'));
      });

      test('AP n=2 indent', () {
        const input = '<div n="2">text</div>';
        final result = BasicDisplay.processHtml(
          html: input,
          dictCode: 'ap',
        );
        expect(result, contains('padding-left:1.0em'));
      });

      test('WIL n=2 indent', () {
        const input = '<div n="2">text</div>';
        final result = BasicDisplay.processHtml(
          html: input,
          dictCode: 'wil',
        );
        expect(result, contains('padding-left:1.5em'));
      });

      test('PE P uses br', () {
        const input = '<div n="P">text</div>';
        final result = BasicDisplay.processHtml(
          html: input,
          dictCode: 'pe',
        );
        expect(result, contains('<br>'));
      });

      test('ACC n=2 indent', () {
        const input = '<div n="2">text</div>';
        final result = BasicDisplay.processHtml(
          html: input,
          dictCode: 'acc',
        );
        expect(result, contains('padding-left:1.5em'));
      });
    });

    group('Bio Elements', () {
      test('transforms bot tags', () {
        const input = '<bot n="taxon">植物</bot>';
        final result = BasicDisplay.processHtml(
          html: input,
          dictCode: 'mw',
        );
        expect(result, contains('class="bio"'));
        expect(result, contains('title="taxon"'));
      });

      test('transforms self-closing bot tags', () {
        const input = '<bot n="taxon"/>';
        final result = BasicDisplay.processHtml(
          html: input,
          dictCode: 'mw',
        );
        expect(result, contains('[taxon]'));
      });

      test('transforms zoo tags', () {
        const input = '<zoo n="animal">text</zoo>';
        final result = BasicDisplay.processHtml(
          html: input,
          dictCode: 'mw',
        );
        expect(result, contains('class="bio"'));
      });
    });

    group('Abbreviation Handling', () {
      test('applies abbreviation cache', () {
        const input = '<ab>m.</ab>';
        final result = BasicDisplay.processHtml(
          html: input,
          dictCode: 'mw',
          abbreviationCache: {'m.': 'masculine'},
        );
        expect(result, contains('title="masculine"'));
      });

      test('keeps abbreviation without expansion', () {
        const input = '<ab>unk.</ab>';
        final result = BasicDisplay.processHtml(
          html: input,
          dictCode: 'mw',
          abbreviationCache: {},
        );
        expect(result, contains('unk.'));
      });
    });

    group('Highlighting', () {
      test('applies highlighting when enabled', () {
        const input = 'some text with keyword';
        final result = BasicDisplay.processHtml(
          html: input,
          dictCode: 'mw',
          highlightTerm: 'keyword',
          highlightEnabled: true,
        );
        expect(result, contains('<mark>'));
      });

      test('skips highlighting when disabled', () {
        const input = 'some text with keyword';
        final result = BasicDisplay.processHtml(
          html: input,
          dictCode: 'mw',
          highlightTerm: 'keyword',
          highlightEnabled: false,
        );
        expect(result, isNot(contains('<mark>')));
      });

      test('skips highlighting when term is empty', () {
        const input = 'some text';
        final result = BasicDisplay.processHtml(
          html: input,
          dictCode: 'mw',
          highlightTerm: '',
          highlightEnabled: true,
        );
        expect(result, isNot(contains('<mark>')));
      });
    });

    group('Image Handling', () {
      test('transforms pic tags', () {
        const input = '<pic name="image.png"/>';
        final result = BasicDisplay.processHtml(
          html: input,
          dictCode: 'mw',
        );
        expect(result, contains('src="images/image.png"'));
      });
    });

    group('HR Handling', () {
      test('transforms hr tags', () {
        const input = '<hr/>';
        final result = BasicDisplay.processHtml(
          html: input,
          dictCode: 'mw',
        );
        expect(result, contains('<hr>'));
      });
    });

    group('Empty Tag Cleanup', () {
      test('removes empty divs', () {
        const input = '<div></div>text';
        final result = BasicDisplay.processHtml(
          html: input,
          dictCode: 'mw',
        );
        expect(result, isNot(contains('<div></div>')));
      });
    });
  });
}
