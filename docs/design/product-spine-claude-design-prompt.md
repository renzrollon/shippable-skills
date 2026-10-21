# Claude Design prompts: product-spine sell sheets

Two artboards. Same visual system as the `/session-retro` card (attach that
JPEG as the style reference). Export each artboard as a JPEG.

Paste **Prompt A**, export `product-spine-card.jpg`. New design, paste
**Prompt B**, export `product-spine-map.jpg`. Do not merge them into one
scrolling page.

No em-dashes anywhere in the rendered copy. Use commas, colons, periods, or
a middot (`·`). No gradients, no drop shadows, no emoji, no stock
illustration, no mock laptop, no people.

---

## Shared visual system (both prompts)

Reproduce the session-retro card, not a generic startup landing page.

**Format.** Portrait trading card, 4:5, generous off-white canvas
(`#F4F1EA` or `#F5F5F5`), dark charcoal text (`#2C2C2C`), muted copper
accent (`#A67C52`) for hairlines, labels, checkbox marks, and the install
button border. Light gray rules (`#D9D4CC`) for column splits. Ample
margins. Flat, editorial, print-like.

**Type.**
- Slash command and install command: monospace (SF Mono / JetBrains Mono).
- Headline: high-contrast serif (Tiempos / Newsreader / Georgia), large,
  tight tracking.
- Section labels: 11px-ish all-caps copper sans, letterspaced.
- Body: small humanist sans, charcoal, two sentences max.
- Meta (`v0.3.0`, `SHIPPABLE SKILLS · MIT`, host list): small gray sans.

**Chrome (every card).**
- Top left: `/product-spine` in bold mono, then `v0.3.0` in small gray.
- Top right: `SHIPPABLE SKILLS · MIT` small all-caps.
- Thin full-width hairline under the header.
- Footer left: rounded rect, 1px copper border, no fill, mono text
  `npx skills add renzrollon/shippable-skills`
- Footer right, two lines gray:
  `Cursor · Copilot · Codex`
  `Claude Code · skills.sh`

Audience is engineers and product managers. The card must make both feel
spoken to: engineers get files and rules, PMs get strategy and what is next.

---

## Prompt A (sell card)

Design one portrait card. Match the session-retro reference layout beat for
beat: header, hero, three-column metrics box, labelled rule row, checkbox
grid, footer.

**Headline (serif, large):**
An engineer who can act as product owner.

**Accent:** a short copper hairline to the left of the body, same as the
reference.

**Body (two sentences):**
Most PM skills fill a template. This one reads the repo, fans out, and
proposes the next features, improvements, and fixes. Pick a thread and it
lands on a greppable spine: one-pager, epics, briefs.

**Metrics box** (thin gray border, three columns, copper all-caps labels):

| Label | Value |
| --- | --- |
| DEFAULT | Threads |
| LANDS AS | Status: draft |
| KINDS | Feature · Improvement · Fix |

Values in serif. Do not invent extra stats or fake scores.

**Rule row**, centered small all-caps gray, hairlines flanking:
THE CONTRACT, NOT A PRD

**Checkbox grid**, two columns, copper square with an `x` (same mark as the
reference), mono or small sans items. Exact strings:

Left:
- `artefacts only, never code`
- `never invent the platform`

Right:
- `Status: draft until you flip`
- `primer, or Cannot confirm`

Do not show SkillGantry pass/fail numbers. This skill has not run that gate
yet. Do not write `validate`, `evaluate`, `security`, or `release` on this
card.

Then the shared footer.

---

## Prompt B (mechanism card)

Same chrome, type, and colors as Prompt A. Different middle: a diagram, not
a metrics box. Still a quiet editorial card, not a whiteboard photo and not
a colorful flowchart.

**Headline (serif, large):**
What to build next, then where it lives.

**Accent copper hairline + body (two sentences):**
Three read-only gathers run in parallel. You get a Now / Next / Later map.
Pick a number; draft writes a file. The change-proposal skill does not
start until you flip a brief to ready-to-propose.

**Block 1: FAN-OUT**
Copper all-caps label `FAN-OUT`. Three equal columns separated by gray
hairlines, no filled boxes:

- `SPINE`
  One-pager, epics, briefs, primer. Invent nothing.
- `SURFACES`
  README, routes, TODOs. Cite paths.
- `FRICTION`
  Gaps, orphaned ladders, users stuck.

A single copper downward mark (a short vertical rule plus a small chevron,
not a fat arrow) into block 2.

**Block 2: THREAD MAP**
Copper all-caps label `THREAD MAP`. Three lanes, hairline columns, serif
lane titles `Now` `Next` `Later`. One example node per lane, numbered, kind
in copper small-caps, title in charcoal serif. Exact strings:

- Now: `1  Fix  retry failed payment`
- Next: `2  Feature  saved payment methods`
- Later: `3  Improvement  clearer failure copy`

Under the lanes, one quiet line of sans:
Pick a number to draft. Nothing is written until you do.

**Block 3: THE LADDER**
Copper all-caps label `THE LADDER`. A vertical stack, left-aligned, like a
spine, not a tree. Three rows, each a path in mono and a role in serif:

```
one-pager    docs/product/one-pager/current.md
             §3 bets · §4 initiatives
        ↑ Ladders to
epic         docs/product/epics/*.md
             feature in flight
        ↑ Part of
brief        docs/product/briefs/*.md
             what / why for a change
```

Keep the up-arrows and the words `Ladders to` / `Part of` (those are the
grep tokens). Do not add a fourth artefact. Do not draw a `threads/` folder.

Then the shared footer.

If anything fights the session-retro reference, the reference wins: same
margins, same copper, same checkbox language on Prompt A, same install pill.
