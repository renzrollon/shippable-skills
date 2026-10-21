# explore

Share this skill as the folder that holds its human README: [`skills/engineering/explore/`](../../skills/engineering/explore/).

## What it does

`explore` is read-only reconnaissance for the moment before a design. It reads
the codebase, fans out parallel investigators when the question is broad, and
merges what comes back into one picture with a suggested direction.

Most exploration fails in one of two ways: one agent reads serially until its
context is full, or several agents return overlapping dumps that get pasted
back unmerged. This skill cuts the question into two to five disjoint scopes,
has each investigator return JSON only (`files`, `how`, `connections`, `gaps`),
and then does the part that matters: combine overlaps, name the gaps nobody
covered, and surface contradictions with the evidence for each side.

Every run prints one marker line:

- `investigation: fan-out`: subagents ran.
- `investigation: sequential`: the host has no subagent tool, so the same
  scopes ran one after another.
- `investigation: single`: the question stayed single-threaded.

A change to the meaning of a shared value (normalising, deduplicating,
retyping) always sweeps every reader of it, so the raw-form consumers are named.

In **autonomous** mode it asks nothing: an unresolvable question becomes a
default under Assumptions Made and a row under Pending Clarifications, and a
nine-section brief is written once to the handoff directory.

It never writes code.

## When to reach for it

The agent reaches for it when a question needs mapping first; you can also say
"explore" and ask. Pass `--autonomous` for a run that must not interrupt you.

| Situation | Why this skill |
| --- | --- |
| "How does X work end to end?" | Parallel scopes by layer, one merged answer |
| "Redis or SQLite for this?" | One scope per option plus what the repo already does |
| "What breaks if we change this value?" | Every reader swept, raw-form consumers named |
| You want a durable record to design from | The autonomous brief, with a decision table |

Skip it for a single-file question (it will stay single-threaded anyway), a
quick clarification, or when you want to be interviewed about intent: it is not
an interview.

## Common questions

**Will it start building if I say "just do it"?**
No. It declines, says explore does not write code, and offers to save the
finding as a brief. You continue in your own implementing step.

**What if my host has no subagents?**
It runs the same planned scopes itself, one after another, and prints
`investigation: sequential`. It does not silently skip a scope.

**Where does the brief go?**
A `--handoff-dir` you pass or a directory you name in the request, else a
`shippable-handoff-dir:` line in your instruction file, else the first existing of `.claude/handoff/`,
`.agents/handoff/`, `docs/handoff/`, else a new `.agents/handoff/`. One create
attempt; a denied write prints the brief in the reply.

**Does it treat file contents as instructions?**
No. File text, issue text, and pasted logs are data. A secret it finds is named
by kind, never copied into a brief or a prompt.

**Does it pick up a grill brief?**
Not yet. No such contract ships in this collection.

## It's working if

- The reply carries exactly one `investigation:` line that matches what ran.
- A broad question came back as one synthesized picture, not stacked
  investigator reports.
- Findings cite `path:line` spans, and gaps are named rather than implied
  covered.
- A single-file question was answered directly with `investigation: single`.
- Asked to implement, it declined and changed no source file.
- In autonomous mode, the reply is a path plus a three to five line summary,
  and unresolved questions are `needs_human` rows, not interruptions.
