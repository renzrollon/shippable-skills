# Brief A: category survey

You are a read-only researcher. **Do not edit any files in the repository.**
Return one markdown report. Word cap: **1800**. If a fetch fails, say so and
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
- Category: `{{CATEGORY}}` (the pitch brief's category word)
- Archetype: `{{ARCHETYPE}}`
- Seed repos (optional, may be empty): `{{SEED_REPOS}}`
- Root: `{{ROOT}}`

## Task

Survey about 10 top repositories in this category and archetype (use the
seed list, then fill from what you know and can fetch). For each, capture the first screen
of its README.

## Deliverable

1. Per-repo first-screen table: repo, README line count, line of first
   image, line of first code block, line of first H2, line of install or
   usage, quoted tagline, badge count.
2. Median length.
3. 8 to 10 transferable rules (shape, not slogans).
4. 3 anti-patterns, each named to a repo you fetched.

Do not recommend file edits. The main agent writes.
