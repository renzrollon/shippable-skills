## Why

Product owners and QA testers file GitLab issues by asking a lightweight chat agent, and the issues come out without the business and technical context the project already keeps in `openspec/` and `docs/`. A self-contained skill that finds that context cheaply, even when the agent has no checkout, and writes it in the reader's language fixes the gap. It needs no openspec CLI, no openspec skills, and no prebuilt index in the agent's container.

## What Changes

- Add `gitlab-issue` (productivity, model-invoked): turns a one-line feature or bug request into a GitLab issue enriched with the project's OpenSpec capabilities, in-flight changes, personas, glossary, and known-issue and backlog titles.
- The issue body puts plain-language content first: summary, who is affected, today against wanted or expected against actual, and acceptance criteria. A short Related list follows, then technical pointers inside a collapsed developer section.
- Context comes from a local checkout of the target project when there is one. Otherwise it comes from a shallow, sparse temporary copy fetched with the GitLab CLI's or git's existing authentication, and otherwise from the request alone. Tokens are never read, printed, or passed.
- Ships `scripts/issue-context.sh`, a POSIX sh script with two modes. `index` prints a compact capability, persona, glossary, and duplicate index, and `outline` prints the Purpose, Requirement titles, and Scenario titles for up to three capabilities.
- Ships `scripts/fetch-context.sh` (validated arguments, sparse clone, no prompts). Each script has an offline `.test.sh`.
- Creation path: a GitLab issue tool the host provides, else `glab issue create`, else the ready-to-paste draft in the reply. Requester text reaches a shell only through temporary files, and a request to draft or preview never creates.
- New convention line `shippable-issue-project: <host>/<path>` in the instruction file, so an agent with no checkout knows its target project. It is documented in README `## Conventions`.
- Catalog wiring per the existing skill-catalog rules: top-level `README.md` (Skills, Docs table, Status line, Conventions), `skills/productivity/README.md`, the `.claude-plugin/plugin.json` skills array, and `docs/productivity/gitlab-issue.md`.
- Nothing in the change names an internal project, host, issue, integration, or person.
- No version bump.

## Capabilities

### New Capabilities
- `gitlab-issue`: request handling, target project and context source resolution, deterministic context lookup from openspec/ and docs/, the audience-split issue body, shell-safe creation, and the create, glab, or draft output path.

### Modified Capabilities
<!-- openspec/specs/ is empty. The skill-catalog rules from add-foundation-skills apply unchanged; this change follows them and does not alter them. -->

## Impact

- New directory: `skills/productivity/gitlab-issue/` (`SKILL.md`, `README.md`, `CHANGELOG.md`, `.gitignore`, `agents/openai.yaml`, `references/`, `scripts/`, `evals/`).
- New docs page: `docs/productivity/gitlab-issue.md`.
- Edited: `README.md`, `skills/productivity/README.md`, `.claude-plugin/plugin.json` (skills array, keywords), and `.claude-plugin/marketplace.json` and `package.json` (descriptions and keywords, no version).
- Runtime: POSIX `sh`, `awk`, `grep`, `sed`, `sort`. `git` (2.25 or later, for sparse checkout) or `glab` for the fetch, and optionally `glab` for creation. No Node, no openspec CLI.
- Validation: `npm run validate` (`claude plugin validate . --strict`), `sh skills/productivity/gitlab-issue/scripts/issue-context.test.sh`, and `sh skills/productivity/gitlab-issue/scripts/fetch-context.test.sh`.
