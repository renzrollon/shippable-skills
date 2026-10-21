# session-handoff

Share this skill as the folder that holds its human README: [`skills/productivity/session-handoff/`](../../skills/productivity/session-handoff/).

## What it does

`session-handoff` writes the state of the **conversation you are in** to a
file, so a fresh session or another agent can pick up without re-deriving what
you already decided.

A context reset throws away the reasoning, and the reasoning is the expensive
part. A diff shows what changed; it does not show why, what was tried and
dropped, or what was only assumed. The handoff keeps those.

The file starts with a resume stamp on its first line
(`<!-- resume: <slug> | branch <branch> | head <short-sha> | <date time> -->`)
and has nine sections, always present, in this order: Progress, Decisions Made,
Rejected Alternatives, Files Touched, Verified vs Assumed, Do Not Redo, Issues /
Blockers, Next Steps, Skills To Invoke. An empty section reads `None.`

Before it writes, it checks what a reset would strand: uncommitted files,
unpushed commits, and running jobs when the host lists them. Those go under
Issues / Blockers. It refers to specs, plans, and commits by path or short SHA
instead of copying them, and replaces any secret with a placeholder naming its
kind.

It then proposes **at most three** reusable rules as exact lines for your
instruction file. Nothing is written there without your yes.

The reply is short: the file path, the resume phrase
(`Read <path> and continue from its Next Steps.`), and a two-line summary.

## When to reach for it

You invoke this by typing `/session-handoff`; the agent will not reach for it on
its own. Pass a slug, or `--handoff-dir <path>`.

| Situation | Why this skill |
| --- | --- |
| About to clear context | The decisions and rejected options survive the reset |
| Switching tools or handing to another agent | One file and one phrase to resume from |
| Ending the day mid-change | Stranded work is listed before you walk away |
| The session learned a project rule | It is proposed as a line for your instruction file, not lost |

Skip it when the work is finished and committed with nothing left to carry, or
when you want to score how the session went: that is a retro, not a handoff.

## Common questions

**Where does the file go?**
A `--handoff-dir` you pass or a directory you name in the request, else a
`shippable-handoff-dir:` line in your instruction file, else the first existing of `.claude/handoff/`,
`.agents/handoff/`, `docs/handoff/`, else a new `.agents/handoff/` (it suggests
a gitignore line). The name is `handoff-<slug>-<YYYYMMDD-HHMMSS>.md`.

**What if the host denies the write?**
It tries once, does not look for another place, and prints the whole handoff in
the reply instead, redacted the same way.

**Does it read an old transcript?**
No. It reads this conversation and a few git facts.

**Will it edit my AGENTS.md or CLAUDE.md?**
Not without a yes. The proposal is shown as the exact line to add; the handoff
itself touches no other file.

**How does the next session use it?**
It reads the newest handoff when you give it the resume phrase, or when
`session-primer` finds it at session start.

**Why a long list of sections for a short session?**
A section with nothing to say reads `None.` so the reader never wonders whether
something was dropped. A handoff past about 150 lines usually copied something
it should have pointed at.

## It's working if

- The first line is a resume stamp with a real branch and short SHA.
- All nine sections are present, and Verified vs Assumed separates a test that
  ran from a belief.
- Stranded work you forgot (an unpushed commit, a dirty file) shows up under
  Issues / Blockers.
- A new session given only the resume phrase can state the next step without
  asking you.
- No token, key, or connection string appears in the file or the reply.
- Nothing in your instruction file changed unless you said yes.
