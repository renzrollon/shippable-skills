# README skeleton

Fix section order and a line budget per section before writing a word. This
is the shape the 2026-09-13 Interlock run converged on, widened so the three
sections that assumed a CLI swap by archetype.

Targets: pitch (sections 1 to 6) complete within 30 rendered lines and about
660 px; whole README 100 to 150 lines; first H2 no later than line 25.
`PITCH COMPLETE BY` is the last line of section 6, which must equal or
precede the first H2.

Do not put an H2 inside the pitch. The H1 is the name; the tagline is bold
prose; usage is a fence; value is a list.

| Order | Section | Budget | Must contain |
|-------|---------|--------|--------------|
| 1 | H1 | 1 line | The name only |
| 2 | Tagline | 1 to 2 lines, bold | What it is, for whom, the outcome, in the pitch brief's register. Under 20 words. The category word (for search). The host or platform only when the archetype has one. No dependency names |
| 3 | Badges | one row, 4 max | Version (only if published), CI, the hardest compatibility constraint as a static badge, license. No stars, downloads, or chat at a young version |
| 4 | Hero | 1 image | Before any code block. Shows the outcome or the mechanism, not the architecture. Cap ~300 px rendered if a usage block must also fit; ~500 px if the image carries the pitch itself. Explicit `width`. |
| 5 | Usage block | 2 to 4 lines | Swaps by archetype (table below). Usage before install: four of ten exemplars do it |
| 6 | Value bullets | 3, each 2 sentences max | The three strongest facts, the brief's claim first. Bold lead words. No aphorisms |
| 7 | Install | 15 to 25 lines | Requirements in one sentence with a link to the full table; the copy-paste commands; the once-per-repo step; a link to the first-hour doc |
| 8 | The flow / How it works | 10 to 15 lines | Swaps by archetype (table below) |
| 9 | Why this | 5 to 6 bullets | Each bullet one differentiator, one link to the doc that proves it |
| 10 | How it compares | 3 short paragraphs | Follows the brief's comparison field. `named`: name the rivals, state the axis, state the trade. `unnamed`: axis and trade, no names. `skip`: drop the section |
| 11 | Experimental / status | 5 to 8 lines | Anything a test pins that does not fit above lives here, one job per sentence |
| 12 | Docs index | one table | Every doc, one line each |
| 13 | Development | 5 lines | Swaps by archetype (table below). Link `CONTRIBUTING.md` |
| 14 | Credits and license | 1 to 2 lines | |

Drop a section that has nothing true to say (no credits to list, no
experimental surface). Do not drop Install, the docs index, or license.

Pinned strings that tests assert on may live in section 5, 7, or 11, but they
stay in this file.

## Archetype swaps

The pitch brief's archetype picks one row. Sections 5, 8, and 13 take the
shape in that row; every other section is the same for all archetypes.

| Archetype | 5 Usage block | 8 The flow / How it works | 13 Development |
|-----------|---------------|---------------------------|----------------|
| `cli` | The commands the reader will type, with comments that say what happens | A table of the user-facing subcommands, one line each | Clone, test, run the binary from source |
| `library` | The import plus the three to six lines that produce the outcome | The two or three entry points a first user touches, one line each | Clone, test, build |
| `service` | How to start it (one command or `docker run`) and the first request | The endpoints or the request and response loop | Clone, test, run locally; env vars live in the docs table |
| `action-or-plugin` | The install line plus the invocation (a workflow step, a slash command) | What the host does when it runs the thing | Clone, test, load into the host |
| `app` | How to open it (URL, download, or one command) | The main screens, or the loop the user repeats | Clone, test, run the dev server |
| `research-or-dataset` | How to load or reproduce (one command or a snippet) | Inputs, outputs, and the pipeline between them | Reproduce, then cite |

The tagline names a host or platform for `action-or-plugin`, and for a
`cli` or `library` bound to one runtime. It does not for the rest.
