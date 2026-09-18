# Changelog

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
