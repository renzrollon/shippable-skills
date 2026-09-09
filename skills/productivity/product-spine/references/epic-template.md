# Epic template

Default path: `docs/product/epics/YYYY-MM-DD-<slug>.md`.

Always written `Status: draft`. `product-spine` never flips it to `ready`.

Sibling folder (name it in the chat reply; do not populate mockups):
`docs/product/epics/<slug>/`. Discovery that exists or is planned becomes
file names there, for example:

- `interviews-YYYY-MM-DD.md`
- `competitor-teardown.md`
- `hypothesis-<x>.md`
- `mockups/<flow>-lofi.html`

Lo-fi only. A hi-fi mockup is out of scope for this skill.

```markdown
# <Epic title>

Status: draft
Ladders to: docs/product/one-pager/current.md §4 <initiative heading>

## 1. User problem

<three lines: who, friction, outcome>

## 2. Platform pieces

<vocabulary from docs/product/context/platform-primer.md, or "primer absent">

## 3. Out of scope

- <what this epic will not do>

## 4. Tasks

- [ ] `tasks/YYYY-MM-DD-<slug>.md` <title>

## 5. Reasons for product decision

<trade-off, or "none yet">
```

`Ladders to:` cites the §4 **heading text**, not only the number. There is no
`Part of:` on an epic.

§4 is a list of task files that serve this epic. Review compares it to
`tasks/*.md` whose `Part of:` points here.
