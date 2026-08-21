# Tool Economy: Locate Before You Read, Batch Your Bash, Read State Don't Re-Derive It

Shared discipline for sessions that investigate a codebase or gather project
state. Cite these rules by name in a session retro's Token Utilization
section.

## The problem

Investigation-heavy sessions burn context three ways, all avoidable:

1. **Sequential single-command shell.** One `git` call, wait, one `grep`
   call, wait, one `ls` call: each an independent round-trip that could have
   shared a turn.
2. **Reading to find, not to understand.** Reading whole files one after
   another to discover *where* something lives, when a single grep would have
   pointed at the file and line.
3. **Re-deriving known state.** Traversing the tree to reconstruct the current
   task, when `git log` / `git status` / an open handoff already report it.

None of these are wrong occasionally. They become expensive when they are the
default: the pattern that fills a context window before the first edit.

## Rule 0: Query the graph before you Grep (when it exists)

If the repo has a codebase graph or navigation index (for example
`.claude/graph/graph.json`, a `GRAPH_REPORT.md`, or another documented graph
CLI), treat it as the first locator for structural questions: "where is X",
"who uses Y", "how does A reach B".

Then Grep/Read only for detail the graph lacks (dynamic imports, stringly
keys, generated code, languages outside the walk).

If no graph exists, do not block. Grep is the locator. Do not install or
rebuild a graph mid-retro; that is a different skill.

## Rule 0.5: Budgeted documentation retrieval (don't preload `docs/`)

Do not read all `docs/*.md` or concatenate spec markdown into context upfront.

1. If an agent-only digest exists (for example `DOCS_DIGEST.md` or a short
   architecture primer), Read it **once**.
2. Task-specific drill-down: grep headings, then Read the cited span
   (`offset`/`limit` or equivalent), not the whole file.
3. If retrieval is empty, broaden terms once, then stop sprawl.

**Authoritative artifact exception:** when implementing against a named plan
or spec for this change, still read that change's artifacts in full. This
rule replaces exploratory preload, not the implementation contract.

## Rule 1: Locate before you Read

Use grep (or the graph, when Rule 0 applies) to find the file and line first,
then Read with `offset`/`limit` around the hit. Do not Read whole files
sequentially to discover where something lives. Read a file in full only once
you know it is the one you need.

## Rule 2: Batch and background your Bash

- **Independent read-only commands** go in one message (multiple tool calls)
  or joined with `;`, not `&&`. `&&` short-circuits: if an early command
  exits non-zero, the later ones never run and their output is silently lost.
  For a status sweep (`git branch`, `git status`, `git log`) you want them
  all, so batch them.
- **Reserve `&&` for dependency-ordered chains** where a later step is
  meaningless if an earlier one failed (typecheck && test && build).
- **Quote shell globs** in filter arguments so the shell does not expand them
  before the command sees them.
- **Background the long-running.** Builds, full test suites, and installs
  should not block other work.

## Rule 3: Read state, don't re-derive it

At session start, current-task context comes from a few cheap, authoritative
sources: `git log --oneline`, `git status --short`, the latest handoff, and
whatever the project uses as a change/status command. Front-load these in one
pass. Read them, then act. Do not re-traverse the tree to reconstruct what
they already tell you.

If a prior explore or grill brief exists for this topic, read it first.
Prefer its recommendations over rediscovering the same files from chat.

## When NOT to apply

This targets *wasted* exploration, not legitimate reconnaissance:

- Genuine cross-subsystem investigation still warrants a fan-out. Rule 1
  applies *within* each investigator; the decision to fan out is unchanged.
- The artifact leash still holds: when you are about to implement against a
  proposal/design/tasks set, read all of it first. That is not the sprawl
  this file is about.
