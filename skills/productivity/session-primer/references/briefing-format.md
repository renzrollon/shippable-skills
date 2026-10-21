# Briefing format

The block `session-primer` prints. Five to eight lines, under twenty in total,
including anything printed around it.

## Lines

```
## Session Briefing
Branch: <name> (<N> ahead, <M> behind <default>)
Last activity: <latest commit subject>, <relative time>
Uncommitted: <count> files (<staged> staged, <unstaged> unstaged)
Open items: <count> unchecked in <N> plan docs (newest: <path>)
Resume from: <path> (<stamp>) | fresh start
Next step: <one line>
```

| Line | Source | Notes |
|------|--------|-------|
| Branch | `git branch --show-current`, distance from the default branch | Default branch from `origin/HEAD`, else `main`, else `master`. Detached head: say `detached at <short-sha>`. No git: `not a git repository`. |
| Last activity | newest of the last five commits | Subject plus relative time. Add a second commit only if it changes the picture. |
| Uncommitted | `git status --porcelain` | Count files, split staged and unstaged. Clean tree: `clean`. |
| Open items | unchecked `- [ ]` boxes in plan docs | Plan docs are `*.md` under `docs/` or the root with unchecked boxes, capped at the five most recently modified. Count only, plus the newest path. None: `none`. |
| Resume from | newest `handoff-*.md` across every handoff directory | Name the file and the resume stamp from its first line. No handoff: `fresh start`. Seven days old or more: add `(stale)`. |
| Next step | the handoff's Next Steps, else inferred from state | See the table. One line. |

Optional lines, only when they add something and the block stays within eight
lines: `Instruction file:` naming which file was found and one rule that matters
for the next step; `Warning:` for a stamp that no longer matches the checkout.

## Resume from

- The handoff is **less than seven days old**: name the file and the stamp (the
  first line of the file, the `session-handoff` resume stamp). `Next step` comes
  from its **Next Steps** section: the first item.
- The stamp's branch or head differs from the checkout: say so in this line,
  for example `stamp branch main, checkout is feature-x`.
- Handoffs in more than one directory: the newest by the timestamp in the
  filename wins, whichever directory it is in.
- None found: `Resume from: fresh start`.

## Next step, inferred from state

Use the first row that matches. Used only when no fresh handoff supplies it.

| State | Next step |
|-------|-----------|
| Fresh handoff | its first Next Steps item |
| Uncommitted files and unchecked plan items | continue the newest plan doc's first open item |
| Uncommitted files, no plan item | review the diff, then commit or discard |
| Clean, ahead of the default branch | push or open the review |
| Clean, unchecked plan items | start the first open item of the newest plan doc |
| Clean, nothing open, on the default branch | ready for new work |
| Not a git repository | ask what the task is |

## Consume rule for the handoff

- Reads the newest `handoff-*.md` across every handoff directory.
- Picks the newest by the timestamp in the filename.
- Takes its decisions and Do Not Redo as settled.
- Re-checks the stamp against the checkout and anything marked Assumed.

## Do not

- Paste the handoff, a plan document, or the instruction file.
- Run a command that writes or changes state.
- Exceed twenty lines, or fall below five.
