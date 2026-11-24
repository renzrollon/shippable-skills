## Branch Name
`feat/new-skills`

## Commit Message
```
feat(skills): add five foundation skills

Add bump-release, fix-tests, explore, session-handoff, and
session-primer, plus the shared contracts (check profile, state
directory, handoff directory, explore brief) later ports inherit.
```

## MR Title
feat(skills): add five foundation skills and shared contracts

## MR Description
## Summary

- Adds `skills/engineering/` as a promoted bucket with three skills: `bump-release` (user-invoked lockstep version bump plus commit, tag, push, release), `fix-tests` (model-invoked test repair with a persisted check profile and a no-weakening assert), and `explore` (model-invoked read-only reconnaissance with fan-out and an explore brief). `explore` is the plugin's first model-invoked skill.
- Adds two productivity skills: `session-handoff` (user-invoked handoff document before a context reset) and `session-primer` (model-invoked session-start briefing).
- Standardizes four shared contracts (check profile, state directory, handoff directory, explore brief), restates each in every skill that uses it, and moves `session-retro` onto the same handoff-directory resolution order.
- Catalog housekeeping: first Model-invoked groups in the READMEs, plugin and marketplace registration, refreshed descriptions and keywords. The version is not bumped; that happens in a separate release step.

## Changes

- **New skills:** `skills/engineering/{bump-release,fix-tests,explore}/`, `skills/productivity/{session-handoff,session-primer}/`. Each one ships `SKILL.md`, `README.md`, `CHANGELOG.md`, `.gitignore`, `agents/openai.yaml`, `references/`, and `evals/` (4 to 7 rule-based cases).
- **Script:** `skills/engineering/fix-tests/scripts/test-ledger.sh` with `test-ledger.test.sh`.
- **Docs pages:** `docs/engineering/{bump-release,explore,fix-tests}.md`, `docs/productivity/{session-handoff,session-primer}.md`. Edits to `session-retro.md` and `product-spine.md`.
- **session-retro:** handoff-directory resolution order, `session-review` references reworded, eval collects `docs/handoff/**`, CHANGELOG Unreleased line.
- **Catalog and manifests:** `README.md`, `skills/engineering/README.md` (new), `skills/productivity/README.md`, `skills/productivity/product-spine/README.md` (new), `CLAUDE.md`, `.claude-plugin/plugin.json`, `.claude-plugin/marketplace.json`, `package.json`.

## High Risk Changes

- `session-retro` changes where it writes handoff notes when a repo has `.agents/handoff/` or `docs/handoff/` but no `.claude/handoff/`. Rollback: revert the `session-retro` hunks. The rest of the PR is additive.

## Prerequisites to Production

None. No runtime dependencies. The optional scripts need bash, and each has a spoken fallback.

## Testing

- Unit: `bash skills/engineering/fix-tests/scripts/test-ledger.test.sh`: 9 pass, 0 fail.
- `npm run validate` (`claude plugin validate . --strict`) fails on the CLAUDE.md-at-root and missing-icon warnings. It fails the same way on `main`, so this PR did not introduce it.
- Repo conventions checked mechanically: no em-dashes added, SKILL.md under 500 lines, user-invoked flags in sync across both harnesses, READMEs, docs pages, and plugin.json entries present for all 7 promoted skills.
- Not covered: the skill evals (`evals/eval.yaml`) were not run in this pass.
