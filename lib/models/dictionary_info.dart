/// Dictionary metadata for a single CSL dictionary.
class DictionaryInfo {
  final String codeUp; // e.g. "LAN"
  final String codeLo; // e.g. "lan"
  final String name; // e.g. "Lanman Sanskrit Reader Dictionary"
  final String title; // e.g. "Lanman Sanskrit Reader Dictionary 1884"
  final bool hasAccent;
  final bool hasDevaTextOption; // can search Sanskrit in body text too
  final String worldCatUrl;
  final String bibliographicEntry;

  /// Language group, e.g. "Sanskrit-English". Null if unknown.
  final String? group;

  /// "active" | "deprecated" | "excluded" (excluded is never listed).
  final String status;

  /// True if headwords are English (search/display skip SLP1 conversion).
  final bool englishHeadwords;

  /// Selects dictionary-specific rendering: "default" or e.g. "abch".
  final String renderProfile;

  const DictionaryInfo({
    required this.codeUp,
    required this.codeLo,
    required this.name,
    required this.title,
    required this.hasAccent,
    required this.hasDevaTextOption,
    required this.worldCatUrl,
    required this.bibliographicEntry,
    this.group,
    this.status = 'active',
    this.englishHeadwords = false,
    this.renderProfile = 'default',
  });

  /// Build an entry for a dictionary the app has no built-in data for,
  /// from one element of the csl-sqlite `dictionaries.json` manifest.
  factory DictionaryInfo.fromManifest(Map<String, dynamic> m) {
    final code = (m['code'] as String).toLowerCase();
    final name = ((m['name'] as String?)?.trim().isNotEmpty ?? false)
        ? (m['name'] as String).trim()
        : code.toUpperCase();
    final year = m['year'] as int?;
    final authors = (m['authors'] as String?)?.trim() ?? '';
    return DictionaryInfo(
      codeUp: code.toUpperCase(),
      codeLo: code,
      name: name,
      title: year != null ? '$name $year' : name,
      hasAccent: m['hasAccent'] as bool? ?? false,
      hasDevaTextOption: m['hasDeva'] as bool? ?? false,
      worldCatUrl: '',
      bibliographicEntry: [
        if (authors.isNotEmpty) authors,
        if (year != null) '($year)',
        '$name.',
      ].join(' '),
      group: m['group'] as String?,
      status: m['status'] as String? ?? 'active',
      englishHeadwords: m['englishHeadwords'] as bool? ?? false,
      renderProfile: m['renderProfile'] as String? ?? 'default',
    );
  }

  /// This entry with the manifest's classification fields applied; keeps the
  /// built-in name/bibliography, which are curated.
  DictionaryInfo withManifest(Map<String, dynamic> m) => DictionaryInfo(
        codeUp: codeUp,
        codeLo: codeLo,
        name: name,
        title: title,
        hasAccent: hasAccent,
        hasDevaTextOption: hasDevaTextOption,
        worldCatUrl: worldCatUrl,
        bibliographicEntry: bibliographicEntry,
        group: m['group'] as String? ?? group,
        status: m['status'] as String? ?? status,
        englishHeadwords: m['englishHeadwords'] as bool? ?? englishHeadwords,
        renderProfile: m['renderProfile'] as String? ?? renderProfile,
      );

  /// Whether this is an English→Sanskrit dictionary (search is in English headwords).
  bool get isEnglishToSanskrit => englishHeadwords;

  /// Download URL for the zip file.
  String get downloadUrl =>
      'https://sanskrit-lexicon.github.io/csl-sqlite/$codeLo.zip';

  /// Correction form base URL.
  String get correctionBaseUrl =>
      'https://www.sanskrit-lexicon.uni-koeln.de/scans/csl-corrections/app/correction_form.php?dict=$codeUp';

  /// PDF view URL.
  String pdfUrl(String pageCol) =>
      'https://www.sanskrit-lexicon.uni-koeln.de/scans/csl-apidev/servepdf.php?dict=$codeUp&page=$pageCol';
}
