import 'package:indic_transliteration_dart/transliterate.dart' as indic;
import 'package:indic_transliteration_dart/indic_transliteration_dart.dart' as indic_pkg;

/// Wrapper around indic_transliteration_dart for the app's transliteration needs.
class TransliterationService {
  /// Initializes the underlying indic_transliteration_dart schemes.
  /// Must be called once before any transliteration happens.
  static void init() {
    indic_pkg.initializeSchemes();
  }

  /// All supported scheme codes from indic_transliteration_dart.
  static const List<String> availableSchemes = [
    'slp1',
    'hk',
    'itrans',
    'iast',
    'kolkata',
    'velthuis',
    'wx',
    'optitrans',
    'devanagari',
    'bengali',
    'gujarati',
    'gurmukhi',
    'kannada',
    'malayalam',
    'oriya',
    'telugu',
    'tamil',
  ];

  /// Human-readable display names for the settings UI.
  static const Map<String, String> schemeDisplayNames = {
    'slp1': 'SLP1',
    'hk': 'Harvard-Kyoto (HK)',
    'itrans': 'ITRANS',
    'iast': 'IAST (Roman)',
    'kolkata': 'Kolkata (RAS)',
    'velthuis': 'Velthuis',
    'wx': 'WX',
    'optitrans': 'Optitrans',
    'devanagari': 'Devanagari (देवनागरी)',
    'bengali': 'Bengali (বাংলা)',
    'gujarati': 'Gujarati (ગુજરાતી)',
    'gurmukhi': 'Gurmukhi (ਗੁਰਮੁਖੀ)',
    'kannada': 'Kannada (ಕನ್ನಡ)',
    'malayalam': 'Malayalam (മലയാളം)',
    'oriya': 'Odia (ଓଡ଼ିଆ)',
    'telugu': 'Telugu (తెలుగు)',
    'tamil': 'Tamil (தமிழ்)',
  };

  /// Transliterate [text] from [fromScheme] to [toScheme].
  /// Returns original text on error or unknown scheme.
  static String transliterate(String text, String fromScheme, String toScheme) {
    if (text.isEmpty) return text;
    if (fromScheme == toScheme) return text;
    try {
      return indic.transliterate(text, fromScheme: fromScheme, toScheme: toScheme);
    } catch (_) {
      return text;
    }
  }

  /// Convenience: input text (any scheme) → SLP1 for DB queries.
  static String toSlp1(String text, String fromScheme) =>
      transliterate(text, fromScheme, 'slp1');

  /// Convenience: SLP1 DB text → display scheme.
  static String fromSlp1(String text, String toScheme, {bool useAccented = false, String? dictCode}) {
    String out = transliterate(text, useAccented ? 'slp1_accented' : 'slp1', toScheme);
    
    // Fallback: if accents are requested for Devanagari but ASCII markers remained, 
    // manually replace them with Vedic Unicode characters.
    if (useAccented && toScheme == 'devanagari') {
      out = out
          .replaceAll('\\', '॒') // Anudatta
          .replaceAll('^', '᳙');  // Svarita (Yajurvedic)
      // Note: '/' is usually correctly handled by slp1_accented to ꣡ or ॑

      // Dictionary-specific PW/PWG overrides to match printed book style
      final d = dictCode?.toLowerCase();
      if (d == 'pw' || d == 'pwg') {
        out = out
            .replaceAll('\uA8E1', '\uA8EB') // ꣡ -> ꣫ (Digit 3)
            .replaceAll('\u1CD9', '\u0951'); // ᳙ -> ॑ (Uvarita/Vertical Svarita)
      }
    }
    return out;
  }




  /// Strip SLP1 accent markers.
  /// In key2, '/' appears before an accented vowel (Vedic pitch accent).
  /// Strip them when accent display is off, or when building LIKE queries.
  static String stripSLP1Accents(String slp1Text) =>
      slp1Text.replaceAll('/', '').replaceAll('\\', '');

  /// Display name for a scheme code.
  static String displayName(String scheme) =>
      schemeDisplayNames[scheme] ?? scheme.toUpperCase();
}
