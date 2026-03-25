# Public API Reference (version 0.1.4)

This document lists all public classes, functions, and methods in the CSL App codebase. Each entry includes the file location, description, parameters, return types, and usage examples where applicable.

---

## Table of Contents

1. [Core Services](#core-services)
2. [Rendering](#rendering)
3. [Models](#models)
4. [Providers](#providers)
5. [Main App](#main-app)

---

## Core Services

### 1. `lib/core/ls_service.dart`

#### Class: `LsResult`

Represents the result of processing a literary source (LS) reference.

| Property | Type | Description |
|----------|------|-------------|
| `expansion` | `String?` | The expanded/full name of the literary source |
| `href` | `String?` | External URL to the scanned text source |
| `tooltip` | `String?` | Tooltip text (falls back to expansion or key) |

**Constructor:**
```dart
LsResult({this.expansion, this.href, this.tooltip});
```

---

#### Class: `LsService`

Provides functionality to process literary source (LS) references from dictionary entries and generate links to external scanned text repositories.

##### Static Method: `romanInt`

Converts a Roman numeral string to its integer value.

| Parameter | Type | Description |
|-----------|------|-------------|
| `roman` | `String` | Roman numeral string (e.g., "i", "ii", "iii", "xii") |

**Returns:** `int` - The integer value, or 0 if not a valid Roman numeral.

```dart
final value = LsService.romanInt("xii"); // Returns 12
```

---

##### Static Method: `extractFirstKey`

Extracts the first key/abbreviation from LS reference text.

| Parameter | Type | Description |
|-----------|------|-------------|
| `data` | `String` | The LS reference text |

**Returns:** `String?` - The extracted key (e.g., "RV.", "MBh."), or null if not found.

```dart
final key = LsService.extractFirstKey("RV. 1.2.3"); // Returns "RV."
```

---

##### Static Method: `getPrefix`

Gets the URL prefix for a dictionary-specific abbreviation key.

| Parameter | Type | Description |
|-----------|------|-------------|
| `dict` | `String` | Dictionary code (e.g., "mw", "pwg", "ap90") |
| `key` | `String` | Abbreviation key (e.g., "RV.", "MBh.", "R.") |

**Returns:** `String?` - The URL prefix (e.g., "rv", "av", "p", "MBH"), or null if not found.

```dart
final prefix = LsService.getPrefix("mw", "RV."); // Returns "rv"
```

---

##### Static Method: `generateHref`

Generates an external URL for a literary source reference.

| Parameter | Type | Description |
|-----------|------|-------------|
| `dict` | `String` | Dictionary code (e.g., "mw", "pwg") |
| `key` | `String` | Abbreviation key |
| `nAttribute` | `String?` | Optional 'n' attribute value from the LS tag |
| `data` | `String` | The full LS reference text |

**Returns:** `String?` - The generated URL, or null if no pattern matches.

```dart
final href = LsService.generateHref("mw", "RV.", null, "RV. 1.2.3");
// Returns: "https://sanskrit-lexicon.github.io/rvlinks/rvhymns/rv01.001.html#rv01.001.01"
```

---

##### Static Method: `processLs`

Processes a single literary source reference and returns expansion and URL.

| Parameter | Type | Description |
|-----------|------|-------------|
| `dictCode` | `String` | Dictionary code (e.g., "mw", "pwg") |
| `lsContent` | `String` | The LS reference text content |
| `nAttribute` | `String?` | Optional 'n' attribute from `<ls n="...">` tag |

**Returns:** `Future<LsResult?>` - The result containing expansion, href, and tooltip.

```dart
final result = await LsService.processLs(
  dictCode: "mw",
  lsContent: "RV. 1.1.1",
  nAttribute: null,
);
```

---

##### Static Method: `batchProcessLs`

Processes multiple LS references in batch.

| Parameter | Type | Description |
|-----------|------|-------------|
| `dictCode` | `String` | Dictionary code |
| `lsContents` | `List<String>` | List of LS reference texts |
| `nAttributes` | `List<String>?` | Optional list of 'n' attributes for each reference |

**Returns:** `Future<Map<String, LsResult>>` - Map keyed by LS content string.

```dart
final results = await LsService.batchProcessLs(
  dictCode: "mw",
  lsContents: ["RV. 1.1.1", "AV. 2.1.1"],
  nAttributes: null,
);
```

---

##### Static Method: `hrefRvAv`

Generates URL for Rig Veda or Atharva Veda references.

| Parameter | Type | Description |
|-----------|------|-------------|
| `pfx` | `String` | Prefix ("rv" or "av") |
| `data1` | `String` | Reference text (e.g., "RV. 1.2.3") |
| `dict` | `String` | Dictionary code |

**Returns:** `String?` - URL to the hymn, or null if parsing fails.

---

##### Static Method: `hrefPanini`

Generates URL for Panini Ashtadhyayi references.

| Parameter | Type | Description |
|-----------|------|-------------|
| `data1` | `String` | Reference text (e.g., "Pāṇ. 1.2.3") |
| `dict` | `String` | Dictionary code |

**Returns:** `String?` - URL to ashtadhyayi.com, or null if parsing fails.

---

##### Static Method: `hrefRamayana`

Generates URL for Ramayana references (Schlegel/Gorresio edition).

| Parameter | Type | Description |
|-----------|------|-------------|
| `data1` | `String` | Reference text (e.g., "R. 1.2.3") |
| `dict` | `String` | Dictionary code |

**Returns:** `String?` - URL to scanned Ramayana, or null if parsing fails.

---

##### Static Method: `hrefRamayanaBombay`

Generates URL for Ramayana Bombay edition references.

| Parameter | Type | Description |
|-----------|------|-------------|
| `data1` | `String` | Reference text |

**Returns:** `String?` - URL to Bombay edition.

---

##### Static Method: `hrefRamayanaGorresio`

Generates URL for Ramayana Gorresio edition references.

| Parameter | Type | Description |
|-----------||------|-------------|
| `data1` | `String` | Reference text |

**Returns:** `String?` - URL to Gorresio edition.

---

##### Static Method: `hrefMahabharata`

Generates URL for Mahabharata references.

| Parameter | Type | Description |
|-----------|------|-------------|
| `data1` | `String` | Reference text (e.g., "MBH. 1.2.3") |
| `pfx` | `String` | Edition prefix ("MBHC" for Calcutta, "MBHB" for Bombay) |

**Returns:** `String?` - URL to scanned Mahabharata.

---

##### Static Method: `hrefPancatantra`

Generates URL for Pancatantra references.

| Parameter | Type | Description |
|-----------|------|-------------|
| `data1` | `String` | Reference text |

**Returns:** `String?` - URL to Pancatantra scanned text.

---

##### Static Method: `hrefHarivamsa`

Generates URL for Harivamsa references.

| Parameter | Type | Description |
|-----------|------|-------------|
| `data1` | `String` | Reference text |

**Returns:** `String?` - URL to Harivamsa scanned text.

---

##### Static Method: `hrefBhagavataPurana`

Generates URL for Bhagavata Purana references.

| Parameter | Type | Description |
|-----------|------|-------------|
| `data1` | `String` | Reference text |

**Returns:** `String?` - URL to Bhagavata Purana scanned text.

---

##### Static Method: `hrefRaghuvamsa`

Generates URL for Raghuvamsa references.

| Parameter | Type | Description |
|-----------|------|-------------|
| `data1` | `String` | Reference text |
| `pfx` | `String` | Edition prefix |

**Returns:** `String?` - URL to Raghuvamsa scanned text.

---

##### Static Method: `hrefVajasansamhita`

Generates URL for Vajasaneyi Samhita references.

| Parameter | Type | Description |
|-----------|------|-------------|
| `data1` | `String` | Reference text |

**Returns:** `String?` - URL to Vajasaneyi Samhita.

---

##### Static Method: `hrefTaittiriyaSamhita`

Generates URL for Taittiriya Samhita references.

| Parameter | Type | Description |
|-----------|------|-------------|
| `data1` | `String` | Reference text |

**Returns:** `String?` - URL to Taittiriya Samhita.

---

##### Static Method: `hrefSatapathaBrahmana`

Generates URL for Satapatha Brahmana references.

| Parameter | Type | Description |
|-----------|------|-------------|
| `data1` | `String` | Reference text |

**Returns:** `String?` - URL to Satapatha Brahmana.

---

##### Static Method: `hrefMeghaduta`

Generates URL for Meghaduta references.

| Parameter | Type | Description |
|-----------|------|-------------|
| `data1` | `String` | Reference text |

**Returns:** `String?` - URL to Meghaduta.

---

##### Static Method: `hrefKumarasambhava`

Generates URL for Kumarasambhava references.

| Parameter | Type | Description |
|-----------|------|-------------|
| `data1` | `String` | Reference text |

**Returns:** `String?` - URL to Kumarasambhava.

---

##### Static Method: `hrefMalavikagnimitra`

Generates URL for Malavikagnimitra references.

| Parameter | Type | Description |
|-----------|------|-------------|
| `data1` | `String` | Reference text |

**Returns:** `String?` - URL to Malavikagnimitra.

---

##### Static Method: `hrefVikramorvashiya`

Generates URL for Vikramorvashiya references.

| Parameter | Type | Description |
|-----------|------|-------------|
| `data1` | `String` | Reference text |

**Returns:** `String?` - URL to Vikramorvashiya.

---

##### Static Method: `hrefBhagavadGita`

Generates URL for Bhagavad Gita references.

| Parameter | Type | Description |
|-----------|------|-------------|
| `data1` | `String` | Reference text |

**Returns:** `String?` - URL to Bhagavad Gita.

---

##### Static Method: `hrefManu`

Generates URL for Manu Smriti references.

| Parameter | Type | Description |
|-----------|------|-------------|
| `data1` | `String` | Reference text |

**Returns:** `String?` - URL to Manu Smriti.

---

##### Static Method: `hrefNirukta`

Generates URL for Nirukta references.

| Parameter | Type | Description |
|-----------|------|-------------|
| `data1` | `String` | Reference text |

**Returns:** `String?` - URL to Nirukta.

---

##### Static Method: `hrefKathasaritsagara`

Generates URL for Kathasaritsagara references.

| Parameter | Type | Description |
|-----------|------|-------------|
| `data1` | `String` | Reference text |

**Returns:** `String?` - URL to Kathasaritsagara.

---

##### Static Method: `hrefSpruch`

Generates URL for Spruch references (PWG dictionary).

| Parameter | Type | Description |
|-----------|------|-------------|
| `data1` | `String` | Reference text |

**Returns:** `String?` - URL to Spruch text.

---

##### Static Method: `hrefVerzOxf`

Generates URL for Verzeichnis der Oxforder Handschriften references.

| Parameter | Type | Description |
|-----------|------|-------------|
| `data1` | `String` | Reference text |

**Returns:** `String?` - URL to Oxford catalog.

---

##### Static Method: `hrefAmarakoSa`

Generates URL for Amarakosha references.

| Parameter | Type | Description |
|-----------|------|-------------|
| `data1` | `String` | Reference text (e.g., "AK. 1.2.3.4") |

**Returns:** `String?` - URL to Amarakosha.

---

##### Static Method: `hrefHemacandra`

Generates URL for Hemacandra Anekartha references.

| Parameter | Type | Description |
|-----------|------|-------------|
| `data1` | `String` | Reference text (e.g., "H. 123") |

**Returns:** `String?` - URL to Anekarthasamgraha.

---

##### Static Method: `hrefAnekartha`

Generates URL for Anekartha references.

| Parameter | Type | Description |
|-----------|------|-------------|
| `data1` | `String` | Reference text (e.g., "an. 1.2") |

**Returns:** `String?` - URL to Anekarthasamgraha.

---

##### Static Method: `hrefMedini`

Generates URL for Medini Kosha references.

| Parameter | Type | Description |
|-----------|------|-------------|
| `data1` | `String` | Reference text (e.g., "MED. a. 123") |

**Returns:** `String?` - URL to Medini Kosha.

---

##### Static Method: `hrefShakuntalaPwg`

Generates URL for Shakuntala references (PWG dictionary).

| Parameter | Type | Description |
|-----------|------|-------------|
| `data1` | `String` | Reference text |

**Returns:** `String?` - URL to Shakuntala.

---

##### Static Method: `hrefRajatarPwg`

Generates URL for Rajatarangini references (PWG dictionary).

| Parameter | Type | Description |
|-----------|------|-------------|
| `data1` | `String` | Reference text |

**Returns:** `String?` - URL to Rajatarangini.

---

##### Static Method: `hrefRaghPwg`

Generates URL for Raghuvamsa references (PWG dictionary).

| Parameter | Type | Description |
|-----------|------|-------------|
| `data1` | `String` | Reference text |
| `pfx` | `String` | Edition prefix |

**Returns:** `String?` - URL to Raghuvamsa.

---

##### Static Method: `hrefMarkandeyaPuranaPwg`

Generates URL for Markandeya Purana references (PWG dictionary).

| Parameter | Type | Description |
|-----------|------|-------------|
| `data1` | `String` | Reference text |

**Returns:** `String?` - URL to Markandeya Purana.

---

##### Static Method: `hrefBhagavadGitaPwg`

Generates URL for Bhagavad Gita references (PWG dictionary).

| Parameter | Type | Description |
|-----------|------|-------------|
| `data1` | `String` | Reference text |

**Returns:** `String?` - URL to Bhagavad Gita.

---

##### Static Method: `hrefYajnavalkya`

Generates URL for Yajnavalkya Smriti references.

| Parameter | Type | Description |
|-----------|------|-------------|
| `data1` | `String` | Reference text |

**Returns:** `String?` - URL to Yajnavalkya.

---

##### Static Method: `hrefAitareyaBrahmana`

Generates URL for Aitareya Brahmana references.

| Parameter | Type | Description |
|-----------|------|-------------|
| `data1` | `String` | Reference text |

**Returns:** `String?` - URL to Aitareya Brahmana.

---

### 2. `lib/core/ls_patterns.dart`

#### Class: `LsPattern`

Represents a pattern for matching literary source references and generating URLs.

| Property | Type | Description |
|----------|------|-------------|
| `prefixes` | `List<String>` | List of text prefixes that trigger this pattern |
| `regex` | `String` | Regular expression to match the reference |
| `urlTemplate` | `String` | URL template or special handler name |
| `dicts` | `List<String>?` | Optional list of dictionary codes this pattern applies to |

**Constructor:**
```dart
const LsPattern({
  required this.prefixes,
  required this.regex,
  required this.urlTemplate,
  this.dicts,
});
```

---

#### Class: `LsPatterns`

Static collections of URL patterns for different dictionary families.

##### Static Field: `pwg`

`List<LsPattern>` - URL patterns for PWG, PW, and PWKVN dictionaries.

---

##### Static Field: `mw`

`List<LsPattern>` - URL patterns for MW, GRA, AP90, SCH, BEN, AP, BHS dictionaries.

---

##### Static Method: `getPatternsForDict`

Returns the appropriate pattern list for a given dictionary code.

| Parameter | Type | Description |
|-----------|------|-------------|
| `dict` | `String` | Dictionary code |

**Returns:** `List<LsPattern>` - The pattern list for the dictionary.

```dart
final patterns = LsPatterns.getPatternsForDict("mw");
```

---

### 3. `lib/core/search_service.dart`

#### Class: `SearchService`

Provides headword and definition search functionality against dictionary SQLite databases.

##### Static Method: `searchHeadword`

Searches dictionary headwords (key column).

| Parameter | Type | Description |
|-----------|------|-------------|
| `dictCode` | `String` | Dictionary code (e.g., "mw", "pwg") |
| `inputWord` | `String` | Search input from user |
| `inputTranslit` | `String` | Input transliteration scheme (e.g., "itrans", "hk") |
| `mode` | `SearchMode` | Search mode (prefix, exact, suffix, substring) |
| `maxResults` | `int` | Maximum number of results to return |

**Returns:** `Future<List<SearchResult>>` - List of matching entries.

```dart
final results = await SearchService.searchHeadword(
  dictCode: "mw",
  inputWord: "agni",
  inputTranslit: "itrans",
  mode: SearchMode.prefix,
  maxResults: 100,
);
```

---

##### Static Method: `searchDefinition`

Searches dictionary definition body (data column).

| Parameter | Type | Description |
|-----------|------|-------------|
| `dictCode` | `String` | Dictionary code |
| `inputWord` | `String` | Search input |
| `inputTranslit` | `String` | Input transliteration scheme (for headword search) |
| `outputTranslit` | `String` | Output transliteration scheme (for definition search - matches displayed text) |
| `mode` | `SearchMode` | Search mode (always uses substring for definitions) |
| `maxResults` | `int` | Maximum results |

**Returns:** `Future<List<SearchResult>>` - List of matching entries.

```dart
final results = await SearchService.searchDefinition(
  dictCode: "mw",
  inputWord: "धवल",
  inputTranslit: "slp1",
  outputTranslit: "devanagari",
  mode: SearchMode.substring,
  maxResults: 100,
);
```

---

##### Static Method: `searchCombined`

Searches with both headword and definition conditions.

| Parameter | Type | Description |
|-----------|------|-------------|
| `dictCode` | `String` | Dictionary code |
| `hwInput` | `String` | Headword search input |
| `defInput` | `String` | Definition search input |
| `inputTranslit` | `String` | Input transliteration scheme (for headword search) |
| `outputTranslit` | `String` | Output transliteration scheme (for definition search - matches displayed text) |
| `hwMode` | `SearchMode` | Headword search mode |
| `maxResults` | `int` | Maximum results |

**Returns:** `Future<List<SearchResult>>` - Entries matching both conditions.

```dart
final results = await SearchService.searchCombined(
  dictCode: "mw",
  hwInput: "agni",
  defInput: "धवल",
  inputTranslit: "slp1",
  outputTranslit: "devanagari",
  hwMode: SearchMode.prefix,
  maxResults: 100,
);
```

---

##### Static Method: `fetchByKey`

Fetches a single entry by exact SLP1 headword key.

| Parameter | Type | Description |
|-----------|------|-------------|
| `dictCode` | `String` | Dictionary code |
| `slp1Key` | `String` | Exact SLP1 headword |

**Returns:** `Future<SearchResult?>` - The matching entry or null.

```dart
final result = await SearchService.fetchByKey(
  dictCode: "mw",
  slp1Key: "agni",
);
```

---

##### Static Method: `fetchAbbreviation`

Fetches abbreviation expansion from abbreviation database.

| Parameter | Type | Description |
|-----------|------|-------------|
| `dictCode` | `String` | Dictionary code |
| `abbr` | `String` | Abbreviation text |

**Returns:** `Future<String?>` - Expanded text or null.

```dart
final expansion = await SearchService.fetchAbbreviation(
  dictCode: "mw",
  abbr: "V.",
);
```

---

##### Static Method: `fetchLsExpansion`

Fetches literary source expansion from authtooltips or bib database.

| Parameter | Type | Description |
|-----------|------|-------------|
| `dictCode` | `String` | Dictionary code |
| `code` | `String` | LS reference code |

**Returns:** `Future<String?>` - Full name or null.

```dart
final expansion = await SearchService.fetchLsExpansion(
  dictCode: "mw",
  code: "RV.",
);
```

---

### 4. `lib/core/database_helper.dart`

#### Class: `DatabaseHelper`

Manages SQLite database connections for all dictionaries.

##### Static Method: `dataDir`

Gets the app documents subdirectory path for sanslex data.

**Returns:** `Future<String>` - Full path to data directory.

```dart
final path = await DatabaseHelper.dataDir;
```

---

##### Static Method: `dbPath`

Gets full path to main dictionary SQLite file.

| Parameter | Type | Description |
|-----------|------|-------------|
| `dictCode` | `String` | Dictionary code |

**Returns:** `Future<String>` - Full path to .sqlite file.

```dart
final path = await DatabaseHelper.dbPath("mw");
```

---

##### Static Method: `abDbPath`

Gets full path to abbreviation database SQLite file.

| Parameter | Type | Description |
|-----------|------|-------------|
| `dictCode` | `String` | Dictionary code |

**Returns:** `Future<String>` - Full path to ab.sqlite file.

---

##### Static Method: `authTooltipsDbPath`

Gets full path to authtooltips database SQLite file.

| Parameter | Type | Description |
|-----------|------|-------------|
| `dictCode` | `String` | Dictionary code |

**Returns:** `Future<String>` - Full path to authtooltips.sqlite file.

---

##### Static Method: `bibDbPath`

Gets full path to bibliography database SQLite file.

| Parameter | Type | Description |
|-----------|------|-------------|
| `dictCode` | `String` | Dictionary code |

**Returns:** `Future<String>` - Full path to bib.sqlite file.

---

##### Static Method: `isAvailable`

Checks if dictionary files exist on device.

| Parameter | Type | Description |
|-----------|------|-------------|
| `dictCode` | `String` | Dictionary code |

**Returns:** `Future<bool>` - True if dictionary is available.

```dart
final available = await DatabaseHelper.isAvailable("mw");
```

---

##### Static Method: `openDict`

Opens or returns cached main dictionary database.

| Parameter | Type | Description |
|-----------|------|-------------|
| `dictCode` | `String` | Dictionary code |

**Returns:** `Future<Database>` - SQLite database instance.

```dart
final db = await DatabaseHelper.openDict("mw");
```

---

##### Static Method: `openAbDict`

Opens or returns cached abbreviation database.

| Parameter | Type | Description |
|-----------|------|-------------|
| `dictCode` | `String` | Dictionary code |

**Returns:** `Future<Database>` - SQLite database instance.

---

##### Static Method: `openAuthTooltips`

Opens or returns cached authtooltips database.

| Parameter | Type | Description |
|-----------|------|-------------|
| `dictCode` | `String` | Dictionary code |

**Returns:** `Future<Database?>` - Database instance or null if not available.

---

##### Static Method: `openBib`

Opens or returns cached bibliography database.

| Parameter | Type | Description |
|-----------|------|-------------|
| `dictCode` | `String` | Dictionary code |

**Returns:** `Future<Database?>` - Database instance or null if not available.

---

##### Static Method: `closeDict`

Closes and removes a dictionary from cache.

| Parameter | Type | Description |
|-----------|------|-------------|
| `dictCode` | `String` | Dictionary code |

**Returns:** `Future<void>`

```dart
await DatabaseHelper.closeDict("mw");
```

---

##### Static Method: `closeAll`

Closes all open databases.

**Returns:** `Future<void>`

```dart
await DatabaseHelper.closeAll();
```

---

### 5. `lib/core/download_service.dart`

#### Class: `DownloadService`

Manages downloading and deleting dictionary SQLite files.

##### Static Method: `downloadDictionary`

Downloads and extracts dictionary zip from CSL server.

| Parameter | Type | Description |
|-----------|------|-------------|
| `info` | `DictionaryInfo` | Dictionary metadata |
| `onProgress` | `void Function(double progress, String status)` | Progress callback |
| `cancelToken` | `ValueNotifier<bool>` | Cancellation token |

**Returns:** `Future<void>`

```dart
final info = DictionaryRegistry.byCode("mw")!;
await DownloadService.downloadDictionary(
  info: info,
  onProgress: (progress, status) {
    print("$status: ${(progress * 100).toStringAsFixed(0)}%");
  },
  cancelToken: ValueNotifier<bool>(false),
);
```

---

##### Static Method: `deleteDictionary`

Deletes all SQLite files for a dictionary.

| Parameter | Type | Description |
|-----------|------|-------------|
| `dictCode` | `String` | Dictionary code |

**Returns:** `Future<void>`

```dart
await DownloadService.deleteDictionary("mw");
```

---

##### Static Method: `downloadedSize`

Gets combined file size of downloaded dictionary.

| Parameter | Type | Description |
|-----------|------|-------------|
| `dictCode` | `String` | Dictionary code |

**Returns:** `Future<int?>` - Size in bytes, or null if not downloaded.

```dart
final size = await DownloadService.downloadedSize("mw");
```

---

##### Static Method: `isDownloaded`

Checks if dictionary is downloaded.

| Parameter | Type | Description |
|-----------|------|-------------|
| `dictCode` | `String` | Dictionary code |

**Returns:** `Future<bool>` - True if downloaded.

```dart
final downloaded = await DownloadService.isDownloaded("mw");
```

---

##### Static Method: `fetchRemoteMetadata`

Fetches remote zip file size and last-modified date.

| Parameter | Type | Description |
|-----------|------|-------------|
| `info` | `DictionaryInfo` | Dictionary metadata |

**Returns:** `Future<({int? size, DateTime? lastModified})>` - Remote metadata.

```dart
final meta = await DownloadService.fetchRemoteMetadata(info);
```

---

##### Static Method: `formatBytes`

Formats bytes as human-readable string.

| Parameter | Type | Description |
|-----------|------|-------------|
| `bytes` | `int` | Size in bytes |

**Returns:** `String` - Formatted string (e.g., "10.5 MB").

```dart
final formatted = DownloadService.formatBytes(10485760); // "10.0 MB"
```

---

### 6. `lib/core/settings_service.dart`

#### Class: `SettingsService`

Persists and loads AppSettings using SharedPreferences.

##### Static Method: `load`

Loads settings from SharedPreferences.

**Returns:** `Future<AppSettings>` - Loaded settings with defaults for missing values.

```dart
final settings = await SettingsService.load();
```

---

##### Static Method: `save`

Saves settings to SharedPreferences.

| Parameter | Type | Description |
|-----------|------|-------------|
| `s` | `AppSettings` | Settings to save |

**Returns:** `Future<void>`

```dart
await SettingsService.save(settings);
```

---

### 7. `lib/core/dictionary_registry.dart`

#### Class: `DictionaryInfo`

Metadata for a single CSL dictionary.

| Property | Type | Description |
|----------|------|-------------|
| `codeUp` | `String` | Uppercase code (e.g., "MW") |
| `codeLo` | `String` | Lowercase code (e.g., "mw") |
| `name` | `String` | Full dictionary name |
| `title` | `String` | Title with year |
| `year` | `String` | Publication year |
| `hasAccent` | `bool` | Whether dictionary has accent marks |
| `hasDevaTextOption` | `bool` | Whether Sanskrit body text search is available |
| `worldCatUrl` | `String` | WorldCat catalog URL |
| `bibliographicEntry` | `String` | Full bibliographic citation |

**Constructor:**
```dart
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
```

##### Getter: `isEnglishToSanskrit`

**Returns:** `bool` - True if this is an English→Sanskrit dictionary.

##### Getter: `downloadUrl`

**Returns:** `String` - URL to download zip file.

##### Getter: `correctionBaseUrl`

**Returns:** `String` - Base URL for correction form.

##### Method: `pdfUrl`

Generates PDF view URL for a page/column.

| Parameter | Type | Description |
|-----------|------|-------------|
| `pageCol` | `String` | Page/column identifier (e.g., "111-a") |

**Returns:** `String` - Full PDF URL.

---

#### Class: `DictionaryRegistry`

Complete catalogue of all CSL dictionaries.

##### Static Field: `all`

`List<DictionaryInfo>` - All available dictionaries.

---

##### Static Method: `byCode`

Looks up dictionary by code.

| Parameter | Type | Description |
|-----------|------|-------------|
| `code` | `String` | Dictionary code (case-insensitive) |

**Returns:** `DictionaryInfo?` - The dictionary info or null.

```dart
final info = DictionaryRegistry.byCode("mw");
```

---

### 8. `lib/core/transliteration_service.dart`

#### Class: `TransliterationService`

Wrapper around indic_transliteration_dart for transliteration needs.

##### Static Method: `init`

Initializes the underlying indic_transliteration_dart schemes. Must be called once before any transliteration.

**Returns:** `void`

```dart
TransliterationService.init();
```

---

##### Static Field: `availableSchemes`

`List<String>` - All supported transliteration scheme codes:
- `slp1`, `hk`, `itrans`, `iast`, `kolkata`, `velthuis`, `wx`, `optitrans`
- `devanagari`, `bengali`, `gujarati`, `gurmukhi`, `kannada`, `malayalam`, `oriya`, `telugu`, `tamil`

---

##### Static Field: `schemeDisplayNames`

`Map<String, String>` - Human-readable display names for each scheme.

---

##### Static Method: `transliterate`

Transliterates text from one scheme to another.

| Parameter | Type | Description |
|-----------|------|-------------|
| `text` | `String` | Input text |
| `fromScheme` | `String` | Source scheme code |
| `toScheme` | `String` | Target scheme code |

**Returns:** `String` - Transliterated text, or original on error.

```dart
final devanagari = TransliterationService.transliterate("agni", "slp1", "devanagari");
// Returns "अग्नि"
```

---

##### Static Method: `toSlp1`

Converts text to SLP1 for database queries.

| Parameter | Type | Description |
|-----------|------|-------------|
| `text` | `String` | Input text |
| `fromScheme` | `String` | Source scheme |

**Returns:** `String` - SLP1 representation.

```dart
final slp1 = TransliterationService.toSlp1("agni", "itrans");
```

---

##### Static Method: `fromSlp1`

Converts SLP1 to display scheme.

| Parameter | Type | Description |
|-----------|------|-------------|
| `text` | `String` | SLP1 input |
| `toScheme` | `String` | Target scheme |
| `useAccented` | `bool` | Whether to show accent marks (default: false) |
| `dictCode` | `String?` | Optional dictionary code for dictionary-specific overrides |

**Returns:** `String` - Transliterated text.

```dart
final deva = TransliterationService.fromSlp1(
  "agni",
  "devanagari",
  useAccent: true,
);
```

---

##### Static Method: `stripSLP1Accents`

Removes SLP1 accent markers.

| Parameter | Type | Description |
|-----------|------|-------------|
| `slp1Text` | `String` | SLP1 text with potential accent markers |

**Returns:** `String` - Text without accent markers.

```dart
final plain = TransliterationService.stripSLP1Accents("agni/"); // "agni"
```

---

##### Static Method: `displayName`

Gets human-readable name for a scheme code.

| Parameter | Type | Description |
|-----------|------|-------------|
| `scheme` | `String` | Scheme code |

**Returns:** `String` - Display name.

```dart
final name = TransliterationService.displayName("iast"); // "IAST (Roman)"
```

---

### 9. `lib/core/logger.dart`

#### Class: `AppLogger`

Debug logging utilities.

##### Static Field: `debugEnabled`

`bool` - Whether debug logging is enabled. Default: `true`.

---

##### Static Method: `debug`

Logs debug message if enabled.

| Parameter | Type | Description |
|-----------|------|-------------|
| `message` | `String` | Debug message |

**Returns:** `void`

```dart
AppLogger.debug("Search query: $query");
```

---

##### Static Method: `entry`

Logs dictionary entry debug information.

| Parameter | Type | Description |
|-----------|------|-------------|
| `dictCode` | `String` | Dictionary code |
| `lnum` | `double` | Entry line number |
| `key1` | `String` | Headword key |
| `bodyHtml` | `String` | Entry body HTML |

**Returns:** `void`

```dart
AppLogger.entry("mw", 1.0, "agni", "<body>...</body>");
```

---

## Rendering

### 10. `lib/rendering/entry_renderer.dart`

#### Class: `EntryRenderer`

Renders a ParsedEntry as a Flutter widget.

| Property | Type | Description |
|----------|------|-------------|
| `settings` | `AppSettings` | App settings |
| `dictCode` | `String` | Dictionary code |
| `useCologneTheme` | `bool` | Whether to use Cologne theme colors |
| `customAccentColor` | `Color?` | Custom accent color override |
| `customHeadwordColor` | `Color?` | Custom headword color override |

**Constructor:**
```dart
EntryRenderer({
  required this.settings,
  required this.dictCode,
  this.useCologneTheme = false,
  this.customAccentColor,
  this.customHeadwordColor,
});
```

---

##### Method: `buildEntryWidget`

Builds the full entry widget.

| Parameter | Type | Description |
|-----------|------|-------------|
| `entry` | `ParsedEntry` | Parsed dictionary entry |
| `onWordTap` | `void Function(String slp1Word)` | Callback for word tap |
| `onCopy` | `VoidCallback` | Callback for copy action |
| `dictCodeUp` | `String` | Uppercase dictionary code |
| `lnum` | `double` | Entry line number |
| `highlightTerm` | `String?` | Optional term to highlight |

**Returns:** `Future<Widget>` - Built Flutter widget.

```dart
final widget = await renderer.buildEntryWidget(
  entry: parsedEntry,
  onWordTap: (word) => print("Tapped: $word"),
  onCopy: () => print("Copied"),
  dictCodeUp: "MW",
  lnum: 1.0,
);
```

---

### 11. `lib/rendering/basic_display.dart`

#### Class: `BasicDisplay`

XML to HTML rendering module. Handles transformation of XML elements to HTML.

##### Static Method: `processHtml`

Processes HTML body with XML element transformations.

| Parameter | Type | Description |
|-----------|------|-------------|
| `html` | `String` | HTML string after BasicAdjust processing |
| `dictCode` | `String` | Dictionary code (e.g., "mw", "pwg") |
| `outputTranslit` | `String` | Output transliteration scheme (default: "devanagari") |
| `abbreviationCache` | `Map<String, String>` | Map of abbreviation to expansion |
| `highlightTerm` | `String?` | Optional term to highlight |
| `highlightEnabled` | `bool` | Whether highlighting is enabled |
| `lsHrefs` | `Map<String, String>` | Map of LS reference keys to external URLs |

**Returns:** `String` - Processed HTML ready for Flutter rendering.

```dart
final processed = BasicDisplay.processHtml(
  html: "<s>agni</s>",
  dictCode: "mw",
  outputTranslit: "devanagari",
  abbreviationCache: {"V.": "Veda"},
  highlightTerm: null,
  highlightEnabled: false,
  lsHrefs: {},
);
```

---

### 12. `lib/rendering/basic_adjust.dart`

#### Class: `BasicAdjust`

XML pre-processing module. Applies dictionary-specific transformations.

##### Static Method: `adjust`

Applies XML pre-processing adjustments.

| Parameter | Type | Description |
|-----------|------|-------------|
| `xmlData` | `String` | Raw XML data from database |
| `dictCode` | `String` | Dictionary code |
| `accent` | `bool` | Whether accent marks should be shown (default: false) |
| `outputTranslit` | `String` | Output transliteration scheme (default: "devanagari") |

**Returns:** `String` - Adjusted XML string.

```dart
final adjusted = BasicAdjust.adjust(
  xmlData: rawXml,
  dictCode: "mw",
  accent: true,
  outputTranslit: "devanagari",
);
```

---

### 13. `lib/rendering/entry_parser.dart`

#### Class: `LsRef`

Represents LS reference data extracted from HTML.

| Property | Type | Description |
|----------|------|-------------|
| `nAttribute` | `String?` | The 'n' attribute value |
| `text` | `String` | Text content of the LS reference |
| `fullMatch` | `String` | Full matched string |

**Constructor:**
```dart
LsRef({this.nAttribute, required this.text, required this.fullMatch});
```

---

#### Class: `ParsedEntry`

Structured representation of a parsed dictionary entry.

| Property | Type | Description |
|----------|------|-------------|
| `key1Slp1` | `String` | Headword in SLP1 |
| `key2Slp1` | `String?` | Headword with accent markers |
| `homonym` | `int?` | Homonym number |
| `bodyHtml` | `String` | Inner HTML of body element |
| `pageCol` | `String?` | Page/column (e.g., "111-a") |
| `lnum` | `double` | Entry serial number |

**Constructor:**
```dart
const ParsedEntry({
  required this.key1Slp1,
  this.key2Slp1,
  this.homonym,
  required this.bodyHtml,
  this.pageCol,
  required this.lnum,
});
```

---

#### Class: `EntryParser`

Parses XML-like data from dictionary SQLite rows.

##### Static Method: `parse`

Parses raw data string into ParsedEntry.

| Parameter | Type | Description |
|-----------|------|-------------|
| `xmlData` | `String` | Raw XML-like data from SQLite |
| `lnum` | `double` | Entry line number |

**Returns:** `ParsedEntry` - Structured entry.

```dart
final entry = EntryParser.parse(xmlData, 1.0);
```

---

##### Static Method: `extractAbbreviations`

Extracts all abbreviation texts from body HTML.

| Parameter | Type | Description |
|-----------|------|-------------|
| `bodyHtml` | `String` | Entry body HTML |

**Returns:** `List<String>` - List of unique abbreviations.

```dart
final abbrs = EntryParser.extractAbbreviations(bodyHtml);
```

---

##### Static Method: `extractLsReferences`

Extracts all LS reference codes from body HTML.

| Parameter | Type | Description |
|-----------|------|-------------|
| `bodyHtml` | `String` | Entry body HTML |

**Returns:** `List<String>` - List of LS reference codes.

```dart
final codes = EntryParser.extractLsReferences(bodyHtml);
```

---

##### Static Method: `extractLsRefsWithDetails`

Extracts LS references with full details.

| Parameter | Type | Description |
|-----------|------|-------------|
| `bodyHtml` | `String` | Entry body HTML |

**Returns:** `List<LsRef>` - List of LsRef objects.

```dart
final refs = EntryParser.extractLsRefsWithDetails(bodyHtml);
```

---

##### Static Method: `processBodyHtml`

Converts body HTML to form suitable for flutter_widget_from_html.

| Parameter | Type | Description |
|-----------|------|-------------|
| `bodyHtml` | `String` | Entry body HTML |
| `outputTranslit` | `String` | Output transliteration scheme |
| `abbreviationCache` | `Map<String, String>` | Abbreviation expansion cache |
| `highlightTerm` | `String?` | Term to highlight |
| `highlightEnabled` | `bool` | Whether highlighting is enabled |

**Returns:** `String` - Processed HTML.

```dart
final processed = EntryParser.processBodyHtml(
  bodyHtml: bodyHtml,
  outputTranslit: "devanagari",
  abbreviationCache: {},
  highlightTerm: null,
  highlightEnabled: false,
);
```

---

## Models

### 14. `lib/models/app_settings.dart`

#### Enum: `AppThemeMode`

Theme mode options:
- `cologne` - Cologne theme (light blue)
- `light` - Standard light theme
- `dark` - Dark theme
- `custom` - User-customized colors

---

#### Extension: `AppThemeModeX`

##### Getter: `label`

**Returns:** `String` - Human-readable label.

##### Getter: `toThemeMode`

**Returns:** `ThemeMode` - Flutter ThemeMode.

---

#### Class: `CustomThemePreset`

Predefined color theme preset.

| Property | Type | Description |
|----------|------|-------------|
| `name` | `String` | Preset name |
| `primary` | `Color` | Primary color |
| `background` | `Color` | Background color |
| `headword` | `Color` | Headword background |
| `sanskritText` | `Color` | Sanskrit text color |

---

#### Class: `CustomThemePresets`

Predefined custom theme presets.

##### Static Fields:
- `cologne` - Cologne theme preset
- `light` - Light theme preset  
- `dark` - Dark theme preset
- `white` - White theme preset

##### Static Field: `all`

`List<CustomThemePreset>` - All available presets.

---

#### Enum: `SearchMode`

Search mode options:
- `prefix` - Prefix matching
- `exact` - Exact match
- `suffix` - Suffix matching
- `substring` - Substring matching

---

#### Extension: `SearchModeX`

##### Getter: `label`

**Returns:** `String` - Human-readable label.

##### Getter: `value`

**Returns:** `String` - Mode name value.

##### Static Method: `fromValue`

Creates SearchMode from value string.

| Parameter | Type | Description |
|-----------|------|-------------|
| `v` | `String` | Mode value string |

**Returns:** `SearchMode` - SearchMode enum value.

---

#### Class: `AppSettings`

All user preferences/settings.

| Property | Type | Description |
|----------|------|-------------|
| `headwordSearchMode` | `SearchMode` | Headword search mode |
| `definitionSearchMode` | `SearchMode` | Definition search mode |
| `inputTranslit` | `String` | Input transliteration scheme |
| `outputTranslit` | `String` | Output transliteration scheme |
| `showAccent` | `bool` | Whether to show accent marks |
| `highlightEnabled` | `bool` | Whether search highlighting is enabled |
| `maxResults` | `int` | Maximum search results |
| `activeDictCodes` | `List<String>` | Active dictionary codes |
| `dictOrder` | `List<String>` | Dictionary order |
| `themeMode` | `AppThemeMode` | Theme mode |
| `customPrimaryColor` | `int` | Custom primary color (ARGB) |
| `customBackgroundColor` | `int` | Custom background color (ARGB) |
| `customHeadwordColor` | `int` | Custom headword color (ARGB) |
| `customSanskritTextColor` | `int` | Custom Sanskrit text color (ARGB) |
| `enableBasicAdjust` | `bool` | Feature 5: XML pre-processing |
| `enableBasicDisplay` | `bool` | Feature 4: XML to HTML rendering |
| `listMode` | `bool` | List Mode: accordion view for search results |

**Constructor:**
```dart
const AppSettings({
  this.headwordSearchMode = SearchMode.prefix,
  this.definitionSearchMode = SearchMode.prefix,
  this.inputTranslit = "itrans",
  this.outputTranslit = "devanagari",
  this.showAccent = true,
  this.highlightEnabled = true,
  this.maxResults = 100,
  this.activeDictCodes = const [],
  this.dictOrder = const [],
  this.themeMode = AppThemeMode.cologne,
  this.customPrimaryColor = 0xFF36648B,
  this.customBackgroundColor = 0xFFFFFFFF,
  this.customHeadwordColor = 0xFFDBE4ED,
  this.customSanskritTextColor = 0xFF339933,
  this.enableBasicAdjust = true,
  this.enableBasicDisplay = true,
  this.listMode = false,
});
```

##### Method: `copyWith`

Creates a copy with modified values.

| Parameter | Type | Description |
|-----------|------|-------------|
| (all properties) | `T?` | Optional new values |

**Returns:** `AppSettings` - New settings instance.

##### Getters:
- `customPrimary` → `Color`
- `customBackground` → `Color`
- `customHeadword` → `Color`
- `customSanskritText` → `Color`

---

### 15. `lib/models/dictionary_info.dart`

(Already documented in DictionaryRegistry section - see `lib/core/dictionary_registry.dart`)

---

### 16. `lib/models/search_result.dart`

#### Class: `SearchResult`

A single search result row from dictionary SQLite.

| Property | Type | Description |
|----------|------|-------------|
| `key` | `String` | SLP1 headword |
| `lnum` | `double` | Unique entry serial number |
| `data` | `String` | Raw XML-like entry data |

**Constructor:**
```dart
const SearchResult({
  required this.key,
  required this.lnum,
  required this.data,
});
```

##### Static Factory: `fromMap`

Creates SearchResult from SQLite map.

| Parameter | Type | Description |
|-----------|------|-------------|
| `map` | `Map<String, dynamic>` | SQLite row map |

**Returns:** `SearchResult` - New instance.

```dart
final result = SearchResult.fromMap({
  "key": "agni",
  "lnum": 1.0,
  "data": "<key1>agni</key1>...",
});
```

---

## Providers

### 17. `lib/providers/search_provider.dart`

#### Provider: `headwordQueryProvider`

`StateProvider<String>` - Current headword search query text.

---

#### Provider: `definitionQueryProvider`

`StateProvider<String>` - Current definition search query text.

---

#### Provider: `closedTabsProvider`

`StateProvider<Set<String>>` - User-closed tabs for current session.

---

#### Provider: `searchResultsProvider`

`FutureProvider.family<List<SearchResult>, String>` - Search results for a dictionary.

| Parameter | Type | Description |
|-----------|------|-------------|
| `dictCode` | `String` | Dictionary code (family parameter) |

Triggered by: headwordQuery, definitionQuery, or settings changes.

```dart
final results = await ref.watch(searchResultsProvider("mw").future);
```

---

#### Provider: `filteredTabsProvider`

`FutureProvider<List<String>>` - Tabs that have results for current search.

```dart
final tabs = await ref.watch(filteredTabsProvider.future);
```

---

#### Provider: `globalResultIndexProvider`

`FutureProvider<Map<String, int>>` - Cumulative result counts for global numbering in list mode. Returns a map of dictCode to the starting index for that dictionary.

```dart
final indexMap = await ref.watch(globalResultIndexProvider.future);
final startIndex = indexMap['mw'] ?? 0; // Starting index for MW dictionary
```

---

### 18. `lib/providers/settings_provider.dart`

#### Class: `SettingsNotifier`

StateNotifier for AppSettings.

##### Constructor

```dart
SettingsNotifier() : super(const AppSettings()) {
  _load();
}
```

##### Method: `update`

Updates settings and persists to storage.

| Parameter | Type | Description |
|-----------|------|-------------|
| `newSettings` | `AppSettings` | New settings |

**Returns:** `Future<void>`

---

##### Method: `addActiveDict`

Adds a dictionary to active list.

| Parameter | Type | Description |
|-----------|------|-------------|
| `code` | `String` | Dictionary code |

**Returns:** `Future<void>`

---

##### Method: `removeActiveDict`

Removes a dictionary from active list.

| Parameter | Type | Description |
|-----------|------|-------------|
| `code` | `String` | Dictionary code |

**Returns:** `Future<void>`

---

##### Method: `reorderDicts`

Reorders dictionary list.

| Parameter | Type | Description |
|-----------|------|-------------|
| `newOrder` | `List<String>` | New dictionary order |

**Returns:** `Future<void>`

---

#### Provider: `settingsProvider`

`StateNotifierProvider<SettingsNotifier, AppSettings>` - Global settings provider.

```dart
final settings = ref.watch(settingsProvider);
```

---

### 19. `lib/providers/dictionaries_provider.dart`

#### Provider: `availableDictsProvider`

`FutureProvider<Set<String>>` - Downloaded dictionary codes.

```dart
final available = await ref.watch(availableDictsProvider.future);
```

---

#### Provider: `downloadProgressProvider`

`StateProvider.family<double?, String>` - Download progress per dictionary.

- `null` = idle/not downloading
- `0.0-1.0` = downloading progress

---

#### Provider: `downloadStatusProvider`

`StateProvider.family<String, String>` - Download status message.

---

#### Provider: `localMetadataProvider`

`FutureProvider.family<DateTime?, String>` - Local download metadata.

| Parameter | Type | Description |
|-----------|------|-------------|
| `dictCode` | `String` | Dictionary code |

---

#### Provider: `remoteMetadataProvider`

`FutureProvider<({int? size, DateTime? lastModified}), String>` - Remote metadata.

| Parameter | Type | Description |
|-----------|------|-------------|
| `dictCode` | `String` | Dictionary code |

---

#### Class: `DownloadNotifier`

Manages dictionary downloads.

##### Constructor

```dart
DownloadNotifier(this._ref);
```

##### Method: `download`

Downloads a specific dictionary.

| Parameter | Type | Description |
|-----------|------|-------------|
| `dictCode` | `String` | Dictionary code |

**Returns:** `Future<void>`

---

##### Method: `downloadAll`

Downloads all available dictionaries.

**Returns:** `Future<void>`

---

## Main App

### 20. `lib/main.dart`

#### Function: `main`

App entry point.

```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize FFI for desktop
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  
  // Initialize transliteration
  TransliterationService.init();
  
  runApp(
    const ProviderScope(
      child: SanslexApp(),
    ),
  );
}
```

---

#### Class: `SanslexApp`

Main app widget.

##### Constructor

```dart
const SanslexApp({super.key});
```

##### Method: `build`

Builds the MaterialApp with appropriate theme.

| Parameter | Type | Description |
|-----------|------|-------------|
| `context` | `BuildContext` | Build context |
| `ref` | `WidgetRef` | Widget ref for providers |

**Returns:** `Widget` - Configured MaterialApp.

---

## Feature Screens

### 21. `lib/features/home/home_screen.dart`

#### Class: `HomeScreen`

Main home screen widget with search functionality and dictionary tabs.

---

### 22. `lib/features/home/widgets/app_drawer.dart`

#### Class: `AppDrawer`

Navigation drawer widget providing access to different app sections.

---

### 23. `lib/features/home/widgets/entry_card.dart`

#### Class: `EntryCardWidget`

Widget for displaying a single dictionary entry in the search results list.

---

### 24. `lib/features/preferences/preferences_screen.dart`

#### Class: `PreferencesScreen`

Settings screen for configuring app preferences.

---

### 25. `lib/features/help/help_screen.dart`

#### Class: `HelpScreen`

Help/documentation screen with usage instructions.

---

### 26. `lib/features/about/about_us_screen.dart`

#### Class: `AboutUsScreen`

About screen with app information and credits.

---

### 27. `lib/features/dictionaries/manage_dictionaries_screen.dart`

#### Class: `ManageDictionariesScreen`

Screen for managing (download/delete) dictionary files.

---

## Dependency Graph

Below is a dependency list showing which modules depend on others (similar to `flutter pub deps`):

```
csl_app
├── lib/main.dart
│   ├── flutter_riverpod (provider)
│   ├── sqflite_common_ffi (database)
│   └── lib/core/transliteration_service.dart
│
├── lib/core/
│   ├── ls_service.dart
│   │   ├── lib/core/ls_patterns.dart
│   │   ├── lib/core/database_helper.dart
│   │   └── flutter/foundation.dart
│   │
│   ├── ls_patterns.dart (standalone - no deps)
│   │
│   ├── search_service.dart
│   │   ├── lib/models/app_settings.dart
│   │   ├── lib/models/search_result.dart
│   │   ├── lib/core/database_helper.dart
│   │   └── lib/core/transliteration_service.dart
│   │
│   ├── database_helper.dart
│   │   ├── path (package)
│   │   ├── path_provider (package)
│   │   └── sqflite_common_ffi (package)
│   │
│   ├── download_service.dart
│   │   ├── archive (package)
│   │   ├── http (package)
│   │   ├── lib/models/dictionary_info.dart
│   │   └── lib/core/database_helper.dart
│   │
│   ├── settings_service.dart
│   │   ├── shared_preferences (package)
│   │   └── lib/models/app_settings.dart
│   │
│   ├── dictionary_registry.dart
│   │   └── lib/models/dictionary_info.dart
│   │
│   ├── transliteration_service.dart
│   │   └── indic_transliteration_dart (package)
│   │
│   └── logger.dart
│       └── flutter/foundation.dart
│
├── lib/rendering/
│   ├── entry_renderer.dart
│   │   ├── flutter/material.dart
│   │   ├── flutter_widget_from_html_core (package)
│   │   ├── url_launcher (package)
│   │   ├── lib/models/app_settings.dart
│   │   ├── lib/models/dictionary_info.dart
│   │   ├── lib/core/dictionary_registry.dart
│   │   ├── lib/core/transliteration_service.dart
│   │   ├── lib/core/search_service.dart
│   │   ├── lib/core/ls_service.dart
│   │   ├── lib/core/logger.dart
│   │   ├── lib/rendering/entry_parser.dart
│   │   ├── lib/rendering/basic_adjust.dart
│   │   └── lib/rendering/basic_display.dart
│   │
│   ├── basic_display.dart (standalone - no deps)
│   │
│   ├── basic_adjust.dart (standalone - no deps)
│   │
│   └── entry_parser.dart (standalone - no deps)
│
├── lib/models/
│   ├── app_settings.dart
│   │   └── flutter/material.dart
│   │
│   ├── dictionary_info.dart (standalone)
│   │
│   └── search_result.dart (standalone)
│
└── lib/providers/
    ├── search_provider.dart
    │   ├── flutter_riverpod (package)
    │   ├── lib/core/search_service.dart
    │   ├── lib/models/search_result.dart
    │   └── lib/providers/settings_provider.dart
    │
    ├── settings_provider.dart
    │   ├── flutter_riverpod (package)
    │   ├── lib/core/settings_service.dart
    │   ├── lib/models/app_settings.dart
    │   └── lib/core/dictionary_registry.dart
    │
    └── dictionaries_provider.dart
        ├── flutter/foundation.dart
        ├── flutter_riverpod (package)
        ├── lib/core/download_service.dart
        ├── lib/core/database_helper.dart
        ├── lib/core/dictionary_registry.dart
        └── shared_preferences (package)
```

---

## Function-Level Dependencies

```
EntryRenderer.buildEntryWidget
├── EntryParser.extractAbbreviations
│   └── EntryParser._abRe (private regex)
├── SearchService.fetchAbbreviation
│   └── DatabaseHelper.openAbDict
├── LsService.processLs
│   ├── LsService.extractFirstKey
│   ├── LsService._fetchExpansion
│   │   ├── LsService._queryAuthtooltips
│   │   │   └── DatabaseHelper.openAuthTooltips
│   │   └── LsService._queryBib
│   │       └── DatabaseHelper.openBib
│   ├── LsService.generateHref
│   │   ├── LsPatterns.getPatternsForDict
│   │   ├── LsService.getPrefix
│   │   └── various href* methods
│   └── LsService.romanInt
├── BasicAdjust.adjust
│   ├── BasicAdjust._generalAdjustments
│   └── BasicAdjust._dictionarySpecificAdjustments
├── BasicDisplay.processHtml
│   ├── BasicDisplay._transformElements
│   ├── BasicDisplay._applyAbbreviations
│   ├── BasicDisplay._applyLsHrefs
│   └── BasicAdjust._applyHighlighting
└── TransliterationService.fromSlp1

SearchService.searchHeadword
├── TransliterationService.toSlp1
└── DatabaseHelper.openDict

SearchService.searchDefinition
├── TransliterationService.toSlp1
└── DatabaseHelper.openDict

SearchService.fetchAbbreviation
└── DatabaseHelper.openAbDict

SearchService.fetchLsExpansion
├── _queryLsFromDb (authtooltips)
│   └── DatabaseHelper.openAuthTooltips
└── _queryLsFromDb (bib)
    └── DatabaseHelper.openBib

DownloadService.downloadDictionary
├── http (package) - for downloading
├── archive (package) - for extracting
├── DatabaseHelper.dataDir
└── DictionaryInfo.downloadUrl
```

---

*Last updated: March 2026*
