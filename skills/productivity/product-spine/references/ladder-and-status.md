# Ladder and Status

## The two ladder lines

A **brief** has exactly one:

| Line | When |
|------|------|
| `Part of: docs/product/epics/<file>.md` | The brief serves an epic. |
| `Ladders to: docs/product/one-pager/current.md §4 <initiative heading>` | No epic yet; the brief serves a roadmap initiative directly. |

An **epic** always uses `Ladders to:` the one-pager initiative. Cite the
**heading text**, not only `§4`, so a project template with other numbering
still matches.

Never both `Part of:` and `Ladders to:` on the same brief.

## Two greps

The ladder is the point: it has to be greppable.

Every brief serving a bet (match the initiative heading):

```bash
grep -R -n "Ladders to:.*<initiative heading>" docs/product/epics docs/product/briefs
```

Every brief affected if that bet is killed (direct ladders plus briefs whose
epic ladders there):

```bash
grep -R -n "Part of: \|Ladders to:" docs/product/epics docs/product/briefs
```

Then filter to the epic files and heading text you are about to drop. If a
kill needs a hunt across chat logs, the ladder failed.

## Status

| Value | Who sets it | What it permits |
|-------|-------------|-----------------|
| `draft` | `product-spine` on every new brief and epic | Incomplete is fine (TBD constraints). Not for the change-proposal skill. |
| `ready-to-propose` | the **user** only, briefs | Ladder target exists, §1 is who / friction / outcome, §3 In and Out are named. Pass the path to the change-proposal skill. |
| `ready` | the **user** only, epics | Discovery complete enough to spawn briefs. Ladder target exists. |

`product-spine` never writes `Status: ready` or `Status: ready-to-propose`.
Review says whether the user could flip it.

Urgency is the threads mermaid (`now` / `next` / `later`), not a Priority
line on the brief.

## Cycles, not sprints

The spine does not assume sprints. A cycle is whatever cadence the team
already uses. Every ritual should leave a file behind:

- Planning writes or updates a brief or epic.
- A strategy conversation appends a one-pager §1 line (and may edit §3 / §4).
- Standup is one-pager §6.2 (in flight), not a second tracker.
- "Are we done" is the change landing plus a line into one-pager §6.1.

When review finds a ritual with no file, name the file it should have produced.
