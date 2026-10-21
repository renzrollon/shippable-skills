# Context folder

Project-supplied, never invented. Default directory:
`docs/product/context/`.

These files are how a team describes **their** platform to the skill. If a
file is absent, say so and continue. Do not guess a sibling path. Do not
fill gaps from training data.

The primer is the **only** source of "can we do X today". Golden Path docs
are optional colour (how this org prefers to build), not a second capability
oracle.

## `platform-primer.md`

What the platform can do today, in the team's own vocabulary. Capability
mode cites a section of this file. Draft §2 (platform pieces) uses its
nouns when it exists, and writes `primer absent` when it does not.

Headings-only skeleton (drop in as `docs/product/context/platform-primer.md`):

```markdown
# Platform primer

## <Area>

<!-- What exists today. Nouns the team already uses. No roadmap. -->

## <Area>
```

## `capability-gaps.md`

What the platform cannot do yet, plus the nearest alternative that **does**
work today. Capability mode may propose a one-line entry; it does not write
this file unless asked.

```markdown
# Capability gaps

- <gap>: not available. Nearest alternative that works today: <primer behaviour>.
```

## `golden-path/`

Optional. `docs/product/context/golden-path/*.md`. How this org prefers to
assemble platform pieces. Read if present. Never treat a Golden Path doc as
proof that a capability ships today.

```markdown
# Golden Path: <flow>

## When to use

## Pieces, in primer vocabulary

## What this is not
```

## Rule

If `platform-primer.md` is missing, capability mode answers `Cannot confirm`
and names that path. It does not answer `Yes today`, `No today`, or `Partly`
from memory.
