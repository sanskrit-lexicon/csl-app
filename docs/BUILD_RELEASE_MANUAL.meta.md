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
[H504-Fable_csl-app_flutter_build_release_manual_10.07.26](https://github.com/gasyoun/Uprava/blob/main/handoffs/archive/H504-Fable_csl-app_flutter_build_release_manual_10.07.26.md)
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

## Intended use / known misuse

**For:** a maintainer or contributor executing an actual build/release/debug
step on `csl-app` — copy-pasting a command, checking a platform-specific
signing requirement, or tracing why a dictionary download failed. It is a
day-to-day operator reference, not an architecture explainer.

**Known/likely misuse:**
- Reading it as documentation of the Cologne-side pipeline that produces
  `{code}.sqlite` files — that pipeline is explicitly out of scope (see
  "Known limitations" below) and lives in the upstream CDSL repos, not here.
- Treating the iOS/macOS signing section as a verified, project-specific
  runbook — it is generic Flutter guidance, untested against a real App
  Store submission, and should not be followed blind for a production iOS
  release.
- Using it as a substitute for
  [reference/public.md](https://github.com/sanskrit-lexicon/csl-app/blob/main/reference/public.md) /
  [reference/private.md](https://github.com/sanskrit-lexicon/csl-app/blob/main/reference/private.md)
  when the question is "what does this API method do" rather than "how do I
  build/ship" — the manual covers process, not the full API surface.
- Assuming any dictionary database ships inside the app binary — it never
  does; every dictionary is downloaded at runtime (§2 of the subject
  document), so the manual's build steps alone never produce an app with
  data preloaded.

## Maintenance & sunset plan

The subject document is maintained by whoever next changes the build/release
surface it documents — CI workflow edits
([.github/workflows/deploy.yml](https://github.com/sanskrit-lexicon/csl-app/blob/main/.github/workflows/deploy.yml)),
`pubspec.yaml` platform/version bumps, or changes to the download pipeline
(`lib/core/download_service.dart`, `lib/core/database_helper.dart`) should
update the manual in the same PR. There is no dedicated owner beyond the
`csl-app` maintainers collectively; the backlog item "scripted release
ritual" (item 5 above) is the closest thing to a planned automation owner.
"Archived/ended" for this document means: `csl-app` itself is retired or
replaced by a different client, or the build/release process it describes
is superseded by a different manual — at that point this file moves to
`docs/archive/` (matching the org's handoff-archive convention) with a
pointer left in its place, rather than being deleted.

## Deprecation status

`active`

## Related documents

- [README.md](https://github.com/sanskrit-lexicon/csl-app/blob/main/README.md) — repo overview + structure table
- [CHANGELOG.md](https://github.com/sanskrit-lexicon/csl-app/blob/main/CHANGELOG.md) — release history the manual's §5.5 feeds
- [CLAUDE.md](https://github.com/sanskrit-lexicon/csl-app/blob/main/CLAUDE.md) — issue taxonomy
- [reference/public.md](https://github.com/sanskrit-lexicon/csl-app/blob/main/reference/public.md) / [reference/private.md](https://github.com/sanskrit-lexicon/csl-app/blob/main/reference/private.md) — API reference checked by [scripts/compare_docs.py](https://github.com/sanskrit-lexicon/csl-app/blob/main/scripts/compare_docs.py)

## Revision history

| Date | Change | By |
|---|---|---|
| 11-07-2026 | Initial version (H504) | Fable 5 (`claude-fable-5`) |
| 11-07-2026 | template v2 backfill (H663) | Sonnet 5 (`claude-sonnet-5`) |

---

_Dr. Mārcis Gasūns_
