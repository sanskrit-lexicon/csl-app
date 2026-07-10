# BUILD_RELEASE_MANUAL.md — metadoc

_Created: 11-07-2026 · Last updated: 11-07-2026_

Companion record for
[docs/BUILD_RELEASE_MANUAL.md](https://github.com/sanskrit-lexicon/csl-app/blob/main/docs/BUILD_RELEASE_MANUAL.md).

## Purpose

The operator manual for csl-app: building/running/testing on all six Flutter
targets, per-platform release procedure (including Android signing and the
automatic web deploy), and the dictionary-data supply chain (csl-sqlite
gh-pages → runtime download → disk/IndexedDB). Answers "how do I ship a
release" and "why is the download failing" without reading `lib/core/`.

## Audience

- A maintainer shipping a versioned release (native or web).
- A new contributor doing their first build.
- An operator diagnosing download/DB failures reported by users.

## Provenance

Authored 11-07-2026 by Fable 5 (`claude-fable-5`) under handoff
[H504-Fable_csl-app_flutter_build_release_manual_10.07.26](https://github.com/gasyoun/Uprava/blob/main/handoffs/H504-Fable_csl-app_flutter_build_release_manual_10.07.26.md)
(the H501–H531 per-repo manuals programme, Litpam-Indexator MANUAL.md gold
standard). Every command, URL, and version constraint was read from the code
(`pubspec.yaml`, `lib/core/*`, `lib/models/dictionary_info.dart`,
`android/app/build.gradle.kts`, `.github/workflows/deploy.yml`) and from the
live csl-sqlite gh-pages listing — none invented.

## Ranked improvement backlog

| # | Item | Status |
|---|---|---|
| 1 | Fix the two stale docstrings the manual flags (§9): io_helper.dart "CSL server" comment; database_helper.dart asset-seeding class comment | open |
| 2 | Add a native-build CI job (at minimum `flutter build apk --debug` as a compile gate) — today only web is CI-built | open |
| 3 | Document (or implement) IndexedDB deletion for web — `deleteDictionary` is a silent no-op on web | open |
| 4 | Screenshot walkthrough of Manage Dictionaries for the release checklist | open |
| 5 | A scripted release ritual (version bump + changelog + tag in one command) | open |

## Known limitations

- iOS/macOS signing is described only generically — no project-specific
  provisioning is committed, and none of today's maintainers ships iOS
  regularly; that section is untested against a real App Store submission.
- The Cologne-side regeneration of `{code}.sqlite` (before it lands on
  csl-sqlite gh-pages) is out of scope here — it belongs to the upstream
  pipeline's docs.

## Related documents

- [README.md](https://github.com/sanskrit-lexicon/csl-app/blob/main/README.md) — repo overview + structure table
- [CHANGELOG.md](https://github.com/sanskrit-lexicon/csl-app/blob/main/CHANGELOG.md) — release history the manual's §5.5 feeds
- [CLAUDE.md](https://github.com/sanskrit-lexicon/csl-app/blob/main/CLAUDE.md) — issue taxonomy
- [reference/public.md](https://github.com/sanskrit-lexicon/csl-app/blob/main/reference/public.md) / [reference/private.md](https://github.com/sanskrit-lexicon/csl-app/blob/main/reference/private.md) — API reference checked by [scripts/compare_docs.py](https://github.com/sanskrit-lexicon/csl-app/blob/main/scripts/compare_docs.py)

## Revision history

| Date | Change | By |
|---|---|---|
| 11-07-2026 | Initial version (H504) | Fable 5 (`claude-fable-5`) |

---

_Dr. Mārcis Gasūns_
