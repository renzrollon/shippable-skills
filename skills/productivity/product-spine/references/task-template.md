# Task template

Default path: `tasks/YYYY-MM-DD-<slug>.md`. On completion the file moves to
`tasks/done/`. The Next-up list lives at the top of `tasks/README.md` and is
only for `ready` work. Status and Priority rules are in
`references/ladder-status-priority.md`.

Always written `Status: draft`. Never set `Priority` unless the user gave one.
Exactly one ladder line: `Part of:` (serves an epic) **or** `Ladders to:`
(serves a one-pager initiative directly). Never both.

```markdown
# <Task title>

Status: draft
Priority:
Part of: docs/product/epics/YYYY-MM-DD-<slug>.md

## 1. User need

- Who:
- Friction:
- Outcome:

## 2. Platform pieces

<vocabulary from docs/product/context/platform-primer.md, or "primer absent">

## 3. Acceptance criteria

- [ ] <testable criterion>
- [ ] <testable criterion>

## 4. Reasons for product decision

<trade-off, or "none">
```

When there is no epic yet, replace the `Part of:` line with:

```
Ladders to: docs/product/one-pager/current.md §4 <initiative heading>
```

If the one-pager is also absent:

```
Ladders to: (one-pager not yet written)
```

`- [ ] TBD` is allowed in §3 while `Status: draft`. Review will not call it
ready until at least two criteria are testable.

## Worked example (neutral)

`tasks/2026-09-08-payment-retry.md`

```markdown
# Retry a failed payment without re-uploading documents

Status: draft
Priority:
Part of: docs/product/epics/2026-08-15-payment-recovery.md

## 1. User need

- Who: a payer whose card charge failed
- Friction: retrying today means opening a new payment and uploading the
  same documents again
- Outcome: retry the same payment; documents already on file are reused

## 2. Platform pieces

primer absent

## 3. Acceptance criteria

- [ ] Retry uses the stored payment, not a newly keyed one
- [ ] Documents already on file are not requested again
- [ ] The payer sees success or the new failure reason

## 4. Reasons for product decision

none
```

This example is a shape, not a claim about any real platform. Capability
answers still come only from the project's primer.
