# Private API Reference (version 0.1.4)

This document lists all private classes, functions, methods, and fields in the CSL App codebase. These are implementation details not intended for external use.

---

## Table of Contents

1. [Core Services](#core-services)
2. [Rendering](#rendering)
3. [Providers](#providers)
4. [Main App](#main-app)

---

## Core Services

### 1. `lib/core/ls_service.dart`

#### Private Static Fields

##### `_codeToPfx`

```dart
static const Map<String, String> _codeToPfx = {
  'RV.': 'rv',
  'AV.': 'av',
  'Pāṇ.': 'p',
  'MBh.': 'MBH.',
  // ... 90+ entries
};
```

Maps Sanskrit text abbreviations to URL prefixes for generating links to scanned texts.

---

##### `_dictSpecificPrefixes`

```dart
static const Map<String, Map<String, String>> _dictSpecificPrefixes = {
  'ap90': {
    'Rv.': 'rv',
    'Av.': 'av',
    'P.': 'p',
  },
  'sch': {
    'ṚV.': 'rv',
    // ... 40+ entries
  },
};
```

Dictionary-specific prefix mappings that override or supplement the default `_codeToPfx`.

---

##### `_authtooltipsDicts`

```dart
static const Set<String> _authtooltipsDicts = {
  'mw',
  'ap90',
  'ben',
  'sch',
  'gra',
  'bhs',
  'ap'
};
```

Set of dictionary codes that have authtooltips databases for expanding literary source abbreviations.

---

##### `_bibDicts`

```dart
static const Set<String> _bibDicts = {'pwg', 'pw', 'pwkvn'};
```

Set of dictionary codes that have bibliography (bib) databases.

---

#### Private Static Methods

##### `_generateHrefFromPatterns`

Attempts to generate URL using pattern-based approach.

| Parameter | Type | Description |
|-----------|------|-------------|
| `dict` | `String` | Dictionary code |
| `data1` | `String` | LS reference text with nAttribute prepended |

**Returns:** `String?` - Generated URL or null.

**Internal Logic:**
1. Gets patterns for dictionary using `LsPatterns.getPatternsForDict(dict)`
2. Iterates through patterns checking if `pattern.dicts` contains current dict
3. Tries to match regex against data
4. Handles special URL generators: `rvAvHymnUrl`, `rvAvHymnUrl2`, `ramayanaUrl`, `dhatuUrl`
5. Evaluates conditional expressions in URL templates
6. Replaces `$1`, `$2`, etc. with regex match groups (converting Roman numerals to integers)

---

##### `_evaluateConditional`

Evaluates ternary conditional expressions in URL templates.

| Parameter | Type | Description |
|-----------|------|-------------|
| `expr` | `String` | Conditional expression (e.g., `($2 == "7") ? "url1" : "url2"`) |
| `match` | `RegExpMatch` | Regex match result |

**Returns:** `String` - Selected URL from conditional.

**Internal Logic:**
1. Parses ternary expression with regex: `^\(?(\$2\s*==\s*"([^"]+)"\)?)\s*\?\s*"([^"]+)"\s*:\s*"([^"]+)"$`
2. Extracts variable reference, compare value, true URL, and false URL
3. Gets actual value from match group
4. Returns appropriate URL based on comparison

---

##### `_fetchExpansion`

Fetches literary source expansion from database.

| Parameter | Type | Description |
|-----------|------|-------------|
| `dict` | `String` | Dictionary code |
| `data` | `String` | Full LS reference text |

**Returns:** `Future<String?>` - Expanded text or null.

**Internal Logic:**
1. Extracts first key from data using `extractFirstKey`
2. For authtooltips dictionaries: calls `_queryAuthtooltips`
3. For bib dictionaries: calls `_queryBib`
4. Returns null if no expansion found

---

##### `_queryAuthtooltips`

Queries authtooltips database for expansion.

| Parameter | Type | Description |
|-----------|------|-------------|
| `dict` | `String` | Dictionary code |
| `keyPrefix` | `String` | Key prefix for LIKE query |
| `data` | `String` | Full LS reference text |

**Returns:** `Future<String?>` - Best matching expansion or null.

**Internal Logic:**
1. Opens authtooltips database using `DatabaseHelper.openAuthTooltips(dict)`
2. Queries table `${dict}authtooltips` with `WHERE key LIKE ?`
3. Iterates through rows finding best match (longest key that data starts with)
4. Combines 'data' and 'type' columns for expansion
5. Returns best match or null

---

##### `_queryBib`

Queries bibliography database for expansion.

| Parameter | Type | Description |
|-----------|------|-------------|
| `dict` | `String` | Dictionary code |
| `keyPrefix` | `String` | Code prefix for LIKE query |
| `data` | `String` | Full LS reference text |

**Returns:** `Future<String?>` - Best matching expansion or null.

**Internal Logic:**
1. Opens bib database using `DatabaseHelper.openBib(dict)`
2. Queries table `${dict}bib` with `WHERE code LIKE ?`
3. Iterates through rows finding best match
4. Combines 'data' and 'codecap' columns
5. Returns best match or null

---

##### `hrefRvAv2`

Generates URL for RV/AV with 3 parameters (mandala, hymn, defaulting verse to 1).

| Parameter | Type | Description |
|-----------|------|-------------|
| `pfx` | `String` | Prefix ("rv" or "av") |
| `data1` | `String` | Reference text |
| `dict` | `String` | Dictionary code |

**Returns:** `String?` - URL or null if parsing fails.

---

##### `hrefDhatu`

Generates URL for Dhatus (Panini's verb roots).

| Parameter | Type | Description |
|-----------|------|-------------|
| `data1` | `String` | Reference text (e.g., "Dhātup. 1, 2") |

**Returns:** `String?` - URL to Westergaard database.

---

### 2. `lib/core/ls_patterns.dart`

No private members - all fields and methods are public.

---

### 3. `lib/core/search_service.dart`

#### Private Static Methods

##### `_likePattern`

Builds SQL LIKE pattern for search.

| Parameter | Type | Description |
|-----------|------|-------------|
| `slpWord` | `String` | SLP1 search word |
| `mode` | `SearchMode` | Search mode |

**Returns:** `String` - LIKE pattern.

```dart
static String _likePattern(String slpWord, SearchMode mode) {
  switch (mode) {
    case SearchMode.exact:
      return slpWord;
    case SearchMode.prefix:
      return '$slpWord%';
    case SearchMode.suffix:
      return '%$slpWord';
    case SearchMode.substring:
      return '%$slpWord%';
  }
}
```

---

##### `_queryLsFromDb`

Helper to query LS from authtooltips or bib database.

| Parameter | Type | Description |
|-----------|------|-------------|
| `dictCode` | `String` | Dictionary code |
| `code` | `String` | LS code to look up |
| `dbType` | `String` | Either "authtooltips" or "bib" |

**Returns:** `Future<String?>` - Expansion or null.

**Internal Logic:**
1. Opens appropriate database using DatabaseHelper
2. Discovers column names using `PRAGMA table_info`
3. Tries multiple column name patterns:
   - key + data + type
   - code + title + type
   - text
   - name
   - description
   - expansion
4. Returns first successful match

---

### 4. `lib/core/database_helper.dart`

#### Private Static Fields

##### `_openDbs`

```dart
static final Map<String, Database> _openDbs = {};
```

In-memory cache of open database connections keyed by lowercase dictionary code.

---

#### No Other Private Members

All methods in DatabaseHelper are public.

---

### 5. `lib/core/download_service.dart`

#### Private Static Methods

##### `_parseHttpDate`

Parses HTTP date string to DateTime.

| Parameter | Type | Description |
|-----------|------|-------------|
| `dateStr` | `String` | HTTP date (RFC 1123 format) |

**Returns:** `DateTime?` - Parsed date or null.

**Internal Logic:**
1. Tries `HttpDate.parse()` first
2. Falls back to `DateTime.tryParse()`

---

##### `_fmtBytes`

Formats bytes as human-readable string.

| Parameter | Type | Description |
|-----------|------|-------------|
| `bytes` | `int` | Size in bytes |

**Returns:** `String` - Formatted (e.g., "10.5 MB").

```dart
static String _fmtBytes(int bytes) {
  if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
  return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
}
```

---

### 6. `lib/core/settings_service.dart`

#### Private Static Fields

##### `_hwMode`

```dart
static const _hwMode = 'hw_search_mode';
```

SharedPreferences key for headword search mode.

---

##### `_defMode`

```dart
static const _defMode = 'def_search_mode';
```

SharedPreferences key for definition search mode.

---

##### `_inputTranslit`

```dart
static const _inputTranslit = 'input_translit';
```

SharedPreferences key for input transliteration.

---

##### `_outputTranslit`

```dart
static const _outputTranslit = 'output_translit';
```

SharedPreferences key for output transliteration.

---

##### `_showAccent`

```dart
static const _showAccent = 'show_accent';
```

SharedPreferences key for accent display.

---

##### `_highlight`

```dart
static const _highlight = 'highlight_enabled';
```

SharedPreferences key for highlight setting.

---

##### `_maxResults`

```dart
static const _maxResults = 'max_results';
```

SharedPreferences key for max results.

---

##### `_activeDicts`

```dart
static const _activeDicts = 'active_dicts';
```

SharedPreferences key for active dictionaries.

---

##### `_dictOrder`

```dart
static const _dictOrder = 'dict_order';
```

SharedPreferences key for dictionary order.

---

##### `_themeMode`

```dart
static const _themeMode = 'theme_mode';
```

SharedPreferences key for theme mode.

---

##### `_customPrimaryColor`

```dart
static const _customPrimaryColor = 'custom_primary_color';
```

SharedPreferences key for custom primary color.

---

##### `_customBackgroundColor`

```dart
static const _customBackgroundColor = 'custom_background_color';
```

SharedPreferences key for custom background color.

---

##### `_customHeadwordColor`

```dart
static const _customHeadwordColor = 'custom_headword_color';
```

SharedPreferences key for custom headword color.

---

##### `_customSanskritTextColor`

```dart
static const _customSanskritTextColor = 'custom_sanskrit_text_color';
```

SharedPreferences key for custom Sanskrit text color.

---

##### `_decodeList`

Decodes JSON-encoded string list.

| Parameter | Type | Description |
|-----------|------|-------------|
| `raw` | `String?` | JSON-encoded string or null |

**Returns:** `List<String>` - Decoded list or empty list on error.

---

### 7. `lib/core/dictionary_registry.dart`

No private members - all fields and methods are public.

---

### 8. `lib/core/transliteration_service.dart`

No private members - all fields and methods are public.

---

### 9. `lib/core/logger.dart`

#### Private Static Fields

##### `debugEnabled`

```dart
static bool debugEnabled = true;
```

Controls whether debug logging outputs. Default: `true`.

---

## Rendering

### 10. `lib/rendering/entry_renderer.dart`

#### Private Methods

##### `_resolveHeadwordSlp1`

Resolves the SLP1 headword to display (key2 if accent enabled).

| Parameter | Type | Description |
|-----------|------|-------------|
| `entry` | `ParsedEntry` | Parsed entry |

**Returns:** `String` - key2Slp1 if showAccent is true, otherwise key1Slp1.

---

##### `_buildBodyHtml`

Builds processed body HTML with all transformations.

| Parameter | Type | Description |
|-----------|------|-------------|
| `bodyHtml` | `String` | Raw body HTML |
| `abbreviationCache` | `Map<String, String>` | Abbreviation expansions |
| `lsCache` | `Map<String, String>` | LS expansions |
| `lsHrefsParam` | `Map<String, String>` | LS external URLs |
| `highlightSlp1` | `String?` | SLP1 term to highlight |
| `rawHighlightTerm` | `String?` | Raw term to highlight |
| `dictCode` | `String` | Dictionary code |

**Returns:** `String` - Processed HTML.

**Internal Logic:**
1. Applies BasicAdjust if enabled
2. Applies BasicDisplay if enabled
3. Applies transliteration via `_applyTransliteration`
4. Wraps in div with styling

---

##### `_applyTransliteration`

Applies transliteration to Sanskrit text within s/SA tags.

| Parameter | Type | Description |
|-----------|------|-------------|
| `html` | `String` | HTML string |
| `abbreviationCache` | `Map<String, String>` | Abbreviation cache |
| `lsCache` | `Map<String, String>` | LS expansion cache |
| `lsHrefs` | `Map<String, String>` | LS URLs |
| `highlightSlp1` | `String?` | SLP1 term to highlight |
| `rawHighlightTerm` | `String?` | Raw term to highlight |
| `dictCode` | `String` | Dictionary code |

**Returns:** `String` - HTML with transliteration applied.

**Internal Logic:**
1. Processes `<s>` and `<SA>` tags:
   - Transliterates SLP1 to output scheme
   - Applies highlighting if term matches
   - Wraps in span.sanskrit
2. Processes `<ab>` tags with abbreviationCache
3. Processes `<abbr>` tags (already transformed)
4. Processes `<ls>` tags with lsCache and lsHrefs
5. Cleans up `<F>`, `<hom>`, `<info>`, `<lex>`, `<s1>` tags
6. Applies highlighting to English/non-Sanskrit matches

---

#### Private Classes

##### `_EntryCard`

Stateless widget that renders a single dictionary entry card.

**Properties:**
- `displayKey` - Display string for headword
- `slp1Key` - SLP1 headword
- `homonym` - Homonym number
- `processedHtml` - Processed body HTML
- `pageCol` - Page/column
- `lnum` - Entry number
- `dictCodeUp` - Uppercase dictionary code
- `lsCache` - LS expansion cache
- `abbrCache` - Abbreviation cache
- `onWordTap` - Word tap callback
- `onCopy` - Copy callback
- `outputTranslit` - Output transliteration
- `dictInfo` - Dictionary info
- `useCologneTheme` - Use Cologne theme
- `customAccentColor` - Custom accent color
- `customHeadwordColor` - Custom headword color

**Methods:**

###### `_getHeadwordColor`

| Parameter | Type | Description |
|-----------|------|-------------|
| `theme` | `ThemeData` | Current theme |

**Returns:** `Color` - Headword color based on theme settings.

---

###### `build`

Builds the entry card widget.

**Returns:** `Widget` - Built card with headword, body, footer links.

---

###### `_linkText`

Creates tappable link text widget.

| Parameter | Type | Description |
|-----------|------|-------------|
| `context` | `BuildContext` | Build context |
| `label` | `String` | Link label |
| `url` | `String` | Target URL |

**Returns:** `Widget` - GestureDetector with Text.

---

###### `_superscript`

Converts number to Unicode superscript.

| Parameter | Type | Description |
|-----------|------|-------------|
| `n` | `int` | Number |

**Returns:** `String` - Superscript representation.

---

### 11. `lib/rendering/basic_display.dart`

#### Private Static Methods

##### `_transformElements`

Transforms XML elements to HTML.

| Parameter | Type | Description |
|-----------|------|-------------|
| `html` | `String` | Input HTML |
| `dictCode` | `String` | Dictionary code |
| `outputTranslit` | `String` | Output transliteration |

**Returns:** `String` - Transformed HTML.

**Internal Transformations:**
- Removes `<hom>` tags
- Transforms `<ls>` via `_transformLsElements`
- Transforms `<F>` (footnote)
- Transforms `<sup>`
- Transforms `<pb>` via `_transformPageBreak`
- Transforms `<lb>` via `_transformLineBreak`
- Transforms `<div>` via `_transformDivElements`
- Transforms `<alt>`
- Transforms `<C>` (commentary)
- Transforms `<bot>`, `<zoo>` via `_transformBioElements`
- Transforms `<lang>` via `_transformLangElements`
- Transforms `<pic>`
- Transforms `<table>` elements
- Cleans empty tags

---

##### `_transformLsElements`

Transforms LS elements to styled spans.

| Parameter | Type | Description |
|-----------|------|-------------|
| `html` | `String` | Input HTML |

**Returns:** `String` - HTML with LS elements transformed.

---

##### `_applyLsHrefs`

Applies external URLs to LS elements.

| Parameter | Type | Description |
|-----------|------|-------------|
| `html` | `String` | Input HTML |
| `lsHrefs` | `Map<String, String>` | LS code to URL map |

**Returns:** `String` - HTML with hrefs applied.

---

##### `_transformPageBreak`

Transforms page break elements (dictionary-specific).

| Parameter | Type | Description |
|-----------|------|-------------|
| `html` | `String` | Input HTML |
| `dictCode` | `String` | Dictionary code |

**Returns:** `String` - Transformed HTML.

**Behavior:**
- `mw`, `bur`, `stc`, `pwg`: Remove pb tags entirely
- Others: Show as small grey text

---

##### `_transformLineBreak`

Transforms line break elements (dictionary-specific).

| Parameter | Type | Description |
|-----------|------|-------------|
| `html` | `String` | Input HTML |
| `dictCode` | `String` | Dictionary code |

**Returns:** `String` - Transformed HTML.

**Behavior:**
- `ap90`, `shs`, `yat`: Replace with space
- Others: Use `<br>`

---

##### `_transformDivElements`

Transforms div elements with dictionary-specific indentation.

| Parameter | Type | Description |
|-----------|------|-------------|
| `html` | `String` | Input HTML |
| `dictCode` | `String` | Dictionary code |

**Returns:** `String` - HTML with div padding applied.

**Supported dictionaries:** `gra`, `bur`, `stc`, `pwg`, `pw`, `ap`, `wil`, `shs`, `gst`, `ieg`, `inm`, `mci`, `ben`, `pui`, `skd`, `krm`, `pe`, `pgn`, `acc`

---

##### `_transformBioElements`

Transforms botanical/zoological name elements.

| Parameter | Type | Description |
|-----------|------|-------------|
| `html` | `String` | Input HTML |

**Returns:** `String` - HTML with bio elements styled.

---

##### `_transformLangElements`

Transforms language elements.

| Parameter | Type | Description |
|-----------|------|-------------|
| `html` | `String` | Input HTML |
| `dictCode` | `String` | Dictionary code |

**Returns:** `String` - Transformed HTML.

**Note:** Dicts with Greek in Unicode (`pwg`, `pw`, `wil`, `md`, etc.) are not transformed.

---

##### `_transformTableElements`

Transforms table elements (currently a pass-through).

| Parameter | Type | Description |
|-----------|------|-------------|
| `html` | `String` | Input HTML |

**Returns:** `String` - Unchanged HTML.

---

##### `_applyAbbreviations`

Applies abbreviation expansions from cache.

| Parameter | Type | Description |
|-----------|------|-------------|
| `html` | `String` | Input HTML |
| `abbreviationCache` | `Map<String, String>` | Abbreviation map |

**Returns:** `String` - HTML with abbreviations expanded.

---

##### `_applyHighlighting`

Applies search term highlighting.

| Parameter | Type | Description |
|-----------|------|-------------|
| `html` | `String` | Input HTML |
| `term` | `String` | Term to highlight |

**Returns:** `String` - HTML with `<mark>` tags.

---

##### `_cleanEmptyTags`

Removes empty tags from HTML.

| Parameter | Type | Description |
|-----------|------|-------------|
| `html` | `String` | Input HTML |

**Returns:** `String` - Cleaned HTML.

---

### 12. `lib/rendering/basic_adjust.dart`

#### Private Static Methods

##### `_generalAdjustments`

Applies general XML adjustments (all dictionaries).

| Parameter | Type | Description |
|-----------|------|-------------|
| `xml` | `String` | Input XML |

**Returns:** `String` - Adjusted XML.

**Adjustments:**
- Replaces broken bar (¦) with space
- Converts `[Page X]` to `<pb>X</pb>`
- Converts `<pc>Page...` to `<pc>...`
- Processes `<s>` tags via `_processSTags`
- Processes `<key2>` tags via `_processKey2Tags`

---

##### `_dictionarySpecificAdjustments`

Applies dictionary-specific adjustments.

| Parameter | Type | Description |
|-----------|------|-------------|
| `xml` | `String` | Input XML |
| `dictCode` | `String` | Dictionary code |

**Returns:** `String` - Adjusted XML.

**Calls:**
- `_adjustMw` for 'mw'
- `_adjustPwFamily` for 'pw', 'pwg', 'pwkvn'
- `_adjustGraMdAp` for 'gra', 'md', 'ap'
- `_adjustBhs` for 'bhs'
- `_adjustAp90` for 'ap90'
- `_adjustBen` for 'ben'
- `_adjustAcc` for 'acc'
- `_adjustShs` for 'shs'
- `_adjustYat` for 'yat'
- `_adjustBor` for 'bor'

---

##### `_adjustMw`

MW-specific adjustments.

**Transformations:**
- `<lang>` → `<ab>`
- `<s1 n="X">Y</s1>` → `<ab n="X">Y</ab>`
- Page number linking
- Column references

---

##### `_adjustPwFamily`

PW family (pw, pwg, pwkvn) adjustments.

**Transformations:**
- `<lang>` → `<ab>`
- `<info n="sup_..."/>` → `<info n="sup"><ab>supplement</ab></info>`

---

##### `_adjustGraMdAp`

GRA, MD, AP adjustments.

**Transformations:**
- `<per>` → `<ab>`
- `<lang>` → `<ab>`
- `<cl>` → `<ab>`

---

##### `_adjustBhs`

BHS dictionary adjustments.

**Transformations:**
- `<lex>` → `<ab>`
- `<lang>` → `<ab>`
- `<ed>` → `<ab>`
- `<ms>` → `<ab>`

---

##### `_adjustAp90`

AP90 dictionary adjustments.

**Transformations:**
- Removes hyphen + `<lb/>`
- Removes `<lb/>` tags entirely

---

##### `_adjustBen`

BEN dictionary adjustments.

**Transformations:**
- `--` → `—` (em-dash)
- `<g></g>` → `<lang n="greek"></lang>`
- `<P/>` → `<div n="P"/>`

---

##### `_adjustAcc`

ACC dictionary adjustments.

**Transformations:**
- Superscript letters `^a` → `<sup>a</sup>`
- `--` → `—`
- Removes breaks

---

##### `_adjustShs`

SHS dictionary adjustments.

**Transformations:**
- Removes hyphen + lb
- `<lb/>` → space
- `--` → `—`

---

##### `_adjustYat`

YAT dictionary adjustments.

**Transformations:**
- Removes hyphen + br
- `<br/>` → space
- `--` → `—`

---

##### `_adjustBor`

BOR dictionary adjustments.

**Transformations:**
- Space before closing div
- Bold first word in div

---

##### `_processSTags`

Processes `<s>` tags (placeholder - actual processing in rendering).

| Parameter | Type | Description |
|-----------|------|-------------|
| `xml` | `String` | Input XML |

**Returns:** `String` - Unchanged (placeholder).

---

##### `_processKey2Tags`

Processes `<key2>` tags (placeholder - actual processing in rendering).

| Parameter | Type | Description |
|-----------|------|-------------|
| `xml` | `String` | Input XML |

**Returns:** `String` - Unchanged (placeholder).

---

### 13. `lib/rendering/entry_parser.dart`

#### Private Static Fields

##### `_key1Re`

```dart
static final _key1Re = RegExp(r'<key1>(.*?)</key1>', dotAll: true);
```

Regex for extracting key1.

---

##### `_key2Re`

```dart
static final _key2Re = RegExp(r'<key2>(.*?)</key2>', dotAll: true);
```

Regex for extracting key2.

---

##### `_homRe`

```dart
static final _homRe = RegExp(r'<hom>(\d+)</hom>');
```

Regex for extracting homonym number.

---

##### `_bodyRe`

```dart
static final _bodyRe = RegExp(r'<body>(.*?)</body>', dotAll: true);
```

Regex for extracting body content.

---

##### `_pcRe`

```dart
static final _pcRe = RegExp(r'<pc>(.*?)</pc>', dotAll: true);
```

Regex for extracting page/column.

---

##### `_abRe`

```dart
static final _abRe = RegExp(r'<ab>(.*?)</ab>', dotAll: true);
```

Regex for extracting abbreviations.

---

#### Private Static Methods

##### `_transliterateSlp1`

Placeholder transliteration method (actual transliteration in rendering).

| Parameter | Type | Description |
|-----------|------|-------------|
| `slp1` | `String` | SLP1 text |
| `outputScheme` | `String` | Output scheme |

**Returns:** `String` - Original text (placeholder).

---

## Providers

### 14. `lib/providers/dictionaries_provider.dart`

#### Private Static Fields

##### `_cancelTokens`

```dart
static final _cancelTokens = <String, StateProvider<bool>>{};
```

Map of dictionary codes to cancel token providers for downloads.

---

#### Private Static Methods

##### `_cancelTokenProvider`

Creates cancel token provider for a dictionary.

| Parameter | Type | Description |
|-----------|------|-------------|
| `dictCode` | `String` | Dictionary code |

**Returns:** `StateProvider<bool>` - Cancel token.

---

## Main App

### 15. `lib/main.dart`

#### Private Static Fields

##### `_cologneBlue`

```dart
static const Color _cologneBlue = Color(0xFF36648B);
```

Cologne theme primary color.

---

##### `_cologneLightBlue`

```dart
static const Color _cologneLightBlue = Color(0xFFDBE4ED);
```

Cologne theme light surface color.

---

#### Private Methods

##### `_buildCologneTheme`

Builds the Cologne theme (light blue).

**Returns:** `ThemeData` - Configured Cologne theme.

---

##### `_buildCustomTheme`

Builds custom theme from AppSettings.

| Parameter | Type | Description |
|-----------|------|-------------|
| `settings` | `AppSettings` | App settings |

**Returns:** `ThemeData` - Configured custom theme.

---

### 16. `lib/features/home/home_screen.dart`

#### Class: `_HomeScreenState`

Private State class for HomeScreen.

---

#### Class: `_DictionaryView`

Private widget for displaying dictionary search results.

---

### 17. `lib/features/preferences/preferences_screen.dart`

#### Class: `_ColorPickerTile`

Private widget for color picker list tiles.

---

#### Class: `_SearchModeSelector`

Private widget for search mode selection.

---

### 18. `lib/features/help/help_screen.dart`

#### Class: `_HelpScreenState`

Private State class for HelpScreen.

---

### 19. `lib/rendering/entry_renderer.dart`

#### Class: `_EntryCard`

Private widget for rendering entry cards.

---

*Last updated: March 2026*
