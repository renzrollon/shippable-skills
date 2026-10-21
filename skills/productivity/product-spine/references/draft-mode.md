# Draft mode

Write the house-format artefact. Always `Status: draft`. Never `Status:
ready`. Never `Status: ready-to-propose`. Never set `Priority`.

Ask at most **one** unanswered question per turn. Skip anything already
answered inline: the invocation text, a pasted blob, a path the user named,
or a **threads card** they picked ("draft 3"). Empty-handed is fine: start
the ladder. When remaining fields have a legal TBD / unknown form and the
required ones are present, write the file this turn instead of blocking.

Templates: [brief-template.md](brief-template.md),
[epic-template.md](epic-template.md),
[one-pager-template.md](one-pager-template.md). Ladder lines:
[ladder-and-status.md](ladder-and-status.md).

Natural language `draft task` / "draft a task for Y" maps to **draft brief**.

## Brief (max 4 questions)

1. User need: who, friction, outcome.
2. Which epic, or which one-pager initiative. Offer the list read from disk as
   numbered options. "none" → suggest `draft epic`, or write
   `Ladders to: (one-pager not yet written)` if `current.md` is absent.
3. Platform pieces: offer primer vocabulary if the primer was present; plain
   words or `primer absent` if not. Invent nothing.
4. Product constraints: In, Out, and Do not invent. `TBD` allowed in draft.

If user need and ladder target are already inline, **write the file this
turn with zero questions.** Fill §2 with primer nouns or `primer absent`,
§3 with named constraints or `TBD`, and §4 with `none` unless a trade-off
was stated. Derive `Suggested change:` as kebab-case from the title.

Ask for reasons (brief §4) only if a trade-off surfaced.

Write `docs/product/briefs/YYYY-MM-DD-<slug>.md`. Exactly one ladder line:
`Part of: <epic path>` when it serves an epic, otherwise `Ladders to:
docs/product/one-pager/current.md §4 <initiative heading>`. Do not write
`openspec/changes/**`.

From a threads card: use its Need, Evidence, and Ladder. Artefact `brief`
(or mapped `task`) on the card means write a brief. TBD constraints are
enough to write when the user picked the card and did not supply In / Out.

Draft chat reply for a brief: path, `Status: draft`, the ladder line, one
open item, and tell the user to pass this path to their change-proposal
skill. Do not Call that skill.

## Epic (max 5 questions)

1. User problem in three lines.
2. Which one-pager §4 initiative (offer headings from `current.md`).
3. Platform pieces (primer vocabulary or `primer absent`).
4. Out of scope.
5. What discovery exists or is planned (becomes file **names** in the sibling
   folder, not files you create).

Write `docs/product/epics/YYYY-MM-DD-<slug>.md`. Always `Status: draft`.
Ladder with `Ladders to: docs/product/one-pager/current.md §4 <initiative
heading>`. Name the sibling folder `docs/product/epics/<slug>/` in the reply.
Do not create that folder's mockups, interviews, or other discovery files.

From a threads card marked `epic`: the Need line is the three-line problem;
Ladder is the initiative; out of scope may be `TBD` in draft.

## One-pager (max 6 questions, only when none exists)

When `current.md` is absent, gather then write from
[one-pager-template.md](one-pager-template.md) (or the project
`TEMPLATE.md`):

1. Who and what job (§2.1)
2. Problem in the users' terms (§2.2)
3. Metrics, baseline `unknown` if unknown (§2.3)
4. Strategy bets (§3)
5. Roadmap initiatives, each mapped to a bet (§4)
6. Risks and open questions (§5)

§1 gets the first dated change-log line. §6 starts empty.

If `current.md` **exists**: one question only ("refresh it, snapshot first, or
start over?"). Snapshot to `docs/product/one-pager/YYYY-MM-DD-current.md`,
edit `current.md`, append a §1 line. Do not skip the snapshot when they chose
refresh or start over.

A threads run that found no one-pager may offer `draft one-pager` in the
closing line. It does not write `current.md` until the user asks.
