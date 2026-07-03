import 'package:flutter_test/flutter_test.dart';
import 'package:cologne_sanskrit_lexicon/core/ls_service.dart';

// PWG cites Benfey's Sanskrit Chrestomathie as "Chr. page,line" and (uppercase)
// "BENF. Chr. page,line". The bchrest2 scan viewer keys on the printed page
// (?ipage, 1-372), so the first number is the page — matching how the app
// already maps `Chr.` for the `pw` dictionary.
void main() {
  test('PWG Chr. -> bchrest2 page viewer (first number = page)', () {
    final url = LsService.generateHref('pwg', 'Chr.', 'Chr.', '197,4');
    expect(url,
        'https://sanskrit-lexicon-scans.github.io/bchrest2/index.html?197');
  });

  test('PWG BENF. Chr. -> bchrest2 page viewer', () {
    final url = LsService.generateHref('pwg', 'BENF.', 'BENF. Chr.', '185,10');
    expect(url,
        'https://sanskrit-lexicon-scans.github.io/bchrest2/index.html?185');
  });
}
