# Changelog

## Unreleased

Handoff directory now follows the shared contract: a user path, an instruction
file override, then the first existing of `.claude/handoff/`, `.agents/handoff/`,
`docs/handoff/`, else `.agents/handoff/`. The write location changes only in a
repo whose sole handoff directory is `docs/handoff/` (it now writes there
instead of creating `.agents/handoff/`), or when a path is passed or configured.
Mentions of `session-review` now read "a log-scoring tool such as agent-insights".

## 0.2.0 (unreleased)

Token Utilization now scores the same dimensions Anthropic's `session-report`
looks for, without reading logs or inventing cache numbers.

- Findings first: 3-5 share-of-session lines (`most`, `~half`, `5×`, `lean`),
  then moments, then 1-4 recommendations that also feed Wiring.
- New tool-economy rules: Attribute-to-skill, Keep-the-prefix,
  Budget-subagents, One-prompt-share. Existing locate/batch/state rules stay.
- `--focus tokens` still forbids wiring tables and exact uncached / cache-read
  / output tables. Point at `session-report` for a 7-day numeric Claude Code
  report; this skill does not run it.

## 0.1.0 (2026-08-21)

First shipped release. Gate run the same day: `validate → evaluate → security → release`.

| Stage | Tool | Result |
| --- | --- | --- |
| 1 · validate | skill-lint 0.2.0 | passed, 0 findings (11 files) |
| 2 · evaluate | skill-up 0.7.0 | passed, 4/4 cases |
| 3 · security | SkillSpector 2.5.1 | passed, 0 actionable (1 reviewed suppress) |
| 4 · optimise | SkillHone | skipped (tool still being wired in SkillGantry) |
| 5 · release | skills 1.5.21 | passed, archive verified installable |

Evaluate cases, all PASS: `current-session-report`, `focus-tokens`, `focus-wiring`, `refuse-transcript-reread`.

The security suppress is SkillSpector rule P2 on an HTML comment in the wire-in template: visible author guidance, not a hidden agent directive. The baseline file stays local (gitignored).
