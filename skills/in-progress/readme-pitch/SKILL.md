---
name: readme-pitch
description: Rewrite this repository's README into a first-screen pitch. Hero above the fold, pitch done before the first heading, technical detail moved into docs with links, every test pin and anchor kept.
license: MIT
argument-hint: "[--ask | --brief <path>] [--repos <owner/repo,...>] [--no-research] [--max-agents <n>] [--hero <path>] [--draft-only] [--force]"
disable-model-invocation: true
metadata:
  version: 0.2.0
---

Rewrite this repository's README into a first-screen pitch. The one-line
rule: **a reader who knows the domain understands in five seconds what this
is, who it is for, what outcome it promises, and what to type next.**

You are already invoked. Run the phases in this file against the repo that is
the current working tree. The main agent is the only writer. Research briefs
do not edit files.

Two kinds of input feed the rewrite. **Facts** are what the repo can settle
(Phase 1 inventory, brief D). Look them up; never ask for them. **Decisions**
are what only the maintainer can settle (who the reader is, the one claim,
the register, whether to name rivals). Phase 1b collects them: asked when
`--ask` is given, read from a file with `--brief`, otherwise recommended from
the facts and named out loud in the report. Never decide silently.

This skill is **host-neutral**. Discover this skill's directory as the folder
that contains this `SKILL.md` (the path the host used to load it). Scripts
live at `<skill-dir>/scripts/`. Map host tool aliases when tallying; do not
depend on a plugin-root env var or one vendor's tool names.

## Input

| Arg | Meaning |
|-----|---------|
| _(none)_ | Pitch the current repo. Research if the host has a web tool. Take the recommended pitch decisions and say so. |
| `--ask` | Run the one pitch-brief round (Phase 1b) and wait for answers before research. |
| `--brief <path>` | Take pitch decisions from this file (format in [references/pitch-brief.md](references/pitch-brief.md)). Missing file: say so, fall back to the default. |
| `--repos a/b,c/d` | Neighbour survey targets (`owner/repo`). Enables brief B even in sequential mode. |
| `--no-research` | Skip briefs A, B, C. Use [references/first-screen-rules.md](references/first-screen-rules.md). Speak the skip. |
| `--max-agents N` | Cap spawned agents across the whole run, including brief E. Default 5. |
| `--hero <path>` | Use this image as the hero. If it is missing, say so and continue. |
| `--draft-only` | Show the draft summary. Do not overwrite `README.md`. |
| `--force` | Rewrite even when Phase 0 finds the README already meets the bar. |

Natural language maps onto the flags. "Ask me first", "interview me", "let
me choose the pitch" is `--ask`. "Don't fetch competitors" is
`--no-research`. "Draft only" / "do not overwrite" is `--draft-only`.
`--ask` with `--brief`: the round still runs, with the file's answers as
the recommendations.

**Overwrite policy.** After the cold read (Phase 6), show a short diff
summary (before/after line counts, sections added or removed, docs that will
absorb content, cold-read changes applied), then overwrite `README.md` on
this same turn. Wait for a human only during the `--ask` round or when they
said `--draft-only`. Showing the summary is the human-visible stop; it is
not a blocking checkpoint.

## Refuse or flag

**Refuse** (stop that action, say why, continue the rest):

- Deleting a section whose facts have no docs home yet. Relocate first.
- Editing, weakening, or deleting a test that asserts on README content. Keep
  the string in the README.
- Restating a number the repo derives (test counts, subcommand counts, cap
  values). Link to the command that prints it, or omit the number.
- Naming a rival the pitch brief's comparison field does not allow, or one
  nobody fetched or supplied. Named rivals come from `--repos`, the pitch
  brief, or a research report that fetched them, nowhere else.
- Asking the user for a fact the repo can settle, or asking any question in
  default mode (no `--ask`), on any host.

**Flag** (do the rewrite, list each under `OUTSIDE THIS CHANGE`):

- A hero whose content contradicts the text.
- An unpublished package, before adding a version badge.
- A landing page or site whose copy the new tagline contradicts.
- A missing social preview. A hero the repo still needs designed (see
  [references/hero-guidance.md](references/hero-guidance.md)).

## Handoff dir

```bash
if [ -d .claude/handoff ]; then HAND=".claude/handoff"
else mkdir -p .agents/handoff; HAND=".agents/handoff"
fi
date +%Y%m%d-%H%M%S
```

Prefer `.claude/handoff` when it already exists. Write:

- `readme-pitch-inventory-<timestamp>.md`
- `readme-pitch-brief-<timestamp>.md` (Phase 1b; reloaded on re-runs)
- `readme-pitch-research-<brief>-<timestamp>.md` for every brief that ran
  (A, B, C, D, E). These are the audit trail for competitor claims.
- `readme-pitch-draft-<timestamp>.md` (Phase 5)
- `readme-pitch-pins-<timestamp>.txt` (one pinned string per line)
- `readme-pitch-hero-prompt-<timestamp>.md` when no usable hero exists

Unavailable I/O: report the item as unavailable, never guess.

## Host dispatch (Phase 2 and 6)

Fan-out without asking. Honour a model policy the user stated or that a
project instructions file names (`AGENTS.md`, `CLAUDE.md`, `.cursor/rules`).
Otherwise use the host default. Do not hard-code a vendor's model names.

| Host | Fan-out | Fallback |
|------|---------|----------|
| Claude Code | Agent tool, `subagent_type: general-purpose`, `run_in_background: true`, one call per brief in a single message | none needed |
| Cursor | `Task` / background agents, brief as the prompt | sequential |
| Codex | no subagents | sequential |
| Copilot | no subagents | sequential |

Each spawned brief counts toward `--max-agents`. Default 5 covers A+B+C+D and
later E. If the cap is lower, queue. Sequential order when there is no
fan-out: **D, then C, then A**. Skip B unless `--repos` names competitors.
Say which briefs were skipped in the report.

**No web tool on the host**, or `--no-research`: skip A, B, and C entirely.
Read [references/first-screen-rules.md](references/first-screen-rules.md).
Degradation is spoken, never silent.

**Brief contract** (every brief already carries it; substitute the
placeholders in memory, then hand the text verbatim): fetch raw READMEs from
`raw.githubusercontent.com/OWNER/REPO/HEAD/README.md`, fall back to `main`
then `master`; if a fetch fails, say so and move on; count lines with a
tool, not by eye; quote taglines verbatim; put per-repo data in tables; end
with rules phrased "Do X before Y because Z, as REPO shows". No brief edits
files. Honour the word cap.

## Scripts

```bash
node "<skill-dir>/scripts/check-links.mjs" README.md <other-touched.md...>
bash "<skill-dir>/scripts/check-pins.sh" "$HAND/readme-pitch-pins-<timestamp>.txt" README.md
```

`check-links.mjs` is stdlib Node (GitHub slugger semantics, no collapsing).
If Node is absent, grep relative links by hand and say so in `LINKS:`.

## Steps

### Phase 0: Gate

- Must be a git repository with a `README.md`. Otherwise stop and say so.
  Make no edits.
- Read the README once, in full. Record line count and the line number of
  the first image, first code block, first H2, and the install snippet.
- If the README is already under 150 lines **and** has an image before the
  first code block, it meets the bar. Say so, name `--force` as the way to
  rewrite it anyway, and stop. Make no edits and emit no report block. Do
  not ask whether to continue; nobody answers in an unattended run. With
  `--force`, continue.

### Phase 1: Inventory (deterministic, cheap, before any research)

Gather with file tools and **one shell command per call**. Best-effort; an
unavailable item is reported as unavailable, never guessed.

| Item | How |
|------|-----|
| Archetype | Detect from the table below. Record every match; the first in table order is the recommendation. |
| Image assets and pixel sizes | list `docs/assets`, `assets`, `.github`; `sips -g pixelWidth -g pixelHeight` (macOS) or `file` |
| Package metadata | `package.json` / `pyproject.toml` / `Cargo.toml`: name, version, description, `files` |
| Publish state | registry lookup (`curl` the npm/PyPI JSON). A version badge on an unpublished package shows "not found" |
| CI workflow names | list `.github/workflows/*.yml`, read `name:` |
| README consumers | grep the repo for `README` outside `node_modules`, `.git`, archives |
| Anchor links into README | grep for `README(.md)?#` in docs, CHANGELOG, skills, site |
| Root entry count | `ls` at root. With 15 or more root entries, nothing in the README is above the fold on the repo home page; the description and topics do that job. Say this in the report. |
| Command or entry inventory | Per archetype: `--help` of every shipped binary; exported names of a library; `inputs:` of an action and frontmatter `name` of every skill; documented endpoints or the start command of a service. The quick start lists only entries that exist. |
| Site or landing copy | `site/`, `docs/index.*`. The README tagline must not contradict the site. |

Archetype signals, in priority order:

| Archetype | Signal |
|-----------|--------|
| `action-or-plugin` | `action.yml`; `.claude-plugin/plugin.json`; a tree of `SKILL.md`; an extension `manifest.json` |
| `cli` | `bin` in `package.json`; `[project.scripts]` in `pyproject.toml`; `[[bin]]` in `Cargo.toml`; `cmd/` in a Go module |
| `app` | `index.html` or `src/app`; a mobile or desktop app manifest |
| `service` | `Dockerfile`, `docker-compose.*`, `Procfile`, a server entry point |
| `library` | `main`, `exports`, or `types` in `package.json` with no `bin`; `[lib]` in `Cargo.toml`; a package with no script entry |
| `research-or-dataset` | `CITATION.cff`, a paper PDF, or `data/` with no code entry |

Write the inventory to the handoff path above. Phase 5 reads it back.

From README consumers, extract every string a test asserts on. Write those
strings, one per line, to the pins file. That file is the contract for
Phase 4 and `check-pins.sh`.

### Phase 1b: Pitch brief (decisions)

Read [references/pitch-brief.md](references/pitch-brief.md). Five decisions:
reader, archetype, claim, register, comparison. Each gets a recommended
answer derived from the inventory (the reference says how).

1. If the handoff dir already holds a `readme-pitch-brief-*.md`, load the
   newest as the recommendation source. `--brief <path>` overrides it. A
   missing `--brief` path is reported and ignored.
2. Derive a recommendation for every decision the source leaves blank.
3. Mode:
   - **default**: take every recommendation. Ask nothing. Not one question,
     on any host, even one with a question tool.
   - **`--ask`**: print the round in the reference's exact shape, end the
     turn, wait. Parse the reply by number and letter. Unanswered items take
     the recommendation.
4. Write the brief to `$HAND/readme-pitch-brief-<timestamp>.md` in the
   reference's file format. Phases 2, 3, 5, 6, and 8 read it. A re-run in
   this repo reloads it, so the README's voice is a repo fact, not a
   per-user setting.

### Phase 2: Research fan-out

Read each brief from `<skill-dir>/references/briefs/`, substitute the
placeholders **in memory**, and pass the result as the agent's prompt (or,
with no fan-out, follow it in-process). **Never write to the skill
directory.** If a filled brief must exist on disk, write it to the handoff
dir.

| # | File | Web | Cap |
|---|------|-----|-----|
| A | [references/briefs/category-survey.md](references/briefs/category-survey.md) | yes | 1800 |
| B | [references/briefs/neighbour-survey.md](references/briefs/neighbour-survey.md) | yes | 1800 |
| C | [references/briefs/pitch-craft.md](references/briefs/pitch-craft.md) | yes | 2000 |
| D | [references/briefs/internal-audit.md](references/briefs/internal-audit.md) | no | 2500 |
| E | [references/briefs/cold-read.md](references/briefs/cold-read.md) | no | 1200 |

Launch A, B, C, D together when the host can and the cap allows. **Hold E**
until Phase 6. Write each returned report to the handoff dir.

| Placeholder | Source |
|-------------|--------|
| `{{REPO_NAME}}`, `{{REPO_DESCRIPTION}}` | package metadata; else the H1 and first paragraph |
| `{{ARCHETYPE}}`, `{{CATEGORY}}` | the pitch brief: its archetype, and the claim's category word |
| `{{SEED_REPOS}}` | `--repos` plus the brief's rivals; may be empty |
| `{{NEIGHBOUR_REPOS}}` | `--repos`; empty skips B |
| `{{INVENTORY_PATH}}`, `{{PITCH_BRIEF_PATH}}`, `{{README_PATH}}`, `{{DRAFT_PATH}}`, `{{ROOT}}` | handoff and repo paths |

### Phase 3: Synthesize the target shape

Read [references/readme-skeleton.md](references/readme-skeleton.md). Apply
the brief's archetype row: it swaps sections 5, 8, and 13 and decides
whether the tagline names a host. Comparison `skip` drops section 10;
`unnamed` keeps it without rivals. Fix the section order and a line budget
per section **before writing a word**. Targets: pitch (sections 1 to 6)
complete within 30 rendered lines and about 660 px; whole README 100 to 150
lines; first H2 no later than line 25.

### Phase 4: Relocate before cutting

Read [references/relocation-checklist.md](references/relocation-checklist.md).
Nothing leaves the README until it has a home. From brief D's orphan-fact
table:

1. For each group with an existing home, extend that doc at the named heading.
2. For groups with no home, create the smallest number of new files. Two
   recurring ones: a CLI and configuration reference (every subcommand
   verified against `--help`, every environment variable in one table) and a
   root `CONTRIBUTING.md` (development commands, conventions, release).
3. Repoint every anchor that pointed into a moved section. GitHub slug
   rules: lowercase, strip punctuation, each space becomes a hyphen, **no
   collapsing**. A heading with a spaced em dash (U+2014) produces a double
   hyphen: the dash is stripped, both spaces remain.
4. Fix stale counts by removing the number or deriving it, never by updating
   one literal to another.
5. Keep every string a test asserts on. A pinned string may move within the
   README but not out of it.

Do relocations with strict single-match replacements so a target that no
longer matches fails loudly instead of silently skipping.

### Phase 5: Draft

Write the README from the skeleton, the budgets, and the pitch brief. The
tagline speaks to the brief's reader, makes its claim, and holds its
register. Rules the cold read will otherwise catch:

- No term before its definition. Define at first use or replace with plain words.
- One job per sentence. Split anything over 30 words.
- Bold the first words of a bullet, never a whole sentence.
- The install snippet says where a bare binary comes from before it asks the
  reader to run one.
- Internal consistency: what the default command does, and what a flag adds,
  said the same way in the code comment, the flow table, and the bullets.
- No hand-written counts of tests, subcommands, or skills. Derive or omit.

Write the draft to the handoff dir. Do not show a diff summary yet: the cold
read changes the draft, and the summary must describe the file that lands.

If no usable hero is in the inventory and `--hero` was not given, write the
design prompt (from [references/hero-guidance.md](references/hero-guidance.md))
to handoff and list it under `OUTSIDE THIS CHANGE`. Do not generate an image.
If a usable image exists, place it with an explicit width, before any code
block.

### Phase 6: Cold read, summary, overwrite

Run brief E against the draft (`{{DRAFT_PATH}}`, with `{{PITCH_BRIEF_PATH}}`
so it can check the draft against the decisions). Prefer a spawned agent if
the `--max-agents` budget remains; otherwise follow the brief in-process.
Apply its top five. Re-run the pin and link checks after.

Then show the diff summary: before/after line counts, sections added or
removed, docs that absorbed content, and how many cold-read changes were
applied. This is the one human-visible stop. Then overwrite `README.md` on
this same turn unless `--draft-only`.

### Phase 7: Verify

- **Links.** Every relative link and anchor in every touched file resolves.
  Run `check-links.mjs` on those files. Where Node is absent, grep and say so.
- **Pins.** Every inventory pin is still present. Run `check-pins.sh`.
- **The repo's own test command**, from `package.json` or the project
  instructions file, run exactly as documented. Paste the tail.
- **Plugin or package validation** if the repo has one (`claude plugin
  validate`, `npm pack --dry-run`, and the like).

### Phase 8: Report

The reply **ends** with this block, exact labels, one per line. Downstream
automation and the evals grep it. Keep honest caveats in the prose above;
keep these tokens exact.

```
README: <before> -> <after> lines
HERO: line <n>, before first code block: yes|no
PITCH COMPLETE BY: line <n>
PINS KEPT: <k>/<k>
LINKS: all resolve | <n> broken
MOVED: <file> (<section>), ...
DECISIONS: <assumed | asked | brief <path>> | reader: <...> | archetype: <...> | claim: <...> | register: <...> | compare: <named|unnamed|skip>
RESEARCH: <ran, pipe-separated> ran | <skipped, pipe-separated> skipped (<reason>)
TESTS: <command> -> <pass>/<fail>
OUTSIDE THIS CHANGE: <one line each>
```

`PITCH COMPLETE BY` is the last line of sections 1 to 6 (the pitch), which
must equal or precede the first H2.

`DECISIONS` starts with the source token, then the five decisions in this
order. Examples:

- `DECISIONS: assumed | reader: a Node developer who already ships a CLI | archetype: cli | claim: turns a long README into a five-second pitch | register: outcome | compare: skip`
- `DECISIONS: asked | ...`
- `DECISIONS: brief .claude/handoff/readme-pitch-brief-20260914-101500.md | ...`

`RESEARCH` examples:

- `RESEARCH: A|B|C|D|E ran | skipped (none)`
- `RESEARCH: D|E ran | A|B|C skipped (--no-research)`
- `RESEARCH: D|E ran | A|B|C skipped (no web tool)`
- `RESEARCH: A|C|D|E ran | B skipped (no --repos)`

When A, B, and C are all skipped, the line **must** contain the substring
`A|B|C skipped` so evals can grep it.

`OUTSIDE THIS CHANGE` is one line per flagged item, or `none`.
`MOVED` is `none` when nothing relocated.

On either Phase 0 stop (no README, or the README already meets the bar
without `--force`), do **not** emit this block. Say why the skill stopped,
and make no edits.

## Related

- Pitch brief, modes, and the `DECISIONS` line: [references/pitch-brief.md](references/pitch-brief.md)
- Distilled first-screen rules: [references/first-screen-rules.md](references/first-screen-rules.md)
- Skeleton, budgets, and archetype swaps: [references/readme-skeleton.md](references/readme-skeleton.md)
- Relocate-before-cutting: [references/relocation-checklist.md](references/relocation-checklist.md)
- Hero choice and design prompt: [references/hero-guidance.md](references/hero-guidance.md)
- Briefs: [references/briefs/category-survey.md](references/briefs/category-survey.md),
  [neighbour-survey.md](references/briefs/neighbour-survey.md),
  [pitch-craft.md](references/briefs/pitch-craft.md),
  [internal-audit.md](references/briefs/internal-audit.md),
  [cold-read.md](references/briefs/cold-read.md)
