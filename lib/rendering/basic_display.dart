/// BasicDisplay: XML to HTML Rendering Module
///
/// This module handles the transformation of XML elements to HTML for display.
/// It applies dictionary-specific styling and element handling.
///
/// Enable/disable via AppSettings.enableBasicDisplay
class BasicDisplay {
  /// Process the HTML body with XML element transformations.
  ///
  /// Parameters:
  /// - html: The HTML string after BasicAdjust processing
  /// - dictCode: The dictionary code (e.g., 'mw', 'pwg', 'pw')
  /// - outputTranslit: Output transliteration scheme
  /// - abbreviationCache: Map of abbreviation to expansion
  /// - highlightTerm: Optional term to highlight
  /// - highlightEnabled: Whether highlighting is enabled
  /// - lsHrefs: Optional map of LS reference keys to external URLs
  ///
  /// Returns the processed HTML string ready for Flutter rendering.
  static String processHtml({
    required String html,
    required String dictCode,
    String outputTranslit = 'devanagari',
    Map<String, String> abbreviationCache = const {},
    String? highlightTerm,
    bool highlightEnabled = false,
    Map<String, String> lsHrefs = const {},
  }) {
    String result = html;

    // Apply element transformations
    result = _transformElements(result, dictCode, outputTranslit);

    // Apply abbreviations
    result = _applyAbbreviations(result, abbreviationCache);

    // Apply LS hrefs
    result = _applyLsHrefs(result, lsHrefs);

    // Apply highlighting
    if (highlightEnabled && highlightTerm != null && highlightTerm.isNotEmpty) {
      result = _applyHighlighting(result, highlightTerm);
    }

    return result;
  }

  /// Transform XML elements to HTML
  static String _transformElements(
      String html, String dictCode, String outputTranslit) {
    String result = html;

    // Remove homonym tags (shown separately in headword)
    result = result.replaceAll(RegExp(r'<hom>.*?</hom>', dotAll: true), '');

    // Note: <s> and <SA> tags are NOT transformed here.
    // They are handled by the original rendering code in entry_renderer.dart
    // which performs transliteration.

    // Transform <ls> (literary source)
    result = _transformLsElements(result);

    // Transform <F> (footnote)
    result = result.replaceAllMapped(
      RegExp(r'<F>(.*?)</F>', dotAll: true),
      (m) => '<small class="footnote">${m.group(1)}</small>',
    );

    // Transform <sup> (superscript)
    result = result.replaceAllMapped(
      RegExp(r'<sup>(.*?)</sup>', dotAll: true),
      (m) => '<sup>${m.group(1)}</sup>',
    );

    // Transform <pb> (page break) - dictionary specific
    result = _transformPageBreak(result, dictCode);

    // Transform <lb> (line break) - dictionary specific
    result = _transformLineBreak(result, dictCode);

    // Transform <div> with indentation - dictionary specific
    result = _transformDivElements(result, dictCode);

    // Transform <alt> (alternate headword)
    result = result.replaceAllMapped(
      RegExp(r'<alt>(.*?)</alt>', dotAll: true),
      (m) => '<span class="alt">(${m.group(1)})</span>',
    );

    // Transform <C n="X"> (commentary marker)
    result = result.replaceAllMapped(
      RegExp(r'<C n="(.*?)">(.*?)</C>', dotAll: true),
      (m) => '<strong>(C${m.group(1)})</strong>',
    );

    // Transform <bot> and <zoo> (scientific names)
    result = _transformBioElements(result);

    // Transform language elements (<lang n="X">)
    result = _transformLangElements(result, dictCode);

    // Transform <pic> (images)
    result = result.replaceAllMapped(
      RegExp(r'<pic name="(.*?)"/>'),
      (m) => '<img src="images/${m.group(1)}" />',
    );

    // Transform <table>, <tr>, <td>, <th>
    result = _transformTableElements(result);

    // Transform <hr>
    result = result.replaceAll('<hr/>', '<hr>');

    // Remove empty tags
    result = _cleanEmptyTags(result);

    return result;
  }

  /// Transform ls elements (literary source references)
  static String _transformLsElements(String html) {
    // <ls n="...">text</ls>
    html = html.replaceAllMapped(
      RegExp(r'<ls\s+n="([^"]*)">(.*?)</ls>', dotAll: true),
      (m) => '<span class="ls" title="${m.group(1)}">${m.group(2)}</span>',
    );

    // Self-closing <ls n="..."/>
    html = html.replaceAllMapped(
      RegExp(r'<ls\s+n="([^"]*?)"\s*/>'),
      (m) => '<span class="ls" title="${m.group(1)}">[ref]</span>',
    );

    // <ls>text</ls> without n attribute - use text as title
    html = html.replaceAllMapped(
      RegExp(r'<ls>(.*?)</ls>', dotAll: true),
      (m) {
        final text = m.group(1) ?? '';
        return '<span class="ls" title="$text">$text</span>';
      },
    );

    return html;
  }

  /// Apply LS hrefs to elements that have matching keys
  static String _applyLsHrefs(String html, Map<String, String> lsHrefs) {
    if (lsHrefs.isEmpty) return html;

    // Transform <span class="ls" title="key">...</span> to include href if available
    html = html.replaceAllMapped(
      RegExp(r'<span class="ls" title="([^"]*)">(.*?)</span>', dotAll: true),
      (m) {
        final key = m.group(1) ?? '';
        final text = m.group(2) ?? '';
        final href = lsHrefs[key];

        if (href != null && href.isNotEmpty) {
          return '<a href="$href"><span class="ls" title="$key">$text</span></a>';
        }
        return '<span class="ls" title="$key">$text</span>';
      },
    );

    return html;
  }

  /// Transform pb (page break) - dictionary specific handling
  static String _transformPageBreak(String html, String dictCode) {
    final dict = dictCode.toLowerCase();

    // Dictionaries that hide pb elements
    final hidePb = ['mw', 'bur', 'stc', 'pwg'].contains(dict);

    if (hidePb) {
      // Remove pb tags entirely
      return html.replaceAll(RegExp(r'<pb>.*?</pb>', dotAll: true), '');
    }

    // Other dictionaries: show as small grey text
    return html.replaceAllMapped(
      RegExp(r'<pb>(.*?)</pb>', dotAll: true),
      (m) => '<small class="page-break">${m.group(1)}</small>',
    );
  }

  /// Transform lb (line break) - dictionary specific
  static String _transformLineBreak(String html, String dictCode) {
    final dict = dictCode.toLowerCase();

    // Some dictionaries handle lb differently
    if (['ap90', 'shs', 'yat', 'bor'].contains(dict)) {
      // Replace with space
      return html.replaceAll('<lb/>', ' ');
    }

    // Default: use <br>
    return html.replaceAll('<lb/>', '<br>');
  }

  /// Transform <div> elements with dictionary-specific indentation
  static String _transformDivElements(String html, String dictCode) {
    final dict = dictCode.toLowerCase();

    // GRA dictionary indentation
    if (dict == 'gra') {
      html = html.replaceAllMapped(
        RegExp(r'<div n="H">'),
        (m) => '<div style="padding-left:1.0em;">',
      );
      html = html.replaceAllMapped(
        RegExp(r'<div n="P">'),
        (m) => '<div style="padding-left:2.0em;">',
      );
      html = html.replaceAllMapped(
        RegExp(r'<div n="P1">'),
        (m) => '<div style="padding-left:3.0em;">',
      );
    }
    // BUR dictionary
    else if (dict == 'bur') {
      html = html.replaceAllMapped(
        RegExp(r'<div n="2">'),
        (m) => '<div style="padding-left:1.0em;">',
      );
      html = html.replaceAllMapped(
        RegExp(r'<div n="3">'),
        (m) => '<div style="padding-left:2.0em;">',
      );
    }
    // STC dictionary
    else if (dict == 'stc') {
      html = html.replaceAllMapped(
        RegExp(r'<div n="P">'),
        (m) => '<div style="padding-left:1.5em;">',
      );
    }
    // PWG dictionary
    else if (dict == 'pwg') {
      html = html.replaceAllMapped(
        RegExp(r'<div n="1">'),
        (m) => '<div style="padding-left:1.0em;">',
      );
      html = html.replaceAllMapped(
        RegExp(r'<div n="2">'),
        (m) => '<div style="padding-left:2.0em;">',
      );
      html = html.replaceAllMapped(
        RegExp(r'<div n="3">'),
        (m) => '<div style="padding-left:3.0em;">',
      );
    }
    // PW dictionary
    else if (dict == 'pw') {
      html = html.replaceAllMapped(
        RegExp(r'<div n="1">'),
        (m) => '<div style="padding-left:1.5em;">',
      );
      html = html.replaceAllMapped(
        RegExp(r'<div n="2">'),
        (m) => '<div style="padding-left:3.0em;">',
      );
      html = html.replaceAllMapped(
        RegExp(r'<div n="3">'),
        (m) => '<div style="padding-left:4.5em;">',
      );
    }
    // AP dictionary
    else if (dict == 'ap') {
      html = html.replaceAllMapped(
        RegExp(r'<div n="2">'),
        (m) => '<div style="padding-left:1.0em;">',
      );
      html = html.replaceAllMapped(
        RegExp(r'<div n="3">'),
        (m) => '<div style="padding-left:2.0em;">',
      );
    }
    // WIL, SHS dictionaries
    else if (['wil', 'shs'].contains(dict)) {
      html = html.replaceAllMapped(
        RegExp(r'<div n="2">'),
        (m) => '<div style="padding-left:1.5em;">',
      );
    }
    // GST, IEG, INM, MCI dictionaries
    else if (['gst', 'ieg', 'inm', 'mci'].contains(dict)) {
      html = html.replaceAllMapped(
        RegExp(r'<div n="P">'),
        (m) => '<div style="padding-left:1.0em;">',
      );
    }
    // BEN, PUI dictionaries
    else if (['ben', 'pui'].contains(dict)) {
      html = html.replaceAllMapped(
        RegExp(r'<div n="P">'),
        (m) => '<div style="padding-left:1.0em;">',
      );
    }
    // SKD, KRM dictionaries
    else if (['skd', 'krm'].contains(dict)) {
      html = html.replaceAllMapped(
        RegExp(r'<div n="F">'),
        (m) => '<div class="footnote" style="padding-left:1.0em;">',
      );
    }
    // PE, PGN dictionaries
    else if (['pe', 'pgn'].contains(dict)) {
      html = html.replaceAllMapped(
        RegExp(r'<div n="P">'),
        (m) => '<br>&nbsp;&nbsp;&nbsp;',
      );
      html = html.replaceAllMapped(
        RegExp(r'<div n="NI">'),
        (m) => '<br><br>',
      );
      html = html.replaceAllMapped(
        RegExp(r'<div n="lb">'),
        (m) => '<br>',
      );
    }
    // ACC dictionary
    else if (dict == 'acc') {
      html = html.replaceAllMapped(
        RegExp(r'<div n="2">|<div n="P">'),
        (m) => '<div style="padding-left:1.5em;">',
      );
    }
    // BOR dictionary - preserve I, 1, etc. with margin, make xe/xs inline
    else if (dict == 'bor') {
      html = html.replaceAllMapped(
        RegExp(r'<div n="I">'),
        (m) => '<div style="margin-top:0.6em;">',
      );
      html = html.replaceAllMapped(
        RegExp(r'<div n="1">|<div n="2">|<div n="3">|<div n="4">'),
        (m) => '<div style="margin-top:0.6em;">',
      );
      html = html.replaceAllMapped(
        RegExp(r'<div n="xe">(.*?)</div>', dotAll: true),
        (m) => '<span>${m.group(1)}</span>',
      );
      html = html.replaceAllMapped(
        RegExp(r'<div n="xs">(.*?)</div>', dotAll: true),
        (m) => '<span>${m.group(1)}</span>',
      );
      html = html.replaceAllMapped(
        RegExp(r'([^- \t\r\n])(\s*)<div n="lb"/>'),
        (m) => '${m.group(1)} ',
      );
      html = html.replaceAllMapped(
        RegExp(r'-(\s*)<div n="lb"/>'),
        (m) => '-',
      );
      html = html.replaceAll('<div n="lb"/>', '');
    }
    // Default: simple div
    else {
      html = html.replaceAllMapped(
        RegExp(r'<div[^>]*>'),
        (m) => '<div style="margin-top:0.6em;">',
      );
    }

    return html;
  }

  /// Transform bot and zoo elements (scientific names)
  static String _transformBioElements(String html) {
    // <bot n="tooltip">name</bot>
    html = html.replaceAllMapped(
      RegExp(r'<bot n="([^"]*)">(.*?)</bot>', dotAll: true),
      (m) =>
          '<span class="bio" title="${m.group(1)}" style="color:brown;">${m.group(2)}</span>',
    );
    // Self-closing <bot/>
    html = html.replaceAllMapped(
      RegExp(r'<bot n="([^"]*)"/>'),
      (m) =>
          '<span class="bio" title="${m.group(1)}" style="color:brown;">[${m.group(1)}]</span>',
    );

    // Same for <zoo>
    html = html.replaceAllMapped(
      RegExp(r'<zoo n="([^"]*)">(.*?)</zoo>', dotAll: true),
      (m) =>
          '<span class="bio" title="${m.group(1)}" style="color:brown;">${m.group(2)}</span>',
    );
    html = html.replaceAllMapped(
      RegExp(r'<zoo n="([^"]*)"/>'),
      (m) =>
          '<span class="bio" title="${m.group(1)}" style="color:brown;">[${m.group(1)}]</span>',
    );

    return html;
  }

  /// Transform language elements
  static String _transformLangElements(String html, String dictCode) {
    final dict = dictCode.toLowerCase();

    // Dictionaries where Greek is provided as Unicode - no change needed
    final noChangeDicts = [
      'pwg',
      'pw',
      'wil',
      'md',
      'yat',
      'mw72',
      'snp',
      'stc',
      'gra',
      'lan',
      'inm',
      'bur',
      'bop',
      'ben',
      'sch'
    ];

    if (noChangeDicts.contains(dict)) {
      return html;
    }

    // For other dictionaries, wrap in span with language info
    html = html.replaceAllMapped(
      RegExp(r'<lang n="([^"]*)">(.*?)</lang>', dotAll: true),
      (m) => '<span class="lang" title="${m.group(1)}">${m.group(2)}</span>',
    );

    return html;
  }

  /// Transform table elements
  static String _transformTableElements(String html) {
    // Preserve table structure with attributes
    // This is a simplified version - full implementation would preserve all attributes
    return html;
  }

  /// Apply abbreviation expansions from cache
  static String _applyAbbreviations(
      String html, Map<String, String> abbreviationCache) {
    if (abbreviationCache.isEmpty) {
      return html;
    }

    return html.replaceAllMapped(
      RegExp(r'<ab>(.*?)</ab>', dotAll: true),
      (m) {
        final abbr = m.group(1)?.trim() ?? '';
        final expansion = abbreviationCache[abbr];
        if (expansion != null) {
          return '<abbr title="$expansion">$abbr</abbr>';
        }
        return abbr;
      },
    );
  }

  /// Apply highlighting to search term
  static String _applyHighlighting(String html, String term) {
    if (term.isEmpty) return html;

    final escaped = RegExp.escape(term);
    // Avoid highlighting inside HTML tags
    html = html.replaceAllMapped(
      RegExp('(?![^<]*>)($escaped)', caseSensitive: false),
      (m) => '<mark>${m.group(1)}</mark>',
    );

    return html;
  }

  /// Clean up empty tags
  static String _cleanEmptyTags(String html) {
    // Remove empty <div></div>
    html = html.replaceAll(RegExp(r'<div[^>]*>\s*</div>'), '');

    // Remove empty <span></span> (but keep ones with classes)
    html = html.replaceAllMapped(
      RegExp(r'<span(?![^>]*class)[^>]*>\s*</span>'),
      (m) => '',
    );

    return html;
  }
}
