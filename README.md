# csl-app

_Created: 18-03-2026 · Last updated: 05-07-2026_

The Cologne Digital Sanskrit Dictionaries are a web service — but a reader in
the field, in a library with no signal, or on a phone with a data cap needs
the dictionaries **offline**. csl-app (package name `cologne_sanskrit_lexicon`)
is a Flutter app that packages the CDSL dictionaries for Android, iOS,
macOS, Linux, Windows, and web from one Dart codebase, so lookup keeps
working with no connection and no per-query server round-trip.

## Structure

| Path | Role |
|---|---|
| [lib/main.dart](lib/main.dart) | App entry point |
| [lib/core/](lib/core) | Shared core logic |
| [lib/features/](lib/features) | Feature modules |
| [lib/models/](lib/models) | Data models |
| [lib/providers/](lib/providers) | State management |
| [lib/rendering/](lib/rendering) | Entry rendering |
| [lib/db_init_io.dart](lib/db_init_io.dart) / [lib/db_init_web.dart](lib/db_init_web.dart) / [lib/db_init_stub.dart](lib/db_init_stub.dart) | Platform-specific DB bootstrap (native / web / fallback) — the offline-first design surfaces directly in the file layout |
| [android/](android), [ios/](ios), [macos/](macos), [linux/](linux), [windows/](windows), [web/](web) | Per-platform Flutter shells |
| [test/](test) | Test suite |
| [scripts/](scripts) | Build/support scripts |
| [reference/](reference) | Reference material |

## Usage example — illustrative, not executed

This is a Flutter mobile/desktop app; running it needs the Flutter SDK and a
target device/emulator, which this session doesn't have. The real, standard
build/run commands for this exact package (read from
[pubspec.yaml](pubspec.yaml), not invented) are:

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
```

## Issues overview

Snapshot 2026-05-29: **3** open, **36** closed.

| Milestone | Open | Closed | Total |
|---|---:|---:|---:|
| User Experience | 2 | 0 | 2 |
| Developer Experience | 1 | 0 | 1 |

Open by type: enhancement 1 · documentation 1 · bug 1. By severity: minor 2 · trivial 1.

## GitHub issue conventions

Follows the [Cologne tooling-repo taxonomy](https://github.com/sanskrit-lexicon/csl-observatory/blob/main/runbook/cologne-tooling-runbook.md):

- **17 type labels** across 5 categories
- **4 severity levels**: trivial, minor, major, critical
- **5 milestones**: API Stability, User Experience, Data Quality, Developer Experience, Community
- **Domain labels** scoped to web-frontend: `domain:ui`, `domain:routing`, `domain:i18n`, `domain:rendering`
- **Org Project**: [Tooling Roadmap](https://github.com/orgs/sanskrit-lexicon/projects/9)

See [CLAUDE.md](CLAUDE.md) for full definitions.

---

_Dr. Mārcis Gasūns_
