# Tool Economy: Locate Before You Read, Batch Your Bash, Read State Don't Re-Derive It

Shared discipline for sessions that investigate a codebase or gather project
state. Cite these rules by name in a session retro's Token Utilization
section.

## The problem

Investigation-heavy sessions burn context in avoidable ways:

1. **Sequential single-command shell.** One `git` call, wait, one `grep`
   call, wait, one `ls` call: each an independent round-trip that could have
   shared a turn.
2. **Reading to find, not to understand.** Reading whole files one after
   another to discover *where* something lives, when a single grep would have
   pointed at the file and line.
3. **Re-deriving known state.** Traversing the tree to reconstruct the current
   task, when `git log` / `git status` / an open handoff already report it.
4. **Unattributed skill spend.** Work after a Skill or slash invocation until
   the next human turn is billed to that skill, but retros only tally Reads.
5. **Broken prefixes.** Mid-task model, tool-set, or compact changes force the
   host to re-send context that was already processed.
6. **Cold fan-out.** Each Task or Agent starts its own conversation. Parallel
   investigators after locate already found the file pay that cost for nothing.
7. **One vague prompt.** A single user turn (including the subagents it
   spawned) can dominate the session when the ask is "improve the codebase"
   instead of a file and function.

None of these are wrong occasionally. They become expensive when they are the
default: the pattern that fills a context window before the first edit.

Cite rules by these exact names in Token Utilization: Query-the-graph-first,
Budgeted-docs, Locate-before-Read, Batch-your-Bash,
Read-state-don't-re-derive, Attribute-to-skill, Keep-the-prefix,
Budget-subagents, One-prompt-share.

## Rule 0: Query the graph before you Grep (when it exists)

If the repo has a codebase graph or navigation index, treat it as the first
locator for structural questions: "where is X", "who uses Y", "how does A
reach B".

Then Grep/Read only for detail the graph lacks (dynamic imports, stringly
keys, generated code, languages outside the walk).

If no graph exists, do not block. Grep is the locator. Do not install or
rebuild a graph mid-retro; that is a different skill.

## Rule 0.5: Budgeted documentation retrieval (don't preload `docs/`)

Do not read all `docs/*.md` or concatenate spec markdown into context upfront.

1. If an agent-only digest or short architecture primer exists, Read it
   **once**.
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

If a prior explore brief or interview notes exist for this topic, read them
first. Prefer those recommendations over rediscovering the same files from
chat.

## Rule 4: Attribute-to-skill

From each Skill or slash invocation until the next human message, that work
belongs to the skill. If it dominated this session, say so and wire the
cheaper path into that skill, not a parallel new one.

Do not treat host auto-continuations (task notifications, scheduled wakeups,
background-task pings) as a new human prompt: roll them into the originating
turn. Internal compact or summary forks are not billed to a prompt.

## Rule 5: Keep-the-prefix

Hosts reuse prior context by matching a stable prefix. A change anywhere in
that prefix forces a rebuild of everything after it. Flag **clustered
mid-task** rebuilds, not a single expected compact at a task boundary.

Observational stand-ins (never invent billed token counts):

- Prefix kept breaking: list the moments (model or effort switch, MCP or
  plugin or tool-set change, compact or clear in the middle of a task).
- This user turn dominated the session (One-prompt-share).
- Fan-out did not pay, or the spawn prompt was huge (Budget-subagents).
- One dump filled context: a full file, a test log, a pasted transcript.

**Not a prefix break:** invoking a skill or command (instructions append),
editing a repo file, rewinding to an earlier turn.

**Next-turn:** compact at a task boundary, rewind to abandon a path instead
of compacting it, keep model / effort / tools stable mid-task, put verbose
work in a subagent that returns a summary.

**Host note (Claude Code, do not claim these figures for this session):** a
log scorer treats cache-read below about 85% of input, a single call above
about 100k uncached, or a prompt above about 2% of a week as anomalies. This
skill never reads those logs. Name the moments you saw.

## Rule 6: Budget-subagents

Each Task or Agent starts cold: own system prompt, own tool set, it does not
read the parent prefix. Fan-out only when parallelism pays.

Flag: N investigators after locate already found the file; a spawn prompt
that pasted the parent's dump; an agent team left running after the answer
landed. Next-turn: fewer agents, a cheap locate agent, summary back (not raw
logs), shut teammates down when their slice is done.

A genuine Agent-Team Investigation (competing hypotheses that must refute
each other) still warrants fan-out. This rule is the wasted kind.

## Rule 7: One-prompt-share

Name the user turn that dominated this session, including subagents it
spawned. Vague "improve this codebase" triggers a broad scan. "Add input
validation to login in auth.ts" does not.

Roll auto-continuations into that originating turn. Do not bill compact or
task-summary forks to a prompt.

## When NOT to apply

This targets *wasted* exploration, not legitimate reconnaissance:

- Genuine cross-subsystem investigation still warrants a fan-out. Rule 1
  applies *within* each investigator; Budget-subagents applies to fan-out
  that did not pay, not to the decision to investigate in parallel.
- The artifact leash still holds: when you are about to implement against a
  proposal/design/tasks set, read all of it first. That is not the sprawl
  this file is about.
- A single compact or model choice at the **start** of a task is prefix
  hygiene, not Keep-the-prefix waste.
