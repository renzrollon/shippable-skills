# product-spine

Share this skill as the folder that holds its human README: [`skills/productivity/product-spine/`](../../skills/productivity/product-spine/).

## What it does

`product-spine` helps an **engineer act as product owner**. Bare invocation
fans out over the repo and proposes several **threads** (new features,
improvements, fixes) on a mermaid map. Picking a thread lands it on the
repo-native spine: a live one-pager, epics, and briefs that ladder to each
other. It also reviews whether a brief could be flipped to `ready-to-propose`
(or an epic to `ready`), and answers "can the platform do X today" from the
project's own primer.

It writes artefacts. It never writes code. Threads write nothing until you
pick one. A request to implement is a one-line refusal pointing at the brief.

## When to reach for it

You invoke this by typing `/product-spine`; the agent will not reach for it
on its own. With no args it runs **threads**. Pass `draft`, `review <file>`,
or `capability "<question>"` when you already know the mode.

| Situation | Why this skill |
| --- | --- |
| You need to function as PO and do not know what is next | bare `/product-spine`: mermaid map plus numbered Feature / Improvement / Fix cards |
| A slice of work has no file yet | `draft brief` (or `draft epic`) in the house format, `Status: draft`; or pick a thread number. `draft task` maps to `draft brief`. |
| You are about to hand a brief to the change-proposal skill | `review` reports whether **you** could flip it to `ready-to-propose` |
| "Can users do X today?" | `capability` cites the primer, or says `Cannot confirm` if there is none |
| Strategy is still in chat | `draft one-pager` so bets and initiatives become greppable headings |
| Someone asked for a PRD or a stack of user stories | This skill is the replacement: the brief's four sections are the unit |

Skip it when you want a framework lesson (how to write a Cohn story, how to
score RICE). Skip it when the ask is to implement the brief: that is a
different skill, against a `ready-to-propose` file.

## The mechanism

Default gather is a **read-only fan-out** (spine files, user-facing surfaces,
friction) via the host Task / subagent tool, or the same briefs sequentially
if that tool is missing. The parent synthesizes threads. Nothing is written
until you say `draft N`.

Three paths, a ladder between them, two greps that have to work:

```
docs/product/one-pager/current.md     §3 bets · §4 initiatives
        ^
        |  Ladders to: ... §4 <heading text>
docs/product/epics/<file>.md          feature in flight
        ^
        |  Part of: <epic>
docs/product/briefs/<date>-<slug>.md  what / why for a change proposal
```

- **Every brief serving a bet:** `grep -R -n 'Ladders to:.*<initiative heading>' docs/product/epics docs/product/briefs`
- **Every brief affected if a bet is killed:** `grep -R -n "Part of: \|Ladders to:" docs/product/epics docs/product/briefs`, then filter to that heading and its epics.

Cite heading text, not only a section number, so a project that drops its own
`docs/product/one-pager/TEMPLATE.md` still greps. Org vocabulary is not in
the skill: it is in `docs/product/context/platform-primer.md`,
`capability-gaps.md`, and optional `golden-path/*.md`, read if present and
never invented when absent.

A brief is input to the project's change-proposal skill (`Suggested change:`
is kebab-case glue for `openspec/changes/<slug>/`). This skill never writes
that folder.

## What it produces

Depends on the mode:

1. **Threads** (default): a mermaid Now / Next / Later map and numbered cards
   (kind, need, evidence paths, suggested artefact, ladder, `grounded` or
   `thin`). Chat only. No `docs/product/threads/` file.
2. **Draft**: a file at the fixed path (`docs/product/briefs/YYYY-MM-DD-<slug>.md`,
   `docs/product/epics/YYYY-MM-DD-<slug>.md`, or
   `docs/product/one-pager/current.md`), always `Status: draft` for briefs and
   epics, plus a short chat line (path, ladder, one open item; briefs also
   say to pass the path to the change-proposal skill). The file is not pasted
   back into chat.
3. **Review**: a block with Strong / Missing / Ladder / Platform pieces /
   Ready to propose (brief) or Ready to flip (epic) / Next step. Read-only.
   The skill never flips `Status`.
4. **Capability**: Yes today / No today / Partly / Cannot confirm, cited from
   the primer. A proposed one-line gap, not written unless you ask.

## The costs, stated

- **Threads are proposals, not a tracker.** They live in chat until you draft
  one. They are not a fourth artefact and not a backlog tool.
- **No PRD, no user stories.** Discovery that would have lived in a PRD lives
  in the epic's sibling folder and in the brief's four sections. If you need a
  ten-section PRD, this is the wrong skill.
- **No stories in the Mike Cohn / Gherkin sense.** Constraints are In / Out /
  Do not invent on the brief. The user need is who, friction, outcome. Spec
  deltas and how live in the change, not here.
- **Primer or nothing for capability.** With no
  `docs/product/context/platform-primer.md`, the answer is `Cannot confirm`.
  The skill will not guess from training data. Threads may still run; they
  mark `thin` and do not answer `Yes today`.
- **Draft never auto-flips.** New files stay `Status: draft`. Ready-to-propose
  (brief) or ready (epic) is a human edit, after review says you could.

Product decisions are captured inline (brief §4, epic §5, one-pager §1). There
is no decisions folder and no ADR from this skill.

## Common questions

**Does this work in Cursor / Copilot / Codex, or only Claude Code?**
It is a standard Agent Skills package (`SKILL.md` plus `references/`). Install
via the top-level README and pick your hosts. The Claude Code plugin is an
optional second route; do not install both. Fan-out uses the host Task /
subagent tool when it exists; otherwise the same gathers run sequentially.

**Will the agent fire this in the middle of my work?**
No. It is user-invoked. You type `/product-spine` (or pick it from the skill
picker). The model is instructed not to start it on its own.

**Why is the default no longer "which mode"?**
An engineer acting as PO needs what to work on next, not a blank template.
`draft` is how a picked thread lands, not the first thing you hit.

**How is this different from Product-Manager-Skills?**
[deanpeters/Product-Manager-Skills](https://github.com/deanpeters/Product-Manager-Skills)
is a **framework curriculum**: each of the 77 skills teaches a PM method
(Cohn stories and Gherkin, epic hypotheses, RICE/ICE, a 10-section PRD,
Humanizing Work splits) and produces a chat answer or a template fill. None
of them read a project's strategy file, check that a brief ladders to a real
initiative, enforce a `Status` contract, or answer "can the
platform do X today" from a primer. There is no name collision (no "spine"
in that catalogue).

`product-spine` is **repo-native and operational**. It proposes threads from
evidence in the repo, operates on three files at fixed paths, keeps the
ladder greppable, and grounds capability answers in the project's own primer.
It deliberately produces no PRD and no user stories.

**Can I use it alongside their `epic-hypothesis` or `problem-statement`?**
Yes, as thinking tools. Run their `problem-statement`, `epic-hypothesis`,
`epic-breakdown-advisor`, or `prioritization-advisor`, then land the result
in the house format with `/product-spine draft`. Their `prd-development` and
`user-story` are the things this skill **replaces**, not complements.

**Where do the primer and gaps files come from?**
You write them. Drop headings into `docs/product/context/platform-primer.md`
and `capability-gaps.md` (skeletons are in the skill's
`references/context-folder.md`). Until the primer exists, capability mode
will not pretend to know the platform. Threads still run from README and
code signals.

**Why does every new file say `Status: draft`?**
So a half-filled brief cannot be mistaken for something ready to propose.
You flip a brief to `ready-to-propose` (or an epic to `ready`) when review
says you could.

**Why a brief and not a task or ticket?**
A ticket would duplicate the change folder the coding agent already works
from. The brief carries only what / why / ladder / primer. Pass its path to
the change-proposal skill. Saying `draft task` still works as an alias for
`draft brief`.

## It's working if

- Bare `/product-spine` draws a mermaid map and numbered Feature /
  Improvement / Fix cards with evidence paths (or `thin`), and writes no
  `src/` file.
- A new brief or epic on disk says `Status: draft` and has exactly one of
  `Part of:` / `Ladders to:`, pointing at a file or heading that exists. A
  brief also has `Suggested change:` in kebab-case.
- grep for an initiative heading finds the epics and briefs that serve it.
- `review` on a thin brief says `Ready to propose: no` and names one next
  step; it does not edit the file.
- `capability` with no primer says `Cannot confirm` and names
  `platform-primer.md`. With a primer, it cites a section and does not invent
  a metric or a platform noun.
- A request to implement is refused in one line. No patch, no `src/` edit,
  no write under `openspec/changes/`.

## Where it fits

`product-spine` is the **house format** at the seam between product thinking
and the change-proposal skill that authors how and spec. Threads are the PO
coaching step. Framework skills (theirs or yours) can feed it. The brief is
the handoff, not a tracker and not an implementation plan. It does not
replace a session retro, a plan, or a code review, and it does not run the
implementation.
