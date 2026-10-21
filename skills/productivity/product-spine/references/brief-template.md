# Brief template

Default path: `docs/product/briefs/YYYY-MM-DD-<slug>.md`. This file is
**what / why** for a change proposal: user need, ladder, primer nouns, and
product constraints. It is not an implementation plan and not a tracker.
Status rules are in `references/ladder-and-status.md`.

Always written `Status: draft`. Never write `ready-to-propose` or `ready`.
Never set `Priority`. Exactly one ladder line: `Part of:` (serves an epic)
**or** `Ladders to:` (serves a one-pager initiative directly). Never both.

`Suggested change:` is kebab-case glue for `openspec/changes/<slug>/`. Do
not create that folder. Optional `Change:` once a matching change exists
(the user fills it; this skill does not).

Do not add acceptance checkboxes or step lists. Review treats those as the
wrong artefact.

```markdown
# <Brief title>

Status: draft
Part of: docs/product/epics/YYYY-MM-DD-<slug>.md
Suggested change: <kebab-case>

## 1. User need

- Who:
- Friction:
- Outcome:

## 2. Platform pieces

<vocabulary from docs/product/context/platform-primer.md, or "primer absent">

## 3. Product constraints

- In:
- Out:
- Do not invent:

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

`TBD` is allowed in §3 while `Status: draft`. Review will not call it
ready to propose until In and Out are named.

## Worked example (neutral)

`docs/product/briefs/2026-09-08-payment-retry.md`

```markdown
# Retry a failed payment without re-uploading documents

Status: draft
Part of: docs/product/epics/2026-08-15-payment-recovery.md
Suggested change: retry-failed-payment

## 1. User need

- Who: a payer whose card charge failed
- Friction: retrying today means opening a new payment and uploading the
  same documents again
- Outcome: retry the same payment; documents already on file are reused

## 2. Platform pieces

primer absent

## 3. Product constraints

- In: retry the stored payment; reuse documents already on file; show
  success or the new failure reason
- Out: new payment methods
- Do not invent: primer absent

## 4. Reasons for product decision

none
```

This example is a shape, not a claim about any real platform. Capability
answers still come only from the project's primer. Pass this path to the
project's change-proposal skill; do not Call that skill from here.
