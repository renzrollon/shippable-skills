---
name: session-handoff
description: Save where this session stands to a handoff file before a context reset, so the next session or agent resumes without re-deriving decisions. Lists stranded work, redacts secrets, and proposes reusable rules for your instruction file.
license: MIT
argument-hint: "[<slug>] [--handoff-dir <path>]"
disable-model-invocation: true
metadata:
  version: 0.1.0
---

Write the state of the current session to a handoff file, so a fresh session
can pick up from it. Run it before clearing context, switching tools, or
passing work to another agent.

This skill is **host-neutral**. It runs on Cursor, Copilot, Codex, Claude Code,
and any other Agent Skills host. It reads this conversation and a few git
facts; it never reads an on-disk transcript.

**Never block on I/O.** Every read, list, and write here is best-effort. If a
call is denied or fails, treat it as unavailable, do not retry, and do not guess
another path. If the file cannot be written, the handoff goes in the chat reply.

---

## Output contract (non-negotiable)

**You are running session-handoff right now.** These instructions are in your
context because the skill was invoked, so write the handoff in this reply.

1. **The file's first line** is the resume stamp, exactly this shape:
   `<!-- resume: <slug> | branch <branch> | head <short-sha> | <YYYY-MM-DD HH:MM> -->`
   Outside a git repository use `branch none | head none`.
2. **The file has these nine sections, in this order,** as `##` headings:
   Progress, Decisions Made, Rejected Alternatives, Files Touched, Verified vs
   Assumed, Do Not Redo, Issues / Blockers, Next Steps, Skills To Invoke. A
   section with nothing to say reads `None.`; never omit one.
3. **The reply** prints the file path and, on its own line, the resume phrase
   verbatim: `Read <path> and continue from its Next Steps.` with the real path.
   Then the constraint proposal (step 5), if any.
4. **Never write a token, key, password, or connection string.** Replace the
   value with a placeholder naming its kind, such as `<api-token>`.

---

## Input

| Argument | Meaning |
|----------|---------|
| `<slug>` | Short kebab-case name for the work. Default: derived from the branch or the main task. |
| `--handoff-dir <path>` | Directory to write to (see step 4) |

---

## Steps

### 1. Stranded-work preflight

Before writing, check what would be lost, and put the findings under
**Issues / Blockers**:

- Uncommitted files: `git status --porcelain`. List up to ten, then a count.
- Unpushed commits: `git rev-list --count @{upstream}..HEAD`. If the branch is
  ahead, state the count and the branch name. If there is no upstream, say so.
- Running background agents or jobs, **only when the host exposes them**. If the
  host has no such listing, skip this check without comment.

Run each command on its own, not chained. Outside a git repository, skip the git
checks and say the state is not under version control.

### 2. Gather the session

From the conversation you already hold, collect: what was done and what remains,
the decisions with the reason for each, the alternatives that were rejected and
why, files changed, what was verified (a test passed, a command was run) versus
only assumed, work that must not be repeated, and the next concrete steps.

**Pointer, not copy.** Refer to specs, plans, briefs, and commits by path or
short SHA. Do not paste their contents. A handoff longer than about 150 lines
usually copied something it should have pointed at.

### 3. Compose and redact

Fill the nine sections from [references/handoff-template.md](references/handoff-template.md).

Then, **before anything is written**, scan what you are about to save for
secrets: API tokens, keys, passwords, bearer strings, connection strings with
credentials, private key blocks. Replace each with a placeholder naming its
kind. The write in step 4 and the inline fallback both use this redacted text,
so a secret is never on disk, even briefly.

### 4. Resolve the directory and write the file

Restated from the collection's shared conventions:

- **Instruction file:** the first existing of `AGENTS.md`, `CLAUDE.md`,
  `.github/copilot-instructions.md`. A line `shippable-handoff-dir: <path>` in
  it (relative to the repo root) overrides the handoff directory. Ignore a value
  that is absolute or contains `..`, and say so.
- **Handoff directory:** a path the user passed or named in the request, else the
  instruction-file override, else the first existing of `.claude/handoff/`,
  `.agents/handoff/`, `docs/handoff/`. When none exists, create `.agents/handoff/`
  and suggest a gitignore line for it.
- **File name:** `handoff-<slug>-<YYYYMMDD-HHMMSS>.md`.

When the user's path is not one of the three defaults, the next session's
`session-primer` will not find the file unless the instruction file names the
directory. Offer the exact line `shippable-handoff-dir: <path>` with the
constraint proposal in step 5, and write it only on a yes.

Write the redacted text from step 3.

**Attempt the create and the write once.** If the host denies either, do not
retry, do not try another location, and print the whole redacted handoff in the
reply instead, after a one-line note that the write was denied.

### 5. Propose reusable constraints

Look for rules this session learned that would apply again in this project, for
example "run the formatter before the type check, the CI order depends on it".
Propose **at most three**. Drop any candidate that names a single file, commit,
or incident instead of a rule that holds next time.

Show each as the exact line you would add to the instruction file. **Write
nothing to the instruction file without a yes.** Wait for it in the reply; an
edit to that file is not part of the handoff. If nothing generalises, say so and
offer no edit.

### 6. Reply

Print the file path, the resume phrase, a two-line summary of the Next Steps,
and the constraint proposal. Nothing else.

---

## Rules

- User-invoked only. Never start on your own because a session got long.
- The file is the product. The reply is short.
- Pointers over copies. Secrets never.
- Do not edit the instruction file, source, or any other file. The handoff and
  the proposal are the whole job.
- A denied write is printed inline once and not retried.
- In Skills To Invoke, list skills by name for the next session to call with the
  host's skill tool. Never tell it to run a user-invoked skill on the user's
  behalf.

---

## Related

- Section guide and example: [references/handoff-template.md](references/handoff-template.md)
