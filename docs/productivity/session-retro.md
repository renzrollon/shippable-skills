## What it does

`session-retro` scores the **conversation you are still in**: the session shape
it matched, where tokens went to waste, and which repeatable steps should be
folded back into the skills that conversation actually called.

A retro is only worth running while the transcript is still in context. The
moment a session ends, its reasoning collapses into a tool-call histogram: you
can count the reads but not see why each one happened. Every finding after that
point is inference. This skill runs *before* that collapse, so it reports what
happened rather than guessing at it.

## When to reach for it

You invoke this by typing `/session-retro`; the agent will not reach for it on
its own. Pass `--since <marker>` to limit the window, or `--focus tokens` /
`--focus wiring` to emit only one section.

| Situation | Why this skill |
| --- | --- |
| Mid- or end-of-session, you want a score | Shape + 1-10 score while the moments are still named |
| Tokens felt expensive | Findings in relative magnitude, each with a next-turn fix |
| You just improvised around a skill | A wire-in note names the file that should have done it |
| The session invented a procedure no skill covers | A skill-candidate brief, not a SKILL.md written on the spot |

Skip it when you want to score a **different** session, or a whole day's work:
this skill only sees the conversation it is in. Skip it for pure chat with no
tools: there is nothing to retro.

## The mechanism

Most session-analysis tools have a gather step: open the log, parse the
events, reconstruct the shape. `session-retro` has none. The session it is
retro-ing is the conversation it is running inside.

- **No log read.** Re-reading on-disk transcripts would re-pay for context the
  model already holds, which is the waste the skill exists to flag, so it is
  forbidden.
- **Grounded, not inferred.** A finding can point at the actual moment ("the
  full-file read before the first edit") instead of a count of reads with the
  motive stripped out.
- **One cheap gather, and it is about the tools, not the transcript.** The
  only files it reads are the three it measures against (session shapes, tool
  economy, skill-candidate brief) plus an enumeration of installed skills so a
  wire-in can name a file that exists.

## What it produces

A short chat report, in a deliberate order:

1. **Session Snapshot**: the shape it matched and a 1-10 score.
2. **Token Utilization**: the headline. Concrete moments where tokens went to
   waste, each tagged with the tool-economy rule it broke and the different
   action for next turn.
3. **What Could Have Been Done Better**: only when the score is below 8/10,
   one shape or execution fix.
4. **Wiring**: for every skill and workflow the session called, the
   repeatable step done *around* it that belongs *inside* it, written as a
   durable wire-in; plus new skill candidates when a procedure had no home.

Handoffs land in `.claude/handoff/` when that directory already exists,
otherwise `.agents/handoff/`. The chat reply is the one-line index into them.
It does not dump a report and then dump it again.

## The costs, stated

- **It has no exact token counts, and does not pretend to.** Per-turn token
  numbers are not available to a skill running mid-session, so every finding
  is stated in *relative magnitude*, anchored to a real moment. A
  precise-looking number would be a fabricated one.
- **It sees this session and only this session.** There is no cross-session
  view, no day rollup. That is the trade for running live.
- **A wire-in is a proposal, not a patch.** It names a target file and the
  change to make; applying it is a separate, deliberate act by whoever owns
  that skill.

## Where wire-ins land

The Wiring section is the half that compounds. A retro that only scored token
spend would teach you the same lesson every session; one that folds the lesson
back into the skill you called teaches it once.

The catch is naming the file that actually **runs**. If a called skill is a
trampoline that launches a workflow script, a wire-in that edits the
trampoline ships nothing. For an ordinary skill the opposite holds: the
`SKILL.md` prose is exactly what the model follows. A wire-in that targets the
wrong file is worse than none, because it looks applied and changes nothing.

## Common questions

**Does this work in Cursor / Copilot / Codex, or only Claude Code?**
It is a standard Agent Skills package (`SKILL.md` plus `references/`). Install
via `npx skills add renzrollon/shippable-skills` and pick your hosts. The
Claude Code plugin is an optional second route; do not install both.

**Will the agent fire this in the middle of my work?**
No. It is user-invoked. You type `/session-retro` (or pick it from the skill
picker). The model is instructed not to start it on its own.

**Where did my wire-in file go?**
`.claude/handoff/` if that folder already exists in the project, otherwise
`.agents/handoff/`. Ask for the path back: the chat reply lists every file
written.

**Can it score yesterday's session?**
No. It only sees the live conversation. A tool that scored other sessions
would need the logs this one refuses to read.

**Why relative magnitude instead of token numbers?**
The host does not give per-turn token counts to a skill running inside the
session. Inventing a precise number would look more rigorous and be a lie.

## It's working if

- The snapshot names a shape you recognize and a score you could defend from
  the last hour of work, without opening `SKILL.md`.
- Each token finding points at a moment ("the three sequential greps") and a
  different next action, not a lecture about context windows.
- Wire-in paths exist on disk, and each names a file that is actually in the
  project or the installed skill set.
- The chat reply is short: snapshot, paths, one line per recommendation. The
  full notes are in the files.
- A lean session is called lean, instead of being padded with invented waste.

## Where it fits

`session-retro` is a **reach-for-it-anytime standalone** at the seam between
sessions rather than inside a build chain. Run it before `/clear`, before a
host swap, or when a messy hour should not repeat. It does not replace a
handoff (which carries work to another agent) and it does not replace a plan
or review skill (which operate on the code, not on how the session spent
itself).
