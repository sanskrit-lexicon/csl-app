/// Dictionary metadata for a single CSL dictionary.
class DictionaryInfo {
  final String codeUp; // e.g. "LAN"
  final String codeLo; // e.g. "lan"
  final String name; // e.g. "Lanman Sanskrit Reader Dictionary"
  final String title; // e.g. "Lanman Sanskrit Reader Dictionary 1884"
  final String year; // e.g. "2020"
  final bool hasAccent;
  final bool hasDevaTextOption; // can search Sanskrit in body text too
  final String worldCatUrl;
  final String bibliographicEntry;

  const DictionaryInfo({
    required this.codeUp,
    required this.codeLo,
    required this.name,
    required this.title,
    required this.year,
    required this.hasAccent,
    required this.hasDevaTextOption,
    required this.worldCatUrl,
    required this.bibliographicEntry,
  });

  /// Whether this is an English→Sanskrit dictionary (search is in English headwords).
  bool get isEnglishToSanskrit =>
      ['ae', 'mwe', 'bor'].contains(codeLo);

  /// Download URL for the zip file.
  String get downloadUrl =>
      'https://www.sanskrit-lexicon.uni-koeln.de/scans/${codeUp}Scan/$year/downloads/${codeLo}web1.zip';

  /// Correction form base URL.
  String get correctionBaseUrl =>
      'https://www.sanskrit-lexicon.uni-koeln.de/scans/csl-corrections/app/correction_form.php?dict=$codeUp';

  /// PDF view URL.
  String pdfUrl(String pageCol) =>
      'https://www.sanskrit-lexicon.uni-koeln.de/scans/csl-apidev/servepdf.php?dict=$codeUp&page=$pageCol';
}
