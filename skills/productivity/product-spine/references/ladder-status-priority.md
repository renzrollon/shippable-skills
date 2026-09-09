# Ladder, Status, Priority

## The two ladder lines

A **task** has exactly one:

| Line | When |
|------|------|
| `Part of: docs/product/epics/<file>.md` | The task serves an epic. |
| `Ladders to: docs/product/one-pager/current.md §4 <initiative heading>` | No epic yet; the task serves a roadmap initiative directly. |

An **epic** always uses `Ladders to:` the one-pager initiative. Cite the
**heading text**, not only `§4`, so a project template with other numbering
still matches.

Never both `Part of:` and `Ladders to:` on the same task.

## Two greps

The ladder is the point: it has to be greppable.

Every task serving a bet (match the initiative heading):

```bash
grep -R -n "Ladders to:.*<initiative heading>" tasks docs/product/epics
```

Every task affected if that bet is killed (direct ladders plus tasks whose
epic ladders there):

```bash
grep -R -n "Part of: \|Ladders to:" tasks
```

Then filter to the epic files and heading text you are about to drop. If a
kill needs a hunt across chat logs, the ladder failed.

## Status

| Value | Who sets it | What it permits |
|-------|-------------|-----------------|
| `draft` | `product-spine` on every new task and epic | Incomplete is fine (TBD criteria, empty Priority). Not for the coding agent. Not on the Next-up list. |
| `ready` | the **user** only | Task: Priority P0-P3 is set, ladder target exists, §3 has at least two testable criteria. The coding agent (whatever executes tasks in this repo) may pick it up. |

`product-spine` never writes `Status: ready`. Review says whether the user
could flip it.

## Priority (P0 to P3)

Set only when the user gives one, usually as they flip to `ready`.

| Code | Meaning |
|------|---------|
| P0 | Users cannot complete the job today. This cycle. |
| P1 | Users are on a workaround. This cycle if capacity. |
| P2 | Valuable. Next cycle is fine. |
| P3 | Nice to have. Pick up when idle. |

## Next-up list

Top of `tasks/README.md`. Only `ready` tasks, highest priority first:

```markdown
# Tasks

## Next-up

- [ ] P0 `tasks/YYYY-MM-DD-<slug>.md` <title>
- [ ] P1 `tasks/YYYY-MM-DD-<other>.md` <title>
```

Draft files do not belong here. Done files move to `tasks/done/`.

## Cycles, not sprints

The spine does not assume sprints. A cycle is whatever cadence the team
already uses. Every ritual should leave a file behind:

- Planning writes or updates a task or epic.
- A strategy conversation appends a one-pager §1 line (and may edit §3 / §4).
- Standup is the Next-up list, not a second tracker.
- "Are we done" moves a task to `tasks/done/` and a line into one-pager §6.1.

When review finds a ritual with no file, name the file it should have produced.
