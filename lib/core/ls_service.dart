import 'package:flutter/foundation.dart';
import 'database_helper.dart';
import 'ls_patterns.dart';

class LsResult {
  final String? expansion;
  final String? href;
  final String? tooltip;

  LsResult({this.expansion, this.href, this.tooltip});
}

class LsService {
  static const Map<String, String> _codeToPfx = {
    'RV.': 'rv',
    'AV.': 'av',
    'Pāṇ.': 'p',
    'MBh.': 'MBH.',
    'Hariv.': 'hariv',
    'MBh. (ed. Calc.)': 'MBHC',
    'MBh. (ed. Bomb.)': 'MBHB',
    'R.': 'R',
    'R. G.': 'RG',
    'R. (G)': 'RG',
    'R. (ed. Gorr.)': 'RG',
    'R. [G]': 'RG',
    'R. ed. Gorresio': 'RG',
    'R. ed. Bomb.': 'ramayanabom',
    'R. (B.)': 'ramayanabom',
    'R. (ed. Bomb.)': 'ramayanabom',
    'R. B.': 'ramayanabom',
    'R. [B.]': 'ramayanabom',
    'R. [B]': 'ramayanabom',
    'R. ed. Bombay': 'ramayanabom',
    'Dhātup.': 'dp',
    'Dhāt.': 'dp',
    'Kathās.': 'kathas',
    'Mn.': 'M.',
    'BhP.': 'bhp',
    'Yājñ.': 'yajn',
    'Ragh.': 'ragh',
    'Sāh.': 'sahitya',
    'Vop.': 'vop',
    'Halāy.': 'halay',
    'VarBṛS.': 'brihatsam',
    'MārkP.': 'markandeyap',
    'Mārk P.': 'markandeyap',
    'H. an.': 'anekarthaS',
    'Śāk.': 'shakuntala',
    'Śak.': 'shakuntalamw',
    'Śat. Br.': 'shatapathabr',
    'ŚBr.': 'shatapathabr',
    'Sāh. D.': 'sahityadarpana',
    'Bhag.': 'bhagavadgita',
    'Pañcat.': 'pantankose',
    'VS.': 'vajasasa',
    'TS.': 'taittiriyas',
    'Ragh. ed. Calc.': 'raghuvamsacalc',
    'Raghuv.': 'raghuvamsacalc',
    'Ragh. (C)': 'raghuvamsacalc',
    'Rājat.': 'rajatar',
    'Rājat. (C)': 'rajatarcalc',
    'Bhaṭṭ.': 'bhattikavya',
    'TBr.': 'taittiriyabr',
    'KātyŚr.': 'katyasr',
    'Kāty. Śr.': 'katyasr1',
    'Kumāras.': 'kumaras',
    'Kum.': 'kumaras',
    'Mālav.': 'malavikagni',
    'Śṛṅgār.': 'srnga',
    'Śṛṅgt.': 'srnga',
    'Megh.': 'meghaduta',
    'Caurap. (A.)': 'Caurapañcāśikā',
    'Caurap.': 'Caurapañcāśikā',
    'Bhartṛ.': 'Bhartṛhariśataka',
    'Hit.': 'Hit.',
    'AK.': 'AK.',
    'Gīt.': 'Gīt.',
    'Pañcar.': 'pancar',
    'Vikr.': 'vikramor',
    'Vikram.': 'vikramor',
    'Ait. Br.': 'aitbr',
    'AitBr.': 'aitbr',
    'Nir.': 'nir',
    'Naigh.': 'naigh',
    'Nigh.': 'naigh',
    // PWG-specific uppercase abbreviations
    'H.': 'h',
    'an.': 'an',
    'MED.': 'med',
    'ŚĀK.': 'shakuntala_pwg',
    'RĀJA-TAR.': 'rajatar_pwg',
    'RĀJAT.': 'rajatar_pwg',
    'RAGH.': 'ragh_pwg',
    'RAGH. ed. ST.': 'ragh_st',
    'RAGH. ed. Calc.': 'ragh_pwg',
    'MĀRK. P.': 'markp_pwg',
    'BHAG.': 'bhag_pwg',
    'YĀJÑ.': 'yajn_pwg',
    'AIT. BR.': 'aitbr_pwg',
  };

  static const Map<String, Map<String, String>> _dictSpecificPrefixes = {
    'ap90': {
      'Rv.': 'rv',
      'Av.': 'av',
      'P.': 'p',
    },
    'sch': {
      'ṚV.': 'rv',
      'AV.': 'av',
      'P.': 'p',
      'Hariv.': 'hariv',
      'R. Gorr.': 'rgorr',
      'R.': 'ramayana',
      'Dhātup.': 'dp',
      'Spr.': 'spr',
      'Verz. d. Oxf. H.': 'verzoxf',
      'Kathās.': 'kathas',
      'M.': 'M.',
      'Bhāg. P.': 'bhagp',
      'Yājñ.': 'yajn',
      'Ragh.': 'ragh',
      'Sāh. D.': 'sahitya',
      'Vop.': 'vop',
      'Med.': 'med',
      'Trik.': 'trik',
      'Hār.': 'har',
      'Halāy.': 'halay',
      'Varāh. Bṛh. S.': 'brihatsam',
      'Mārk. P.': 'markandeyap',
      'H. an.': 'anekarthaS',
      'Śāk.': 'shakuntala',
      'Śat. Br.': 'shatapathabr',
      'Sāh. Dār.': 'sahityadarpana',
      'Bhag.': 'bhagavadgita',
      'R. ed. Bomb.': 'ramayanabom',
      'Pañcat.': 'pantankose',
      'VS.': 'vajasasa',
      'TS.': 'taittiriyas',
      'Ragh. ed. Calc.': 'raghuvamsacalc',
      'Raghuv.': 'raghuvamsacalc',
      'Rājat.': 'rajatar',
      'Bhaṭṭ.': 'bhattikavya',
      'Tbr.': 'taittiriyabr',
      'Kāty. Śr.': 'katyasr',
      'Kumāras.': 'kumaras',
      'Mālav.': 'malavikagni',
      'Megh.': 'meghaduta',
      'Śṛṅgt.': 'srnga',
      'Caurap. (A.)': 'Caurapañcāśikā',
      'MBh.': 'MBH',
      'Hit.': 'Hit.',
      'AK.': 'AK.',
      'Gīt.': 'Gīt.',
      'Pañcar.': 'pancar',
      'Vikr.': 'vikramor',
      'Vikram.': 'vikramor',
      'Ait. Br.': 'aitbr',
      'Nir.': 'nir',
      'Nigh.': 'naigh',
    },
    'pwg': {
      'P.': 'p_pwg',
      'ṚV.': 'rv_pwg',
      'AV.': 'av_pwg',
    },
  };

  static const Set<String> _authtooltipsDicts = {
    'mw',
    'ap90',
    'ben',
    'sch',
    'gra',
    'bhs',
    'ap'
  };

  static const Set<String> _bibDicts = {'pwg', 'pw', 'pwkvn'};

  // Public methods for testing
  static int romanInt(String roman) {
    final romanNums = {
      'i': 1,
      'ii': 2,
      'iii': 3,
      'iv': 4,
      'v': 5,
      'vi': 6,
      'vii': 7,
      'viii': 8,
      'ix': 9,
      'x': 10,
      'xi': 11,
      'xii': 12,
    };
    return romanNums[roman.toLowerCase()] ?? 0;
  }

  static String? extractFirstKey(String data) {
    final match = RegExp(r"^([^ .,']+\.?)").firstMatch(data);
    return match?.group(1);
  }

  static String? getPrefix(String dict, String key) {
    if (_dictSpecificPrefixes.containsKey(dict)) {
      final dictPrefixes = _dictSpecificPrefixes[dict]!;
      if (dictPrefixes.containsKey(key)) {
        return dictPrefixes[key];
      }
    }
    return _codeToPfx[key];
  }

  static String? generateHref(
      String dict, String key, String? nAttribute, String data) {
    String data1;
    if (nAttribute != null && nAttribute.isNotEmpty) {
      data1 = '$nAttribute $data';
    } else {
      data1 = data;
    }

    // First try pattern-driven approach
    final patternResult = _generateHrefFromPatterns(dict, data1);
    if (patternResult != null) {
      return patternResult;
    }

    // Fall back to old helper methods
    final pfx = getPrefix(dict, key);
    if (pfx == null) {
      return null;
    }

    if (pfx == 'rv' || pfx == 'av') {
      return hrefRvAv(pfx, data1, dict);
    } else if (pfx == 'p') {
      return hrefPanini(data1, dict);
    } else if (pfx == 'R' || pfx == 'ramayana') {
      return hrefRamayana(data1, dict);
    } else if (pfx == 'ramayanabom') {
      return hrefRamayanaBombay(data1);
    } else if (pfx == 'RG' || pfx == 'rgorr') {
      return hrefRamayanaGorresio(data1);
    } else if (pfx == 'MBH.' ||
        pfx == 'MBHC' ||
        pfx == 'MBHB' ||
        pfx == 'MBH') {
      return hrefMahabharata(data1, pfx);
    } else if (pfx == 'Pañcat.') {
      return hrefPancatantra(data1);
    } else if (pfx == 'Hariv.') {
      return hrefHarivamsa(data1);
    } else if (pfx == 'BhP.' || pfx == 'bhagp') {
      return hrefBhagavataPurana(data1);
    } else if (pfx == 'Ragh.' || pfx == 'raghuvamsacalc') {
      return hrefRaghuvamsa(data1, pfx);
    } else if (pfx == 'VS.') {
      return hrefVajasansamhita(data1);
    } else if (pfx == 'TS.') {
      return hrefTaittiriyaSamhita(data1);
    } else if (pfx == 'ŚBr.' || pfx == 'Śat. Br.' || pfx == 'shatapathabr') {
      return hrefSatapathaBrahmana(data1);
    } else if (pfx == 'Megh.') {
      return hrefMeghaduta(data1);
    } else if (pfx == 'Kum.' || pfx == 'Kumāras.' || pfx == 'kumaras') {
      return hrefKumarasambhava(data1);
    } else if (pfx == 'Mālav.') {
      return hrefMalavikagnimitra(data1);
    } else if (pfx == 'Vikr.' || pfx == 'vikramor') {
      return hrefVikramorvashiya(data1);
    } else if (pfx == 'Bhag.') {
      return hrefBhagavadGita(data1);
    } else if (pfx == 'Mn.' || pfx == 'M.') {
      return hrefManu(data1);
    } else if (pfx == 'Nir.') {
      return hrefNirukta(data1);
    } else if (pfx == 'kathas') {
      return hrefKathasaritsagara(data1);
    } else if (pfx == 'spr') {
      return hrefSpruch(data1);
    } else if (pfx == 'verzoxf') {
      return hrefVerzOxf(data1);
    } else if (pfx == 'AK.') {
      return hrefAmarakoSa(data1);
    } else if (pfx == 'h') {
      return hrefHemacandra(data1);
    } else if (pfx == 'an') {
      return hrefAnekartha(data1);
    } else if (pfx == 'med') {
      return hrefMedini(data1);
    } else if (pfx == 'shakuntala_pwg') {
      return hrefShakuntalaPwg(data1);
    } else if (pfx == 'rajatar_pwg') {
      return hrefRajatarPwg(data1);
    } else if (pfx == 'ragh_pwg' || pfx == 'ragh_st') {
      return hrefRaghPwg(data1, pfx);
    } else if (pfx == 'markp_pwg') {
      return hrefMarkandeyaPuranaPwg(data1);
    } else if (pfx == 'bhag_pwg') {
      return hrefBhagavadGitaPwg(data1);
    } else if (pfx == 'yajn_pwg') {
      return hrefYajnavalkya(data1);
    } else if (pfx == 'aitbr_pwg') {
      return hrefAitareyaBrahmana(data1);
    }

    return null;
  }

  static String? _generateHrefFromPatterns(String dict, String data1) {
    final patterns = LsPatterns.getPatternsForDict(dict);

    for (final pattern in patterns) {
      // Check if this pattern applies to this dictionary
      if (pattern.dicts != null &&
          !pattern.dicts!.contains(dict.toLowerCase())) {
        continue;
      }

      try {
        final regex = RegExp(pattern.regex);
        final match = regex.firstMatch(data1);

        if (match != null) {
          String url = pattern.urlTemplate;

          // Handle special URL generators
          if (url == 'rvAvHymnUrl') {
            final key = extractFirstKey(data1);
            final keyLower = key?.toLowerCase() ?? '';
            final pfx = (keyLower.contains('rv') && !keyLower.contains('av'))
                ? 'rv'
                : 'av';
            return hrefRvAv(pfx, data1, dict);
          } else if (url == 'rvAvHymnUrl2') {
            final key = extractFirstKey(data1);
            final keyLower = key?.toLowerCase() ?? '';
            final pfx = (keyLower.contains('rv') && !keyLower.contains('av'))
                ? 'rv'
                : 'av';
            return hrefRvAv2(pfx, data1, dict);
          } else if (url == 'ramayanaUrl') {
            return hrefRamayana(data1, dict);
          } else if (url == 'dhatuUrl') {
            return hrefDhatu(data1);
          }

          // Handle conditional expressions
          if (url.contains('(') && url.contains('?') && url.contains(':"')) {
            url = _evaluateConditional(url, match);
          } else {
            // Simple replacement with Roman numeral conversion
            for (int i = 1; i <= match.groupCount; i++) {
              var replacement = match.group(i) ?? '';
              // Check for _lc suffix (lowercase)
              var lowercase = false;
              final placeholder = r'$' + i.toString();
              final lcPlaceholder = r'$' + i.toString() + '_lc';
              if (url.contains(lcPlaceholder)) {
                lowercase = true;
                url = url.replaceAll(lcPlaceholder, placeholder);
              }
              // Convert Roman numerals to integers, but only if it's not a single lowercase letter (a-z)
              // Note: Allow uppercase Roman numerals like I, V, X to be converted
              if (replacement.length == 1 &&
                  replacement.codeUnitAt(0) >= 97 &&
                  replacement.codeUnitAt(0) <= 122) {
                // Single lowercase letter (a-z) - keep as is
              } else {
                final romanVal = romanInt(replacement);
                if (romanVal > 0) {
                  replacement = romanVal.toString();
                }
              }
              if (lowercase) {
                replacement = replacement.toLowerCase();
              }
              url = url.replaceAll(placeholder, replacement);
            }
          }

          if (url.isNotEmpty) {
            return url;
          }
        }
      } catch (e) {
        // Silently skip patterns that fail
      }
    }

    return null;
  }

  static String _evaluateConditional(String expr, RegExpMatch match) {
    try {
      final ternaryMatch = RegExp(
              r'^\(?(\$2\s*==\s*"([^"]+)"\)?)\s*\?\s*"([^"]+)"\s*:\s*"([^"]+)"$')
          .firstMatch(expr);
      if (ternaryMatch != null) {
        final varRef = ternaryMatch.group(1)!;
        final compareVal = ternaryMatch.group(2)!;
        final urlTrue = ternaryMatch.group(3)!;
        final urlFalse = ternaryMatch.group(4)!;

        final varNum = int.tryParse(
            varRef.replaceAll(r'$', '').replaceAll('==', '').trim());
        if (varNum != null && varNum <= match.groupCount) {
          final actualVal = match.group(varNum);
          final resultUrl = (actualVal == compareVal) ? urlTrue : urlFalse;
          return resultUrl.replaceAll('\$$varNum', match.group(varNum) ?? '');
        }
      }
    } catch (e) {
      // Ignore
    }
    return '';
  }

  static String? hrefRvAv2(String pfx, String data1, String dict) {
    final regex = RegExp(r'^(.*?)\. *([^ ,]+)[ ,]+([0-9]+)(.*)$');
    final match = regex.firstMatch(data1);
    if (match == null) return null;

    final mandala = match.group(2)!;
    final imandala = romanInt(mandala);
    if (imandala == 0) return null;

    final ihymn = int.parse(match.group(3)!);
    final iverse = 1;

    final hymnFilePfx =
        '${pfx == 'rv' ? 'rv' : 'av'}${imandala.toString().padLeft(2, '0')}.${ihymn.toString().padLeft(3, '0')}';
    final anchor = '$hymnFilePfx.${iverse.toString().padLeft(2, '0')}';
    final dir = 'https://sanskrit-lexicon.github.io/${pfx}links/${pfx}hymns';
    return '$dir/$hymnFilePfx.html#$anchor';
  }

  static String? hrefDhatu(String data1) {
    final regex = RegExp(r'^(.*?[.]) *([0-9]+)[ ,]+([0-9]+)');
    final match = regex.firstMatch(data1);
    if (match == null) return null;

    final section = match.group(2)!;
    if (section == '0') return null;

    final dir =
        'https://www.sanskrit-lexicon.uni-koeln.de/scans/csl-westergaard/disp/index.php';
    return '$dir?section=$section';
  }

  // Public href generators
  static String? hrefRvAv(String pfx, String data1, String dict) {
    RegExpMatch? match;

    if (dict == 'ap90') {
      final regex =
          RegExp(r'^(.*?)[.] *([0-9]+)[.] +([0-9]+)[.] +([0-9]+)(.*)$');
      match = regex.firstMatch(data1);
      if (match != null) {
        final imandala = int.parse(match.group(2)!);
        final ihymn = int.parse(match.group(3)!);
        final iverse = int.parse(match.group(4)!);

        final hymnFilePfx =
            '${pfx == 'rv' ? 'rv' : 'av'}${imandala.toString().padLeft(2, '0')}.${ihymn.toString().padLeft(3, '0')}';
        final anchor = '$hymnFilePfx.${iverse.toString().padLeft(2, '0')}';
        final dir =
            'https://sanskrit-lexicon.github.io/${pfx}links/${pfx}hymns';
        return '$dir/$hymnFilePfx.html#$anchor';
      }
    }

    final regex = RegExp(r'^(.*?)\. *([^ ,]+)[ ,]+([0-9]+)[ ,]+([0-9]+)(.*)$');
    match = regex.firstMatch(data1);

    if (match != null) {
      final mandala = match.group(2)!;
      final imandala = romanInt(mandala);
      final ihymn = int.parse(match.group(3)!);
      final iverse = int.parse(match.group(4)!);

      if (imandala > 0) {
        final hymnFilePfx =
            '${pfx == 'rv' ? 'rv' : 'av'}${imandala.toString().padLeft(2, '0')}.${ihymn.toString().padLeft(3, '0')}';
        final anchor = '$hymnFilePfx.${iverse.toString().padLeft(2, '0')}';
        final dir =
            'https://sanskrit-lexicon.github.io/${pfx}links/${pfx}hymns';
        return '$dir/$hymnFilePfx.html#$anchor';
      }
    }

    final regex2 = RegExp(r'^(.*?)\. *([^ ,]+)[ ,]+([0-9]+)(.*)$');
    match = regex2.firstMatch(data1);
    if (match != null) {
      final mandala = match.group(2)!;
      final imandala = romanInt(mandala);
      final ihymn = int.parse(match.group(3)!);

      if (imandala > 0) {
        final hymnFilePfx =
            '${pfx == 'rv' ? 'rv' : 'av'}${imandala.toString().padLeft(2, '0')}.${ihymn.toString().padLeft(3, '0')}';
        final anchor = '$hymnFilePfx.01';
        final dir =
            'https://sanskrit-lexicon.github.io/${pfx}links/${pfx}hymns';
        return '$dir/$hymnFilePfx.html#$anchor';
      }
    }

    return null;
  }

  static String? hrefPanini(String data1, String dict) {
    RegExpMatch? match;

    if (dict == 'ap90') {
      final regex =
          RegExp(r'^(.*?)[.] *([IV]+)[.] +([0-9]+)[.] +([0-9]+)(.*)$');
      match = regex.firstMatch(data1);
      if (match != null) {
        final roman = match.group(2)!;
        final romanlo = roman.toLowerCase();
        final ic = romanInt(romanlo);
        final is1 = int.parse(match.group(3)!);
        final iv = int.parse(match.group(4)!);

        if (ic > 0) {
          return 'https://ashtadhyayi.com/sutraani/$ic/$is1/$iv';
        }
      }
    }

    final regex = RegExp(r'^(.*?)\. *([iv]+)[ ,]+([0-9]+)[ ,]+([0-9]+)(.*)$');
    match = regex.firstMatch(data1);
    if (match == null) return null;

    final romanlo = match.group(2)!;
    final ic = romanInt(romanlo);
    final is1 = int.parse(match.group(3)!);
    final iv = int.parse(match.group(4)!);

    if (ic > 0) {
      return 'https://ashtadhyayi.com/sutraani/$ic/$is1/$iv';
    }
    return null;
  }

  static String? hrefRamayana(String data1, String dict) {
    final data2 = data1.replaceFirst(RegExp(r'^R\. *'), '');

    final regex = RegExp(r' *([iv]+)[ ,]+([0-9]+)[ ,]+([0-9]+)(.*)$');
    final match = regex.firstMatch(data2);
    if (match == null) return null;

    final romanlo = match.group(1)!;
    final ic = romanInt(romanlo);
    final is1 = int.parse(match.group(2)!);
    final iv = int.parse(match.group(3)!);

    String dir = 'https://sanskrit-lexicon-scans.github.io/ramayanagorr';
    if (dict == 'mw' && (ic == 1 || ic == 2)) {
      dir = 'https://sanskrit-lexicon-scans.github.io/ramayanaschl';
    }

    return '$dir/?$ic,$is1,$iv';
  }

  static String? hrefRamayanaBombay(String data1) {
    final data2 = data1.replaceFirst(RegExp(r'^R\.?.*? *'), '');

    final regex = RegExp(r' *([iv]+)[ ,]+([0-9]+)[ ,]+([0-9]+)(.*)$');
    final match = regex.firstMatch(data2);
    if (match == null) return null;

    final romanlo = match.group(1)!;
    final k = romanInt(romanlo);
    final s = int.parse(match.group(2)!);
    final v = int.parse(match.group(3)!);

    return 'https://sanskrit-lexicon-scans.github.io/ramayanabom/app1/?$k,$s,$v';
  }

  static String? hrefRamayanaGorresio(String data1) {
    final data2 = data1.replaceFirst(RegExp(r'^R\.?.*? *'), '');

    final regex = RegExp(r' *([iv]+)[ ,]+([0-9]+)[ ,]+([0-9]+)(.*)$');
    final match = regex.firstMatch(data2);
    if (match == null) return null;

    final romanlo = match.group(1)!;
    final k = romanInt(romanlo);
    final s = int.parse(match.group(2)!);
    final v = int.parse(match.group(3)!);

    return 'https://sanskrit-lexicon-scans.github.io/ramayanagorr/?$k,$s,$v';
  }

  static String? hrefMahabharata(String data1, String pfx) {
    final regex = RegExp(r'([0-9]+)[ ,]+([0-9]+)[ ,]+([0-9]+)');
    final match = regex.firstMatch(data1);
    if (match == null) return null;

    final adhyaya = match.group(1)!;
    final bhaga = match.group(2)!;
    final shloka = match.group(3)!;

    if (pfx == 'MBHC') {
      return 'https://sanskrit-lexicon-scans.github.io/mahabharata/calc/?$adhyaya,$bhaga,$shloka';
    } else if (pfx == 'MBHB') {
      return 'https://sanskrit-lexicon-scans.github.io/mahabharata/bomb/?$adhyaya,$bhaga,$shloka';
    }
    return null;
  }

  static String? hrefPancatantra(String data1) {
    var regex = RegExp(r'^(Pañcat\.) *([0-9]+), *([0-9]+)');
    var match = regex.firstMatch(data1);
    if (match != null) {
      final t = match.group(2)!;
      final s = match.group(3)!;
      return 'https://sanskrit-lexicon-scans.github.io/pantankose/app2?$t,$s';
    }

    regex = RegExp(r'^(Pañcat\.) ([vi]+), *([0-9]+), *([0-9]+)');
    match = regex.firstMatch(data1);
    if (match != null) {
      final adhyaya = romanInt(match.group(2)!);
      final page = match.group(3)!;
      final line = match.group(4)!;
      if (adhyaya > 0) {
        return 'https://sanskrit-lexicon-scans.github.io/pantankose/app1?$adhyaya,$page,$line';
      }
    }

    return null;
  }

  static String? hrefHarivamsa(String data1) {
    final regex = RegExp(r'([0-9]+)[ ,]+([0-9]+)[ ,]+([0-9]+)');
    final match = regex.firstMatch(data1);
    if (match == null) return null;

    final adhyaya = match.group(1)!;
    final verse = match.group(2)!;
    final line = match.group(3)!;

    return 'https://sanskrit-lexicon-scans.github.io/harivamsa/app1?$adhyaya,$verse,$line';
  }

  static String? hrefBhagavataPurana(String data1) {
    final regex = RegExp(r'([0-9]+)[ ,]+([0-9]+)[ ,]+([0-9]+)');
    final match = regex.firstMatch(data1);
    if (match == null) return null;

    final skandha = match.group(1)!;
    final adhyaya = match.group(2)!;
    final shloka = match.group(3)!;

    return 'https://sanskrit-lexicon-scans.github.io/bhagavatapurana/app1?$skandha,$adhyaya,$shloka';
  }

  static String? hrefRaghuvamsa(String data1, String pfx) {
    final regex = RegExp(r'([0-9]+)[ ,]+([0-9]+)[ ,]+([0-9]+)');
    final match = regex.firstMatch(data1);
    if (match == null) return null;

    final sarga = match.group(1)!;
    final shloka = match.group(2)!;
    final line = match.group(3)!;

    if (pfx == 'raghuvamsacalc') {
      return 'https://sanskrit-lexicon-scans.github.io/raghuvamsacalc/app1?$sarga,$shloka,$line';
    }
    return null;
  }

  static String? hrefVajasansamhita(String data1) {
    final regex = RegExp(r'([0-9]+)[ ,]+([0-9]+)[ ,]+([0-9]+)');
    final match = regex.firstMatch(data1);
    if (match == null) return null;

    final adhyaya = match.group(1)!;
    final anuvaka = match.group(2)!;
    final mantra = match.group(3)!;

    return 'https://sanskrit-lexicon-scans.github.io/vajasasa/app1?$adhyaya,$anuvaka,$mantra';
  }

  static String? hrefTaittiriyaSamhita(String data1) {
    final regex = RegExp(r'([0-9]+)[ ,]+([0-9]+)[ ,]+([0-9]+)');
    final match = regex.firstMatch(data1);
    if (match == null) return null;

    final prapathaka = match.group(1)!;
    final anuvaka = match.group(2)!;
    final mantra = match.group(3)!;

    return 'https://sanskrit-lexicon-scans.github.io/taittiriyas/app1?$prapathaka,$anuvaka,$mantra';
  }

  static String? hrefSatapathaBrahmana(String data1) {
    final regex = RegExp(r'([0-9]+)[ ,]+([0-9]+)[ ,]+([0-9]+)');
    final match = regex.firstMatch(data1);
    if (match == null) return null;

    final adhyaya = match.group(1)!;
    final brahmana = match.group(2)!;
    final mantra = match.group(3)!;

    return 'https://sanskrit-lexicon-scans.github.io/shatapathabr/app1?$adhyaya,$brahmana,$mantra';
  }

  static String? hrefMeghaduta(String data1) {
    final regex = RegExp(r'([0-9]+)[ ,]+([0-9]+)');
    final match = regex.firstMatch(data1);
    if (match == null) return null;

    final stanza = match.group(1)!;
    final verse = match.group(2)!;

    return 'https://sanskrit-lexicon-scans.github.io/meghaduta/app1?$stanza,$verse';
  }

  static String? hrefKumarasambhava(String data1) {
    final regex = RegExp(r'([0-9]+)[ ,]+([0-9]+)[ ,]+([0-9]+)');
    final match = regex.firstMatch(data1);
    if (match == null) return null;

    final sarga = match.group(1)!;
    final shloka = match.group(2)!;
    final line = match.group(3)!;

    return 'https://sanskrit-lexicon-scans.github.io/kumaras/app1?$sarga,$shloka,$line';
  }

  static String? hrefMalavikagnimitra(String data1) {
    final regex = RegExp(r'([0-9]+)[ ,]+([0-9]+)');
    final match = regex.firstMatch(data1);
    if (match == null) return null;

    final act = match.group(1)!;
    final shloka = match.group(2)!;

    return 'https://sanskrit-lexicon-scans.github.io/malavikagni/app1?$act,$shloka';
  }

  static String? hrefVikramorvashiya(String data1) {
    final regex = RegExp(r'([0-9]+)[ ,]+([0-9]+)');
    final match = regex.firstMatch(data1);
    if (match == null) return null;

    final act = match.group(1)!;
    final verse = match.group(2)!;

    return 'https://sanskrit-lexicon-scans.github.io/vikramor/app1?$act,$verse';
  }

  static String? hrefBhagavadGita(String data1) {
    final regex = RegExp(r'([0-9]+)[ ,]+([0-9]+)');
    final match = regex.firstMatch(data1);
    if (match == null) return null;

    final adhyaya = match.group(1)!;
    final shloka = match.group(2)!;

    return 'https://sanskrit-lexicon-scans.github.io/bhagavadgita/app1?$adhyaya,$shloka';
  }

  static String? hrefManu(String data1) {
    final regex = RegExp(r'([0-9]+)[ ,]+([0-9]+)');
    final match = regex.firstMatch(data1);
    if (match == null) return null;

    final adhyaya = match.group(1)!;
    final verse = match.group(2)!;

    return 'https://sanskrit-lexicon-scans.github.io/manusmriti/app1?$adhyaya,$verse';
  }

  static String? hrefNirukta(String data1) {
    final regex = RegExp(r'([0-9]+)[ ,]+([0-9]+)');
    final match = regex.firstMatch(data1);
    if (match == null) return null;

    final adhyaya = match.group(1)!;
    final verse = match.group(2)!;

    return 'https://sanskrit-lexicon-scans.github.io/nirukta/app1?$adhyaya,$verse';
  }

  static String? hrefKathasaritsagara(String data1) {
    final regex = RegExp(r'^(Kathās\.) *([0-9]+), *([0-9]+)');
    final match = regex.firstMatch(data1);
    if (match != null) {
      final t = match.group(2)!;
      final s = match.group(3)!;
      return 'https://sanskrit-lexicon-scans.github.io/kss/index.html?$t,$s';
    }
    return null;
  }

  static String? hrefSpruch(String data1) {
    final regex = RegExp(r'^(Spr\.) *([0-9]+)');
    final match = regex.firstMatch(data1);
    if (match != null) {
      final verse = match.group(2)!;
      return 'https://sanskrit-lexicon-scans.github.io/boesp2/web1/boesp.html?$verse';
    }
    return null;
  }

  static String? hrefVerzOxf(String data1) {
    final regex = RegExp(r'^(Verz\. d\. Oxf\. H\.?) *([0-9]+)');
    final match = regex.firstMatch(data1);
    if (match != null) {
      final page = match.group(2)!;
      return 'https://sanskrit-lexicon-scans.github.io/Oxf_Cat_Aufrecht/index.html?$page';
    }
    return null;
  }

  // PWG-specific href generators
  static String? hrefAmarakoSa(String data1) {
    final regex = RegExp(r'^AK\. *([0-9]+), *([0-9]+), *([0-9]+), *([0-9]+)');
    final match = regex.firstMatch(data1);
    if (match != null) {
      final khanda = match.group(1)!;
      final adhyaya = match.group(2)!;
      final verse = match.group(3)!;
      return 'https://sanskrit-lexicon-scans.github.io/amarakosha/app1?$khanda,$adhyaya,$verse';
    }
    return null;
  }

  static String? hrefHemacandra(String data1) {
    final regex = RegExp(r'^H\. *([0-9]+)');
    final match = regex.firstMatch(data1);
    if (match != null) {
      final entry = match.group(1)!;
      return 'https://sanskrit-lexicon-scans.github.io/anekarthasamgraha/app1?$entry';
    }
    return null;
  }

  static String? hrefAnekartha(String data1) {
    final regex = RegExp(r'^an\. *([0-9]+), *([0-9]+)');
    final match = regex.firstMatch(data1);
    if (match != null) {
      final entry = match.group(1)!;
      final sub = match.group(2)!;
      return 'https://sanskrit-lexicon-scans.github.io/anekarthasamgraha/app1?$entry,$sub';
    }
    return null;
  }

  static String? hrefMedini(String data1) {
    final regex = RegExp(r'^MED\. *([a-z]), *([0-9]+)');
    final match = regex.firstMatch(data1);
    if (match != null) {
      final startLetter = match.group(1)!;
      final entry = match.group(2)!;
      return 'https://sanskrit-lexicon-scans.github.io/medini/app1?$startLetter,$entry';
    }
    return null;
  }

  static String? hrefShakuntalaPwg(String data1) {
    var regex = RegExp(r'^ŚĀK\. *([0-9]+), *([0-9]+), *([0-9]+)');
    var match = regex.firstMatch(data1);
    if (match != null) {
      final page = match.group(1)!;
      final line = match.group(2)!;
      final col = match.group(3)!;
      return 'https://sanskrit-lexicon-scans.github.io/shakuntala/app2?$page,$line,$col';
    }
    regex = RegExp(r'^ŚĀK\. *([0-9]+)');
    match = regex.firstMatch(data1);
    if (match != null) {
      final verse = match.group(1)!;
      return 'https://sanskrit-lexicon-scans.github.io/shakuntala/app1?$verse';
    }
    return null;
  }

  static String? hrefRajatarPwg(String data1) {
    final regex = RegExp(r'^(RĀJA-TAR\.|RĀJAT\.) *([0-9]+), *([0-9]+)');
    final match = regex.firstMatch(data1);
    if (match != null) {
      final taranga = match.group(2)!;
      final shloka = match.group(3)!;
      if (taranga == '7' || taranga == '8') {
        return 'https://sanskrit-lexicon-scans.github.io/rajatarcalc/app1?$taranga,$shloka';
      }
      return 'https://sanskrit-lexicon-scans.github.io/rajatar/app1?$taranga,$shloka';
    }
    return null;
  }

  static String? hrefRaghPwg(String data1, String pfx) {
    final regex = RegExp(r'^(RAGH\..*?) *([0-9]+), *([0-9]+)');
    final match = regex.firstMatch(data1);
    if (match != null) {
      final sarga = match.group(2)!;
      final shloka = match.group(3)!;
      if (pfx == 'ragh_st' || data1.contains('ST.')) {
        return 'https://sanskrit-lexicon-scans.github.io/raghuvamsa/app1?$sarga,$shloka';
      }
      return 'https://sanskrit-lexicon-scans.github.io/raghuvamsacalc/app1?$sarga,$shloka';
    }
    return null;
  }

  static String? hrefMarkandeyaPuranaPwg(String data1) {
    final regex = RegExp(r'^(MĀRK\. P\.) *([0-9]+), *([0-9]+)');
    final match = regex.firstMatch(data1);
    if (match != null) {
      final adhyaya = match.group(2)!;
      final shloka = match.group(3)!;
      return 'https://sanskrit-lexicon-scans.github.io/markandeyapurana/app1?$adhyaya,$shloka';
    }
    return null;
  }

  static String? hrefBhagavadGitaPwg(String data1) {
    final regex = RegExp(r'^(BHAG\.) *([0-9]+), *([0-9]+)');
    final match = regex.firstMatch(data1);
    if (match != null) {
      final adhyaya = match.group(2)!;
      final shloka = match.group(3)!;
      return 'https://sanskrit-lexicon-scans.github.io/bhagavadgita/app1?$adhyaya,$shloka';
    }
    return null;
  }

  static String? hrefYajnavalkya(String data1) {
    final regex = RegExp(r'^(YĀJÑ\.) *([0-9]+), *([0-9]+)');
    final match = regex.firstMatch(data1);
    if (match != null) {
      final adhyaya = match.group(2)!;
      final verse = match.group(3)!;
      return 'https://sanskrit-lexicon-scans.github.io/yajnavalkya/app1?$adhyaya,$verse';
    }
    return null;
  }

  static String? hrefAitareyaBrahmana(String data1) {
    var regex = RegExp(r'^(AIT\. BR\.) *([0-9]+), *([0-9]+), *([0-9]+)');
    var match = regex.firstMatch(data1);
    if (match != null) {
      final pancika = match.group(2)!;
      final kandika = match.group(3)!;
      final kanda = match.group(4)!;
      return 'https://sanskrit-lexicon-scans.github.io/aitbr_auf/app1?$pancika,$kandika,$kanda';
    }
    regex = RegExp(r'^(AIT\. BR\.) *([0-9]+), *([0-9]+)');
    match = regex.firstMatch(data1);
    if (match != null) {
      final pancika = match.group(2)!;
      final kandika = match.group(3)!;
      return 'https://sanskrit-lexicon-scans.github.io/aitbr_auf/app1?$pancika,$kandika';
    }
    return null;
  }

  // Main processLs method
  static Future<LsResult?> processLs({
    required String dictCode,
    required String lsContent,
    String? nAttribute,
  }) async {
    final dict = dictCode.toLowerCase();

    String data;
    if (nAttribute != null && nAttribute.isNotEmpty) {
      data = '$nAttribute $lsContent';
    } else {
      data = lsContent;
    }

    final key = extractFirstKey(data);
    debugPrint(
        '=== LS PROCESS DEBUG: dict=$dict, data="$data", extracted key="$key"');
    if (key == null) return null;

    final expansion = await _fetchExpansion(dict, data);
    debugPrint(
        '=== LS PROCESS DEBUG: expansion="${expansion?.substring(0, expansion.length > 50 ? 50 : expansion.length)}..."');
    final href = generateHref(dict, key, nAttribute, lsContent);
    debugPrint('=== LS PROCESS DEBUG: href="$href"');

    return LsResult(
      expansion: expansion,
      href: href,
      tooltip: expansion ?? key,
    );
  }

  static Future<String?> _fetchExpansion(String dict, String data) async {
    final key = extractFirstKey(data);
    if (key == null) return null;

    final keyPrefix = '$key%';

    if (_authtooltipsDicts.contains(dict)) {
      final result = await _queryAuthtooltips(dict, keyPrefix, data);
      if (result != null) return result;
    }

    if (_bibDicts.contains(dict)) {
      final result = await _queryBib(dict, keyPrefix, data);
      if (result != null) return result;
    }

    return null;
  }

  static Future<String?> _queryAuthtooltips(
      String dict, String keyPrefix, String data) async {
    try {
      final db = await DatabaseHelper.openAuthTooltips(dict);
      if (db == null) {
        debugPrint('=== LS DB DEBUG: $dict not in authtooltips (no db)');
        return null;
      }

      final table = '${dict}authtooltips';
      debugPrint(
          '=== LS DB DEBUG: querying $table with keyPrefix="$keyPrefix"');
      final rows = await db.rawQuery(
        'SELECT * FROM $table WHERE key LIKE ?',
        [keyPrefix],
      );

      debugPrint(
          '=== LS DB DEBUG: found ${rows.length} rows for keyPrefix="$keyPrefix"');
      if (rows.isEmpty) return null;

      String? bestMatch;
      int maxLen = -1;

      for (final row in rows) {
        final code = row['key'] as String?;
        debugPrint('=== LS DB DEBUG: checking row key="$code"');
        if (code != null && data.startsWith(code)) {
          debugPrint('=== LS DB DEBUG: MATCH - data starts with "$code"');
          if (code.length > maxLen) {
            maxLen = code.length;
            final dataCol = row['data'] as String?;
            final typeCol = row['type'] as String?;
            if (dataCol != null && typeCol != null) {
              bestMatch = '$dataCol ($typeCol)';
            } else if (dataCol != null) {
              bestMatch = dataCol;
            }
          }
        }
      }

      return bestMatch;
    } catch (e) {
      debugPrint('=== LS DB DEBUG: error querying authtooltips: $e');
      return null;
    }
  }

  static Future<String?> _queryBib(
      String dict, String keyPrefix, String data) async {
    try {
      final db = await DatabaseHelper.openBib(dict);
      if (db == null) {
        debugPrint('=== LS DB DEBUG: $dict not in bib (no db)');
        return null;
      }

      final table = '${dict}bib';
      debugPrint(
          '=== LS DB DEBUG: querying $table with keyPrefix="$keyPrefix"');
      final rows = await db.rawQuery(
        'SELECT * FROM $table WHERE code LIKE ?',
        [keyPrefix],
      );

      debugPrint(
          '=== LS DB DEBUG: found ${rows.length} rows for keyPrefix="$keyPrefix"');
      if (rows.isEmpty) return null;

      String? bestMatch;
      int maxLen = -1;

      for (final row in rows) {
        final code = row['code'] as String?;
        debugPrint('=== LS DB DEBUG: checking row code="$code"');
        if (code != null && data.startsWith(code)) {
          debugPrint('=== LS DB DEBUG: MATCH - data starts with "$code"');
          if (code.length > maxLen) {
            maxLen = code.length;
            final dataCol = row['data'] as String?;
            final codecapCol = row['codecap'] as String?;
            if (dataCol != null && codecapCol != null) {
              bestMatch = '$dataCol ($codecapCol)';
            } else if (dataCol != null) {
              bestMatch = dataCol;
            }
          }
        }
      }

      return bestMatch;
    } catch (e) {
      debugPrint('=== LS DB DEBUG: error querying bib: $e');
      return null;
    }
  }

  static Future<Map<String, LsResult>> batchProcessLs({
    required String dictCode,
    required List<String> lsContents,
    List<String>? nAttributes,
  }) async {
    final results = <String, LsResult>{};

    for (int i = 0; i < lsContents.length; i++) {
      final content = lsContents[i];
      final nAttr =
          nAttributes != null && i < nAttributes.length ? nAttributes[i] : null;

      final result = await processLs(
        dictCode: dictCode,
        lsContent: content,
        nAttribute: nAttr,
      );

      if (result != null) {
        results[content] = result;
      }
    }

    return results;
  }
}
