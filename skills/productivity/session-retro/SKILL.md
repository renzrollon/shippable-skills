---
name: session-retro
description: Retro the current session. Score it against session shapes, flag token waste with next-turn fixes, and propose wire-ins into the skills this conversation actually called.
license: MIT
argument-hint: "[--since <marker>] [--focus tokens|wiring]"
disable-model-invocation: true
---

Retro the **current session**: the conversation you are in right now. Score it
against the session-shapes taxonomy, surface where **this session** spent tokens
badly with fixes actionable on the *next* turn, and turn the repeatable
procedures it just performed into concrete **wire-ins** for the skills and
workflows it actually called (or new skill candidates when nothing existing
fits).

The thing that makes this cheap and honest: **the transcript is already your
own context.** There is no gather step, no log to parse, so the analysis is
grounded in what actually happened, not inferred from a tool-call histogram.

Two rules follow from that:

- **Do not re-read the on-disk transcript** (`~/.claude/projects/**/*.jsonl`,
  Cursor/Copilot/Codex session logs, and the like). You already hold it.
  Re-reading it is the exact waste this skill exists to flag.
- Score from what actually happened in this conversation. Never invent tool
  calls, quotes, or token numbers. You do not have exact per-turn token counts;
  reason in **relative magnitude** ("that Read returned ~2k lines", "the grep
  dumped a full histogram") and cite the concrete moment.

This skill is **host-neutral**. It runs on Cursor, Copilot, Codex, Claude Code,
and any other Agent Skills host. Follow [references/skill-candidate-brief.md](references/skill-candidate-brief.md)
for new-skill briefs. Do **not** write `SKILL.md` files yourself: only handoffs.

---

## Input

| Arg / flag | Meaning |
|------------|---------|
| _(none)_ | Retro this whole conversation |
| `--since <marker>` | Only the portion after a natural marker (e.g. "since the first edit", "since compact") |
| `--focus tokens` / `--focus wiring` | Emit only the Token Utilization or the Wiring section |

Natural language works: "retro this session", "how did this session use tokens",
"what should we wire into the skills we called".

---

## Steps

### 1. Gather the cheap context (no transcript re-read)

Batch these read-only lookups in one turn (skip any that are absent). Resolve
paths relative to **this skill directory** (the folder that contains this
`SKILL.md`):

- Read `references/session-shapes.md` for shape names + the 1-10 score key.
- Read `references/tool-economy.md`: cite its rules by name in Token Utilization.
- Read `references/skill-candidate-brief.md` (brief contract for new skills).
- List existing skills so wire-ins target real files:

  ```bash
  # Project-level (skills.sh / plugin / repo catalog)
  for d in skills .agents/skills .claude/skills .cursor/skills .github/skills; do
    [ -d "$d" ] || continue
    find "$d" -maxdepth 4 -name SKILL.md 2>/dev/null
  done
  # User-level
  for d in ~/.claude/skills ~/.cursor/skills ~/.codex/skills ~/.copilot/skills ~/.agents/skills ~/.config/agents/skills; do
    [ -d "$d" ] || continue
    ls "$d"
  done
  ```

  Also note workflow scripts and existing handoff dirs if the session touched them.

If none of the reference files exist (the skill was copied without
`references/`), proceed from the six-shape names and the brief headings you
already have in this file. Do not block.

### 2. Reconstruct THIS session from context (introspection, not a file read)

From the conversation you already hold, note:

- **Shape**: best-fit from `session-shapes.md`, plus a 1-10 score (same key).
- **Tool pattern**: rough tally of Read / Edit·Write / Bash / Grep·Glob /
  Agent / Skill / Workflow calls you made. Host aliases (treat as the
  canonical name when tallying):

  | Host | Aliases |
  |------|---------|
  | Cursor | `read_file_v2` ≈ Read; `edit_file_v2` / `write` ≈ Edit/Write; `run_terminal_command_v2` / `Shell` ≈ Bash; `ripgrep_raw_search` / `Grep` / `glob_file_search` / `Glob` ≈ Grep/Glob; `Task` ≈ Agent |
  | Copilot | file-read ≈ Read; file-edit ≈ Edit; terminal/bash ≈ Bash; grep/search ≈ Grep |
  | Codex | `Read` / file open ≈ Read; `apply_patch` ≈ Edit; `shell` ≈ Bash |
  | Claude Code | Read, Edit, Write, Bash, Grep, Glob, Agent, Skill, Workflow as named |

- **Called artifacts**: every skill, prompt, and workflow invoked this
  session, in order. This list drives the Wiring section. Use the name the
  host showed (`session-retro`, `tdd`, `code-review`), not a guessed vendor prefix.
- **Waste moments**: large full-file reads, re-derivation of state already
  reported, un-batched sequential Bash, redundant greps, backtracking after a
  wrong shape. Anchor each to where it happened.

### 3. Analyze: output this structure in chat (concise)

#### Session Snapshot

| Shape | Score | Rough tool mix | Verdict |
|-------|-------|----------------|---------|
| Targeted Fix | 7/10 | 12 Read · 3 Edit · 5 Bash | Right shape, front-loaded exploration |

#### Token Utilization  *(headline: lead with this)*

Concrete moments in **this** session where tokens were spent badly. For each:

- **Moment**: what happened + where (`the three sequential greps before the first edit`).
- **Rule**: the `tool-economy.md` rule it broke (Query-the-graph-first,
  Budgeted-docs, Locate-before-Read, Batch-your-Bash,
  Read-state-don't-re-derive).
- **Next-turn fix**: the specific different action.
- **Magnitude**: relative (`~2k-line read → ~200 with offset+limit`), never a
  fabricated token count.

If the session was already lean, say so and name the one thing that kept it lean.

#### What Could Have Been Done Better

Only if the score is below 8/10: one shape/execution improvement. What this
session did, the correct shape step or skill instead, and why it matters.

#### Skill / Workflow Wiring  *(second focus)*

**A. Wire-ins into artifacts this session called.** For each skill / workflow
invoked, whether a repeatable step you performed *around* it should be folded
in so next time it is automatic:

| Called artifact | Observed gap this session | Proposed wire-in | Where |
|-----------------|---------------------------|------------------|-------|
| tdd | Re-ran the full suite after each one-line edit | Run only the failing test until green, then the suite | the tdd skill's SKILL.md |

If a called artifact needed nothing, omit it. If nothing was called: `No skills / workflows invoked this session.`

**B. New skill candidates.** Only for a repeatable procedure this session
performed that **no** existing skill covers. Prefer a wire-in (extend) over a
new skill. Cap at top 3.

| Slug | Confidence | Why | Existing overlap |
|------|------------|-----|------------------|

If none: `No new skill candidates from this session.`

### 4. Write handoffs

```bash
if [ -d .claude/handoff ]; then
  HAND=".claude/handoff"
else
  mkdir -p .agents/handoff
  HAND=".agents/handoff"
fi
date +%Y%m%d-%H%M%S
```

Prefer `.claude/handoff` when that directory already exists. Otherwise write
`.agents/handoff`. Create the directory if needed.

- **Wire-in** → `$HAND/wire-in-<target>-<YYYYMMDD-HHMMSS>.md`, using the
  Wire-in note format below. `<target>` = the called skill/workflow slug.
- **New skill** → `$HAND/skill-candidate-<slug>-<YYYYMMDD-HHMMSS>.md` per
  `references/skill-candidate-brief.md`, `source: interactive`,
  `evidence_basis: current-session (live context, no transcript)`. Fill every
  section. No `<placeholder>` leftovers.

**Wire-in note format** (this skill's own contract: keep it short, ~0.5-1k tokens):

```markdown
# Wire-in: <target skill / workflow>

## Target
- file: <path to the file that actually runs>
- source: current-session (interactive)
- created: <ISO-8601>

## Session evidence
<!-- What you did around the target this session that should have been part of it.
     Live context only: cite the moment, no invented quotes. -->

## Proposed wire-in
<!-- The concrete step / guardrail / token-economy rule to add, and WHERE in the file. -->

## Payoff
<!-- Token or quality win next time, in relative terms. -->

## Risk / blast radius
<!-- Who else calls this artifact; what could regress. If the called skill is a
     trampoline that launches a workflow script, name the script, not the trampoline
     SKILL.md: editing the trampoline ships nothing. For a plain skill, SKILL.md
     prose IS what runs. -->
```

A wire-in must name a **real** target file from step 1's list, not a guess,
and the file that actually runs.

### 5. Chat reply

Do **not** re-dump full handoffs. Reply with:

1. Snapshot line (shape + score) and the single biggest token win.
2. Paths to each `wire-in-*.md` / `skill-candidate-*.md` written (or the two
   "none" lines).
3. One line per recommendation: target/slug + the change + confidence.
4. "Hand wire-ins to whoever owns that skill; hand new-skill briefs to a
   skill-author agent."

---

## Rules

- Current session only. This skill sees this conversation and nothing else.
- Never re-read the on-disk transcript: you already have the context.
- No fabricated token counts, tool calls, or quotes. Relative magnitude only.
- Prefer a wire-in that extends a called skill over inventing a parallel one.
- A wire-in must name a real target file from step 1's list, not a guess, and
  the file that actually runs (workflow script vs skill prose).
- Be concise; every line earns its place.

---

## Related

- Shapes + score key: [references/session-shapes.md](references/session-shapes.md)
- Token discipline (cite by rule name): [references/tool-economy.md](references/tool-economy.md)
- New-skill brief contract: [references/skill-candidate-brief.md](references/skill-candidate-brief.md)
