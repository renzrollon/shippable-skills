# session-primer

Share this skill as the folder that holds its human README: [`skills/productivity/session-primer/`](../../skills/productivity/session-primer/).

## What it does

`session-primer` briefs a fresh session in one read-only pass. It reads git
state, plan documents with unchecked boxes, the newest handoff file, and your
instruction file, then prints a `## Session Briefing` block of five to eight
lines: branch, last activity, uncommitted files, open items, where to resume,
and the next step.

It is the reader for the handoff that `session-handoff` writes. When a handoff
less than seven days old exists, its Next Steps supply the next step and its
decisions count as settled. Otherwise the next step is inferred from the repo
state.

It never edits anything. It does not fetch, pull, stage, stash, or change
branches, and it does not paste the handoff or instruction file into the reply.

## When to reach for it

The agent runs it on its own at session start, or when you say "where was I",
"catch me up", "continue where we left off", or "brief me".

| Situation | Why this skill |
| --- | --- |
| You reopen a repo after a break | One block says what changed and what is open |
| A new session follows a handoff | The stamp is checked against the checkout and the next step is taken from it |
| You picked up a branch someone else started | Branch distance, uncommitted files, and open plan items in eight lines |

Skip it when your question names a specific file or feature ("how does the
payment module work?"): that is a question to answer, not a briefing to print.

## Common questions

**Which handoff does it use?**
The newest `handoff-*.md` across `.claude/handoff/`, `.agents/handoff/`,
`docs/handoff/`, and any directory your instruction file names, picked by the
timestamp in the filename rather than file modification time.

**What if the handoff is old?**
One seven days old or more is named as stale and does not supply the next step.

**What counts as a plan document?**
Any `*.md` under `docs/` or at the repo root with an unchecked `- [ ]` item. It
keeps the five most recently modified and reports counts, not contents.

**Does it work outside a git repository?**
Yes. It skips the git lines, says the directory is not under version control,
and reports what the other sources hold.

**Does it work in Cursor, Copilot, or Codex?**
It uses plain shell commands and file reads. Install from the
[collection README](../../README.md).

## It's working if

- The briefing is five to eight lines and under twenty in total, including
  anything around it.
- Every labelled line is present: Branch, Last activity, Uncommitted, Open
  items, Resume from, Next step.
- A stale or mismatched handoff is called out in the Resume from line instead
  of silently trusted.
- Nothing in the working tree or branch state changed afterwards.
- A question that names a file gets an answer, not a briefing.
