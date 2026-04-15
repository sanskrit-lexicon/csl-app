/// BasicAdjust: XML Pre-Processing Module
///
/// This module handles pre-processing of dictionary XML data before rendering.
/// It applies various transformations based on dictionary-specific rules.
///
/// Enable/disable via AppSettings.enableBasicAdjust
class BasicAdjust {
  /// Apply XML pre-processing adjustments to the raw XML data.
  ///
  /// Parameters:
  /// - xmlData: The raw XML data string from the database
  /// - dictCode: The dictionary code (e.g., 'mw', 'pwg', 'pw')
  /// - accent: Whether accent marks should be shown
  /// - outputTranslit: Output transliteration scheme
  ///
  /// Returns the adjusted XML string.
  static String adjust({
    required String xmlData,
    required String dictCode,
    bool accent = false,
    String outputTranslit = 'devanagari',
  }) {
    String xml = xmlData;

    // General transformations (apply to all dictionaries)
    xml = _generalAdjustments(xml);

    // Dictionary-specific adjustments
    xml = _dictionarySpecificAdjustments(xml, dictCode);

    return xml;
  }

  /// General adjustments that apply to all dictionaries
  static String _generalAdjustments(String xml) {
    // Replace broken bar (¦) with space
    xml = xml.replaceAll('¦', ' ');

    // Convert [Page X] to <pb>X</pb>
    xml = xml.replaceAllMapped(
      RegExp(r'\[(Page.*?)\]'),
      (m) => '<pb>${m.group(1)}</pb>',
    );

    // Convert <pc>Page...<pc> to <pc>...<pc>
    xml = xml.replaceAllMapped(
      RegExp(r'<pc>Page(.*?)</pc>'),
      (m) => '<pc>${m.group(1)?.trim()}</pc>',
    );

    // Handle <s> tags - convert SLP1 content
    xml = _processSTags(xml);

    // Handle <key2> tags
    xml = _processKey2Tags(xml);

    return xml;
  }

  /// Dictionary-specific adjustments
  static String _dictionarySpecificAdjustments(String xml, String dictCode) {
    final dict = dictCode.toLowerCase();

    // mw-specific adjustments
    if (dict == 'mw') {
      xml = _adjustMw(xml);
    }
    // pw, pwg, pwkvn adjustments
    else if (['pw', 'pwg', 'pwkvn'].contains(dict)) {
      xml = _adjustPwFamily(xml, dict);
    }
    // gra, md, ap adjustments
    else if (['gra', 'md', 'ap'].contains(dict)) {
      xml = _adjustGraMdAp(xml);
    }
    // bhs adjustments
    else if (dict == 'bhs') {
      xml = _adjustBhs(xml);
    }
    // ap90 adjustments
    else if (dict == 'ap90') {
      xml = _adjustAp90(xml);
    }
    // ben adjustments
    else if (dict == 'ben') {
      xml = _adjustBen(xml);
    }
    // acc adjustments
    else if (dict == 'acc') {
      xml = _adjustAcc(xml);
    }
    // shs adjustments
    else if (dict == 'shs') {
      xml = _adjustShs(xml);
    }
    // yat adjustments
    else if (dict == 'yat') {
      xml = _adjustYat(xml);
    }
    // bor adjustments
    else if (dict == 'bor') {
      xml = _adjustBor(xml);
    }
    // abch, acph, acsj adjustments (add line breaks after certain tags)
    else if (['abch', 'acph', 'acsj'].contains(dict)) {
      xml = _adjustAbchFamily(xml, dict);
    }

    return xml;
  }

  /// MW-specific adjustments
  static String _adjustMw(String xml) {
    // Convert <lang ...> to <ab ...> for better display
    xml = xml.replaceAllMapped(
      RegExp(r'<lang(.*?)>(.*?)</lang>', dotAll: true),
      (m) => '<ab${m.group(1)}>${m.group(2)}</ab>',
    );

    // Convert <s1 n="X">Y</s1> to <ab n="X">Y</ab> for tooltip
    xml = xml.replaceAllMapped(
      RegExp(r'<s1( n=".*?")>(.*?)</s1>', dotAll: true),
      (m) => '<ab${m.group(1)}>${m.group(2)}</ab>',
    );

    // Page number linking: "<ab>p.</ab> 1234" -> "<ab>p.</ab> <pref>1234</pref>"
    xml = xml.replaceAllMapped(
      RegExp(r'<ab>p\.</ab> ([0-9]+)'),
      (m) => '<ab>p.</ab> <pref>${m.group(1)}</pref>',
    );

    // Column reference: "<ab>col.</ab> 1" -> "<ab>col.</ab> <cref>page 1</cref>"
    // Note: This requires pagecol context, simplified here
    xml = xml.replaceAllMapped(
      RegExp(r'<ab>col\.</ab> ([1-3]+)'),
      (m) => '<ab>col.</ab> <cref>${m.group(1)}</cref>',
    );

    // Bold abbreviations following <div n="vp"/>
    xml = xml.replaceAllMapped(
      RegExp(r'(<div n="vp"/> *)(<ab.*?</ab>)', dotAll: true),
      (m) => '${m.group(1)}<b>${m.group(2)}</b>',
    );

    return xml;
  }

  /// PW family (pw, pwg, pwkvn) adjustments
  static String _adjustPwFamily(String xml, String dict) {
    // Convert <lang ...> to <ab ...>
    xml = xml.replaceAllMapped(
      RegExp(r'<lang(.*?)>(.*?)</lang>', dotAll: true),
      (m) => '<ab${m.group(1)}>${m.group(2)}</ab>',
    );

    // Supplement note for entries merged into pw
    xml = xml.replaceAllMapped(
      RegExp(r'<info n="sup_(.*?)"/>'),
      (m) => '<info n="sup"><ab>supplement</ab></info>',
    );

    return xml;
  }

  /// GRA, MD, AP adjustments
  static String _adjustGraMdAp(String xml) {
    // Convert <per> to <ab>
    xml = xml.replaceAllMapped(
      RegExp(r'<per(.*?)>(.*?)</per>', dotAll: true),
      (m) => '<ab${m.group(1)}>${m.group(2)}</ab>',
    );

    // Convert <lang> to <ab>
    xml = xml.replaceAllMapped(
      RegExp(r'<lang(.*?)>(.*?)</lang>', dotAll: true),
      (m) => '<ab${m.group(1)}>${m.group(2)}</ab>',
    );

    // Convert <cl> to <ab>
    xml = xml.replaceAllMapped(
      RegExp(r'<cl(.*?)>(.*?)</cl>', dotAll: true),
      (m) => '<ab${m.group(1)}>${m.group(2)}</ab>',
    );

    return xml;
  }

  /// BHS adjustments
  static String _adjustBhs(String xml) {
    // Convert <lex> to <ab>
    xml = xml.replaceAll('<lex>', '<ab>');
    xml = xml.replaceAll(RegExp(r'<lex '), '<ab ');
    xml = xml.replaceAll('</lex>', '</ab>');

    // Convert <lang> to <ab>
    xml = xml.replaceAll('<lang>', '<ab>');
    xml = xml.replaceAll(RegExp(r'<lang '), '<ab ');
    xml = xml.replaceAll('</lang>', '</ab>');

    // Convert <ed> to <ab>
    xml = xml.replaceAll('<ed>', '<ab>');
    xml = xml.replaceAll(RegExp(r'<ed '), '<ab ');
    xml = xml.replaceAll('</ed>', '</ab>');

    // Convert <ms> to <ab>
    xml = xml.replaceAll('<ms>', '<ab>');
    xml = xml.replaceAll(RegExp(r'<ms '), '<ab ');
    xml = xml.replaceAll('</ms>', '</ab>');

    return xml;
  }

  /// AP90 adjustments - hyphenation handling
  static String _adjustAp90(String xml) {
    // Remove hyphen followed by <lb/>
    xml = xml.replaceAll(RegExp(r'- *<lb/>'), '');

    // Remove hyphen between </s> and <lb/><s>
    xml = xml.replaceAll(RegExp(r'-</s> <lb/><s>'), '');

    // Remove <lb/> tags entirely
    xml = xml.replaceAll('<lb/>', '');

    return xml;
  }

  /// BEN adjustments
  static String _adjustBen(String xml) {
    // Em-dash handling
    xml = xml.replaceAll('--', '—');

    // Greek handling
    xml = xml.replaceAll('<g></g>', '<lang n="greek"></lang>');

    // P div handling
    xml = xml.replaceAll('<P/>', '<div n="P"/>');

    return xml;
  }

  /// ACC adjustments
  static String _adjustAcc(String xml) {
    // Superscript letters
    xml = xml.replaceAllMapped(
      RegExp(r'\^([a-d02th]+)'),
      (m) => '<sup>${m.group(1)}</sup>',
    );

    // Em-dash
    xml = xml.replaceAll('--', '—');

    // Remove breaks
    xml = xml.replaceAll(RegExp(r'- <br/>'), '');
    xml = xml.replaceAll('<br/>', ' ');

    return xml;
  }

  /// SHS adjustments
  static String _adjustShs(String xml) {
    // Remove hyphen + lb
    xml = xml.replaceAll(RegExp(r'- <lb/>'), '');

    // Replace lb with space
    xml = xml.replaceAll('<lb/>', ' ');

    // Em-dash
    xml = xml.replaceAll('--', '—');

    return xml;
  }

  /// YAT adjustments
  static String _adjustYat(String xml) {
    // Remove hyphen + br
    xml = xml.replaceAll(RegExp(r'- <br/>'), '');

    // Replace br with space
    xml = xml.replaceAll('<br/>', ' ');

    // Em-dash
    xml = xml.replaceAll('--', '—');

    return xml;
  }

  /// BOR adjustments
  static String _adjustBor(String xml) {
    // Add space before closing div
    xml = xml.replaceAll('</div>', ' </div>');

    // Bold first word in div n="1" or div n="I"
    xml = xml.replaceAllMapped(
      RegExp(r'<div n="([1I])">([^ ]*)'),
      (m) => '<div n="${m.group(1)}"><b>${m.group(2)}</b>',
    );

    return xml;
  }

  /// Process <s> tags - transliterate SLP1 content within
  static String _processSTags(String xml) {
    // This is a placeholder - actual transliteration happens in rendering
    // The BasicAdjust module just marks tags for processing
    return xml;
  }

  /// Process key2 tags
  static String _processKey2Tags(String xml) {
    // Key2 tags are typically processed during rendering
    return xml;
  }

  /// ABCH/ACPH/ACSJ-specific adjustments - add line breaks after certain tags
  static String _adjustAbchFamily(String xml, String dictCode) {
    // Add visual line breaks after </eid> and </s> tags
    xml = xml.replaceAll('</eid>', '</eid><br>');
    xml = xml.replaceAll('</s>', '</s><br>');

    return xml;
  }
}
