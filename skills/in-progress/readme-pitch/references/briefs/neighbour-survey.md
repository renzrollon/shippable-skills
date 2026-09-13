# Brief B: neighbour survey

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
- Neighbour / competitor repos (owner/repo, comma-separated; may be empty):
  `{{NEIGHBOUR_REPOS}}`
- Root: `{{ROOT}}`

If `{{NEIGHBOUR_REPOS}}` is empty, return a three-line report that says you
were skipped because no neighbours were named, and stop. Do not pick rivals
from memory.

## Task

For each named neighbour, fetch its README and answer: why would I use this,
in the first ten lines? How do they show the install (or usage) command?

## Deliverable

1. Same first-screen table as brief A, for these repos only.
2. Per repo: the "why would I use this" answer in ten lines or fewer,
   quoted or closely paraphrased with a citation.
3. How each shows the install or usage command (fence, one-liner, copy
   button prose, delayed until later).
4. 5 to 8 transferable rules about comparison, naming rivals, and install
   placement.

Do not recommend file edits. The main agent writes. Do not claim a fact you
did not fetch.
