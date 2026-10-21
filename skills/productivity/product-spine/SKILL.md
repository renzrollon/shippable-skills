---
name: product-spine
description: >-
  Help an engineer act as product owner: suggest parallel work threads
  (features, improvements, fixes) from the repo, then draft, review, and
  capability-check the one-pager, epics, and briefs that land them. Writes
  artefacts, never code. Answers "can the platform do X?" from the project's
  own primer.
license: MIT
argument-hint: "threads | draft <one-pager|epic|brief> | review <file> | capability \"<question>\""
disable-model-invocation: true
metadata:
  version: 0.3.0
---

**Bare invocation runs threads, this turn, with no question.** If the
invocation has no arguments (bare `/product-spine`) or the only argument is
`threads`, you are already in threads mode: do **not** ask "which mode?", do
**not** print a mode menu, do **not** wait for confirmation. Go straight to
Step 2, gather, and output the mermaid `## Thread map` with cards before you
stop. Only an explicit `draft`, `review`, or `capability` argument (or its
natural-language equivalent) selects another mode. A bare invocation is never a
prompt to disambiguate.

Help an **engineer act as product owner**. Default is **threads**: look at
the repo, fan out read-only gathers, and propose several next pieces of work
(features, improvements, fixes) on a mermaid map. Picking a thread **lands**
it on the product spine: a live **one-pager** (strategy), **epics** (features
in flight, each named against a strategy bet), and **briefs** (what / why
for a change proposal). Three paths:

- `docs/product/one-pager/current.md`
- `docs/product/epics/*.md` (sibling folder `docs/product/epics/<slug>/`)
- `docs/product/briefs/*.md`

```
one-pager   docs/product/one-pager/current.md
            §3 strategy bets · §4 roadmap initiatives
                ^
                |  Ladders to: ... §4 <initiative heading>
epics       docs/product/epics/*.md
            features in flight, each named against a bet
                ^
                |  Part of: <epic path>
                |  or Ladders to: the one-pager initiative (no epic yet)
briefs      docs/product/briefs/*.md
            what / why / ladder / primer for a change proposal
```

Cite the **heading text** on ladder lines, not only a section number, so a
project template with other numbering still greps. This skill is
**host-neutral**: it runs on Cursor, Copilot, Codex, Claude Code, and any
other Agent Skills host. It does not name a vendor agent, a platform product,
or a host slash for executing work. Call the Task tool for fan-out (or the
host's equivalent subagent tool). Do not Call the Skill tool with another
user-invoked skill.

Threads are **chat-only** until the user picks one. Draft writes a file plus
a short chat reply. Never re-dump the file into chat.

Templates, Status, threads fan-out, and draft question ladders live in
[references/](references/threads-mode.md). Org-specific platform vocabulary
lives in `docs/product/context/` if the project supplied it; this skill
never invents it. See [references/context-folder.md](references/context-folder.md).

---

## Firm rules (non-negotiable)

1. **Never writes code** and never edits outside `docs/product/**`. Never
   write `openspec/changes/**`. A request to implement gets a one-line
   refusal pointing at the brief (or epic): this skill's job is the artefact,
   not the implementation. If the turn asks to implement (in `src/`, a
   patch, a function, "then build it"), refuse and stop. Do not
   draft-and-then-code in the same turn. Threads mode writes **no** files.
2. **Never invents** metrics, baselines, capabilities, or platform vocabulary.
   Absent input is stated as absent (`baseline: unknown`, `primer absent`,
   `thin`), never filled in.
3. **Decisions live inline** (brief §4, epic §5, one-pager §1 change log). No
   separate decisions log, no ADR, no threads file on disk.
4. **New briefs and epics are always saved `Status: draft`.** This skill never
   flips a file to `ready` or `ready-to-propose`. Review reports whether the
   user could.
5. **One question per turn** in draft mode, capped per artefact. Inline
   context counts as answered (including a picked threads card), never
   re-asked. Empty-handed is fine: start the ladder. When the remaining
   fields have a legal TBD / unknown form and the required ones are present,
   write the file this turn instead of blocking.
6. **Never block on I/O.** Every read, list, and write in this skill is
   best-effort. If a call is denied, errors, or the file is absent, treat it as
   unavailable and proceed immediately from what you already hold. Do not retry
   a denied or failed call, and do not guess alternate paths for it.
7. **Lo-fi first.** Never generate a hi-fi mockup. Point at the epic's sibling
   folder (`docs/product/epics/<slug>/mockups/`) for a lo-fi mockup. Do not
   create mockup files.
8. **Threads cite evidence** (paths on disk) or mark `Confidence: thin`.
   Fan-out subagents are read-only. The visual is a mermaid diagram in chat,
   not a vendor canvas.

---

## Output contract (non-negotiable)

Downstream greps these strings. Keep the parsed tokens exact.

**Threads reply** (no file write) always includes:

- a fenced mermaid diagram (language tag `mermaid`)
- `## Thread map` and `## Threads`
- at least one of `Feature`, `Improvement`, `Fix` as a kind label
- numbered cards starting at `1.`
- a closer telling the user to pick a number to draft, or name `review` /
  `capability`

Never write `Status: ready` or `ready-to-propose` in this mode.

**Draft file** (brief or epic) always contains `Status: draft` and exactly one
of `Part of:` / `Ladders to:`. Never write `Status: ready` or
`ready-to-propose`. A brief also has `Suggested change:` (kebab-case).

**Draft chat reply** (do not paste the file body) always includes:

- the path written
- the line `Status: draft`
- the `Part of:` or `Ladders to:` line copied verbatim
- exactly one open item
- for a brief: tell the user to pass this path to their change-proposal
  skill (do not Call that skill)

**Review reply** is the block only:

```
## Review: <path>

**Strong**
**Missing**
**Ladder**
**Platform pieces**
<ready line>
**Next step**
```

Ready line is exactly one of:

- brief: `**Ready to propose: yes**` or `**Ready to propose: no** (<reason>)`
- epic: `**Ready to flip: yes**` or `**Ready to flip: no** (<reason>)`

Omit it for a one-pager. **Next step** is exactly one item. Put the yes/no
inside the bold label so the greps `Ready to propose: no` and
`Ready to flip: no` match.

**Capability reply** is the block only:

```
**Answer**: Yes today | No today | Partly | Cannot confirm
**From the primer**
**Nearest alternative that works today**
**Gap to record**
```

`Gap to record` is a proposed one-line entry for `capability-gaps.md`. Do not
write that file unless asked. With **no primer on disk**, Answer is
`Cannot confirm`, name the missing path
`docs/product/context/platform-primer.md`, and assert nothing else (no
`Yes today`, no invented alternative). Offer the skeleton in
[references/context-folder.md](references/context-folder.md).

---

## Input

| Arg / mode | Meaning |
|------------|---------|
| _(none)_ or `threads` | Engineer-as-PO: fan out, mermaid map, numbered threads. No file write. |
| `draft one-pager` / `draft epic` / `draft brief` | Write that artefact. `draft task` maps to `draft brief`. |
| `draft N` / `land N` | Draft the Nth card from this conversation's threads reply. |
| `review <file>` | Read-only checklist on that path. |
| `capability "<question>"` | Can the platform do this today, from the primer only. |

Natural language maps to the same modes: "what should we build next" /
"suggest features" (`threads`), "draft an epic for X" (`draft epic`),
"draft a brief for Y" / "draft a task for Y" (`draft brief`), "review
`docs/product/briefs/foo.md`" (`review`), "can users retry a payment?"
(`capability`). These phrasings **are** invocations of this skill, not
free-form PM chat.

---

## Steps

### 0. Mode and code gate (before any write)

Parse the mode from the args or the natural-language map. If the turn asks for
implementation (code, a patch, `src/`, "then implement", "build it"), **make
no code edits**. Reply in one line that this skill writes the artefact, not
code, point at the brief path if one exists, and stop. Skip later steps.

- `draft` / `review` / `capability` when those words (or their map) are
  present, including `draft N` after a threads reply.
- **Otherwise** (no args, bare `/product-spine`, `threads`, "what's next",
  "suggest features"): run **threads** now, this turn. Never reply with a mode
  menu or a "which mode?" question: bare invocation **is** threads, not a
  prompt to disambiguate. Gather (fan-out, or sequential if the host has no
  subagent tool), then emit the mermaid `## Thread map` and cards. Empty-handed
  still emits a map, marked `thin`. Do **not** list modes and stop.

### 1. Gather

**Threads:** skip a parent-only crawl. Follow
[references/threads-mode.md](references/threads-mode.md): Call the Task tool
2 to 4 times in one turn (Spine, Surfaces, Friction). If the host has no
subagent tool, run those briefs sequentially this turn.

**Draft / review / capability:** best-effort, **one plain command per call**,
literal paths: no `$HOME` / `~` expansion, no `for` loops, no `;`-chaining.
Skip any call that is denied, errors, or is absent, the first time. State
which inputs are absent.

Read or list, each once:

- `docs/product/one-pager/current.md` (and `docs/product/one-pager/TEMPLATE.md`
  if present: then use **that** file's headings and numbering)
- list `docs/product/epics/*.md`
- list `docs/product/briefs/*.md`
- directory names under `openspec/changes/` (absence is fine; do not write)
- `docs/product/context/platform-primer.md`
- `docs/product/context/capability-gaps.md`
- list `docs/product/context/golden-path/*.md`
- this skill's `references/*.md` (resolve relative to **this skill
  directory**)

Do not invent a fourth context path. Golden Path docs are optional; if the
folder is missing, say so and continue.

### 2. Threads mode

Read [references/threads-mode.md](references/threads-mode.md) and follow it.
Synthesize 4 to 8 cards mixing Feature / Improvement / Fix (fewer if evidence
is thin, at least two). Each card: kind, title, need, evidence paths,
artefact (`brief` or `epic`), ladder, `grounded` or `thin`.

Emit the Thread map mermaid (subgraphs `now`, `next`, `later`) then the
cards, then the pick-to-draft closer. Write nothing to disk.

### 3. Draft mode

Read [references/draft-mode.md](references/draft-mode.md) for question
ladders, write paths, and "write this turn" rules. Always `Status: draft`.
Exactly one of `Part of:` / `Ladders to:`. A picked threads card counts as
inline context.

### 4. Review mode (read-only, never edits)

Read the named file once. Run the matching checklist. Emit the Review block.
Do not edit the file, and do not flip `Status`.

**Brief**

- Status line present.
- Exactly one ladder line, and its target exists on disk (epic file, or a
  §4 heading in `current.md` whose text matches).
- `Suggested change:` is kebab-case.
- §1 names who, friction, outcome.
- §2 uses primer vocabulary and invents nothing (flag invented platform
  words; if primer absent, §2 must say so).
- §3 names In and Out (not only TBD) for ready-to-propose.
- §4 records a trade-off or says none.
- No implementation step list and no acceptance checkboxes (wrong artefact:
  a **Missing** item).
- Optional `Change:`: if present, the matching `openspec/changes/<slug>/`
  folder may exist (claimed but absent is **Missing**, not a write).

**Epic**

- Ladder to a real §4 heading in `current.md`.
- Three-line problem.
- Out of scope named.
- §4 brief list versus `docs/product/briefs/*.md` that claim `Part of:` this
  epic.
- Sibling folder `docs/product/epics/<slug>/` present (missing is a
  **Missing** item, not a write).

**One-pager**

- Sections present (or the project's TEMPLATE headings).
- §2.3 metrics carry a baseline or `unknown`.
- Every §4 initiative maps to a §3 bet.
- §1 has dated entries.
- Orphaned epics: an epic `Ladders to:` a heading that no longer exists.

Ready-to-propose (brief): `yes` only if the checklist is clean enough that
the **user** could set `Status: ready-to-propose`. Ready-to-flip (epic):
`yes` only if the user could set `Status: ready`. Otherwise
`**Ready to propose: no**` or `**Ready to flip: no**` with a reason. Next
step: exactly one action the user can take.

### 5. Capability mode

Read `platform-primer.md` and `capability-gaps.md` once each (golden-path
files if present: extra colour, not a second source of "can we"). Classify
the question:

- **Yes today**: the primer describes it as available.
- **No today**: the primer does not, or it names the gap.
- **Partly**: the primer covers some of the asked behaviour.
- **Cannot confirm**: no primer on disk.

Cite the primer section under **From the primer**. When `No today`, give the
**Nearest alternative that works today** from the primer, or from
`capability-gaps.md` if the primer is silent on an alternative. Propose a
**Gap to record** one-liner if the question exposes an unrecorded gap. Do not
write `capability-gaps.md` unless asked.

If no primer: `**Answer**: Cannot confirm`, name
`docs/product/context/platform-primer.md`, offer the skeleton, stop asserting.

### 6. Chat reply

- **Threads**: Thread map, mermaid, numbered cards, pick-to-draft closer. No
  file dump.
- **Draft**: path written, `Status: draft`, the ladder line, one open item
  (briefs: also the change-proposal closer). Never re-dump the file.
- **Review**: the Review block only.
- **Capability**: the capability block only.
- **Refusal** (code gate): one line, contains `artefact` and that this is
  not code. No code fence, no `export function`, no implementation patch.

---

## Rules

- Artefacts only, never code, never outside `docs/product/**`, never
  `openspec/changes/**`.
- Threads write no files; they cite evidence or `thin`.
- Never invent metrics, capabilities, or platform vocabulary.
- Decisions inline; no decisions folder; no threads folder.
- New work is `Status: draft`; the user flips to `ready-to-propose` (brief)
  or `ready` (epic).
- One draft question per turn; inline context counts; empty-handed is fine.
- Never block on I/O: unavailable, once, no retry, no alternate-path guessing.
- Lo-fi pointer only; do not generate mockups.
- Visual is mermaid in chat, not a vendor canvas.
- Host-neutral: Task tool for fan-out, no host-only execute slashes.

---

## Related

- Threads (fan-out, mermaid, cards): [references/threads-mode.md](references/threads-mode.md)
- Draft question ladders: [references/draft-mode.md](references/draft-mode.md)
- One-pager template: [references/one-pager-template.md](references/one-pager-template.md)
- Epic template: [references/epic-template.md](references/epic-template.md)
- Brief template: [references/brief-template.md](references/brief-template.md)
- Ladder and Status: [references/ladder-and-status.md](references/ladder-and-status.md)
- Context folder: [references/context-folder.md](references/context-folder.md)
