## Why

The repo promotes two productivity skills and has no engineering bucket, no model-invoked skill, and none of the shared contracts (check profile, state directory, handoff directory, brief files) that most of the 21 skills in `docs/generalizable-skills.md` depend on. Shipping the five Wave 1 skills that establish those contracts in one change lets every later port inherit settled conventions instead of inventing them per skill.

## What Changes

- Add `skills/engineering/` as a promoted bucket with its own `README.md`, and `docs/engineering/` for its docs pages.
- Add `bump-release` (engineering, user-invoked): port of the private `bump-release`, amended with forge detection for the release step, a wider manifest sweep, lockfile handling, tag-prefix detection, a missing-upstream path, and a stop when the repo uses changesets, lerna, release-please, or semantic-release.
- Add `fix-tests` (engineering, model-invoked): one skill merged from two private copies. Discovers and persists a check profile once, baselines, flake-checks, clusters failures by error signature, fixes by root cause with a hard iteration cap, and asserts no test was weakened. Ships `scripts/test-ledger.sh`.
- Add `explore` (engineering, model-invoked): thinking-partner reconnaissance that never implements, fans out read-only investigators when a question spans subsystems, falls back to sequential scopes when no subagent tool exists, and writes an explore brief in autonomous mode. First model-invoked skill in the plugin.
- Add `session-handoff` (productivity, user-invoked): writes a structured handoff before a context reset, proposes reusable constraints for the instruction file, prints the resume phrase.
- Add `session-primer` (productivity, model-invoked): one batched read-only sweep of git state, open plan boxes, the newest handoff, and the instruction file, then a short briefing with the next step.
- Standardize four shared contracts and restate each in every consuming skill: check profile (managed block plus JSON cache), state directory, handoff directory, explore brief. Update `session-retro` to the handoff-directory contract so all writers and readers agree; it keeps its current write location except in a repo whose only handoff directory is `docs/handoff/`.
- Housekeeping: reword the five `session-review` references in `session-retro`, add a `README.md` beside `product-spine/SKILL.md`, add the first Model-invoked entries to the top-level and bucket catalogs, document the shared contracts once in the top-level README, register the five skills in `.claude-plugin/plugin.json`, and refresh the plugin, package, and marketplace descriptions.
- Every new skill ships `SKILL.md`, `README.md`, `CHANGELOG.md`, `.gitignore`, `agents/openai.yaml`, `references/`, `evals/eval.yaml` with 4 to 7 rule-based cases, and a four-section docs page.
- No version bump. The release bump is a separate step and `bump-release` is the tool for it.

## Capabilities

### New Capabilities
- `bump-release`: lockstep version bump across every version-bearing manifest, then commit, tag, push, release.
- `fix-tests`: persisted check profile, baseline and cluster-driven repair, no-weakening assert.
- `explore`: read-only reconnaissance with fan-out, synthesis, and the explore brief contract.
- `session-handoff`: structured handoff document before a context reset.
- `session-primer`: session-start briefing from git state, plan docs, handoffs, and the instruction file.
- `shared-contracts`: the check profile, state directory, handoff directory, and brief conventions every consuming skill restates.
- `skill-catalog`: what a promoted skill must carry and where it must be listed, including the Model-invoked groups.

### Modified Capabilities
<!-- openspec/specs/ is empty; session-retro has no living spec. Its handoff-directory change is a requirement of shared-contracts above. -->

## Impact

- New directories: `skills/engineering/{bump-release,fix-tests,explore}/`, `skills/productivity/{session-handoff,session-primer}/`, `docs/engineering/`.
- Edited: `README.md` (Skills, Docs, How it works, Conventions, Status), `skills/productivity/README.md`, `CLAUDE.md` (engineering bucket line), `.claude-plugin/plugin.json` (skills, keywords, description), `.claude-plugin/marketplace.json` and `package.json` (descriptions and keywords, no version), `skills/productivity/session-retro/SKILL.md` (five rewords, handoff-dir rule), `skills/productivity/session-retro/references/skill-candidate-brief.md` (handoff-dir rule), `skills/productivity/session-retro/CHANGELOG.md` (Unreleased line), `docs/productivity/session-retro.md` (handoff-dir prose), `skills/productivity/session-retro/evals/eval.yaml` (collect `docs/handoff/**`), `docs/productivity/product-spine.md` (H1 and share line).
- Added: `skills/productivity/product-spine/README.md`.
- No runtime dependencies. Optional scripts need bash or Node, each with a spoken fallback.
- Validation: `npm run validate` (`claude plugin validate . --strict`) must pass; no CI exists yet.
