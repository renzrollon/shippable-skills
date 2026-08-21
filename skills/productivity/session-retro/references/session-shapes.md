# Session Shapes

Patterns that produce expert-level sessions. Use these as mental models when
starting a session, or when scoring one that just ran.

The key insight: expert sessions are not longer or harder. They are better
structured from the start. The right shape chosen upfront eliminates
backtracking, scope drift, and wasted exploration.

These shapes are host-neutral. Name the skills, plans, or workflows this
project actually uses; do not assume any one vendor's command names.

---

## Score key (1-10)

Score the **session's shape and execution**, not the user's domain expertise
and not the difficulty of the task.

| Score | Meaning |
|-------|---------|
| 10 | Textbook shape. Cheap locate, batched tools, no re-derivation. Output matches the entry signal. |
| 8-9 | Right shape. One or two small wastes (an extra full-file read, one sequential bash). |
| 6-7 | Right-ish shape, or the right shape with notable waste: a wrong fork that got corrected, unbatched gathers, state re-derived once. |
| 4-5 | Wrong shape for the entry signal, or significant backtracking / scope drift. Work landed, but expensive. |
| 1-3 | Exploration without output, repeated re-derivation, Read-to-find instead of locate-then-Read, or the session never classified itself. |

A session that was already lean can still score 8-10. Say so, and name the one
thing that kept it lean. Do not invent a token count to justify a number.

---

## Shape 1: Plan-then-Execute

**Duration:** 15-25 min | **Pattern:** think → structure → do

**Entry signal:** "I want to build X": no durable plan exists yet, scope spans
multiple files.

**Flow:**
1. Optional read-only explore if the domain is not already understood. Write a
   durable brief; do not leave findings only in chat.
2. Produce a plan or spec (proposal, design, tasks, or the project's equivalent)
   and stop for a human read if the change is non-trivial.
3. Implement against that plan. One logical commit (or the project's equivalent
   ship step).

**Expert version:** State the full scope upfront. Let the plan generate in one
pass. Read it once. Execution does not reopen design. No mid-session scope
changes.

**Common failure mode:** Starting to code before planning. Scope drifts
mid-implementation. Multiple commits for what should be one logical change.
Thirty-plus minutes because exploration and execution are interleaved.

**Preconditions:**
- A one-sentence scope statement before starting
- Clear in / out boundaries
- Enough domain knowledge to skip explore, or an explore brief already written

---

## Shape 2: Structured Execute

**Duration:** 7-15 min | **Pattern:** load → classify → do

**Entry signal:** "Ship it" / "implement the tasks": a reviewed plan already
exists.

**Flow:**
1. Load **all** plan artifacts (not only the task list) before writing code.
2. Execute in the project's preferred order (sequential for a handful of
   dependent tasks, parallel waves when tasks are independent).
3. Verify, then one feature-level commit.

**Expert version:** This session is pure execution. Zero exploration, zero new
design decisions. Read everything before writing anything.

**Common failure mode:** Implementing after reading only the tasks, not the
design. Making decisions that contradict the plan. Re-deriving the plan from
the codebase instead of reading the artifacts.

**Preconditions:**
- Plan artifacts exist and were reviewed
- Tasks have clear acceptance criteria

---

## Shape 3: Investigate-then-Propose

**Duration:** 20-35 min | **Pattern:** understand → capture → structure

**Entry signal:** "How does X work? I might need to change it." Understanding
must land before a design is committed.

**Flow:**
1. Read-only investigation. Fan out across subsystems when the question spans
   them. Prefer a graph or index if the repo has one.
2. Write a durable brief (handoff, explore note, or equivalent).
3. Turn understanding into a plan/spec. The next session should load the brief,
   not rediscover the same files.

**Expert version:** Investigation writes something a later session can open
after a context reset or a host swap. The propose step consumes that brief.

**Common failure mode:** Exploring in one long single-threaded chat. Findings
live only in history and vanish. Never converting understanding into a plan,
so the next session pays again.

**Preconditions:**
- Multiple modules involved (justifies breadth)
- The question is specific enough to decompose
- Prior briefs / memory checked first

---

## Shape 4: Targeted Fix

**Duration:** 5-12 min | **Pattern:** locate → fix → verify

**Entry signal:** "X is broken" or "fix the error in Y": specific bug, narrow
scope.

**Flow:**
1. Check known constraints about this area (memory, ADRs, recent commits).
2. Locate the issue (grep, graph query, or test failure span), not a full-file
   read sweep.
3. Fix it.
4. Run the relevant tests.
5. Commit, or report if the fix is broader than it looked.

**Expert version:** The relevant constraint is already known. Go to the fix.
Verify immediately. Done in under ten minutes.

**Common failure mode:** Guessing without reading constraints. Trying three
wrong approaches. Exploring broadly when the fix is one function. Skipping
tests.

**Preconditions:**
- The error is specific (not "something is slow": that is Investigate-then-Propose)
- Scope is genuinely narrow (one file, one concept)

---

## Shape 5: Workflow-Orchestrated

**Duration:** 10-40 min | **Pattern:** script controls flow, agents do work

**Entry signal:** Complex work that benefits from deterministic orchestration:
a reviewed change ready to ship, a large independent task set, or a structured
review.

**Flow:**
1. Launch the project's workflow or orchestrator (an implement loop, a CI
   pipeline, a review fan-out), not a hand-rolled loop in chat.
2. Independent tasks run in parallel; dependent ones wait on gates.
3. Intermediate results stay in script state or files, not in the conversation.

**Expert version:** The script holds the plan. The model does slices. Retry
logic is in the script, not "hopefully it retries."

**Common failure mode:** Re-implementing a workflow's job inline in the
conversation. Using a workflow for work that is sequential or needs a human
decision between steps.

**Preconditions:**
- Tasks can parallelize without file conflicts, or the orchestrator serializes
  collisions
- Verification commands exist (typecheck, test, lint)
- For an orchestrated run: the plan already passed its human checkpoint

---

## Shape 6: Agent-Team Investigation

**Duration:** 15-45 min | **Pattern:** debate → converge → decide

**Entry signal:** Unclear root cause, or a decision with genuine competing
approaches. Value comes from agents **challenging each other**, not from
silent parallel reads.

**Flow:**
1. Spawn several investigators, each assigned a hypothesis or angle.
2. They investigate independently **and** refute each other.
3. The lead synthesizes what survived into a decision or a plan.

**Expert version:** Unlike a workflow fan-out (which collects results
silently), a team communicates. That communication is the product.

**Common failure mode:** Using a team for mechanical parallelism (use a
workflow). Teams add coordination cost; only worth it when agents need to talk.

**Preconditions:**
- The host can run parallel agents that share findings
- Multiple plausible causes or approaches exist

---

## Shape selection heuristic

When in doubt, start with the simplest shape that fits:

```
Specific error + narrow scope              → Targeted Fix
"Ship the tasks" + reviewed plan           → Structured Execute
"Build X" + clear scope                    → Plan-then-Execute
"How / why / what if" + broad scope        → Investigate-then-Propose
Reviewed change ready, or a large parallel set → Workflow-Orchestrated
Unclear root cause + competing theories    → Agent-Team Investigation
```

If you pick Targeted Fix and the scope is broader than expected, escalate to
Investigate-then-Propose. If you pick Plan-then-Execute and the plan is already
reviewed, downgrade to Structured Execute. Shape classification is a starting
point, not a commitment.

**Workflow vs agent team:**
- Tasks independent, orchestration known → workflow (deterministic, cheaper)
- Agents need to communicate, challenge, or negotiate → team

---

## Anti-patterns

| Anti-pattern | Why it fails | Instead |
|-------------|--------------|---------|
| Explore everything first | Burns twenty minutes before any output | Pick a shape, start |
| Read the whole codebase | Context fills with irrelevant code | Locate, then Read spans |
| Figure out the approach as we go | Backtracking and scope drift | Classify, announce scope, then execute |
| Just one more thing | Scope creep past thirty minutes | Handoff + new session for new scope |
| Single-thread independent work | 3x wall-clock | Workflow or parallel agents |
| Re-implement a workflow in chat | Context fills, results vanish | Launch the workflow |
| Skip the human checkpoint on a new design | Wrong idea gets implemented cheaply in the wrong place | Stop; let a human read the plan |
