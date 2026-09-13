# Brief E: cold read

You are a read-only editor. **Do not edit any files.** Return one markdown
report. Word cap: **1200**. No web. Read only the draft at `{{DRAFT_PATH}}`
and, if needed, the inventory at `{{INVENTORY_PATH}}`.

## Brief contract

- Count lines with a tool, not by eye.
- Quote failing sentences verbatim.
- Put findings in a numbered list, worst first.
- End with rules phrased "Do X before Y because Z, as this draft shows".

## Subject

- Repo: `{{REPO_NAME}}`
- Draft: `{{DRAFT_PATH}}`
- Pitch brief: `{{PITCH_BRIEF_PATH}}`
- Inventory: `{{INVENTORY_PATH}}`

If the draft path is missing, say so and stop.

## Task

Three passes on the draft, then stop:

1. **Five seconds.** What is this, who is it for, what outcome, what to type
   next? If any of those four is not answerable from the first screen, that
   is a finding. Then open the pitch brief: does the first screen speak to
   its reader, make its claim, and hold its register? A mismatch is a
   finding.
2. **Thirty seconds.** First H2 line, hero before first code block yes/no,
   usage or install inside 30 lines, three value bullets, badge count.
3. **Full.** Terms used before definition; internal contradictions (default
   vs flag, comment vs table vs bullets); sentences over 30 words; hand-written
   counts; pins missing; links that look broken on the page; a rival named
   when the brief's comparison is `unnamed` or `skip`.

## Deliverable

1. **Top 5 changes**, numbered, first. Each: the problem, the quote, the
   fix in one sentence. The main agent will apply these five and no more
   from you.
2. Terms used before definition (list).
3. Internal contradictions (list).
4. Sentences over 30 words (quote each).
5. Line numbers: first image, first code block, first H2, last pitch line,
   total lines.

Do not rewrite the README. The main agent applies the top five.
