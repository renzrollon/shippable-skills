# Explore brief

A durable record of an exploration, written so the next step can reload discovery after a context reset without re-deriving it from chat.

## Where and when

Path: `<handoff-dir>/explore-<slug>-<YYYYMMDD-HHMMSS>.md`. The handoff directory is a path the user passed (`--handoff-dir`) or named in the request, else a `shippable-handoff-dir: <path>` line in the instruction file (ignored when absolute or containing `..`), else the first existing of `.claude/handoff/`, `.agents/handoff/`, `docs/handoff/`, else create `.agents/handoff/` and advise a gitignore line. Slug is the topic in kebab-case.

Required in autonomous mode. Optional in conversational mode when the user asks to save the exploration. Attempt the create and the write once; on denial or error do not retry or guess another location, print the brief in the reply.

Keep it to roughly 2 to 6k tokens. Decision-oriented, cited, pointers over pasted code.

## Template

The headings are stable. Consumers depend on them.

```markdown
# Explore Brief: <slug>

## Meta
- mode: autonomous | conversational-capture
- investigation: fan-out | sequential | single
- topic: <one-line topic>
- created: <ISO-8601 timestamp>
- suggested_change_name: <kebab-case or none>
- related_plan: <existing plan, issue, or spec path, or none>

## Problem / Intent
<Crystallized problem statement and desired outcome.>

## Codebase Findings
<Decision-relevant conclusions about how it works today. Cite path:line spans. Do not inventory every file touched.>

## Critical Files
<path:line, why it matters. Citations over pasted code.>

## Options Considered
<Each option: tradeoffs and evidence. Mark recommended or rejected, with the reason.>

## Recommended Direction
<Chosen approach and why.>

## Assumptions Made
<Defaults taken where intent was ambiguous.>

## Pending Clarifications
<Only product or policy unknowns the repo cannot resolve. Autonomous mode lists them and never asks mid-run.>

## Risks / Gaps
<What could go wrong, layers not swept, contradictions between investigators.>
```

The `investigation:` line says how the work was done. `fan-out` means investigators ran in parallel, `sequential` means the host had no subagent tool and the same scopes ran one after another, `single` means the question stayed single-threaded. The chat reply repeats the same line.

## Decision table (optional)

Add when ambiguities were resolved or left open. One row per ambiguity.

| id | question | class | resolution | evidence |
|----|----------|-------|------------|----------|
| D1 | ... | agent_resolved | what was chosen | path:line or source a reader can follow |
| D2 | ... | needs_human | pending | pending |

Classes:

- `agent_resolved`: the repo or a stated source answers it. The evidence cell must be followable. "Obvious" is not evidence.
- `needs_human`: only a person can decide. Every Pending Clarifications item becomes one of these.

Number rows `D1`, `D2`, and so on. Never renumber and never reuse an id.

## Section rules

| Section | Rule |
|---------|------|
| Codebase Findings | Conclusions and cited spans only. No exhaustive file lists, no raw investigator output. |
| Critical Files | Path, line, why. No code dumps. |
| Options Considered | Tradeoffs plus evidence. State why the rejected ones lost. |
| Assumptions Made | Prefer a reasonable default over blocking. Record it here. |
| Pending Clarifications | Repo-unresolvable only. "I did not look" does not belong here. |

## Chat reply after writing

Do not re-dump the brief. Reply with the brief path, the same `investigation:` line, and a three to five line summary (intent, recommended direction, top risk).

## Consume rule

A skill that reads an explore brief restates these four lines:

1. Reads the newest `explore-*.md` across every handoff directory it scans, or the path the user names.
2. Picks the newest file whose Meta topic overlaps the request; ignores the others.
3. Takes the Recommended Direction, Assumptions Made, and `agent_resolved` rows as settled.
4. Re-checks only Pending Clarifications, Risks / Gaps, and any cited span that no longer exists.
