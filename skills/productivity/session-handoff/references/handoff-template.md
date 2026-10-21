# Handoff template

The file `session-handoff` writes. Fill every section. A section with nothing to
say reads `None.`

## File

Name: `handoff-<slug>-<YYYYMMDD-HHMMSS>.md`, in the resolved handoff directory.

## Template

```markdown
<!-- resume: <slug> | branch <branch> | head <short-sha> | <YYYY-MM-DD HH:MM> -->
# Handoff: <slug>

## Progress
<!-- What is done and what is left. Cite paths or short SHAs. -->
- Done: ...
- Left: ...

## Decisions Made
<!-- One line each: the decision, then why. -->
- <decision>. Why: <reason>

## Rejected Alternatives
<!-- What was considered and dropped, with the reason, so it is not re-proposed. -->
- <option>. Dropped because: <reason>

## Files Touched
<!-- Path plus a few words. Changed files only. -->
- `path/to/file`: <what changed>

## Verified vs Assumed
<!-- Be honest. A claim without a run or a read behind it is Assumed. -->
- Verified: <what, and how: command run, file read>
- Assumed: <what, and what would confirm it>

## Do Not Redo
<!-- Work that is finished or investigated and should not be repeated. -->
- <item>

## Issues / Blockers
<!-- Stranded work from the preflight goes here first. -->
- Uncommitted: <count> files (<up to ten paths>)
- Unpushed: <N> commits on `<branch>`
- Background: <running agents or jobs, if the host exposes them>
- <open problem or blocker>

## Next Steps
<!-- Ordered, concrete, each startable without asking. -->
1. <step>
2. <step>

## Skills To Invoke
<!-- Skills the next session should call, by name. Or `None.` -->
- `<skill-name>`: <when>
```

## Resume stamp

First line, exactly:

```
<!-- resume: <slug> | branch <branch> | head <short-sha> | <YYYY-MM-DD HH:MM> -->
```

- `<slug>`: the same slug as the file name.
- `<branch>`: `git branch --show-current`, or `none` outside a repository or on
  a detached head.
- `<short-sha>`: `git rev-parse --short HEAD`, or `none`.
- Time: local, minute precision.

A reader (such as `session-primer`) takes the stamp as the quick check of
whether the handoff still matches the checkout.

## Rules for the content

- Point at specs, plans, briefs, and commits by path or short SHA. Do not paste
  them.
- No secrets. Tokens, keys, passwords, and connection strings become a
  placeholder naming the kind, such as `<api-token>`.
- Keep it under about 150 lines. Longer usually means something was copied.
- Do not paste the proposed instruction-file constraints into the file. They go
  in the reply and need a yes before they go anywhere else.

## Resume phrase

Printed in the reply, verbatim, with the real path:

```
Read <path> and continue from its Next Steps.
```
