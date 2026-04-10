import '../models/dictionary_info.dart';

/// Complete catalogue of all CSL dictionaries, sourced from dictparms.py.
class DictionaryRegistry {
  static const List<DictionaryInfo> all = [
    DictionaryInfo(
      codeUp: 'ACC',
      codeLo: 'acc',
      name: 'Aufrecht Catalogus Catalogorum',
      title: 'Aufrecht Catalogus Catalogorum 1962',
      hasAccent: false,
      hasDevaTextOption: false,
      worldCatUrl:
          'https://www.worldcat.org/title/catalogus-catalogorum-an-alphabetical-register-of-sanskrit-works-and-authors/oclc/4478703',
      bibliographicEntry:
          'AUFRECHT, T. (1891). Catalogus catalogorum. Leipzig, F.A. Brockhaus.',
    ),
    DictionaryInfo(
      codeUp: 'AE',
      codeLo: 'ae',

      name: 'Apte Student\'s English-Sanskrit Dictionary',
      title: 'Apte English-Sanskrit Dictionary 1884',
      hasAccent: false,
      hasDevaTextOption: false,
      worldCatUrl:
          'https://www.worldcat.org/title/students-english-sanskrit-dictionary/oclc/43456219',
      bibliographicEntry:
          'APTE, V. S. (1884). The student\'s English-Sanskrit dictionary. Poona.',
    ),
    DictionaryInfo(
      codeUp: 'AP',
      codeLo: 'ap',

      name: 'Apte Practical Sanskrit-English Dictionary, revised edition, 1957',
      title: 'Apte Sanskrit Dictionary 1957',
      hasAccent: false,
      hasDevaTextOption: true,
      worldCatUrl:
          'https://www.worldcat.org/title/prin-vs-aptes-the-practical-sanskrit-english-dictionary/oclc/716419540',
      bibliographicEntry:
          'APTE, V. S. (1957). The practical Sanskrit-English dictionary. Poona: Prasad Prakashan.',
    ),
    DictionaryInfo(
      codeUp: 'AP90',
      codeLo: 'ap90',

      name: 'Apte Practical Sanskrit-English Dictionary, 1890',
      title: 'Apte Sanskrit Dictionary 1890',
      hasAccent: false,
      hasDevaTextOption: true,
      worldCatUrl:
          'https://www.worldcat.org/title/practical-sanskrit-english-dictionary/oclc/18293791',
      bibliographicEntry:
          'APTE, V. S. (1890). The practical Sanskrit-English dictionary. Poona, Shiralkar.',
    ),
    DictionaryInfo(
      codeUp: 'BEN',
      codeLo: 'ben',

      name: 'Benfey Sanskrit-English Dictionary',
      title: 'Benfey Sanskrit Dictionary 1866',
      hasAccent: false,
      hasDevaTextOption: true,
      worldCatUrl:
          'https://www.worldcat.org/title/sanskrit-english-dictionary/oclc/3320706',
      bibliographicEntry:
          'BENFEY, T. (1866). A Sanskrit-English dictionary. London, Longmans, Green.',
    ),
    DictionaryInfo(
      codeUp: 'BHS',
      codeLo: 'bhs',

      name: 'Edgerton Buddhist Hybrid Sanskrit Dictionary',
      title: 'Edgerton Sanskrit Dictionary 1953',
      hasAccent: false,
      hasDevaTextOption: false,
      worldCatUrl:
          'https://www.worldcat.org/title/buddhist-hybrid-sanskrit-grammar-and-dictionary-2-dictionary/oclc/174004867',
      bibliographicEntry:
          'EDGERTON, F. (1953). Buddhist hybrid sanskrit grammar and dictionary 2. New Haven, Yale Univ. Press.',
    ),
    DictionaryInfo(
      codeUp: 'BOP',
      codeLo: 'bop',

      name: 'Bopp Glossarium Sanscritum',
      title: 'Bopp Glossarium Sanscritum 1847',
      hasAccent: false,
      hasDevaTextOption: true,
      worldCatUrl:
          'https://www.worldcat.org/title/glossarium-sanscritum/oclc/257696310',
      bibliographicEntry:
          'BOPP, F. (1847). Glossarium Sanscritum. Berolini, Dümmler.',
    ),
    DictionaryInfo(
      codeUp: 'BOR',
      codeLo: 'bor',

      name: 'Borooah English-Sanskrit Dictionary',
      title: 'Borooah English-Sanskrit Dictionary 1877',
      hasAccent: false,
      hasDevaTextOption: false,
      worldCatUrl:
          'https://www.worldcat.org/title/practical-english-sanskrit-dictionary/oclc/457102878',
      bibliographicEntry:
          'BOROOAH, A. (1877). A Practical English-Sanskrit Dictionary. Calcutta, Wyman.',
    ),
    DictionaryInfo(
      codeUp: 'BUR',
      codeLo: 'bur',

      name: 'Burnouf Dictionnaire Sanscrit-Français',
      title: 'Burnouf Dictionnaire Sanscrit 1866',
      hasAccent: false,
      hasDevaTextOption: true,
      worldCatUrl:
          'https://www.worldcat.org/title/dictionnaire-classique-sanscrit-francais/oclc/3436551',
      bibliographicEntry:
          'BURNOUF, E., & LEUPOL, L. (1866). Dictionnaire classique sanscrit-français. Paris, Maissonneuve.',
    ),
    DictionaryInfo(
      codeUp: 'CAE',
      codeLo: 'cae',

      name: 'Cappeller Sanskrit-English Dictionary',
      title: 'Cappeller Sanskrit Dictionary 1891',
      hasAccent: true,
      hasDevaTextOption: true,
      worldCatUrl:
          'https://www.worldcat.org/title/sanskrit-english-dictionary/oclc/786426334',
      bibliographicEntry:
          'CAPPELLER, C. (1891). A Sanskrit-English dictionary. Strassburg, Trübner.',
    ),
    DictionaryInfo(
      codeUp: 'CCS',
      codeLo: 'ccs',

      name: 'Cappeller Sanskrit Wörterbuch',
      title: 'Cappeller Sanskrit Wörterbuch 1887',
      hasAccent: true,
      hasDevaTextOption: true,
      worldCatUrl:
          'https://www.worldcat.org/title/sanskrit-worterbuch/oclc/3192816',
      bibliographicEntry:
          'CAPPELLER, C. (1887). Sanskrit wörterbuch. Strassburg, K.J. Trübner.',
    ),
    DictionaryInfo(
      codeUp: 'GRA',
      codeLo: 'gra',

      name: 'Grassmann Wörterbuch zum Rig Veda',
      title: 'Grassman Wörterbuch 1873',
      hasAccent: false,
      hasDevaTextOption: false,
      worldCatUrl:
          'https://www.worldcat.org/title/worterbuch-zum-rig-veda/oclc/184798352',
      bibliographicEntry:
          'GRASSMANN, H. G. (1873). Worterbuch zum Rig-veda. Wiesbaden, O. Harrassowitz.',
    ),
    DictionaryInfo(
      codeUp: 'GST',
      codeLo: 'gst',

      name: 'Goldstücker Sanskrit-English Dictionary',
      title: 'Goldstücker Sanskrit Dictionary 1856',
      hasAccent: false,
      hasDevaTextOption: true,
      worldCatUrl:
          'https://www.worldcat.org/title/dictionary-sanskrit-and-english/oclc/61965219',
      bibliographicEntry:
          'GOLDSTÜCKER, T., & WILSON, H. H. (1856). A Dictionary, Sanskrit and English. Berlin, Asher.',
    ),
    DictionaryInfo(
      codeUp: 'IEG',
      codeLo: 'ieg',

      name: 'Indian Epigraphical Glossary',
      title: 'Indian Epigraphical Glossary 1966',
      hasAccent: false,
      hasDevaTextOption: false,
      worldCatUrl:
          'https://www.worldcat.org/title/indian-epigraphical-glossary/oclc/769741727',
      bibliographicEntry:
          'SIRCAR, D. C. (1966). Indian epigraphical glossary. Delhi, Motilal Banarsidass.',
    ),
    DictionaryInfo(
      codeUp: 'INM',
      codeLo: 'inm',

      name: 'Index to the Names in the Mahabharata',
      title: 'Index to the Names in the Mahabharata 1904',
      hasAccent: false,
      hasDevaTextOption: false,
      worldCatUrl:
          'https://www.worldcat.org/title/index-to-the-names-in-the-mahabharata/oclc/2302004',
      bibliographicEntry:
          'SØRENSEN, S. (1904). An index to the names in the Mahābhārata. Delhi, Motilal Banarsidass.',
    ),
    DictionaryInfo(
      codeUp: 'KRM',
      codeLo: 'krm',

      name: 'Kṛdantarūpamālā',
      title: 'Kṛdantarūpamālā 1965',
      hasAccent: false,
      hasDevaTextOption: true,
      worldCatUrl:
          'https://www.worldcat.org/title/krdantarupamala/oclc/11091001',
      bibliographicEntry:
          'RAMASUBBA SASTRI, S. (1965). Kṛdantarūpamālā. Madrās.',
    ),
    DictionaryInfo(
      codeUp: 'LAN',
      codeLo: 'lan',

      name: 'Lanman Sanskrit Reader Dictionary',
      title: 'Lanman Sanskrit Reader Dictionary 1884',
      hasAccent: false,
      hasDevaTextOption: true,
      worldCatUrl:
          'https://www.worldcat.org/title/sanskrit-reader-with-vocabulary-and-notes/oclc/1120214238',
      bibliographicEntry:
          'LANMAN, C. R. (1888). A Sanskrit Reader: with vocabulary and notes. Ginn and Co, Boston.',
    ),
    DictionaryInfo(
      codeUp: 'LRV',
      codeLo: 'lrv',

      name: 'Vaidya Standard Sanskrit-English Dictionary',
      title: 'Vaidya Sanskrit Dictionary 1889',
      hasAccent: false,
      hasDevaTextOption: true,
      worldCatUrl: 'https://www.worldcat.org/title/1264141730',
      bibliographicEntry:
          'VAIDYA L. R. (1889). The Standard Sanskrit-English Dictionary. Bombay.',
    ),
    DictionaryInfo(
      codeUp: 'MCI',
      codeLo: 'mci',

      name: 'Mehendale Mahabharata Cultural Index',
      title: 'Mahabharata Cultural Index 1993',
      hasAccent: false,
      hasDevaTextOption: false,
      worldCatUrl:
          'https://www.worldcat.org/title/mahabharata-cultural-index/oclc/30512863',
      bibliographicEntry:
          'MEHENDALE, M. A. (1993). Mahābhārata, cultural index. Pune, Bhandarkar Oriental Research Institute.',
    ),
    DictionaryInfo(
      codeUp: 'MD',
      codeLo: 'md',

      name: 'Macdonell Sanskrit-English Dictionary',
      title: 'Macdonell Sanskrit Dictionary 1893',
      hasAccent: false,
      hasDevaTextOption: false,
      worldCatUrl:
          'https://www.worldcat.org/title/sanskrit-english-dictionary/oclc/5140323',
      bibliographicEntry:
          'MACDONELL, A. A. (1893). A Sanskrit-English dictionary. London, Longmans, Green.',
    ),
    DictionaryInfo(
      codeUp: 'MW',
      codeLo: 'mw',

      name: 'Monier-Williams Sanskrit-English Dictionary, 1899',
      title: 'Monier-Williams Sanskrit Dictionary 1899',
      hasAccent: true,
      hasDevaTextOption: true,
      worldCatUrl:
          'https://www.worldcat.org/title/sanskrit-english-dictionary/oclc/471589783',
      bibliographicEntry:
          'MONIER-WILLIAMS, M. (1899). A Sanskrit-English dictionary. Oxford, The Clarendon Press.',
    ),
    DictionaryInfo(
      codeUp: 'MW72',
      codeLo: 'mw72',

      name: 'Monier-Williams Sanskrit-English Dictionary, 1872',
      title: 'Monier-Williams Sanskrit Dictionary 1872',
      hasAccent: false,
      hasDevaTextOption: false,
      worldCatUrl:
          'https://www.worldcat.org/title/sanskrit-english-dictionary/oclc/3592375',
      bibliographicEntry:
          'MONIER-WILLIAMS, M. (1872). A Sanskṛit-English dictionary. Oxford, The Clarendon Press.',
    ),
    DictionaryInfo(
      codeUp: 'MWE',
      codeLo: 'mwe',

      name: 'Monier-Williams English-Sanskrit Dictionary',
      title: 'Monier-Williams English-Sanskrit Dictionary 1851',
      hasAccent: false,
      hasDevaTextOption: false,
      worldCatUrl:
          'https://www.worldcat.org/title/dictionary-english-and-sanscrit/oclc/5333096',
      bibliographicEntry:
          'MONIER-WILLIAMS, M. (1851). A dictionary, English and Sanscrit. London, W.H. Allen.',
    ),
    DictionaryInfo(
      codeUp: 'PE',
      codeLo: 'pe',

      name: 'Puranic Encyclopedia',
      title: 'Puranic Encyclopedia 1975',
      hasAccent: false,
      hasDevaTextOption: false,
      worldCatUrl:
          'https://www.worldcat.org/title/puranic-encyclopaedia/oclc/638562346',
      bibliographicEntry:
          'MANI, V. (1975). Puranic encyclopaedia. Delhi, Motilal Banarsidass.',
    ),
    DictionaryInfo(
      codeUp: 'PGN',
      codeLo: 'pgn',

      name: 'Personal and Geographical Names in the Gupta Inscriptions',
      title: 'Names in the Gupta Inscriptions 1978',
      hasAccent: false,
      hasDevaTextOption: false,
      worldCatUrl:
          'https://www.worldcat.org/title/personal-and-geographical-names-in-the-gupta-inscriptions/oclc/5413655',
      bibliographicEntry:
          'SHARMA, T. R. (1978). Personal and geographical names in the Gupta inscriptions. Delhi, Concept.',
    ),
    DictionaryInfo(
      codeUp: 'PUI',
      codeLo: 'pui',

      name: 'The Purana Index',
      title: 'Purana Index 1951',
      hasAccent: false,
      hasDevaTextOption: false,
      worldCatUrl:
          'https://www.worldcat.org/title/purana-index-1-from-a-to-n/oclc/174625299',
      bibliographicEntry:
          'RAMACHANDRA DĪKSHITAR, V. R. (1951). The Purana index. Madras, Univ. of Madras.',
    ),
    DictionaryInfo(
      codeUp: 'PW',
      codeLo: 'pw',

      name: 'Böhtlingk Sanskrit-Wörterbuch in kürzerer Fassung',
      title: 'Böhtlingk Sanskrit-Wörterbuch 1879',
      hasAccent: true,
      hasDevaTextOption: true,
      worldCatUrl:
          'https://www.worldcat.org/title/sanskrit-worterbuch-in-kurzerer-fassung/oclc/3028346',
      bibliographicEntry:
          'BÖHTLINGK, O. V. (1879). Sanskrit-wörterbuch in kürzerer fassung. St. Petersburg.',
    ),
    DictionaryInfo(
      codeUp: 'PWG',
      codeLo: 'pwg',

      name: 'Böhtlingk and Roth Grosses Petersburger Wörterbuch',
      title: 'Böhtlingk and Roth Wörterbuch 1855',
      hasAccent: true,
      hasDevaTextOption: true,
      worldCatUrl:
          'https://www.worldcat.org/title/sanskrit-worterbuch/oclc/457088562',
      bibliographicEntry:
          'BÖHTLINGK, O. (1855). Sanskrit Wörterbuch. St-Petersburg, Eggers.',
    ),
    DictionaryInfo(
      codeUp: 'PWKVN',
      codeLo: 'pwkvn',

      name: 'Böhtlingk Sanskrit-Wörterbuch, Nachträge und Verbesserungen',
      title: 'Böhtlingk Sanskrit-Wörterbuch 1879 (Supplement)',
      hasAccent: true,
      hasDevaTextOption: true,
      worldCatUrl:
          'https://www.worldcat.org/title/sanskrit-worterbuch-in-kurzerer-fassung/oclc/3028346',
      bibliographicEntry:
          'BÖHTLINGK, O. V. (1879). Sanskrit-wörterbuch in kürzerer fassung (Supplement). St. Petersburg.',
    ),
    DictionaryInfo(
      codeUp: 'SCH',
      codeLo: 'sch',

      name: 'Schmidt Nachträge zum Sanskrit-Wörterbuch',
      title: 'Schmidt Nachträge zum Sanskrit-Wörterbuch 1928',
      hasAccent: false,
      hasDevaTextOption: false,
      worldCatUrl:
          'https://www.worldcat.org/title/nachtrage-zum-sanskrit-worterbuch/oclc/5901453',
      bibliographicEntry:
          'SCHMIDT, R. (1928). Nachträge zum Sanskrit-Wörterbuch. Leipzig, O. Harrassowitz.',
    ),
    DictionaryInfo(
      codeUp: 'SHS',
      codeLo: 'shs',

      name: 'Shabda-Sagara Sanskrit-English Dictionary',
      title: 'Shabda-Sagara Sanskrit Dictionary 1900',
      hasAccent: false,
      hasDevaTextOption: true,
      worldCatUrl:
          'https://www.worldcat.org/title/shabda-sagara/oclc/457574734',
      bibliographicEntry:
          'BHAṬṬĀCĀRYA, J. V. (1900). A comprehensive Sanskrit-English lexicon. Calcutta.',
    ),
    DictionaryInfo(
      codeUp: 'SKD',
      codeLo: 'skd',

      name: 'Sabda-kalpadruma',
      title: 'Sabda-kalpadruma 1886',
      hasAccent: false,
      hasDevaTextOption: true,
      worldCatUrl:
          'https://www.worldcat.org/title/sabdakalpadrumah/oclc/214968657',
      bibliographicEntry: 'RĀDHĀKĀNTADEVA (1886). Śabdakalpadrumah. Kalikātā.',
    ),
    DictionaryInfo(
      codeUp: 'SNP',
      codeLo: 'snp',

      name: 'Meulenbeld Sanskrit Names of Plants',
      title: 'Meulenbeld Sanskrit Names of Plants',
      hasAccent: false,
      hasDevaTextOption: false,
      worldCatUrl:
          'https://www.worldcat.org/title/madhavanidana/oclc/463543891',
      bibliographicEntry:
          'MEULENBELD, G. J. (1974). The Mādhavanidāna and its chief commentary. Leiden, E.J. Brill.',
    ),
    DictionaryInfo(
      codeUp: 'STC',
      codeLo: 'stc',

      name: 'Stchoupak Dictionnaire Sanscrit-Français',
      title: 'Stchoupak Dictionnaire Sanscrit 1932',
      hasAccent: false,
      hasDevaTextOption: false,
      worldCatUrl:
          'https://www.worldcat.org/title/dictionnaire-sanskrit-francais/oclc/504480084',
      bibliographicEntry:
          'STCHOUPAK, N., NITTI, L. & RENOU, L. (1932). Dictionnaire sanskrit-français.',
    ),
    DictionaryInfo(
      codeUp: 'VCP',
      codeLo: 'vcp',

      name: 'Vacaspatyam',
      title: 'Vacaspatyam 1873',
      hasAccent: false,
      hasDevaTextOption: true,
      worldCatUrl: 'https://www.worldcat.org/title/vacaspatyam/oclc/634904608',
      bibliographicEntry:
          'BHAṬṬĀCĀRYA, T. V. (1873). Vācaspatyam. Vārāṇasī, Caukhambā Saṃskṛta.',
    ),
    DictionaryInfo(
      codeUp: 'VEI',
      codeLo: 'vei',

      name: 'The Vedic Index of Names and Subjects',
      title: 'Vedic Index 1912',
      hasAccent: false,
      hasDevaTextOption: false,
      worldCatUrl:
          'https://www.worldcat.org/title/vedic-index-of-names-and-subjects/oclc/600507768',
      bibliographicEntry:
          'MACDONELL, A. A., & KEITH, A. B. (1912). Vedic index of names and subjects. London, J. Murray.',
    ),
    DictionaryInfo(
      codeUp: 'WIL',
      codeLo: 'wil',

      name: 'Wilson Sanskrit-English Dictionary',
      title: 'Wilson Sanskrit Dictionary 1832',
      hasAccent: false,
      hasDevaTextOption: true,
      worldCatUrl:
          'https://www.worldcat.org/title/dictionary-in-sanskrit-and-english/oclc/473496524',
      bibliographicEntry:
          'WILSON, H. (1832). A dictionary in Sanskrit and English. Calcutta, The Education Press.',
    ),
    DictionaryInfo(
      codeUp: 'YAT',
      codeLo: 'yat',

      name: 'Yates Sanskrit-English Dictionary',
      title: 'Yates Sanskrit Dictionary 1846',
      hasAccent: false,
      hasDevaTextOption: true,
      worldCatUrl:
          'https://www.worldcat.org/title/dictionary-in-sanscrit-and-english/oclc/12413832',
      bibliographicEntry:
          'YATES, W. (1846). A dictionary in Sanscrit and English. Calcutta, Baptist Mission Press.',
    ),
    DictionaryInfo(
      codeUp: 'ARMH',
      codeLo: 'armh',

      name: 'Abhidhānaratnamālā of Halāyudha',
      title: 'Abhidhānaratnamālā of Halāyudha 1957',
      hasAccent: false,
      hasDevaTextOption: true,
      worldCatUrl:
          'https://www.worldcat.org/title/halayudhas-abhidhanaratnamala/oclc/320893849',
      bibliographicEntry:
          'HALĀYUDHA. Abhidhānaratnamālā (a Sanskrit vocabulary).',
    ),
    DictionaryInfo(
      codeUp: 'ABCH',
      codeLo: 'abch',

      name: 'Abhidhānacintāmaṇi of Hemacandrācārya',
      title: 'Abhidhānacintāmaṇi of Hemacandrācārya',
      hasAccent: false,
      hasDevaTextOption: true,
      worldCatUrl: 'https://search.worldcat.org/title/163083433',
      bibliographicEntry: 'Abhidhānacintāmaṇi of Hemacandrācārya.',
    ),
    DictionaryInfo(
      codeUp: 'ACPH',
      codeLo: 'acph',

      name: 'Abhidhānacintāmaṇipariśiṣṭa of Hemacandrācārya',
      title: 'Abhidhānacintāmaṇipariśiṣṭa of Hemacandrācārya',
      hasAccent: false,
      hasDevaTextOption: true,
      worldCatUrl: 'https://search.worldcat.org/title/163083433',
      bibliographicEntry: 'Abhidhānacintāmaṇipariśiṣṭa of Hemacandrācārya.',
    ),
    DictionaryInfo(
      codeUp: 'ACSJ',
      codeLo: 'acsj',

      name: 'Abhidhānacintāmaṇiśiloñcha of Jinadeva',
      title: 'Abhidhānacintāmaṇiśiloñcha of Jinadeva',
      hasAccent: false,
      hasDevaTextOption: true,
      worldCatUrl: 'https://search.worldcat.org/title/163083433',
      bibliographicEntry: 'Abhidhānacintāmaṇiśiloñcha of Jinadeva.',
    ),
    DictionaryInfo(
      codeUp: 'FRI',
      codeLo: 'fri',

      name: 'Frisch Sanskrit Reader Vocabulary, 1956',
      title: 'Frisch Sanskrit Reader Vocabulary, 1956',
      hasAccent: false,
      hasDevaTextOption: false,
      worldCatUrl: 'https://search.worldcat.org/title/255638305',
      bibliographicEntry:
          'FRISH, O. (1956). Sanskrit Reader Dictionary / ed. V. Porzhizka. Prague.',
    ),
  ];

  /// Look up a dictionary by its lowercase code.
  static DictionaryInfo? byCode(String code) {
    final lo = code.toLowerCase();
    try {
      return all.firstWhere((d) => d.codeLo == lo);
    } catch (_) {
      return null;
    }
  }
}
