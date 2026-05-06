# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## About

The **Cologne Sanskrit Lexicon (CSL) App** is a Flutter-based cross-platform offline dictionary for Sanskrit. It supports Android, iOS, macOS, Windows, Linux, and Web, with 50+ dictionaries stored as local SQLite databases.

## Commands

```bash
# Install dependencies
flutter pub get

# Run (debug)
flutter run

# Analyze / lint
flutter analyze

# Format
dart format lib/

# All tests
flutter test

# Single test file
flutter test test/search_service_test.dart

# Build release (example platforms)
flutter build apk --release
flutter build windows --release
flutter build web --release

# Regenerate app icons
dart run flutter_launcher_icons
```

Lint config is in `analysis_options.yaml` (uses `flutter_lints`; `print` statements are allowed).

## Architecture

### State management

The app uses **Riverpod** (`flutter_riverpod`). The three core providers are:

- `settingsProvider` (`StateNotifier<AppSettings>`) — user preferences, persisted via `SharedPreferences`
- `searchResultsProvider` (`FutureProvider`) — watches headword/definition query state + settings, fans out to `SearchService` across active dictionaries in parallel
- `dictionariesProvider` — dictionary availability, download progress

### Search pipeline

```
User input
  → TransliterationService.toSlp1()        # normalise to SLP1 (internal DB scheme)
  → SearchService.searchHeadword/Definition # SQLite LIKE/exact query per active dict
  → List<SearchResult>                      # (key, lnum, raw XML data)
  → EntryCard / EntryRenderer
```

All dictionary `key` columns store SLP1. Input is converted to SLP1 before querying; output is re-transliterated into the user's chosen display scheme. English-only dictionaries (AE, MWE, BOR) skip transliteration.

### Entry rendering pipeline

Raw XML from the DB travels through four stages before display:

1. **`EntryParser.parse()`** — regex-extracts `<key1>`, `<key2>`, `<hom>`, `<body>`, `<pc>` from the stored XML string → `ParsedEntry`
2. **`BasicAdjust.adjust()`** — dictionary-specific XML pre-processing (broken-bar replacement, `[Page X]` → `<pb>`, per-dictionary quirks for MW, PW/PWG, GRA/MD/AP, BHS, …)
3. **`LsService.processLs()` + `SearchService.fetchAbbreviation()`** — resolve `<ls n="...">` literary-source references and `<ab>` abbreviations (look-ups against `{code}ab.sqlite`, URL generation via `ls_patterns.dart`)
4. **`BasicDisplay.processHtml()`** — transforms the adjusted XML into HTML (`<ls>` → `<a href>`, `<F>` → footnote, `<pb>`, `<lb>`, highlighting, tooltips); result is rendered by `flutter_widget_from_html_core`

### Platform abstraction

Platform-specific code is selected via conditional imports (`if (dart.library.io)`):

| Concern | Native (io) | Web |
|---------|-------------|-----|
| SQLite init | `db_init_io.dart` (sqflite_common_ffi) | `db_init_web.dart` (WASM + IndexedDB) |
| Path resolution | `path_helper_io.dart` (path_provider) | `path_helper_web.dart` (virtual prefix `sanslex`) |
| Download / extract | `io_helper.dart` (http + archive) | stubs (throws) |

DB files on native live at `{AppDocumentsDir}/csl_db_{code}.sqlite`; on web they are stored in IndexedDB under the key `csl_db_{code}`.

### Dictionary lifecycle

Each dictionary ships four SQLite files: `{code}.sqlite` (entries), `{code}ab.sqlite` (abbreviations), `{code}authtooltips.sqlite`, `{code}bib.sqlite`. `DictionaryRegistry.all` is the static catalogue. `DownloadService` fetches ZIPs from GitHub Releases (web) or the Cologne server (native), extracts, and writes them; `settingsProvider` then auto-enables the newly downloaded dictionary.

### Literary source (LS) handling

`ls_patterns.dart` maps dictionary-specific source abbreviations to URL templates for `sanskrit-lexicon.uni-koeln.de`. `LsService.processLs()` reads these patterns, resolves the references, and generates hrefs that `BasicDisplay` injects into the rendered HTML as clickable links.

## Testing

The test suite exercises search logic, transliteration, XML parsing/adjustment/display, and LS URL generation. Tests use `test/data/lan.sqlite` (a portable DB included in the repo) rather than production dictionaries.

Key test files: `search_service_test.dart`, `transliteration_service_test.dart`, `entry_parser_test.dart`, `basic_adjust_test.dart`, `basic_display_test.dart`, `ls_service_test.dart`, and per-dictionary `ls_url_*_test.dart` files.
