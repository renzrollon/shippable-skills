# Plan: `readme-pitch`

A user-invoked, host-neutral skill that rewrites a repository's README into a first-screen pitch: hero visible without scrolling, the pitch finished before the first H2, every technical detail moved into docs with a link, and not one fact, test pin or anchor lost on the way.

Extracted from the Interlock README redesign session of 2026-09-13 (359 lines to 127, five Opus subagents, suite green throughout). Everything below that is a rule was learned there; everything that is a prompt was run there.

Status: `in-progress` (implemented in this folder; not in the plugin). Promote to `engineering/` once the evals pass and one repo other than Interlock has been through it.

Section 7 open questions are locked to the proposed defaults: overwrite after a draft summary unless the user said draft only; write brief reports to the handoff dir; hero image stays a human step; no hard-coded vendor model names; stay in this bucket until promotion.

---

## 1. What the skill does, in one screen

| | |
|---|---|
| Invoke | `/readme-pitch [--repos a/b,c/d] [--no-research] [--max-agents N] [--hero <path>]` |
| Input | The repo you are in. Optional: competitor repos to survey, a hero image path |
| Output | A rewritten `README.md`, the docs that absorbed its technical content, a fixed final report block |
| Human stops | One: the draft is shown before it overwrites the old README. Everything else runs |
| Never | Deletes a fact without giving it a docs home. Breaks a string a test asserts on. Restates a number the repo derives. Invents a competitor claim it did not fetch |

The one-line rule the skill enforces: **a reader who knows the domain understands in five seconds what this is, who it is for, what outcome it promises, and what to type next.**

---

## 2. Phases

Each phase names its deliverable so a host without subagents can still run it in order in one context.

### Phase 0: Gate

- Must be a git repository with a `README.md`. Otherwise stop and say so.
- Read the README once, in full. Record line count and the line number of the first image, first code block, first H2, and the install snippet.
- If the README is already under 150 lines with an image before the first code block, say so and ask whether to continue. Do not rewrite a README that already meets the bar.

### Phase 1: Inventory (deterministic, cheap, before any research)

Gather these with the host's file tools and one shell command per call. Every item is best-effort; an unavailable item is reported as unavailable, never guessed.

| Item | How | Why it matters |
|---|---|---|
| Image assets and pixel sizes | list `docs/assets`, `assets`, `.github`; `sips -g pixelWidth -g pixelHeight` (macOS) or `file` | Decides whether a hero exists and how tall it renders at 900 px wide |
| Package metadata | `package.json` / `pyproject.toml` / `Cargo.toml`: name, version, description, `files` | Tagline consistency; whether README ships in the package |
| Publish state | registry lookup (`curl` the npm/PyPI JSON) | A version badge on an unpublished package shows "not found" |
| CI workflow names | list `.github/workflows/*.yml`, read `name:` | The CI badge needs the exact file name |
| README consumers | grep the repo for `README` outside `node_modules`, `.git`, archives | Tests that assert README strings; scripts that read it |
| Anchor links into README | grep for `README(.md)?#` in docs, CHANGELOG, skills, site | Sections you move must keep or redirect these |
| Root entry count | `ls` at root | Sets how far below the fold the README starts on the repo home page |
| Command inventory | `--help` of every shipped binary; frontmatter `name` of every skill | The quick start must list only commands that exist |
| Site or landing copy | `site/`, `docs/index.*` | The README tagline must not contradict the site |

Write the inventory to `<handoff-dir>/readme-pitch-inventory-<timestamp>.md` (`.claude/handoff` if it exists, else `.agents/handoff`). Phase 5 reads it back; the report cites it.

### Phase 2: Research fan-out (up to five agents, or sequential)

Five briefs, shipped as files under `references/briefs/`. Each is handed to an agent verbatim with the placeholders filled. Each returns a markdown report under a word cap. **No brief edits files.** The main agent is the only writer.

| # | Brief | Needs web | Deliverable | Word cap |
|---|---|---|---|---|
| A | `category-survey.md` | yes | Per-repo first-screen table for ~10 top repos in the project's category; median length; 8 to 10 transferable rules; 3 anti-patterns. Every claim cites a README it fetched | 1800 |
| B | `neighbour-survey.md` | yes | Same table for direct competitors and ecosystem neighbours; how each answers "why would I use this" in ten lines; how they show the install command | 1800 |
| C | `pitch-craft.md` | yes | First 30 lines of ~10 tools known for excellent READMEs; a pixel-budget skeleton; 6 taglines in named registers; 3 three-bullet value blocks; badge discipline; hero recommendation | 2000 |
| D | `internal-audit.md` | no | Coverage map README section to docs anchor; orphan facts grouped by natural home; consumers and pins with `file:line`; assets; metadata; verified command inventory; discrepancies | 2500 |
| E | `cold-read.md` | no | Held back. Runs on the draft in Phase 6: three passes (5 s, 30 s, full), top 5 changes first, terms used before definition, internal contradictions, sentences over 30 words | 1200 |

Launch A, B, C, D together. Hold E. Never spawn more than `--max-agents` (default 5) across the whole run.

**Host dispatch.** The skill names the mechanism per host and falls back without asking:

| Host | Fan-out | Fallback when absent |
|---|---|---|
| Claude Code | `Agent` tool, `subagent_type: general-purpose`, `run_in_background: true`, one call per brief in a single message. Honour the user's stated model policy for subagents; if none is stated, use the host default | none needed |
| Cursor | `Task` / background agents with the brief as the prompt | sequential |
| Codex | no subagents | sequential |
| Copilot | no subagents | sequential |

**Sequential order when there is no fan-out:** D first (the audit is required), then C (pitch craft), then A. Skip B unless `--repos` names competitors. Say which briefs were skipped in the final report.

**No web tool on the host:** skip A, B and C entirely and use `references/first-screen-rules.md`, the distilled rules from the 2026-09-13 run. Say so in the report. Degradation is spoken, never silent.

**Brief contract (every brief carries it):** fetch raw READMEs from `raw.githubusercontent.com/OWNER/REPO/HEAD/README.md`, fall back to `main` then `master`; if a fetch fails, say so and move on; count lines with a tool, not by eye; quote taglines verbatim; put per-repo data in tables; end with rules phrased "Do X before Y because Z, as REPO shows".

### Phase 3: Synthesize the target shape

From the reports plus `references/readme-skeleton.md`, fix the section order and a line budget per section before writing a word. The skeleton the 2026-09-13 run converged on:

| Order | Section | Budget | Must contain |
|---|---|---|---|
| 1 | H1 | 1 line | The name only |
| 2 | Tagline | 1 to 2 lines, bold | What it is, for whom, the outcome. Under 20 words. The category word (for search) and the host or platform. No dependency names |
| 3 | Badges | one row, 4 max | Version (only if published), CI, the hardest compatibility constraint as a static badge, license. No stars, downloads or chat at a young version |
| 4 | Hero | 1 image | Before any code block. Shows the outcome or the mechanism, not the architecture. Cap ~300 px rendered if a usage block must also fit; ~500 px if the image carries the pitch itself |
| 5 | Usage block | 2 to 4 lines | The commands the reader will actually type, with comments that say what happens. Usage before install: four of ten exemplars do it |
| 6 | Value bullets | 3, each 2 sentences max | The three strongest facts. Bold lead words. No aphorisms |
| 7 | Install | 15 to 25 lines | Requirements in one sentence with a link to the full table; the copy-paste commands; the once-per-repo step; a link to the first-hour doc |
| 8 | The flow / How it works | 10 to 15 lines | A table of the user-facing commands with one line each |
| 9 | Why this | 5 to 6 bullets | Each bullet one differentiator, one link to the doc that proves it |
| 10 | How it compares | 3 short paragraphs | Name the competitors. State the axis. State the trade |
| 11 | Experimental / status | 5 to 8 lines | Anything a test pins that does not fit above lives here, one job per sentence |
| 12 | Docs index | one table | Every doc, one line each |
| 13 | Development | 5 lines | Clone, test, load. Link `CONTRIBUTING.md` |
| 14 | Credits and license | 1 to 2 lines | |

Targets: pitch (sections 1 to 6) complete within 30 rendered lines and about 660 px; whole README 100 to 150 lines; first H2 no later than line 25.

### Phase 4: Relocate before cutting

Nothing leaves the README until it has a home. From brief D's orphan-fact table:

1. For each group with an existing home, extend that doc at the named heading.
2. For groups with no home, create the smallest number of new files. Two recurring ones: a **CLI and configuration reference** (every subcommand verified against `--help`, every environment variable in one table) and a root **`CONTRIBUTING.md`** (development commands, conventions, release procedure).
3. Repoint every anchor that pointed into a moved section (docs, CHANGELOG, site). Use GitHub slug rules when you write the new anchor: lowercase, strip punctuation, each space becomes a hyphen, **no collapsing**, so a heading that contains a spaced em dash produces a double hyphen (the dash is stripped, both spaces remain).
4. Fix stale counts you meet on the way by removing the number or deriving it, never by updating one literal to another.
5. Keep every string a test asserts on. Read the assertions; they are the contract. A pinned string may move within the README but not out of it.

Do all of this with strict single-match replacements in a script, so a target that no longer matches fails loudly instead of silently skipping.

### Phase 5: Draft

Write the README from the skeleton and the budgets. Rules the cold read will otherwise catch:

- No term before its definition. "Waves", "lane", "strict", protocol acronyms: define at first use or replace with plain words.
- One job per sentence. Split anything over 30 words.
- Bold the first words of a bullet, never a whole sentence.
- The install snippet says where a bare binary comes from before it asks the reader to run one.
- Internal consistency: what the default command does, and what a flag adds, said the same way in the code comment, the flow table and the bullets.
- No hand-written counts of tests, subcommands or skills. Derive or omit.

Show the draft. This is the one human stop.

### Phase 6: Cold read

Run brief E against the draft. Apply its top five. Re-run the pin and link checks after.

### Phase 7: Verify

- **Links.** Every relative link and anchor in every touched file resolves. Ship `scripts/check-links.mjs` (stdlib Node, GitHub slugger semantics); where Node is absent, do it by grep and say so.
- **Pins.** Every string the inventory found a test asserting on is still present. Ship `scripts/check-pins.sh` that takes the list and greps.
- **The repo's own test command**, from `package.json` or the project instructions file, run exactly as documented. Paste the tail.
- **Plugin or package validation** if the repo has one.

### Phase 8: Report (machine-parse contract)

The reply ends with this block, exact labels, one per line, so downstream automation and the evals can grep it:

```
README: <before> -> <after> lines
HERO: line <n>, before first code block: yes|no
PITCH COMPLETE BY: line <n>
PINS KEPT: <k>/<k>
LINKS: all resolve | <n> broken
MOVED: <file> (<section>), ...
RESEARCH: A|B|C|D|E ran | skipped (<reason>)
TESTS: <command> -> <pass>/<fail>
OUTSIDE THIS CHANGE: <one line each>
```

`OUTSIDE THIS CHANGE` carries what the skill noticed but must not do on its own: a hero image whose content contradicts the text, a missing social preview, a stale version on a landing page.

---

## 3. Files to create

```
skills/engineering/readme-pitch/
  SKILL.md                         under 500 lines; the phases above as steps
  agents/openai.yaml               display_name "README pitch", allow_implicit_invocation: false
  CHANGELOG.md
  references/
    first-screen-rules.md          the distilled rules and anti-patterns (section 4 below)
    readme-skeleton.md             the section table from Phase 3 with budgets
    relocation-checklist.md        Phase 4 as a checklist, with the slug rules and the grep commands
    hero-guidance.md               hero choice (screenshot vs designed frame vs diagram), sizes, the terminal-frame design prompt template with a verbatim-text appendix and a "no invented lines" rule
    briefs/
      category-survey.md
      neighbour-survey.md
      pitch-craft.md
      internal-audit.md
      cold-read.md
  scripts/
    check-links.mjs                stdlib Node; relative links and anchors, github-slugger rules
    check-pins.sh                  greps a list of pinned strings in README.md
  evals/
    eval.yaml
    cases/*.yaml                   section 6 below
docs/engineering/readme-pitch.md   four sections: What it does, When to reach for it, Common questions, It's working if
```

Frontmatter for `SKILL.md`:

```yaml
name: readme-pitch
description: Rewrite this repository's README into a first-screen pitch. Hero above the fold, pitch done before the first heading, technical detail moved into docs with links, every test pin and anchor kept.
license: MIT
argument-hint: "[--repos <owner/repo,...>] [--no-research] [--max-agents <n>] [--hero <path>]"
disable-model-invocation: true
metadata:
  version: 0.1.0
```

Repo housekeeping when promoting out of `in-progress/`: entry in the top-level `README.md` under User-invoked, entry in `skills/engineering/README.md`, path in `.claude-plugin/plugin.json` `skills`, docs page created, version bumped in `package.json` and `plugin.json` together. No em-dashes in any prose.

---

## 4. The distilled rules (seed for `references/first-screen-rules.md`)

From three surveys covering about 30 repositories on 2026-09-13. Each rule names the repo that demonstrated it so a maintainer can re-check it.

**Above the fold**

1. The one-sentence "what it is" goes before the badge row. Codex CLI states it on line 1 with no logo; crewAI buries it at line 58 under badges and nav.
2. The hero image goes before the install snippet, because the reader decides whether to install from it. aider: hero line 15, install line 105. OpenHands: 29 and 70. Codex: 3 and 18.
3. The hero shows the product running or the outcome, not the architecture. aider's animated terminal, OpenHands' screenshot, Claude Code's demo GIF at line 11. No repo in the top set leads with a box diagram; AutoGen's concept art sits at line 174 of 241.
4. Set an explicit width on the hero (OpenHands 100%, Codex 80%). Without one it renders at native size.
5. The install or usage command lands inside the first 30 lines (LangGraph 26, Codex 18, openclaw 24). Four of ten excellent-README tools lead with usage rather than install (bun, gum, biome, tauri).
6. One tagline sentence that names the reader's problem; the title itself does semantic work (openclaw's H1 is the tagline).

**Length and order**

7. Pitch under 35 lines before the first H2 (median 36 across the harness set; the 122-line outlier is the worst read).
8. Whole README 60 to 160 lines. The most-starred repo in the harness set is 81 lines. The long ones inline tutorials and FAQs; the short ones ship one command and a link list.
9. No table of contents in a README short enough not to need one; GitHub renders an outline.
10. Requirements go at the install step, not above the pitch (OpenSpec puts "Requires Node 20.19+" directly above `npm install`; spec-kit defers Prerequisites to line 465 of 492).
11. Name competitors explicitly; the comparison happens whether or not you host it (OpenSpec dispatches Spec Kit, Kiro and "nothing" in 7 lines; six of eleven neighbours ship no comparison).
12. Link the philosophy out; the essay converts nobody who has not installed (openclaw reduces it to one link and reaches Install by line 24).

**Badges**

13. One rendered row, 4 or fewer. The most-adopted tools carry the fewest (ripgrep 3, uv 3, gum 3; Cline and Codex 0). Each badge is evidence a reader acts on: version if published, CI, the hardest compatibility constraint, license. Omit stars, downloads, chat, coverage and sponsor badges at a young version.

**Anti-patterns seen**

- Badge and sponsor walls before the title (claude-code-templates: 58 lines and a sponsor's install command before the project's own H1).
- The collapsed value proposition: social proof hidden in `<details>` while a philosophy block takes the first screen (OpenSpec; its real pitch sits at line 188 of 257).
- Dated announcements and long TOCs in permanent prime space (spec-kit's anniversary note plus 20-line TOC between tagline and first useful sentence).

**Pixel budget (GitHub, ~900 px column, 1080p screen, ~660 px of README visible on the README view)**

| Element | px |
|---|---|
| H1 | 60 |
| One-line paragraph | 40 |
| Badge row | 36 |
| Code block | 24 per line + 48 |
| List item | 24 |
| Hero at 900 wide | 900 / aspect ratio |

On the repository home page the README starts below the file list, so with 15 or more root entries nothing in the README is above the fold there; the repository description and topics do that job. Say this in the report.

---

## 5. Things the skill must refuse or flag

- **Refuse** to delete a section whose facts have no docs home yet. Relocate first.
- **Refuse** to edit, weaken or delete a test that asserts on README content. Keep the string.
- **Refuse** to restate a number the repo derives (test counts, subcommand counts, cap values). Link to the command that prints it.
- **Refuse** to claim a competitor fact a brief did not fetch. If research was skipped, the comparison paragraph names competitors only when the user supplied them.
- **Flag** a hero image whose content contradicts the text (the Interlock poster shows the `--strict` sequence as the default ship).
- **Flag** an unpublished package before adding a version badge.
- **Flag** a landing page or site whose copy the new tagline now contradicts.

---

## 6. Evals (skill-up cases, one fixture repo)

Fixture: a small repo with a 300-line README, a `docs/` folder, one test that asserts three README strings, one doc linking to a README anchor, one image asset, and a `package.json` with a test script. Cases grade the reply and the artifacts.

| Case | Prompt | Pass when |
|---|---|---|
| `report-contract` | `/readme-pitch --no-research` | Reply ends with the Phase 8 block; `PINS KEPT: 3/3`; `LINKS: all resolve` |
| `hero-before-code` | same | Output README has an `<img` or `![` before the first code fence, and `HERO: line <n>` is under 15 |
| `pitch-by-line-30` | same | `PITCH COMPLETE BY:` is 30 or lower; first `## ` heading at or before line 30 |
| `pins-kept` | same | All three pinned strings present in the new README; the fixture test passes when run |
| `anchor-repointed` | same | The doc that linked into the moved README section now links to a file and heading that exist |
| `no-fact-lost` | same | Each of five sentinel facts planted only in the old README appears in some file under `docs/` or `CONTRIBUTING.md` |
| `research-skipped-is-spoken` | `/readme-pitch` on a host with no web tool | `RESEARCH:` line names A, B, C as skipped with a reason |
| `refuse-no-readme` | `/readme-pitch` in a repo with no README | Reply says it needs a README and makes no edits |

All rule-based judges; no LLM judge until a calibration set exists.

---

## 7. Open questions before writing `SKILL.md`

1. **Overwrite policy.** Show the draft and wait (the Interlock run did not wait because the user had asked for the rewrite outright). Default proposed: show the draft as a diff summary, then overwrite on the same turn unless the user said "draft only". Confirm.
2. **Where the briefs' reports go.** Chat only, or also `<handoff-dir>/readme-pitch-research-<brief>-<timestamp>.md` so a later session can reuse them. Proposed: write them; they are the audit trail for every competitor claim in the README.
3. **Hero production.** In scope is choosing and placing a hero. Out of scope is producing one. The skill writes the design prompt file (from `hero-guidance.md`) and lists it under `OUTSIDE THIS CHANGE`. Confirm that the image itself stays a human step.
4. **Model policy for subagents.** The Interlock run used a user-stated cap (five, Opus). The skill should not hard-code a vendor's model names; it reads the policy from the user's message or the project instructions file and otherwise uses the host default. Confirm.
5. **Bucket.** `engineering/` on promotion, since it is code-repo work, even though the output is prose.

---

## 8. Revisions (2026-09-14)

Where this section disagrees with sections 1 to 7, this section wins.
`SKILL.md` is the source of truth; this is the reasoning behind the changes.

**Decisions side.** Sections 1 to 7 collect facts well (inventory, brief D)
and make every product decision silently: who the reader is, which of brief
C's six taglines wins, whether to name rivals. `{{CATEGORY}}` and
`{{SEED_REPOS}}` had no producer. Phase 1b now collects five decisions
(reader, archetype, claim, register, comparison) with a recommendation
derived from the inventory. Three modes: `--ask` runs one answer-by-number
round and waits; `--brief <path>` reads a file; the default assumes and
reports. The principle is borrowed from a grill-style interview (facts are
looked up, decisions are asked); the loop is not. One round, five questions,
because the tree is shallow and the skill's value is an unattended run.

**Archetype.** The skeleton assumed a CLI in sections 2, 5, 8, and 13 and in
the command inventory. Phase 1 now detects an archetype from `bin`,
`exports`, `action.yml`, `Dockerfile`, `[project.scripts]` and similar, and
the skeleton carries a swap table. The brief can override which face leads.

**Run-blockers.** Phase 0 asked whether to continue on a README that already
met the bar; nobody answers in an eval or an autonomous run, so it now stops
and names `--force`. Phase 2 read as "edit the brief files", which would
mutate the installed skill; it now substitutes in memory.

**Ordering.** The diff summary moves from Phase 5 to after the cold read in
Phase 6, so the human sees the file that lands.

**Flags.** `draft only` becomes `--draft-only`. The report gains a
`DECISIONS:` line. Human stops are now: the `--ask` round (opt-in), and the
summary (visible, non-blocking) unless `--draft-only`.

**Evals.** `decisions-assumed` (default mode reports `assumed`, writes the
brief file, detects `cli`) and `already-pitched-stops` (Phase 0 stop, no
edits, names `--force`). The sentinel grader accepts any root markdown file
other than README.md, matching the checklist's CHANGELOG destination.

**Still open before promotion.** Evals have not been run against a real
model. A second fixture that is a `library`, not a `cli`, is the next test:
it exercises the archetype swap the CLI fixture cannot.
