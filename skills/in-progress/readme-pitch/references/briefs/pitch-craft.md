# Brief C: pitch craft

You are a read-only researcher. **Do not edit any files in the repository.**
Return one markdown report. Word cap: **2000**. If a fetch fails, say so and
move on.

## Brief contract

- Fetch raw READMEs from
  `https://raw.githubusercontent.com/OWNER/REPO/HEAD/README.md`. Fall back
  to branch `main`, then `master`.
- Count lines with a tool, not by eye.
- Quote taglines verbatim.
- Put per-repo data in tables.
- End with rules phrased "Do X before Y because Z, as REPO shows".
- Every claim cites a README you fetched. Do not invent a competitor fact.

## Subject

- Repo: `{{REPO_NAME}}`
- Description: `{{REPO_DESCRIPTION}}`
- Category: `{{CATEGORY}}`
- Archetype: `{{ARCHETYPE}}`
- Pitch brief: `{{PITCH_BRIEF_PATH}}`
- Root: `{{ROOT}}`

Suggested exemplars of excellent READMEs (fetch what you can; skip failures):
bun, gum, biome, tauri, uv, ripgrep, aider, openai/codex, openclaw,
langchain-ai/langgraph. Swap in closer category cousins when they are clearly
better fits.

## Task

Read the pitch brief first. Its reader, claim, and register are decided;
you design for them, you do not reopen them. Then read the first 30 lines
of about 10 tools known for excellent READMEs, preferring the same
archetype. Design a first-screen for `{{REPO_NAME}}` from what those lines
do, not from taste.

## Deliverable

1. First-30-lines table: repo, what occupies lines 1 to 30, usage-before-install
   yes/no, hero yes/no.
2. A pixel-budget skeleton for this repo (H1, tagline, badges, hero, usage,
   value), with the usage block in the archetype's shape, and a running px
   total against a 660 px first screen. Use:
   H1 60, one-line paragraph 40, badge row 36, code block 24 per line + 48,
   list item 24, hero at 900 wide = 900 / aspect ratio.
3. 6 taglines, one per register (problem, outcome, category, host, verb,
   deadpan). Each under 20 words, each speaking to the brief's reader and
   making its claim. No dependency names. Mark the one in the brief's
   register; the main agent leads with it and may show the rest.
4. 3 three-bullet value blocks. Bold lead words. No aphorisms. Facts only
   this repo can defend.
5. Badge discipline: which 4 or fewer, and which to omit.
6. Hero recommendation: screenshot, designed terminal frame, or "none yet,
   write a design prompt". Not an architecture diagram.

Do not write the README. The main agent writes.
