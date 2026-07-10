# csl-app Build & Release Manual

_Created: 11-07-2026 · Last updated: 11-07-2026_

The operator manual for building, running, testing, and releasing the
`cologne_sanskrit_lexicon` Flutter app on all six platforms (Android, iOS,
macOS, Windows, Linux, web), and for understanding where the dictionary data
actually comes from. Written for someone who has never built this repo before
and needs to ship a release — or just answer "why is the download failing" —
without reverse-engineering the code.

Companion metadoc: [docs/BUILD_RELEASE_MANUAL.meta.md](https://github.com/sanskrit-lexicon/csl-app/blob/main/docs/BUILD_RELEASE_MANUAL.meta.md).

---

## 1. Cheat-sheet — the six commands you actually run

```bash
flutter pub get                                # once per checkout / pubspec change
dart run sqflite_common_ffi_web:setup          # ONLY before web runs/builds (see §4.3)
flutter run                                    # dev run on connected device/emulator/browser
flutter test                                   # full suite under test/
flutter build apk --release                    # Android (or: appbundle / windows / linux / macos / ios)
flutter build web --release --base-href /csl-app/   # web — exact flag CI uses
```

Releasing the **web app** is not a command at all: every push to `main`
triggers [.github/workflows/deploy.yml](https://github.com/sanskrit-lexicon/csl-app/blob/main/.github/workflows/deploy.yml),
which builds and publishes to
[https://sanskrit-lexicon.github.io/csl-app/](https://sanskrit-lexicon.github.io/csl-app/)
automatically. Releasing a **native binary** is manual — see §5.

## 2. What this app is, in one diagram

The single most important fact: **no dictionary database is bundled in the
app.** [assets/sqlite/](https://github.com/sanskrit-lexicon/csl-app/tree/main/assets/sqlite)
contains only a `.gitkeep`. Every dictionary is downloaded **at runtime, on
user demand**, from the `csl-sqlite` data-store repo's `gh-pages` branch.

```
Cologne CDSL pipeline (upstream, not this repo)
  csl-orig text  →  displays  →  {code}.sqlite files
        │
        ▼
sanskrit-lexicon/csl-sqlite  (gh-pages branch)
  https://sanskrit-lexicon.github.io/csl-sqlite/{code}.zip
  54 zips: 44 dictionaries + *_lslinks extras
        │  runtime HTTP GET, user taps "Download" in Manage Dictionaries
        ▼
csl-app DownloadService (lib/core/download_service.dart)
  ├─ native (Android/iOS/macOS/Windows/Linux) — io_helper.dart:
  │    unzip → {code}.sqlite, {code}ab.sqlite, {code}authtooltips.sqlite,
  │    {code}bib.sqlite → app documents dir (path_provider)
  └─ web — io_helper_stub.dart + sqflite_web_writer.dart:
       unzip in browser → raw bytes written into IndexedDB
       (virtual keys csl_db_{code}…)
        │
        ▼
DatabaseHelper (lib/core/database_helper.dart)
  opens read-only (native), PRAGMA case_sensitive_like = ON
        │
        ▼
search_service / ls_service / rendering → UI
```

Per dictionary there are up to **four** SQLite files; only the main one is
mandatory:

| File | Content | Optional? |
|---|---|---|
| `{code}.sqlite` | headwords + entry bodies | required |
| `{code}ab.sqlite` | abbreviation expansions | optional |
| `{code}authtooltips.sqlite` | author tooltips | optional — "not found in zip. Normal for some dictionaries." |
| `{code}bib.sqlite` | bibliography | optional |

The catalogue of all 44 dictionaries (codes, titles, accent/Devanagari flags,
WorldCat + bibliographic entries) is hardcoded in
[lib/core/dictionary_registry.dart](https://github.com/sanskrit-lexicon/csl-app/blob/main/lib/core/dictionary_registry.dart),
"sourced from dictparms.py" (the Cologne pipeline's dictionary-parameter
file). Adding a dictionary to the app = adding a `DictionaryInfo` entry there
**and** making sure `{code}.zip` exists on csl-sqlite gh-pages.

### 2.1 Why gh-pages and not GitHub Releases

The download base URL is fixed in
[lib/models/dictionary_info.dart](https://github.com/sanskrit-lexicon/csl-app/blob/main/lib/models/dictionary_info.dart):

```dart
String get downloadUrl =>
    'https://sanskrit-lexicon.github.io/csl-sqlite/$codeLo.zip';
```

Both csl-app (web) and csl-sqlite are served from
`sanskrit-lexicon.github.io` — the **same origin** — so browser `fetch()`
needs no CORS preflight. GitHub Releases redirects through
`objects.githubusercontent.com`, which lacks CORS headers and silently breaks
the web build's downloads. **Never "upgrade" this URL to a Releases asset.**
(The comment block in
[lib/core/io_helper_stub.dart](https://github.com/sanskrit-lexicon/csl-app/blob/main/lib/core/io_helper_stub.dart)
documents this; note that older docstrings in
[io_helper.dart](https://github.com/sanskrit-lexicon/csl-app/blob/main/lib/core/io_helper.dart)
still say "Cologne server" — the code's `info.downloadUrl` is the gh-pages
URL on **every** platform.)

## 3. Repository map — where the moving parts live

| Path | Role |
|---|---|
| [lib/main.dart](https://github.com/sanskrit-lexicon/csl-app/blob/main/lib/main.dart) | Entry point: `initDatabaseFactory()` → `TransliterationService.init()` → `runApp` |
| [lib/db_init_io.dart](https://github.com/sanskrit-lexicon/csl-app/blob/main/lib/db_init_io.dart) / [db_init_web.dart](https://github.com/sanskrit-lexicon/csl-app/blob/main/lib/db_init_web.dart) / [db_init_stub.dart](https://github.com/sanskrit-lexicon/csl-app/blob/main/lib/db_init_stub.dart) | Conditional-import trio picking the SQLite factory: sqflite (mobile), sqflite_common_ffi (desktop), sqflite_common_ffi_web (browser IndexedDB) |
| [lib/core/download_service.dart](https://github.com/sanskrit-lexicon/csl-app/blob/main/lib/core/download_service.dart) | Public download/delete/size API; delegates to the platform half below |
| [lib/core/io_helper.dart](https://github.com/sanskrit-lexicon/csl-app/blob/main/lib/core/io_helper.dart) / [io_helper_stub.dart](https://github.com/sanskrit-lexicon/csl-app/blob/main/lib/core/io_helper_stub.dart) | Native disk extraction vs web IndexedDB writing (same zip, two destinations) |
| [lib/core/database_helper.dart](https://github.com/sanskrit-lexicon/csl-app/blob/main/lib/core/database_helper.dart) | Path resolution, availability checks, cached read-only opens of all four per-dict DBs |
| [lib/core/dictionary_registry.dart](https://github.com/sanskrit-lexicon/csl-app/blob/main/lib/core/dictionary_registry.dart) | The 44-dictionary catalogue |
| [lib/core/search_service.dart](https://github.com/sanskrit-lexicon/csl-app/blob/main/lib/core/search_service.dart) | Headword search over the opened DBs |
| [lib/core/ls_service.dart](https://github.com/sanskrit-lexicon/csl-app/blob/main/lib/core/ls_service.dart) + [ls_patterns.dart](https://github.com/sanskrit-lexicon/csl-app/blob/main/lib/core/ls_patterns.dart) | Literary-source citation → deep-link URL generation (per-dictionary pattern sets; MW alone has 150+) |
| [lib/core/transliteration_service.dart](https://github.com/sanskrit-lexicon/csl-app/blob/main/lib/core/transliteration_service.dart) | Script conversion via `indic_transliteration_dart`; Devanagari renders with the bundled `assets/siddhanta1.ttf` |
| [lib/features/](https://github.com/sanskrit-lexicon/csl-app/tree/main/lib/features) | Screens: home, dictionaries (Manage Dictionaries = the download UI), help, about |
| [test/](https://github.com/sanskrit-lexicon/csl-app/tree/main/test) | Suite incl. per-dictionary `ls_url_*_test.dart`; fixture DB at [test/data/sanslex/lan.sqlite](https://github.com/sanskrit-lexicon/csl-app/tree/main/test/data) |
| [bin/ls_url_test.dart](https://github.com/sanskrit-lexicon/csl-app/blob/main/bin/ls_url_test.dart) | Manual CLI harness for LS URL spot-checks |
| [scripts/compare_docs.py](https://github.com/sanskrit-lexicon/csl-app/blob/main/scripts/compare_docs.py) | Doc-drift checker: compares [reference/public.md](https://github.com/sanskrit-lexicon/csl-app/blob/main/reference/public.md) / [reference/private.md](https://github.com/sanskrit-lexicon/csl-app/blob/main/reference/private.md) API docs against `lib/` signatures |
| [.github/workflows/](https://github.com/sanskrit-lexicon/csl-app/tree/main/.github/workflows) | `deploy.yml` (web build+Pages), `readme-guard.yml`, `dependabot-auto-merge.yml` |

Other runtime URLs baked into `DictionaryInfo`: the correction form
(`…uni-koeln.de/scans/csl-corrections/app/correction_form.php?dict={CODE}`)
and scan-PDF viewer (`…/csl-apidev/servepdf.php?dict={CODE}&page=…`) — those
DO point at the Cologne server and require the user to be online when tapped.

## 4. Environment & first build

### 4.1 Toolchain versions

- **Dart SDK**: `>=3.4.0 <4.0.0` ([pubspec.yaml](https://github.com/sanskrit-lexicon/csl-app/blob/main/pubspec.yaml)).
- **Effective floor is higher**: `flutter_lints ^6.0.0` requires Dart
  `^3.8.0`, i.e. **Flutter 3.32+**. CI deliberately pins no version and rides
  the `stable` channel (comment in `deploy.yml`).
- **Android**: JDK 17 (source/target compatibility in
  [android/app/build.gradle.kts](https://github.com/sanskrit-lexicon/csl-app/blob/main/android/app/build.gradle.kts)),
  `minSdk 21`, application ID `de.uni_koeln.sanskrit_lexicon`.
- **iOS/macOS**: Xcode with a signing team configured (standard Flutter; no
  repo-specific tweaks).
- **Linux**: the usual GTK/ninja Flutter desktop deps.

### 4.2 First build, any native platform

```bash
git clone https://github.com/sanskrit-lexicon/csl-app
cd csl-app
flutter pub get
flutter run          # picks the connected device; -d windows / -d macos / -d linux to force
```

The app starts with zero dictionaries; open **Manage Dictionaries** and
download one (LAN at ~1 MB is the quick smoke test — it's also the test
fixture).

### 4.3 Web has one extra mandatory step

`sqflite_common_ffi_web` needs two generated artifacts (`sqflite_sw.js`
service worker + `sqlite3.wasm`) in `web/` before anything DB-touching will
work in a browser:

```bash
dart run sqflite_common_ffi_web:setup
flutter run -d chrome
```

CI runs the same setup step (deploy.yml step 4). Forgetting it locally is the
#1 web-run failure — see §7.

### 4.4 Version numbering

`pubspec.yaml` `version: 0.2.3+11` is the single source: `0.2.3` becomes
Android `versionName` / iOS `CFBundleShortVersionString`, `+11` becomes
`versionCode` / build number (wired through `flutter.versionCode` /
`flutter.versionName` in the Gradle file). **Every release bumps both parts**
and adds a [CHANGELOG.md](https://github.com/sanskrit-lexicon/csl-app/blob/main/CHANGELOG.md)
section (keep-a-changelog style, `## [x.y.z] - YYYY-MM-DD` with
Added/Fixed/Changed).

## 5. Release procedures per platform

### 5.1 Web — automatic on merge

Push/merge to `main` → `deploy.yml`:

1. checkout → Flutter stable → `flutter pub get`
2. `dart run sqflite_common_ffi_web:setup`
3. `flutter build web --release --base-href /csl-app/`
4. `peaceiris/actions-gh-pages@v4` force-orphan pushes `build/web` to the
   `gh-pages` branch → served at
   [https://sanskrit-lexicon.github.io/csl-app/](https://sanskrit-lexicon.github.io/csl-app/).

The `--base-href /csl-app/` must match the Pages sub-path exactly; a local
`flutter build web` without it produces a bundle that 404s all its assets if
deployed there. Nothing manual to do beyond merging — verify the Actions run
went green and hard-refresh the site.

### 5.2 Android — signed release

Release signing reads `android/key.properties` (gitignored, machine-local):

```properties
storeFile=C:/path/to/upload-keystore.jks
storePassword=…
keyAlias=…
keyPassword=…
```

The Gradle config **falls back to debug signing when the file is absent** —
the build succeeds and looks fine, but a debug-signed APK cannot be uploaded
to Play or installed over a properly-signed copy. Check before shipping.

```bash
flutter build appbundle --release   # Play Store upload (.aab)
flutter build apk --release         # direct-install APK
```

Output: `build/app/outputs/bundle/release/` and
`build/app/outputs/flutter-apk/`. Launcher icons are generated (not
hand-edited) — after changing the logo asset run
`dart run flutter_launcher_icons` (config in `pubspec.yaml`, section
`flutter_launcher_icons`).

### 5.3 iOS / macOS

```bash
flutter build ios --release      # then archive/upload via Xcode (Product → Archive)
flutter build macos --release
```

Requires Apple Developer signing set in Xcode
(`ios/Runner.xcworkspace` / `macos/Runner.xcworkspace`). No repo-specific
provisioning is committed.

### 5.4 Windows / Linux

```bash
flutter build windows --release   # build/windows/x64/runner/Release/
flutter build linux --release     # build/linux/x64/release/bundle/
```

Ship the whole output folder (the exe needs its adjacent DLLs / `data/`
directory). Desktop builds use `sqflite_common_ffi`, which bundles its own
SQLite — no system SQLite needed on the target machine.

### 5.5 Release checklist (all platforms)

1. `flutter test` green locally.
2. Bump `version:` in `pubspec.yaml` (both halves) + CHANGELOG section.
3. PR → merge to `main` (web ships itself at this moment).
4. Build the native artifacts you're releasing (§5.2–5.4).
5. Tag `vX.Y.Z`. Creating the GitHub *release page* is a human (MG) action —
   agents push tags only.

## 6. Dictionary data: source and refresh

- **Where the data comes from**: the Cologne CDSL pipeline (csl-orig →
  displays) generates each dictionary's SQLite; the zips are stored on the
  **`gh-pages` branch of
  [sanskrit-lexicon/csl-sqlite](https://github.com/sanskrit-lexicon/csl-sqlite)**
  (the repo's `main` is just a README — the data lives only on gh-pages,
  54 zips as of 07-2026).
- **Refreshing a dictionary DB** is therefore an *upstream* act: regenerate
  `{code}.sqlite` in the Cologne pipeline, re-zip as
  `{code}/{code}.sqlite` (+ optional `ab`/`authtooltips`/`bib` siblings —
  the extractor matches those exact inner paths), and push to csl-sqlite
  gh-pages. **csl-app itself needs no rebuild and no release** — users
  re-download from Manage Dictionaries.
- **How users see an update exists**: on native, the app HEAD-requests the
  zip (`fetchRemoteMetadataNative`) and shows remote size + `Last-Modified`
  next to the local copy. On web those show as unknown (HEAD metadata is
  not exposed), and deleting a dictionary from IndexedDB is not supported by
  the current API — re-downloading overwrites.
- **Adding a new dictionary**: zip on csl-sqlite gh-pages + a
  `DictionaryInfo` entry in `dictionary_registry.dart` (+ LS patterns in
  `ls_patterns.dart` if it should get literary-source links) + a release of
  the app (the registry is compiled in).

## 7. Symptom → cause → cure

| Symptom | Cause | Cure |
|---|---|---|
| Web run: white screen / `databaseFactory` errors / missing `sqflite_sw.js` 404 in console | `sqflite_common_ffi_web:setup` never run in this checkout | `dart run sqflite_common_ffi_web:setup`, then rerun (§4.3) |
| Web: dictionary download fails with a CORS error in console | Download URL changed to GitHub Releases (or any non-`sanskrit-lexicon.github.io` host) | Restore the gh-pages URL in `dictionary_info.dart` — same-origin is load-bearing (§2.1) |
| Native download completes but console notes `…authtooltips.sqlite not found in zip` | That sibling DB genuinely doesn't exist for this dictionary | Nothing — expected; the code treats ab/authtooltips/bib as optional |
| `flutter pub get` / analyze fails around `flutter_lints` | Flutter older than 3.32 (Dart < 3.8) | Upgrade Flutter stable (§4.1) |
| Deployed web app 404s its own JS/assets | Built without `--base-href /csl-app/` | Use the exact CI flag; or just let CI build it (§5.1) |
| Release APK won't install over the Play version / Play rejects upload | `android/key.properties` missing → silent debug-signing fallback | Create `key.properties` pointing at the real keystore; rebuild (§5.2) |
| Entries render but Devanagari boxes/tofu | `Siddhanta1` font asset not loading (asset section edited) | Keep `assets/siddhanta1.ttf` + the `fonts:` block in `pubspec.yaml` intact |
| Search behaves case-insensitively / wrong matches | `PRAGMA case_sensitive_like = ON` lost in an `openDatabase` refactor | Re-add the `onOpen` pragma in `database_helper.dart` open helpers |
| `flutter test` fails on LS URL suites after touching `ls_patterns.dart` | Pattern routing regression (MW falling back to AP patterns was a real 0.2.3 bug) | Run the per-dict `ls_url_*_test.dart` suites; `bin/ls_url_test.dart` for manual probing |
| Docs in `reference/` disagree with code | API drift | `python scripts/compare_docs.py` and fix whichever side is wrong |
| Dictionary shows as not downloaded right after a successful download (web) | IndexedDB write path (`sqflite_web_writer.dart`) vs `databaseExists` key mismatch — virtual keys are `csl_db_{code}` | Compare `DatabaseHelper.dbPath` web branch against the writer's key construction |

## 8. Glossary

| Term | Meaning |
|---|---|
| CDSL | Cologne Digital Sanskrit Dictionaries — the upstream project all data comes from |
| `codeUp` / `codeLo` | Dictionary siglum in upper/lower case (`MW`/`mw`) — `codeLo` names files/URLs, `codeUp` names Cologne endpoints |
| L-number (`lnum`) | Stable per-entry ID within a dictionary; decimal-valued; search results sort by it |
| ab / authtooltips / bib | The three optional sibling SQLites per dictionary (abbreviations, author tooltips, bibliography) |
| LS | Literary Source — a citation like `BhP. 3.12` inside an entry, deep-linked to the source text by `ls_service` |
| gh-pages (csl-sqlite) | The branch that *is* the dictionary CDN — same-origin with the deployed web app |
| IndexedDB | Browser storage where the web build keeps downloaded DBs (virtual keys `csl_db_{code}…`) |
| sqflite / sqflite_common_ffi / sqflite_common_ffi_web | The three SQLite bindings: mobile / desktop / browser, chosen by the `db_init_*` conditional import |
| Siddhanta1 | Bundled Devanagari font (`assets/siddhanta1.ttf`) |
| dictparms.py | Cologne pipeline's dictionary-parameter file — the upstream source the in-app registry mirrors |

## 9. Maintainer appendix

- **Known stale docstrings** (found 11-07-2026 while writing this manual; the
  code is right, the comments lag): (1)
  [io_helper.dart](https://github.com/sanskrit-lexicon/csl-app/blob/main/lib/core/io_helper.dart)
  says native downloads come "from the CSL server" — the actual
  `info.downloadUrl` is the csl-sqlite gh-pages URL on all platforms; (2) the
  [database_helper.dart](https://github.com/sanskrit-lexicon/csl-app/blob/main/lib/core/database_helper.dart)
  class comment still describes web DBs being "seeded from Flutter assets
  (assets/sqlite/…)" — asset seeding was removed (the file's own line-9 NOTE
  says so), `assets/sqlite/` is empty by design.
- **CI**: [deploy.yml](https://github.com/sanskrit-lexicon/csl-app/blob/main/.github/workflows/deploy.yml)
  (web release), [readme-guard.yml](https://github.com/sanskrit-lexicon/csl-app/blob/main/.github/workflows/readme-guard.yml)
  (README hygiene), [dependabot-auto-merge.yml](https://github.com/sanskrit-lexicon/csl-app/blob/main/.github/workflows/dependabot-auto-merge.yml).
  There is **no native-build CI** — Android/desktop artifacts are built by
  hand (§5.2–5.4).
- **Issue taxonomy**: Cologne tooling-repo taxonomy — one type + one severity
  label + one milestone per issue; see
  [CLAUDE.md](https://github.com/sanskrit-lexicon/csl-app/blob/main/CLAUDE.md).
- **Never-touch list**: the gh-pages download base URL (§2.1); the
  `--base-href /csl-app/` flag; the `onOpen` case-sensitivity pragma; the
  `assets/` + `fonts:` blocks in `pubspec.yaml`; `force_orphan: true` in the
  Pages deploy (gh-pages history is disposable by contract).

---

_Dr. Mārcis Gasūns_
