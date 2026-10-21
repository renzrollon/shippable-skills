# One-pager template

Default path: `docs/product/one-pager/current.md`.

A project may drop its own template at `docs/product/one-pager/TEMPLATE.md`.
When that file exists, use **its** headings and numbering. Ladder lines still
cite the **heading text** of each roadmap initiative so greps survive a
renumber.

`product-spine` writes this file. It does not write a PRD, a hypotheses
folder, a metrics folder, or a decisions folder. Strategy lives here; product
decisions append to §1.

```markdown
# One-pager: <product or area>

## 1. Change log

- YYYY-MM-DD: first draft.

## 2. Problem and outcomes

### 2.1 Who

Who is this for, and what job are they hiring the product to do.

### 2.2 Problem

The problem in the users' terms, not the team's.

### 2.3 Metrics

| Name | Baseline | Target | Date |
|------|----------|--------|------|
| <metric> | unknown | <target or unknown> | <date or unknown> |

Every metric carries a baseline or the literal `unknown`. Never invent a
baseline.

## 3. Strategy bets

Named bets the roadmap will map to. Stable names: briefs and epics cite them
by heading text under §4, which must name the bet they serve.

## 4. Roadmap initiatives

Stable headings. Epics and briefs ladder here:

### <Initiative heading>

- Serves bet: <§3 bet name>
- Intent: <one or two lines>

## 5. Risks and open questions

- <risk or question>

## 6. Delivery

### 6.1 Delivered

<!-- Filled when work lands. -->

### 6.2 In flight

<!-- Pointers to epics and ready-to-propose briefs, not a second tracker. -->
```

On a refresh of an existing `current.md`: snapshot first to
`docs/product/one-pager/YYYY-MM-DD-current.md`, then edit `current.md` and
append a dated §1 line.
