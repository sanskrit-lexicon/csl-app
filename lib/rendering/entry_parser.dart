/// Structured representation of a parsed dictionary entry.
class ParsedEntry {
  final String key1Slp1; // from <key1> — headword in SLP1
  final String? key2Slp1; // from <key2> — with accent markers
  final int? homonym; // from <hom>
  final String bodyHtml; // innerHTML of <body>
  final String? pageCol; // from <pc>  e.g. "111-a"
  final double lnum; // entry serial number

  const ParsedEntry({
    required this.key1Slp1,
    this.key2Slp1,
    this.homonym,
    required this.bodyHtml,
    this.pageCol,
    required this.lnum,
  });
}

/// Parses the XML-like `data` field from a dictionary SQLite row.
///
/// The data format is custom XML-like markup (not always valid XML), so
/// we use regex-based extraction rather than a strict XML parser.
class EntryParser {
  static final _key1Re = RegExp(r'<key1>(.*?)</key1>', dotAll: true);
  static final _key2Re = RegExp(r'<key2>(.*?)</key2>', dotAll: true);
  static final _homRe = RegExp(r'<hom>(\d+)</hom>');
  static final _bodyRe = RegExp(r'<body>(.*?)</body>', dotAll: true);
  static final _pcRe = RegExp(r'<pc>(.*?)</pc>', dotAll: true);
  static final _abRe = RegExp(r'<ab>(.*?)</ab>', dotAll: true);

  /// Parse the raw data string from SQLite into a [ParsedEntry].
  static ParsedEntry parse(String xmlData, double lnum) {
    final key1 = _key1Re.firstMatch(xmlData)?.group(1)?.trim() ?? '';
    final key2 = _key2Re.firstMatch(xmlData)?.group(1)?.trim();
    final homStr = _homRe.firstMatch(xmlData)?.group(1);
    final hom = homStr != null ? int.tryParse(homStr) : null;
    final body = _bodyRe.firstMatch(xmlData)?.group(1)?.trim() ?? xmlData;
    final pc = _pcRe.firstMatch(xmlData)?.group(1)?.trim();

    return ParsedEntry(
      key1Slp1: key1,
      key2Slp1: key2,
      homonym: hom,
      bodyHtml: body,
      pageCol: pc,
      lnum: lnum,
    );
  }

  /// Extract all abbreviation texts from body HTML for pre-fetching.
  static List<String> extractAbbreviations(String bodyHtml) {
    return _abRe
        .allMatches(bodyHtml)
        .map((m) => m.group(1)?.trim() ?? '')
        .where((s) => s.isNotEmpty)
        .toSet()
        .toList();
  }

  /// Convert the body HTML to a form suitable for flutter_widget_from_html.
  ///
  /// Transformations applied:
  ///   `<ab>text</ab>`     → `<abbr title="expansion">text</abbr>`  (expansion from cache)
  ///   `<s>slp1</s>`       → `<span class="sa">transliterated</span>`
  ///   `<SA>slp1</SA>`     → `<span class="sa">transliterated</span>`
  ///   `<ls n="...">t</ls>`→ `<span class="ls">t</span>`
  ///   `<ls n="..."/>`     → `<span class="ls">[ref]</span>`
  ///   `<F>...</F>`        → `<small>...</small>`
  ///   `<hom>n</hom>`      → removed (shown in headword)
  static String processBodyHtml({
    required String bodyHtml,
    required String outputTranslit,
    required Map<String, String> abbreviationCache,
    required String? highlightTerm,
    required bool highlightEnabled,
  }) {
    String html = bodyHtml;

    // Remove <hom> tags (shown separately in headword)
    html = html.replaceAll(RegExp(r'<hom>.*?</hom>', dotAll: true), '');

    // Replace <s>slp1text</s> and <SA>slp1text</SA> with transliterated spans
    html = html.replaceAllMapped(
      RegExp(r'<(?:s|SA)>(.*?)</(?:s|SA)>', dotAll: true),
      (m) {
        final slp1 = m.group(1) ?? '';
        final out = _transliterateSlp1(slp1, outputTranslit);
        return '<span class="sa">$out</span>';
      },
    );

    // Replace <ab>text</ab> with expansion tooltip
    html = html.replaceAllMapped(
      _abRe,
      (m) {
        final abbr = m.group(1)?.trim() ?? '';
        final expansion = abbreviationCache[abbr] ?? abbr;
        return '<abbr title="$expansion"><i>$abbr</i></abbr>';
      },
    );

    // Replace <ls n="ref">text</ls> with styled reference
    html = html.replaceAllMapped(
      RegExp(r'<ls\s+n="([^"]*)">(.*?)</ls>', dotAll: true),
      (m) {
        final text = m.group(2) ?? '';
        return '<span class="ls">$text</span>';
      },
    );
    // Self-closing <ls n="..."/>
    html = html.replaceAllMapped(
      RegExp(r'<ls\s+n="([^"]*)"\s*/>'),
      (m) => '<span class="ls">[${m.group(1) ?? ''}]</span>',
    );

    // Replace <F>...</F> (footnotes) with small text
    html = html.replaceAllMapped(
      RegExp(r'<F>(.*?)</F>', dotAll: true),
      (m) => '<small>${m.group(1)}</small>',
    );

    // Highlight search term in body text (not inside tags)
    if (highlightEnabled && highlightTerm != null && highlightTerm.isNotEmpty) {
      // Escape for regex
      final escaped = RegExp.escape(highlightTerm);
      html = html.replaceAllMapped(
        RegExp('(?![^<]*>)($escaped)', caseSensitive: false),
        (m) => '<mark>${m.group(1)}</mark>',
      );
    }

    return html;
  }

  static String _transliterateSlp1(String slp1, String outputScheme) {
    // Import-free transliteration call; actual call is via TransliterationService
    // This stub is replaced by the renderer which calls TransliterationService directly.
    return slp1;
  }
}
