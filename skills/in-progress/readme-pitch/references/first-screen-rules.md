# First-screen rules

Distilled from three surveys covering about 30 repositories on 2026-09-13
(the Interlock README redesign). Each rule names the repo that demonstrated
it so a maintainer can re-check it.

Use this file when briefs A, B, and C were skipped (`--no-research`, or the
host has no web tool). Do not invent competitor claims from memory; these
rules are about shape, not about named rivals.

## Above the fold

1. The one-sentence "what it is" goes before the badge row. Codex CLI states
   it on line 1 with no logo; crewAI buries it at line 58 under badges and nav.
2. The hero image goes before the install snippet, because the reader decides
   whether to install from it. aider: hero line 15, install line 105.
   OpenHands: 29 and 70. Codex: 3 and 18.
3. The hero shows the product running or the outcome, not the architecture.
   aider's animated terminal, OpenHands' screenshot, Claude Code's demo GIF
   at line 11. No repo in the top set leads with a box diagram; AutoGen's
   concept art sits at line 174 of 241.
4. Set an explicit width on the hero (OpenHands 100%, Codex 80%). Without one
   it renders at native size.
5. The install or usage command lands inside the first 30 lines (LangGraph 26,
   Codex 18, openclaw 24). Four of ten excellent-README tools lead with usage
   rather than install (bun, gum, biome, tauri).
6. One tagline sentence that names the reader's problem; the title itself
   does semantic work (openclaw's H1 is the tagline).

## Length and order

7. Pitch under 35 lines before the first H2 (median 36 across the harness
   set; the 122-line outlier is the worst read).
8. Whole README 60 to 160 lines. The most-starred repo in the harness set is
   81 lines. The long ones inline tutorials and FAQs; the short ones ship one
   command and a link list.
9. No table of contents in a README short enough not to need one; GitHub
   renders an outline.
10. Requirements go at the install step, not above the pitch (OpenSpec puts
    "Requires Node 20.19+" directly above `npm install`; spec-kit defers
    Prerequisites to line 465 of 492).
11. Name competitors explicitly; the comparison happens whether or not you
    host it (OpenSpec dispatches Spec Kit, Kiro and "nothing" in 7 lines; six
    of eleven neighbours ship no comparison). If research was skipped, name
    competitors only when the user supplied them.
12. Link the philosophy out; the essay converts nobody who has not installed
    (openclaw reduces it to one link and reaches Install by line 24).

## Badges

13. One rendered row, 4 or fewer. The most-adopted tools carry the fewest
    (ripgrep 3, uv 3, gum 3; Cline and Codex 0). Each badge is evidence a
    reader acts on: version if published, CI, the hardest compatibility
    constraint, license. Omit stars, downloads, chat, coverage, and sponsor
    badges at a young version.

## Anti-patterns seen

- Badge and sponsor walls before the title (claude-code-templates: 58 lines
  and a sponsor's install command before the project's own H1).
- The collapsed value proposition: social proof hidden in `<details>` while a
  philosophy block takes the first screen (OpenSpec; its real pitch sits at
  line 188 of 257).
- Dated announcements and long TOCs in permanent prime space (spec-kit's
  anniversary note plus 20-line TOC between tagline and first useful sentence).

## Pixel budget

GitHub, ~900 px column, 1080p screen, ~660 px of README visible on the
README view.

| Element | px |
|---------|-----|
| H1 | 60 |
| One-line paragraph | 40 |
| Badge row | 36 |
| Code block | 24 per line + 48 |
| List item | 24 |
| Hero at 900 wide | 900 / aspect ratio |

On the repository home page the README starts below the file list, so with
15 or more root entries nothing in the README is above the fold there; the
repository description and topics do that job. Say this in the report.
