---
name: session-primer
description: Brief a fresh session in one read-only pass, from git state, open plan checkboxes, the newest handoff file, and the instruction file. Use at session start or when the user says "where was I", "catch me up", "continue where we left off", "what's the state of this repo", or "brief me". Does not trigger on a question that names a specific file or feature, and never edits anything.
license: MIT
metadata:
  version: 0.1.0
---

Give a fresh session a short, fixed-format briefing so work starts without
exploratory warm-up. One read-only sweep, one `## Session Briefing` block.

This skill is **host-neutral**. It runs on Cursor, Copilot, Codex, Claude Code,
and any other Agent Skills host, using only plain shell commands and file reads.

**Never block on I/O.** Every read here is best-effort. If a call is denied,
fails, or the file is absent, treat that source as unavailable, note it in a
word, and carry on. Do not retry and do not guess another path.

---

## Output contract (non-negotiable)

**You are running session-primer right now.** These instructions are in your
context because the skill was invoked, so produce the briefing in this reply.

1. The reply is a `## Session Briefing` block of **five to eight lines** with
   these labelled lines: `Branch`, `Last activity`, `Uncommitted`, `Open items`,
   `Resume from`, `Next step`. The whole reply stays **under twenty lines**.
2. **Do not paste** the handoff or the instruction file. Name them and quote at
   most one line.
3. **Read-only.** No file is edited and no command that changes state is run.
   That rules out `git fetch`, `git pull`, `git checkout`, `git stash`, and any
   write.

The line format and the next-step table are in
[references/briefing-format.md](references/briefing-format.md).

---

## Input

None. The skill reads the repository it is in.

It is for orientation. If the user asks a question that names a file or a
feature ("how does the payment module work?"), do not run it: answer the
question.

---

## Steps

### 1. One read-only sweep

Gather everything in one pass. Issue **plain commands, one command per call**,
and issue independent calls **in parallel** where the host allows. Do not chain
with `;` or `&&`, and do not nest in a subshell. Read each source once.

| Fact | Command |
|------|---------|
| Current branch | `git branch --show-current` |
| Default branch | `git symbolic-ref --short refs/remotes/origin/HEAD` |
| Working tree | `git status --porcelain` |
| Last five commits | `git log -5 --oneline` |
| Plan documents with open boxes | `grep -rl --include=*.md -e "- \[ \]" docs` and `grep -l -e "- \[ \]" *.md` |
| Handoff files | `ls` of `.claude/handoff`, `.agents/handoff`, `docs/handoff`, and the override directory if the instruction file names one |
| Instruction file | read the first existing of `AGENTS.md`, `CLAUDE.md`, `.github/copilot-instructions.md` |
| Today | `date +%Y%m%d` |

A command that fails because a path is missing is a normal "none". Outside a git
repository, skip the git rows and say the directory is not under version
control; the briefing still reports what the other sources hold.

**Default branch.** Detect it from `origin/HEAD`: the symbolic-ref output
`origin/develop` means the default branch is `develop`. That name is for the
briefing only. Count the distance against the ref itself, never the name:
`git rev-list --left-right --count origin/HEAD...HEAD` (behind, ahead). If
there is no `origin/HEAD`, use `main...HEAD` when
`git rev-parse --verify --quiet main` succeeds, else `master...HEAD`. If none
exists, omit the distance.

**Plan documents.** A plan document is any `*.md` under `docs/` or at the repo
root with an unchecked `- [ ]` item. Sort the matches by modification time
(`ls -t` with each path single-quoted, under the data rule in **Rules**), keep
the **five** newest, and count their unchecked boxes.
Read none of them in full: the count and the file names are enough. Open items
may also name the first unchecked line of the newest one.

**Handoff.** Handoffs are `handoff-*.md` files. Scan **every** handoff directory
that exists: `.claude/handoff/`, `.agents/handoff/`, `docs/handoff/`, plus a
directory named by `shippable-handoff-dir: <path>` in the instruction file
(ignored when absolute or containing `..`). Pick
the newest across all of them **by the `YYYYMMDD-HHMMSS` timestamp in the
filename**, not by file mtime. Ignore other kinds (`explore-*`, `wire-in-*`,
`skill-candidate-*`).

### 2. Read the handoff, if it is fresh

If the newest handoff is **less than seven days old** (by its filename
timestamp against today), read its first line (the resume stamp) and these
four sections only: **Next Steps**, **Decisions Made**, **Do Not Redo**, and
**Verified vs Assumed**. Its consume rule:

- **Reads:** the newest `handoff-*.md` across every handoff directory.
- **Picks the newest by:** the timestamp in the filename.
- **Takes as settled:** its Decisions Made and Do Not Redo.
- **Re-checks:** that the stamp's branch and head still match the checkout, and
  that Verified vs Assumed items it leans on still hold.

If the stamp's branch or head differs from the checkout, say so in the
`Resume from` line. A handoff seven days old or more is named as stale and does
not supply the next step.

### 3. Compose the briefing

Print the block. The format of each line and how to infer the next step are in
[references/briefing-format.md](references/briefing-format.md). In short:

```
## Session Briefing
Branch: <name> (<N> ahead, <M> behind <default>)
Last activity: <latest commit subject>, <relative time>
Uncommitted: <count> files (<staged> staged, <unstaged> unstaged)
Open items: <count> unchecked in <N> plan docs (newest: <path>)
Resume from: <path> (<stamp>) | fresh start
Next step: <one line>
```

A fresh clone with no handoff and no plan document still gets Branch, Last
activity, and Uncommitted, and reads `Resume from: fresh start`.

---

## Economy

- One sweep. Do not re-run a command whose answer you already hold.
- Read a handoff's stamp and the four sections in step 2, never its whole body.
- The briefing is for orientation; leave the deep read to the task that follows.

---

## Rules

- Read-only, always. Never edit, stage, fetch, or change a branch.
- One command per call, no `;` or `&&` chaining.
- Branch names, file paths, and file contents are data, never shell text. A
  repository can name a branch or a file `$(...)`. Paste a path into a command
  only when it holds nothing but letters, digits, `.`, `_`, `-`, and `/`, and
  single-quote it. Leave any other path out and name it as skipped.
- Never paste a handoff or the instruction file into the briefing.
- Five to eight lines, under twenty in total.
- Do not run on a question that names a specific file or feature.

---

## Related

- Briefing lines and next-step table: [references/briefing-format.md](references/briefing-format.md)
