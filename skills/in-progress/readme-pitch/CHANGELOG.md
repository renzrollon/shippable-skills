# Changelog

## 0.2.0 (2026-09-14)

Decisions side added; two run-blockers fixed.

- **Pitch brief (Phase 1b).** Five decisions the repo cannot settle (reader,
  archetype, claim, register, comparison), each with a recommendation
  derived from the inventory. `--ask` runs one answer-by-number round and
  waits; `--brief <path>` reads answers from a file; the default takes the
  recommendations and says so. The brief is written to the handoff dir and
  reloaded on re-runs, so a README's voice is a repo fact.
- **`DECISIONS:` report line**, source token first, so evals can tell
  assumed from asked from file.
- **Archetype detection** in Phase 1 (`cli`, `library`, `service`,
  `action-or-plugin`, `app`, `research-or-dataset`). The skeleton swaps
  sections 5, 8, and 13 by archetype; briefs A, C, D, E receive it.
- **Phase 0 no longer asks.** A README that already meets the bar stops the
  run with a message that names `--force`.
- **Briefs are filled in memory.** Phase 2 no longer reads as an instruction
  to edit the installed skill's own `references/briefs/`.
- **Diff summary moved after the cold read**, so the summary describes the
  file that lands.
- **`--draft-only` flag** replaces the `draft only` phrase; the phrase still
  maps to it.
- **Sentinel grader** accepts any root markdown file other than README.md as
  a home, matching the relocation checklist (CHANGELOG.md included).
- New evals: `decisions-assumed`, `already-pitched-stops`.

## 0.1.0 (2026-09-13)

First cut, extracted from the Interlock README redesign session. User-invoked,
host-neutral, in-progress until evals pass and one repo other than Interlock
has been through it.
