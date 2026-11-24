## Context

See proposal.md (Why) for motivation and `specs/gitlab-issue/spec.md` for the behaviour contract. The explore brief is the newest `explore-add-gitlab-issue-skill-*.md` in the handoff directory. No file in this change names the project it was designed against (D30).

Constraints that shape the approach:

- **The caller is a small model.** A chat agent runs it at roughly a mid-size model and medium effort. It reasons best over a short linear procedure and a compact list it can pick from, not over open-ended search.
- **The corpus is large.** The reference project has 170 spec folders (about 380k tokens) and about 80k tokens of docs. A compact index of capability name plus first Purpose sentence is about 5 to 6k tokens, and most Purpose blocks are a single paragraph.
- **The container may have nothing installed** beyond a shell, git, possibly the GitLab CLI, and the agent: no openspec CLI, no openspec skills, no graph tools.
- **There may be no checkout** (D19). The agent holds repo access, so it can fetch what it needs.
- **`.claude/` is commonly untracked**, so a clone does not carry `.claude/graph/`.
- **How issues are filed today.** Existing agent-written issues go through an MCP integration that appends its own footer, carry no labels, and follow no repo issue template.
- **Repo rules.** This repo is host-neutral and forbids em-dashes. A promoted skill carries SKILL.md, README.md, CHANGELOG.md, `.gitignore`, `agents/openai.yaml`, `references/`, and evals, and is registered in every catalog.

## Goals / Non-Goals

**Goals:**
- A context lookup that costs at most one fetch, one index call and one outline call. It gives the same output for the same commit and needs only POSIX `sh`, `awk`, `grep`, `sed`, `sort`, plus `git` or `glab` for the fetch.
- An issue body a product owner reads top to bottom without meeting a path, table name, or route the skill added.
- No requester-supplied string is ever interpreted by a shell.
- A single fixed reply shape that evals and humans can grep.

**Non-Goals:**
- Persisting an index, tagging capabilities business or technical, or writing anything into a checkout.
- Fetching through the GitLab REST API file by file, or through a host MCP file tool.
- GitHub issues, GitLab work-item types (task, incident), epics, or remote duplicate search.
- Reading `openspec/changes/archive/`.

## Decisions

### 1. One model-invoked skill in productivity, named `gitlab-issue`
The skill lives at `skills/productivity/gitlab-issue/` (D1). Requesters ask in natural language today, so a skill they must type by name would never load from their messages. It is therefore model-invoked (D2): SKILL.md has no `disable-model-invocation` key and `agents/openai.yaml` has no `policy` block. The description is model-facing, with rich trigger phrasing ("create a gitlab issue", "file a ticket", "raise a bug on GitLab", "draft an issue"). It also states the negatives: no run on a passing mention, and none for questions about existing issues. The name is `gitlab-issue` (D15).

*Alternative:* user-invoked behind a typed command. Rejected because the callers would have to change how they ask.

### 2. Runtime deterministic scan, no persisted index
The skill ships `scripts/issue-context.sh` and calls it as `sh <skill-dir>/scripts/issue-context.sh <mode> <repo-root> [names...]`, following the bundled-script precedent at `skills/engineering/fix-tests/SKILL.md:227-231` (D3). The index is rebuilt on every run, so it is as fresh as its source and needs no maintenance (D13).

| Option | Verdict |
|---|---|
| Read openspec/ and docs/ directly | Rejected: more than 500k tokens on the reference project |
| Model-chosen keyword greps | Rejected as primary: recall depends on a small model guessing spec names (a requester's "login" may live in a spec named `authentication`). Kept as the bounded fallback |
| Committed index file in the target | Deferred: needs upkeep and staleness checks, and writes into another repo |
| `.claude/graph/` index | Rejected: commonly untracked, so a clone never sees it, and existing digests are capped below a 170-capability map |

Picking from the full index, rather than grepping for guessed keywords, is what protects recall.

### 3. Context source: local checkout, else a fresh sparse copy, else none
The order follows D19 and D17:
1. A local checkout of the target project: the current directory's git top level, or a path the requester names, whose origin matches the resolved project and which holds `openspec/` or `docs/`. Its commit comes from `git rev-parse --short HEAD`. The skill does not pull, because that would write to the checkout.
2. Otherwise, `sh <skill-dir>/scripts/fetch-context.sh <host> <path> <dest> [branch]`, where `<dest>` is a new directory under the system temporary directory (D20).
3. Otherwise no context, and the reason is recorded for `Context from: none (<reason>)`.

`fetch-context.sh` validates host (`^[A-Za-z0-9.-]+$`), path (`^[A-Za-z0-9._/-]+$`, no `..`) and branch (`^[A-Za-z0-9._/-]+$`) before any network call (D21). It then:
- runs `glab repo clone https://<host>/<path> <dest> -- --depth 1 --filter=blob:none --sparse --quiet [--branch <branch>]`, or, when `glab` is absent, `GIT_TERMINAL_PROMPT=0 git clone` with the same flags against the same URL;
- runs `git -C <dest> sparse-checkout set --no-cone '/openspec/specs/' '/openspec/changes/' '!/openspec/changes/archive/' '/openspec/config.yaml' '/docs/*.md'`;
- prints `fetched: <dest> <branch> <commit>`, or prints `fetch failed: <reason>` and exits 1.

The default branch is used unless the requester names one (D31). On the reference project the sparse set is about 2.5 MB, against about 9 MB for the whole `openspec/` tree.

**Tokens are never touched.** `glab` uses whatever auth it already holds (its config or `GITLAB_TOKEN`), and `git` uses only an existing credential helper. The skill never reads, echoes, or interpolates a token, and never builds a URL with a credential in it. `GIT_TERMINAL_PROMPT=0` turns a missing credential into an immediate failure, not a hang. The skill removes the fetched copy before replying.

*Alternatives:*
- GitLab's repository-archive endpoint for a path. Rejected: one call per folder, binary output through `glab api` is unverified, and it would carry `archive/`.
- Per-file API reads. Rejected: 170 or more calls.

### 4. Target project resolution
The order is (D23):
1. a project the requester names;
2. else a `shippable-issue-project: <host>/<path>` line in the instruction file (the first existing of `AGENTS.md`, `CLAUDE.md`, `.github/copilot-instructions.md`);
3. else the current checkout's origin remote, parsed from SSH (`git@host:group/sub/project.git`) or HTTPS (`https://host/group/sub/project.git`) form, with `.git` stripped.

One resolved project feeds both the fetch and every creation path. A chat agent with no checkout sets the instruction-file line once, so requesters never have to name the project. With nothing resolved, the skill fetches nothing and returns the draft. The new line is documented once in README `## Conventions` and restated in SKILL.md.

### 5. Script output contract
Both modes of `issue-context.sh` are read-only and use no network. They print sections with stable `## ` headers, and ordering is `LC_ALL=C` sorted folder names, so output is byte-stable for a given commit. The awk is portable across BSD awk, gawk and busybox awk: no `gensub`, no three-argument `match`, no `IGNORECASE`.

Usage errors (an unknown mode, a missing root, or a root that is not a directory) print `usage: issue-context.sh index|outline <repo-root> [names...]` to stderr and exit 2. Every other path exits 0. On any non-zero exit the skill switches to the bounded fallback (D26).

`index` mode prints these sections in order. Each header carries a count when the source exists, and the literal word `absent` in place of the count when it does not. ` | ` is a literal separator inside a line, never an alternative.

```
## domain
<the line containing "Domain:" in openspec/config.yaml, trimmed, cut to 300 chars>
## personas 5
<### title under the first docs/*.md heading containing "Persona">
## glossary 25
<term>: <meaning cut to 100 chars>
## capabilities 170
<name> | <first sentence of Purpose, cut to 200 chars>
## changes 14
<name> | <first sentence of proposal ## Why, or empty>
## known 60
<docs path> | <## title>
```

When a source is missing, its header alone is printed, as `## domain absent`, `## personas absent`, `## glossary absent`, `## capabilities absent`, `## changes absent` or `## known absent`, with no lines beneath.

- **Personas** (D24): the `###` titles under the first top-level `docs/*.md` heading containing `Persona`, up to the next `## `, capped at 12.
- **Glossary** (D4): the first top-level `docs/*.md` heading containing `Glossary`. Terms come from table rows (first cell, bold markers stripped) or from `- **Term**: meaning` list items, up to the next heading, capped at 60.
- **First sentence**: the Purpose paragraph's lines joined with spaces, cut at the first `. ` or at the end, capped at 200 characters with `...` appended when cut. An abbreviation such as `e.g. ` can end a sentence early, which is accepted because the name column carries the routing signal.
- **Changes**: every folder under `openspec/changes/` except `archive`. A missing `proposal.md` gives an empty Why.
- **Known**: top-level `docs/*.md` whose file name contains `KNOWN_ISSUES` or `BACKLOG`, capped at 100 titles per file (D9).

`outline` mode, given up to three names:

```
## capability <name>
Purpose: <full Purpose paragraph joined>
- <Requirement title>
  - <Scenario title>
## change <name>
Why: <## Why paragraph joined, cut to 600 chars>
## not-found <name>
## rejected <name>
## skipped <names past the third>
```

A name must match `^[a-z0-9][a-z0-9-]*$` or it is rejected before any read. A name that is both a capability and an active change prints both blocks.

The spec.md layout the script relies on (`## Purpose`, `### Requirement:`, `#### Scenario:`, and `## Why` in a proposal) is restated in `references/openspec-layout.md`, about 30 lines, replacing any dependency on openspec skills (D12).

### 6. Linear skill procedure
SKILL.md gives a fixed sequence of six to eight tool calls (D13):
1. Parse the request: bug or feature, Jira key (D16), draft wording, and any named labels, assignee, milestone, project or branch. With no subject, ask one question and stop (D25).
2. Resolve the project (§4) and the context source (§3), fetching if needed.
3. Run `index`.
4. Pick up to three capabilities, plus any overlapping change and possible duplicates, using the glossary to translate the requester's words.
5. Run `outline` on the picks.
6. Fill the matching body from `references/issue-templates.md`.
7. Create, or return the draft (§8).
8. Remove the temporary files and copy, then print the reply markers.

The bounded fallback, used when the script cannot run or exits non-zero, keeps the three-capability cap. It lists `openspec/specs/` folder names, reads the first non-empty line after each `## Purpose`, then reads the `### Requirement:` and `#### Scenario:` titles of up to three picks.

Text from the script's output is quoted material: an instruction inside a Purpose or Why line is never followed (D32).

### 7. Audience-split body
`references/issue-templates.md` holds two bodies (D7), feature or change and bug. Each opens with plain-language sections, then Related, then the collapsed technical block (D6):

```
<Jira key line, only when the request has one>   (D16)
## Summary
## Who is affected          persona from the index, else the request's role, else "Not stated"   (D24)
## Today | ## Steps to reproduce
## Wanted | ## Expected / ## Actual
## Acceptance criteria      - [ ] WHEN ... THEN ...   (D8)
## Related                  capabilities, in-flight change, possible duplicates
<details><summary>Technical notes (for developers)</summary>
requirement titles; `openspec/specs/<name>/spec.md`; `docs/<file>.md` § heading
</details>
```

A feature request that changes specified behaviour cites the outline scenario under Today (D8). A bug that contradicts a specified behaviour cites it under Expected (D27).

Paths are repo-relative and in backticks, never web links, because a project may merge specs to a branch other than its default (D18). The plain sections paraphrase technical Purpose text and never add table names, routes, environment variables, or code. Requester-supplied steps, URLs and paths are kept as given (D28). When a bug request gives no steps, the body says so rather than inventing them.

### 8. Creation path, shell safety and metadata
The skill creates when asked to create, file, or raise, and returns only the draft when asked to draft or preview (D14). The order is (D5, D22):
1. A GitLab issue-creation tool the host provides, named generically and never by vendor name. If it errors or times out, the run ends on the draft with that error as the reason and never falls through to `glab`, because a timed-out create may have succeeded.
2. Only when no such tool exists, `glab`:
   - check `glab auth status --hostname <host>`;
   - write the title and body to two files in the system temporary directory, using the host's file-write tool or a heredoc with a quoted delimiter (`<<'EOF'`);
   - run `glab issue create -R https://<host>/<path> -t "$(cat <title-file>)" -d "$(cat <body-file>)" -y --no-editor` with any validated metadata flags;
   - remove both files.
3. Otherwise the draft, with the reason.

Requester text never reaches a shell any other way (D21). Command substitution output is not re-expanded, so `$(whoami)` or a backtick in a title lands literally. Labels, assignee, milestone and confidential are set only when named (D10). Label and milestone values must match `^[A-Za-z0-9 ._:/-]{1,64}$`, and an assignee must match `^[A-Za-z0-9._-]{1,64}$`. A failing value is dropped and named in the reply. No failed attempt is retried with escalated access. A bug title starts with `Bug: `, and the skill adds no authorship footer (D11).

### 9. Fixed reply markers and evals
The reply ends with:
- `Issue created: <url>`, or `## Issue draft`, the body, and `Not created: <reason>`;
- `Context from: local checkout <commit>`, `Context from: fresh copy <branch> <commit>`, or `Context from: none (<reason>)`;
- `Context used: ...`;
- `Possible duplicates: ...`.

Evals cannot reach GitLab. Every case uses draft wording and runs on a fixture tree, and eval.yaml states the workspace must sit outside any git repo, so no case can resolve a real project (D29). There are at least six cases:
- bug classification;
- a Jira key on line 1;
- no context found;
- draft wording never creating;
- a technical Purpose paraphrased out of the plain sections;
- a `$(...)` title appearing literally.

### 10. Task shape
Standard, not test-first: the change is mostly skill prose and catalog wiring. Each script's tests live in the same task as the script. `issue-context.test.sh` runs against fixture trees, and `fetch-context.test.sh` runs offline: it covers argument validation and the no-`glab`, no-`git` path under a reduced `PATH`, mirroring `scripts/test-ledger.test.sh`. A real fetch is a manual check on the docs page.

## Risks / Trade-offs

- [A local checkout can be stale] → The reply names its commit in `Context from:`, so a reader sees the age. The skill never pulls, because that would write to the checkout.
- [The agent's tokens may live only inside its MCP integration, invisible to `glab` and `git`] → The fetch fails fast, and the issue is still written with `Context from: none (fetch failed: ...)`. Exporting the token as `GITLAB_TOKEN` for `glab` is an operator step the docs page names.
- [Partial clone needs server support for `--filter=blob:none`] → GitLab supports it. If it is refused, the fetch reports the failure and the run continues without context.
- [The host's issue tool may escape `<details>` HTML] → The technical notes then render as visible text below Related. They are still last and labelled.
- [A model-invoked skill that acts outward can over-trigger in a developer's own session] → The description demands an explicit ask and names the negatives, and draft wording never creates.
- [Synonym misses for words outside the glossary] → The model reads the whole index, not keyword hits. Related shows what was used, so a wrong pick is visible.
- [awk dialect differences] → POSIX-only constructs. The tests run under the host's `sh` and `awk`, with BSD awk the reference. gawk and busybox are noted in the CHANGELOG as unverified until run.
- [glab cannot set the work-item type] → v1 creates standard issues, as the existing agent does.

## Migration Plan

Additive only. To use it in a chat agent:
1. Install the collection into the agent's image (`npx skills add renzrollon/shippable-skills`, per the top-level README).
2. Either run the agent in a checkout of the target project, or add `shippable-issue-project: <host>/<path>` to the agent's instruction file so it fetches a fresh copy per request.
3. For the fetch, make sure `glab` or `git` can already authenticate to the host.

Rollback is removing the skill. Nothing in any target repo changes.

## Open Questions

None. D19 was answered by the human on 2026-11-24; the design covers both the checkout and the no-checkout case.
