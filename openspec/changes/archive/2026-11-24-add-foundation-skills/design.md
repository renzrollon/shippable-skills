## Context

See `proposal.md` for motivation. The explore brief at `.claude/handoff/explore-add-foundation-skills-20261021-223012.md` holds the source verification with line cites. What shapes the design:

- The repo's conventions are set by one exemplar, `skills/productivity/session-retro/` (frontmatter order, `agents/openai.yaml` shape, skill-up `v1alpha1` evals with rule-based judges, the `---` separated H2 body, the four-line `.gitignore`). No model-invoked skill exists yet; its shape follows `CLAUDE.md:21`.
- Sources are private pack skills coupled to OpenSpec, Interlock CLIs, and `.claude/` paths. Every coupling has a plain replacement (a file the user points at, grep, a documented directory). Sources carry between 2 and 58 em-dashes each.
- `session-retro` already implements a handoff-directory rule (`.claude/handoff` if present, else `.agents/handoff`) read by its docs page and its eval's `collect_artifacts`.
- References cannot be shared across skills, so each shared contract is restated inside every consumer and documented once in the top-level README.

## Goals / Non-Goals

**Goals:**
- Five skills that install and run with nothing else installed: no openspec, no interlock, no graph CLI, no host-specific tool names.
- Every shared contract has at least one writer in this change and a restated consume rule. The handoff document's reader (`session-primer`) ships here; the explore brief's reader is a later spec skill.
- `npm run validate` green; every promoted skill carries evals in the existing format.

**Non-Goals:**
- The review cluster, `fan-out`, `grill` (and so grill-brief pickup in `explore`, D22), and any Wave 2 or 3 skill.
- A repo lint or CI workflow for the `CLAUDE.md` rules (tracked separately).
- A version bump or release (D13).
- Running the SkillGantry gate; CHANGELOG entries say "Not yet run through the SkillGantry gate."

## Decisions

Ledger ids refer to `decisions.md`.

**D1: Scope is five contract-establishing skills plus housekeeping.** Alternative: all ten Wave 1 skills. Rejected because the review cluster has its own contracts (scope step, finding schema, policy file) and `mr` depends on Wave 2's `manual-test-plan`; one review of ten skills is not a ten-minute read.

**D2: Handoff skill name.** Open; artifacts use `session-handoff` so the family reads `session-retro`, `session-handoff`, `session-primer`. Renaming to `handoff` before ship is a find-and-replace across the skill folder, both catalogs, the docs page, and `plugin.json`.

**D3: State directory and JSON cache.** `.claude/` if present else `.agents/`, matching `session-retro`; a `--state-dir` argument or a `shippable-state-dir:` line in the instruction file wins. The instruction file is the first existing of `AGENTS.md`, `CLAUDE.md`, `.github/copilot-instructions.md`. The managed block is authoritative so a human edit always wins; the cache mirrors it and is what `fix-tests` falls back to when the block cannot be written. Alternative: instruction-file-only. Rejected: a declined or denied block write would then lose the discovery.

**D4: Test-file edits in `fix-tests`.** Allowed with a stated reason and one ledger line per file, plus `scripts/test-ledger.sh` as the runnable check. Alternative: forbid all test edits (the private hook). Rejected: a wrong expected value is a real `test-bug` verdict and must be fixable.

**D5: Check profile home and fence.** Managed block fenced `shippable:checks` in the first existing of `AGENTS.md`, `CLAUDE.md`, `.github/copilot-instructions.md`, created in `AGENTS.md` when none exists. The survey gives two names for this block; the Formats section is taken as canonical. `AGENTS.md` leads because more hosts read it. A skill writes its own fenced block without asking and names the write in its report; anything outside a fence (such as `session-handoff`'s proposed constraints) waits for a yes. That is why model-invoked `fix-tests` may write and `session-handoff` must ask.

**D6: Profile fields.** unit, typecheck, lint, build, e2e, known flaky, discovered-from. Typecheck and lint come from the specflow profile; build is new and nullable. `null` plus a note line means "looked and found nothing"; an absent key means "not looked". This resolves the ambiguity the private engine had, where null was also the default for unconfigured e2e.

**D7: Assert failure behaviour.** Stop, print which count moved, revert only edits made since the run snapshot (D20); an explained drop is reported not reverted. Mirrors the private engine's actual behaviour rather than the prose that said "revert blindly".

**D8: `session-primer` reads plan docs and the instruction file.** New behaviour versus the source, which read OpenSpec tasks and a memory corpus. Plan docs are any `*.md` under `docs/` or the repo root with unchecked boxes, capped at the five most recently modified.

**D9: `session-handoff` proposes instruction-file constraints.** New behaviour versus the source, which filed memory entries. Writes nothing without a yes; durable-knowledge filing is deferred to a future `capture-learnings`.

**D10: `bump-release` forge and tag prefix.** Forge from `git remote get-url origin`; `gh` for GitHub, `glab` for GitLab, else skip with the manual command printed. Tag prefix from `git tag --list` sorted by version, default `v`.

**D11: Lockfiles.** Excluded from the manifest sweep by name, then refreshed in the edit step with the ecosystem command (`npm install --package-lock-only`, `cargo update --workspace`, `uv lock`), and staged by name.

**D12: Evals.** 4 to 7 `rule_based` cases per skill, prompts for user-invoked skills start with the slash form, prompts for model-invoked skills are natural language that should trigger. No LLM judge; skill-up's judge types beyond `rule_based` and `script` are unconfirmed.

**D13: No version bump.** `CLAUDE.md:13` ties the bump to a release and `README.md:86` names the next release step as the product-spine gate run.

**D14: `product-spine` README.** Added as housekeeping because `CLAUDE.md:15` requires it and it is missing.

**D15: `explore` fan-out and fallback.** Uses the host's subagent tool when present, runs scopes sequentially otherwise, and says which in the brief. The source had no fallback.

**D16: Explore brief template.** Drops the Ready Checklist and `source_grill`; keeps nine headings; adds an optional decision table with two classes. Validity of `agent_resolved` is not audited by a tool here, so the brief only requires a followable evidence cell.

**D17: Investigator return schema.** JSON only, `{files, how, connections, gaps}`, taken from the specflow source; the carl-workflow source used narrative bullets.

**D18: Discovery ladder extension.** Adds Maven, Gradle, dotnet, Makefile `test`, rspec to the source ladder (which already had Node, Python, Go, Rust, tox, and runner configs).

**D19: Handoff directory order.** `.claude/handoff/`, `.agents/handoff/`, `docs/handoff/`; write to the first found, readers scan all three. When none exists, writers create `.agents/handoff/`, not `<state-dir>/handoff/`: tying the create to the state directory would move `session-retro`'s writes to `.claude/handoff/` in every repo that has `.claude/` but no handoff directory. The survey's order put `docs/handoff/` first; that would silently move where `session-retro` writes in a repo that has both. With this order and fallback, `session-retro` writes exactly where it does today unless `docs/handoff/` is the only handoff directory, or the user passes or configures a path. `session-retro` only writes handoffs, so it gains the third fallback and the overrides, not the read-all. Consumers updated in this change: `session-retro/SKILL.md`, `session-retro/references/skill-candidate-brief.md`, its docs page, its eval `collect_artifacts`, its CHANGELOG, plus the three new skills.

**D20: Run snapshot in `fix-tests`.** `git stash create` prints a commit object for the dirty tree without touching the tree, index, or stash list; `HEAD` stands in when the tree is clean. The ledger script and the D7 revert diff against it, so edits that predate the run are neither reported nor reverted. Alternative: refuse to run on a dirty tree. Rejected: failing tests are usually fixed mid-change.

**D21: Pre-existing failures.** Re-run the failing tests on the default branch in a temporary worktree under the system temp directory, then remove it. This never touches the user's tree or index. When `git worktree add` fails, the failure stays in scope and the report says the check was skipped.

**D22: Grill pickup deferred.** No grill skill or grill-brief contract ships here, so `explore` does not read grill briefs yet; `grill` stays a reserved handoff kind.

**Skill body layout.** Every new `SKILL.md` follows the exemplar: intro with the host-neutral paragraph and the never-block-on-I/O rule, `## Output contract (non-negotiable)`, `## Input`, `## Steps` (`### 0.` gate first), `## Rules`, `## Related`. Long tables (discovery ladder, forbidden moves, brief template, entry patterns) go to `references/` so `SKILL.md` stays well under 500 lines.

**Descriptions.** User-invoked descriptions are human-facing and name what the skill does. Model-invoked descriptions carry trigger phrasing and a negative clause: `explore` says it skips single-file questions and is not for interviewing; `session-primer` says it does not trigger on questions that name a file or feature; `fix-tests` says it is not a general debugger.

## Risks / Trade-offs

- [No model-invoked precedent; `claude plugin validate --strict` may reject an inferred shape] → run `npm run validate` in the last task section and fix the shape before catalog edits are considered done.
- [Em-dash drift from source text] → every port task ends with a grep for the character over the skill folder and its docs page.
- [`explore` description triggers too often or never] → three eval cases pin trigger, non-trigger on a single-file question, and refusal to implement.
- [`fix-tests` discovery on Maven or Gradle is untested] → one eval case uses a `pom.xml` fixture; the docs page states which ecosystems were exercised.
- [Handoff-directory change touches `session-retro`] → its consumers (SKILL.md, the skill-candidate-brief reference, docs page, eval) are covered by tasks 1.20 and 1.21, which copy the rule from `specs/shared-contracts/spec.md`; task 3.2 greps for leftover two-directory wording, and task 3.4 re-runs `session-retro`'s evals.
- [`SKILL.md` length] → `fix-tests` and `explore` keep procedure in `SKILL.md` and tables in `references/`; the task for each names the 500-line cap as its check.

## Migration Plan

Additive. Merge the branch; nothing to roll back beyond reverting the merge. `session-retro` keeps writing where it writes today in every repo except one whose only handoff directory is `docs/handoff/`; there it now writes to `docs/handoff/` instead of creating `.agents/handoff/`. Its CHANGELOG says so.
