# csl-app

_Created: 18-03-2026 · Last updated: 11-07-2026_

The Cologne Digital Sanskrit Dictionaries are a web service — but a reader in
the field, in a library with no signal, or on a phone with a data cap needs
the dictionaries **offline**. csl-app (package name `cologne_sanskrit_lexicon`)
is a Flutter app that packages the CDSL dictionaries for Android, iOS,
macOS, Linux, Windows, and web from one Dart codebase, so lookup keeps
working with no connection and no per-query server round-trip.

The web build is deployed to GitHub Pages at
[sanskrit-lexicon.github.io/csl-app](https://sanskrit-lexicon.github.io/csl-app/)
(published from the `gh-pages` branch by
[.github/workflows/deploy.yml](https://github.com/sanskrit-lexicon/csl-app/blob/main/.github/workflows/deploy.yml)).

## Structure

| Path | Role |
|---|---|
| [lib/main.dart](https://github.com/sanskrit-lexicon/csl-app/blob/main/lib/main.dart) | App entry point |
| [lib/core/](https://github.com/sanskrit-lexicon/csl-app/tree/main/lib/core) | Shared core logic |
| [lib/features/](https://github.com/sanskrit-lexicon/csl-app/tree/main/lib/features) | Feature modules |
| [lib/models/](https://github.com/sanskrit-lexicon/csl-app/tree/main/lib/models) | Data models |
| [lib/providers/](https://github.com/sanskrit-lexicon/csl-app/tree/main/lib/providers) | State management |
| [lib/rendering/](https://github.com/sanskrit-lexicon/csl-app/tree/main/lib/rendering) | Entry rendering |
| [lib/db_init_io.dart](https://github.com/sanskrit-lexicon/csl-app/blob/main/lib/db_init_io.dart) / [lib/db_init_web.dart](https://github.com/sanskrit-lexicon/csl-app/blob/main/lib/db_init_web.dart) / [lib/db_init_stub.dart](https://github.com/sanskrit-lexicon/csl-app/blob/main/lib/db_init_stub.dart) | Platform-specific DB bootstrap (native / web / fallback) — the offline-first design surfaces directly in the file layout |
| [android/](https://github.com/sanskrit-lexicon/csl-app/tree/main/android), [ios/](https://github.com/sanskrit-lexicon/csl-app/tree/main/ios), [macos/](https://github.com/sanskrit-lexicon/csl-app/tree/main/macos), [linux/](https://github.com/sanskrit-lexicon/csl-app/tree/main/linux), [windows/](https://github.com/sanskrit-lexicon/csl-app/tree/main/windows), [web/](https://github.com/sanskrit-lexicon/csl-app/tree/main/web) | Per-platform Flutter shells |
| [test/](https://github.com/sanskrit-lexicon/csl-app/tree/main/test) | Test suite |
| [scripts/](https://github.com/sanskrit-lexicon/csl-app/tree/main/scripts) | Build/support scripts |
| [reference/](https://github.com/sanskrit-lexicon/csl-app/tree/main/reference) | Reference material |
| [docs/BUILD_RELEASE_MANUAL.md](https://github.com/sanskrit-lexicon/csl-app/blob/main/docs/BUILD_RELEASE_MANUAL.md) | **Operator manual**: per-platform build/run/release, Android signing, the automatic web deploy, and where the dictionary SQLites come from (csl-sqlite gh-pages, downloaded at runtime — nothing bundled) |

## Usage example — illustrative, not executed

This is a Flutter mobile/desktop app; running it needs the Flutter SDK and a
target device/emulator, which this session doesn't have. The real, standard
build/run commands for this exact package (read from
[pubspec.yaml](https://github.com/sanskrit-lexicon/csl-app/blob/main/pubspec.yaml), not invented) are:

```bash
flutter pub get
flutter run              # launches on a connected device/emulator/browser
flutter test              # runs the suite under test/
flutter build apk          # or: build ios / build macos / build linux / build windows / build web
```

`pubspec.yaml` confirms the package identity used above:

```
name: cologne_sanskrit_lexicon
description: Cologne Sanskrit Lexicon - offline dictionary app for the Cologne Digital Sanskrit Dictionaries.
version: 0.2.3+11
```

## Issues overview

Snapshot 2026-07-11: **0** open, **39** closed.

## GitHub issue conventions

Follows the [Cologne tooling-repo taxonomy](https://github.com/sanskrit-lexicon/csl-observatory/blob/main/runbook/cologne-tooling-runbook.md):

- **9 type labels**: `bug`, `feature`, `enhancement`, `performance`, `tech-debt`, `security`, `documentation`, `infrastructure`, `question`
- **4 severity levels**: `trivial`, `minor`, `major`, `critical`
- **5 milestones**: API Stability, User Experience, Data Quality, Developer Experience, Community
- **Domain labels** scoped to the web-frontend: `domain:ui`, `domain:routing`, `domain:i18n`, `domain:rendering`
- **Org Project**: [Tooling Roadmap](https://github.com/orgs/sanskrit-lexicon/projects/9)

See [CLAUDE.md](https://github.com/sanskrit-lexicon/csl-app/blob/main/CLAUDE.md) for full definitions.

---

_Dr. Mārcis Gasūns_
