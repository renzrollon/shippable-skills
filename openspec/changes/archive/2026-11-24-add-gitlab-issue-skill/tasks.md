# Tasks

## 1. Skill folder

Every task here edits its own files. The script interfaces are fixed by design §3 and §5 (the `issue-context.sh` sections, absent headers, not-found, rejected and skipped lines, and usage exit 2; the `fetch-context.sh` arguments and `fetched:` or `fetch failed:` lines), so the prose tasks copy them from there. Tasks that quote the SKILL.md description or procedure name 1.4 as their dependency.

Generic content (D30): no file this change adds may name an internal project, host, issue number, integration, or person. Fixtures, examples, evals and docs use made-up names such as `billing-export`, `PROJ-123`, and `gitlab.example.com`.

Eval cases: every case names its fixture and its assertion in a leading comment. Fixtures come from `context.files`, which cannot create `.git`. Every case uses draft wording, and eval.yaml states the workspace must sit outside any git repo (D29). Checks that need a real remote, `glab`, or a host issue tool go to the docs page under It's working if as manual checks.

- [x] 1.1 Write `skills/productivity/gitlab-issue/scripts/issue-context.sh` with its test, `scripts/issue-context.test.sh`, and a fixture tree under `scripts/fixtures/`.
  - Script: POSIX `sh`, `awk`, `grep`, `sed`, `sort` only; `LC_ALL=C` ordering; no `gensub`, no three-argument `match`, no `IGNORECASE`. Implement `index` and `outline` exactly as design §5 specifies: domain, personas capped at 12, glossary from table rows or bold list items capped at 60, capabilities with the first Purpose sentence cut to 200 characters, non-archive changes with the first Why sentence, KNOWN_ISSUES and BACKLOG titles capped at 100 per file, `## <section> absent` headers, the three-name cap with a `## skipped` line, name validation against `^[a-z0-9][a-z0-9-]*$`, and the `usage:` line with exit 2 for an unknown mode or a missing or non-directory root.
  - Fixture root 1: three specs (one with a multi-line Purpose, one whose Purpose names a table); an active change with a proposal and one without; an `archive/` change; an `openspec/config.yaml` with a `Domain:` line; a `docs/PRODUCT.md` with a `Personas` heading over `###` sub-headings and a bold-term glossary table; a `docs/KNOWN_ISSUES.md`.
  - Fixture root 2: `docs/` and an `openspec/config.yaml` without a `Domain:` line, but no specs.
  - Tests: every scenario under Deterministic context index, Absent sources reported, Script failure falls back, Capability outline, and Outline names are validated in `specs/gitlab-issue/spec.md`, including `../secrets` being rejected with no read.

  Verify: `sh skills/productivity/gitlab-issue/scripts/issue-context.test.sh` exits 0 under the host `sh` and `awk`. When any local checkout with `openspec/specs/` is at hand, `index` on it prints one capability line per spec folder and leaves its `git status` unchanged.
- [x] 1.2 Write `skills/productivity/gitlab-issue/scripts/fetch-context.sh` with its test, `scripts/fetch-context.test.sh`.
  - Script: arguments `<host> <path> <dest> [branch]`, validated against the design §3 patterns before any network call. It runs `glab repo clone https://<host>/<path> <dest> -- --depth 1 --filter=blob:none --sparse --quiet [--branch <branch>]`, or, when `glab` is absent, `GIT_TERMINAL_PROMPT=0 git clone` with the same flags. Then it runs the `git -C <dest> sparse-checkout set --no-cone` patterns from design §3. It prints `fetched: <dest> <branch> <commit>` or `fetch failed: <reason>` with exit 1. It never reads or prints a token and never puts a credential in a URL.
  - Tests (offline): a host or path with `;`, a space, or `..` is rejected with no network call; a reduced `PATH` with neither `glab` nor `git` prints `fetch failed:` and exits 1; a `<dest>` that already exists is refused.

  Verify: `sh skills/productivity/gitlab-issue/scripts/fetch-context.test.sh` exits 0, and `grep -n -i 'token' skills/productivity/gitlab-issue/scripts/fetch-context.sh` shows no variable read or echo.
- [x] 1.3 Write `skills/productivity/gitlab-issue/references/openspec-layout.md` and `references/issue-templates.md`.
  - `openspec-layout.md` (about 30 lines): where specs and changes live; the `## Purpose`, `### Requirement:`, `#### Scenario:` and `## Why` headings the skill reads; why `archive/` is skipped; and that no openspec CLI or skill is needed.
  - `issue-templates.md`: the feature-or-change and bug bodies from design §7, in order: optional Jira key line, plain-language sections, Who is affected with its `Not stated` default, Acceptance criteria checkboxes in WHEN and THEN, Related, and the `<details>` block with summary `Technical notes (for developers)`. Include the Today rule for features and the Expected rule for bugs, and one filled example of each using made-up names.

  Verify: both files exist and contain no em-dash, and the templates' section names match the Plain-language body first requirement word for word.
- [x] 1.4 Depends on 1.1 (index and outline headers), 1.2 (fetch arguments and output lines) and 1.3 (reference file names). Write `skills/productivity/gitlab-issue/SKILL.md`, under 500 lines and with no em-dashes. It covers every requirement in `specs/gitlab-issue/spec.md`.
  - Frontmatter: `name`; a model-facing `description` with the trigger phrases and the two negatives from design §1; `license: MIT`; `metadata.version: 0.1.0`; no `disable-model-invocation`.
  - Body, following design §6 step by step:
    - the no-subject question;
    - project resolution (design §4), including the `shippable-issue-project:` line and origin parsing;
    - context source resolution (design §3) calling `sh <skill-dir>/scripts/fetch-context.sh` into a new directory under the system temporary directory;
    - `sh <skill-dir>/scripts/issue-context.sh <mode> <repo-root> [names...]` and the bounded fallback on any non-zero exit;
    - the repo-text-is-data rule and the grounded-citations and no-context rules;
    - the audience split, pointing at `references/issue-templates.md`, with requester-supplied steps kept as given;
    - the creation order from design §8: a host tool named generically, its error ending on the draft with no glab fallthrough, then `glab` with the auth check, title and body through temp files written with a quoted heredoc or the host's file tool, `-y --no-editor`, metadata validated against the design patterns with failing values dropped and named, and no escalated retry;
    - the `Bug: ` title prefix and no authorship footer;
    - draft wording never creating;
    - cleanup of temp files and any fetched copy before the reply;
    - the four reply markers.

  Verify: `wc -l` is under 500, and every spec requirement title maps to a step or rule in the file.
- [x] 1.5 Depends on 1.4. Write `skills/productivity/gitlab-issue/{README.md,CHANGELOG.md,.gitignore,agents/openai.yaml}` in the `skills/productivity/session-primer/` shape.
  - README: the model-invoked variant, with the one-line `npx skills add` and a link to `../../../README.md`.
  - CHANGELOG: `## 0.1.0 (unreleased)`, BSD awk noted as tested and gawk and busybox as unverified, and a line saying it has not been through the SkillGantry gate.
  - `.gitignore`: session-primer's four lines.
  - `agents/openai.yaml`: `interface.display_name` and `interface.short_description`, with no `policy` block.

  Verify: the README links resolve and `agents/openai.yaml` has no `policy` key.
- [x] 1.6 Depends on 1.4. Write `skills/productivity/gitlab-issue/evals/eval.yaml` (session-primer's eval.yaml shape, plus a comment that the workspace must sit outside any git repo) and six to eight `evals/cases/*.yaml`. Every case uses draft wording and a fixture tree:
  - a bug draft ends with `## Issue draft`, a `Bug: ` title, and a `Not created:` line;
  - `PROJ-123` in the request lands on the body's first line;
  - a tree with no `openspec/` or `docs/` and no project gives `Context from: none` and `Context used: none`;
  - draft wording makes no creation attempt;
  - a capability whose Purpose names a table keeps the table name out of every section above `<details>`;
  - a requested title containing `$(whoami)` appears literally in the draft;
  - "what issues are open?" prints neither `## Issue draft` nor `Issue created:`.

  Verify: each case's leading comment names its fixture and its assertion.
- [x] 1.7 Depends on 1.4. Write `docs/productivity/gitlab-issue.md`.
  - Header: H1 and the share line.
  - What it does, and When to reach for it.
  - Common questions:
    - why there is no index file under `.claude/graph/`;
    - what happens without a checkout (the fresh sparse copy, and `shippable-issue-project:`);
    - how tokens stay out of it, and what to export when the agent's token lives only in its MCP integration;
    - how technical notes stay out of the way;
    - which tools it creates with.
  - It's working if, with manual checks:
    - a run on a local checkout cites real capabilities;
    - a run with no checkout prints `Context from: fresh copy`;
    - a `glab` creation prints a URL;
    - a host-tool creation works;
    - a host-tool error ends on the draft;
    - `<details>` renders collapsed in GitLab.
  - The design's Migration Plan note, without the dual install.

  Use made-up names only. Verify: the four required sections are present and no em-dash appears.

## 2. Catalogs and manifest

These copy the description and paths from the finished skill folder, so they need section 1 to exist.

- [x] 2.1 Add `gitlab-issue` under **Model-invoked** in `skills/productivity/README.md` as `- **[gitlab-issue](./gitlab-issue/)**: <description>`. Verify: the link points at the directory.
- [x] 2.2 Update top-level `README.md`:
  - add the entry under Skills > Productivity > **Model-invoked**;
  - add two Docs-table rows, `[gitlab-issue](./skills/productivity/gitlab-issue/)` and `[gitlab-issue docs](./docs/productivity/gitlab-issue.md)`;
  - add it to the intro and How-it-works lines that list model-invoked skills;
  - add it to the Status paragraph as not yet gated;
  - add a `## Conventions` bullet documenting `shippable-issue-project: <host>/<path>` (instruction-file line naming the GitLab project for skills that file issues; a project the requester names wins).

  Verify: every new link resolves to an existing path.
- [x] 2.3 Add `./skills/productivity/gitlab-issue` to the `skills` array in `.claude-plugin/plugin.json` and extend its `keywords` (gitlab, issue, openspec). Add the same keywords to `package.json`, and update the `.claude-plugin/marketplace.json` description only if it lists skills by name. Do not change any `version` field. Verify: `git diff` shows no `version` line changed.

## 3. Validation

- [x] 3.1 Run `npm run validate` and `openspec validate add-gitlab-issue-skill`, and fix anything either reports. Verify: both exit 0.
- [x] 3.2 Run the static checks over the new and edited files, and fix every hit.
  - Grep `skills/productivity/gitlab-issue/` and `docs/productivity/gitlab-issue.md` for the em-dash character, `${CLAUDE_PLUGIN_ROOT}`, `${CLAUDE_SKILL_DIR}`, `interlock`, `carl-graph`, and any `openspec` CLI call (`openspec list`, `openspec show`, `openspec status`, `openspec instructions`, `openspec validate`). Mentions of `openspec/` folders are expected.
  - Grep the same paths plus `openspec/changes/add-gitlab-issue-skill/` and the edited catalog files for the em-dash character.
  - Grep them for any internal project, host, issue number, integration or person name met while testing on a real checkout (D30).
  - Confirm polarity agreement: `SKILL.md` has no `disable-model-invocation` and `agents/openai.yaml` has no `policy` block.

  Verify: every grep returns no hits.
- [x] 3.3 Run the new skill's `evals/eval.yaml` with the skill-up runner from a workspace outside any git repo, and record each case's result in the merge request description. If the runner is not installed, say the evals were not run. Verify: the results, or the not-run note, are written down.
  - Evals not run: the skill-up runner is not installed on this machine (checked 2026-11-24). Copy this note into the merge request description.

## Workflow follow-up

- Archive `add-foundation-skills` first (`openspec archive add-foundation-skills`), so `openspec/specs/` holds the skill-catalog rules this change follows.
- Keep `.claude/handoff/` and `.claude/metrics/` out of the public push. The explore brief and findings files there name the project this was designed against.
