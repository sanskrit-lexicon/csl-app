import 'database_helper.dart';

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

  static int _romanInt(String roman) {
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

  static String? _extractFirstKey(String data) {
    final match = RegExp(r"^([^ .,']+)").firstMatch(data);
    return match?.group(1);
  }

  static String? _getPrefix(String dict, String key) {
    if (_dictSpecificPrefixes.containsKey(dict)) {
      final dictPrefixes = _dictSpecificPrefixes[dict]!;
      if (dictPrefixes.containsKey(key)) {
        return dictPrefixes[key];
      }
    }
    return _codeToPfx[key];
  }

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

    final key = _extractFirstKey(data);
    if (key == null) return null;

    final expansion = await _fetchExpansion(dict, data);
    final href = _generateHref(dict, key, nAttribute, lsContent);

    return LsResult(
      expansion: expansion,
      href: href,
      tooltip: expansion ?? key,
    );
  }

  static Future<String?> _fetchExpansion(String dict, String data) async {
    final key = _extractFirstKey(data);
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
      if (db == null) return null;

      final table = '${dict}authtooltips';
      final rows = await db.rawQuery(
        'SELECT * FROM $table WHERE key LIKE ?',
        [keyPrefix],
      );

      if (rows.isEmpty) return null;

      String? bestMatch;
      int maxLen = -1;

      for (final row in rows) {
        final code = row['key'] as String?;
        if (code != null && data.startsWith(code)) {
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
      return null;
    }
  }

  static Future<String?> _queryBib(
      String dict, String keyPrefix, String data) async {
    try {
      final db = await DatabaseHelper.openBib(dict);
      if (db == null) return null;

      final table = '${dict}bib';
      final rows = await db.rawQuery(
        'SELECT * FROM $table WHERE code LIKE ?',
        [keyPrefix],
      );

      if (rows.isEmpty) return null;

      String? bestMatch;
      int maxLen = -1;

      for (final row in rows) {
        final code = row['code'] as String?;
        if (code != null && data.startsWith(code)) {
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
      return null;
    }
  }

  static String? _generateHref(
      String dict, String key, String? nAttribute, String data) {
    final pfx = _getPrefix(dict, key);
    if (pfx == null) return null;

    String data1;
    if (nAttribute != null && nAttribute.isNotEmpty) {
      data1 = '$nAttribute $data';
    } else {
      data1 = data;
    }

    if (pfx == 'rv' || pfx == 'av') {
      return _hrefRvAv(pfx, data1, dict);
    } else if (pfx == 'p') {
      return _hrefPanini(data1, dict);
    } else if (pfx == 'R' || pfx == 'ramayana') {
      return _hrefRamayana(data1, dict);
    } else if (pfx == 'ramayanabom') {
      return _hrefRamayanaBombay(data1);
    } else if (pfx == 'RG' || pfx == 'rgorr') {
      return _hrefRamayanaGorresio(data1);
    } else if (pfx == 'MBH.' ||
        pfx == 'MBHC' ||
        pfx == 'MBHB' ||
        pfx == 'MBH') {
      return _hrefMahabharata(data1, pfx);
    } else if (pfx == 'Pañcat.') {
      return _hrefPancatantra(data1);
    } else if (pfx == 'Hariv.') {
      return _hrefHarivamsa(data1);
    } else if (pfx == 'BhP.' || pfx == 'bhagp') {
      return _hrefBhagavataPurana(data1);
    } else if (pfx == 'Ragh.' || pfx == 'raghuvamsacalc') {
      return _hrefRaghuvamsa(data1, pfx);
    } else if (pfx == 'VS.') {
      return _hrefVajasansamhita(data1);
    } else if (pfx == 'TS.') {
      return _hrefTaittiriyaSamhita(data1);
    } else if (pfx == 'ŚBr.' || pfx == 'Śat. Br.' || pfx == 'shatapathabr') {
      return _hrefSatapathaBrahmana(data1);
    } else if (pfx == 'Megh.') {
      return _hrefMeghaduta(data1);
    } else if (pfx == 'Kum.' || pfx == 'Kumāras.' || pfx == 'kumaras') {
      return _hrefKumarasambhava(data1);
    } else if (pfx == 'Mālav.') {
      return _hrefMalavikagnimitra(data1);
    } else if (pfx == 'Vikr.' || pfx == 'vikramor') {
      return _hrefVikramorvashiya(data1);
    } else if (pfx == 'Bhag.') {
      return _hrefBhagavadGita(data1);
    } else if (pfx == 'Mn.' || pfx == 'M.') {
      return _hrefManu(data1);
    } else if (pfx == 'Nir.') {
      return _hrefNirukta(data1);
    } else if (pfx == 'kathas') {
      return _hrefKathasaritsagara(data1);
    } else if (pfx == 'spr') {
      return _hrefSpruch(data1);
    } else if (pfx == 'verzoxf') {
      return _hrefVerzOxf(data1);
    }

    return null;
  }

  static String? _hrefRvAv(String pfx, String data1, String dict) {
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
        final anchor = '${hymnFilePfx}.${iverse.toString().padLeft(2, '0')}';
        final dir =
            'https://sanskrit-lexicon.github.io/${pfx}links/${pfx}hymns';
        return '$dir/${hymnFilePfx}.html#$anchor';
      }
    }

    final regex = RegExp(r'^(.*?)\. *([^ ,]+)[ ,]+([0-9]+)[ ,]+([0-9]+)(.*)$');
    match = regex.firstMatch(data1);

    if (match != null) {
      final mandala = match.group(2)!;
      final imandala = _romanInt(mandala);
      final ihymn = int.parse(match.group(3)!);
      final iverse = int.parse(match.group(4)!);

      if (imandala > 0) {
        final hymnFilePfx =
            '${pfx == 'rv' ? 'rv' : 'av'}${imandala.toString().padLeft(2, '0')}.${ihymn.toString().padLeft(3, '0')}';
        final anchor = '${hymnFilePfx}.${iverse.toString().padLeft(2, '0')}';
        final dir =
            'https://sanskrit-lexicon.github.io/${pfx}links/${pfx}hymns';
        return '$dir/${hymnFilePfx}.html#$anchor';
      }
    }

    final regex2 = RegExp(r'^(.*?)\. *([^ ,]+)[ ,]+([0-9]+)(.*)$');
    match = regex2.firstMatch(data1);
    if (match != null) {
      final mandala = match.group(2)!;
      final imandala = _romanInt(mandala);
      final ihymn = int.parse(match.group(3)!);

      if (imandala > 0) {
        final hymnFilePfx =
            '${pfx == 'rv' ? 'rv' : 'av'}${imandala.toString().padLeft(2, '0')}.${ihymn.toString().padLeft(3, '0')}';
        final anchor = '${hymnFilePfx}.01';
        final dir =
            'https://sanskrit-lexicon.github.io/${pfx}links/${pfx}hymns';
        return '$dir/${hymnFilePfx}.html#$anchor';
      }
    }

    return null;
  }

  static String? _hrefPanini(String data1, String dict) {
    RegExpMatch? match;

    if (dict == 'ap90') {
      final regex =
          RegExp(r'^(.*?)[.] *([IV]+)[.] +([0-9]+)[.] +([0-9]+)(.*)$');
      match = regex.firstMatch(data1);
      if (match != null) {
        final roman = match.group(2)!;
        final romanlo = roman.toLowerCase();
        final ic = _romanInt(romanlo);
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
    final ic = _romanInt(romanlo);
    final is1 = int.parse(match.group(3)!);
    final iv = int.parse(match.group(4)!);

    if (ic > 0) {
      return 'https://ashtadhyayi.com/sutraani/$ic/$is1/$iv';
    }
    return null;
  }

  static String? _hrefRamayana(String data1, String dict) {
    final data2 = data1.replaceFirst(RegExp(r'^R\. *'), '');

    final regex = RegExp(r' *([iv]+)[ ,]+([0-9]+)[ ,]+([0-9]+)(.*)$');
    final match = regex.firstMatch(data2);
    if (match == null) return null;

    final romanlo = match.group(1)!;
    final ic = _romanInt(romanlo);
    final is1 = int.parse(match.group(2)!);
    final iv = int.parse(match.group(3)!);

    String dir = 'https://sanskrit-lexicon-scans.github.io/ramayanagorr';
    if (dict == 'mw' && (ic == 1 || ic == 2)) {
      dir = 'https://sanskrit-lexicon-scans.github.io/ramayanaschl';
    }

    return '$dir/?$ic,$is1,$iv';
  }

  static String? _hrefRamayanaBombay(String data1) {
    final data2 = data1.replaceFirst(RegExp(r'^R\.?.*? *'), '');

    final regex = RegExp(r' *([iv]+)[ ,]+([0-9]+)[ ,]+([0-9]+)(.*)$');
    final match = regex.firstMatch(data2);
    if (match == null) return null;

    final romanlo = match.group(1)!;
    final k = _romanInt(romanlo);
    final s = int.parse(match.group(2)!);
    final v = int.parse(match.group(3)!);

    return 'https://sanskrit-lexicon-scans.github.io/ramayanabom/app1/?$k,$s,$v';
  }

  static String? _hrefRamayanaGorresio(String data1) {
    final data2 = data1.replaceFirst(RegExp(r'^R\.?.*? *'), '');

    final regex = RegExp(r' *([iv]+)[ ,]+([0-9]+)[ ,]+([0-9]+)(.*)$');
    final match = regex.firstMatch(data2);
    if (match == null) return null;

    final romanlo = match.group(1)!;
    final k = _romanInt(romanlo);
    final s = int.parse(match.group(2)!);
    final v = int.parse(match.group(3)!);

    return 'https://sanskrit-lexicon-scans.github.io/ramayanagorr/?$k,$s,$v';
  }

  static String? _hrefMahabharata(String data1, String pfx) {
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

  static String? _hrefPancatantra(String data1) {
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
      final adhyaya = _romanInt(match.group(2)!);
      final page = match.group(3)!;
      final line = match.group(4)!;
      if (adhyaya > 0) {
        return 'https://sanskrit-lexicon-scans.github.io/pantankose/app1?$adhyaya,$page,$line';
      }
    }

    return null;
  }

  static String? _hrefHarivamsa(String data1) {
    final regex = RegExp(r'([0-9]+)[ ,]+([0-9]+)[ ,]+([0-9]+)');
    final match = regex.firstMatch(data1);
    if (match == null) return null;

    final adhyaya = match.group(1)!;
    final verse = match.group(2)!;
    final line = match.group(3)!;

    return 'https://sanskrit-lexicon-scans.github.io/harivamsa/app1?$adhyaya,$verse,$line';
  }

  static String? _hrefBhagavataPurana(String data1) {
    final regex = RegExp(r'([0-9]+)[ ,]+([0-9]+)[ ,]+([0-9]+)');
    final match = regex.firstMatch(data1);
    if (match == null) return null;

    final skandha = match.group(1)!;
    final adhyaya = match.group(2)!;
    final shloka = match.group(3)!;

    return 'https://sanskrit-lexicon-scans.github.io/bhagavatapurana/app1?$skandha,$adhyaya,$shloka';
  }

  static String? _hrefRaghuvamsa(String data1, String pfx) {
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

  static String? _hrefVajasansamhita(String data1) {
    final regex = RegExp(r'([0-9]+)[ ,]+([0-9]+)[ ,]+([0-9]+)');
    final match = regex.firstMatch(data1);
    if (match == null) return null;

    final adhyaya = match.group(1)!;
    final anuvaka = match.group(2)!;
    final mantra = match.group(3)!;

    return 'https://sanskrit-lexicon-scans.github.io/vajasasa/app1?$adhyaya,$anuvaka,$mantra';
  }

  static String? _hrefTaittiriyaSamhita(String data1) {
    final regex = RegExp(r'([0-9]+)[ ,]+([0-9]+)[ ,]+([0-9]+)');
    final match = regex.firstMatch(data1);
    if (match == null) return null;

    final prapathaka = match.group(1)!;
    final anuvaka = match.group(2)!;
    final mantra = match.group(3)!;

    return 'https://sanskrit-lexicon-scans.github.io/taittiriyas/app1?$prapathaka,$anuvaka,$mantra';
  }

  static String? _hrefSatapathaBrahmana(String data1) {
    final regex = RegExp(r'([0-9]+)[ ,]+([0-9]+)[ ,]+([0-9]+)');
    final match = regex.firstMatch(data1);
    if (match == null) return null;

    final adhyaya = match.group(1)!;
    final brahmana = match.group(2)!;
    final mantra = match.group(3)!;

    return 'https://sanskrit-lexicon-scans.github.io/shatapathabr/app1?$adhyaya,$brahmana,$mantra';
  }

  static String? _hrefMeghaduta(String data1) {
    final regex = RegExp(r'([0-9]+)[ ,]+([0-9]+)');
    final match = regex.firstMatch(data1);
    if (match == null) return null;

    final stanza = match.group(1)!;
    final verse = match.group(2)!;

    return 'https://sanskrit-lexicon-scans.github.io/meghaduta/app1?$stanza,$verse';
  }

  static String? _hrefKumarasambhava(String data1) {
    final regex = RegExp(r'([0-9]+)[ ,]+([0-9]+)[ ,]+([0-9]+)');
    final match = regex.firstMatch(data1);
    if (match == null) return null;

    final sarga = match.group(1)!;
    final shloka = match.group(2)!;
    final line = match.group(3)!;

    return 'https://sanskrit-lexicon-scans.github.io/kumaras/app1?$sarga,$shloka,$line';
  }

  static String? _hrefMalavikagnimitra(String data1) {
    final regex = RegExp(r'([0-9]+)[ ,]+([0-9]+)');
    final match = regex.firstMatch(data1);
    if (match == null) return null;

    final act = match.group(1)!;
    final shloka = match.group(2)!;

    return 'https://sanskrit-lexicon-scans.github.io/malavikagni/app1?$act,$shloka';
  }

  static String? _hrefVikramorvashiya(String data1) {
    final regex = RegExp(r'([0-9]+)[ ,]+([0-9]+)');
    final match = regex.firstMatch(data1);
    if (match == null) return null;

    final act = match.group(1)!;
    final verse = match.group(2)!;

    return 'https://sanskrit-lexicon-scans.github.io/vikramor/app1?$act,$verse';
  }

  static String? _hrefBhagavadGita(String data1) {
    final regex = RegExp(r'([0-9]+)[ ,]+([0-9]+)');
    final match = regex.firstMatch(data1);
    if (match == null) return null;

    final adhyaya = match.group(1)!;
    final shloka = match.group(2)!;

    return 'https://sanskrit-lexicon-scans.github.io/bhagavadgita/app1?$adhyaya,$shloka';
  }

  static String? _hrefManu(String data1) {
    final regex = RegExp(r'([0-9]+)[ ,]+([0-9]+)');
    final match = regex.firstMatch(data1);
    if (match == null) return null;

    final adhyaya = match.group(1)!;
    final verse = match.group(2)!;

    return 'https://sanskrit-lexicon-scans.github.io/manusmriti/app1?$adhyaya,$verse';
  }

  static String? _hrefNirukta(String data1) {
    final regex = RegExp(r'([0-9]+)[ ,]+([0-9]+)');
    final match = regex.firstMatch(data1);
    if (match == null) return null;

    final adhyaya = match.group(1)!;
    final verse = match.group(2)!;

    return 'https://sanskrit-lexicon-scans.github.io/nirukta/app1?$adhyaya,$verse';
  }

  static String? _hrefKathasaritsagara(String data1) {
    final regex = RegExp(r'^(Kathās\.) *([0-9]+), *([0-9]+)');
    final match = regex.firstMatch(data1);
    if (match != null) {
      final t = match.group(2)!;
      final s = match.group(3)!;
      return 'https://sanskrit-lexicon-scans.github.io/kss/index.html?$t,$s';
    }
    return null;
  }

  static String? _hrefSpruch(String data1) {
    final regex = RegExp(r'^(Spr\.) *([0-9]+)');
    final match = regex.firstMatch(data1);
    if (match != null) {
      final verse = match.group(2)!;
      return 'https://sanskrit-lexicon-scans.github.io/boesp2/web1/boesp.html?$verse';
    }
    return null;
  }

  static String? _hrefVerzOxf(String data1) {
    final regex = RegExp(r'^(Verz\. d\. Oxf\. H\.?) *([0-9]+)');
    final match = regex.firstMatch(data1);
    if (match != null) {
      final page = match.group(2)!;
      return 'https://sanskrit-lexicon-scans.github.io/Oxf_Cat_Aufrecht/index.html?$page';
    }
    return null;
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
