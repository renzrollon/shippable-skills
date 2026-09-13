# Brief D: internal audit

You are a read-only auditor. **Do not edit any files in the repository.**
Return one markdown report. Word cap: **2500**. This brief does not use the
web. Work only from the repo at `{{ROOT}}` and the inventory at
`{{INVENTORY_PATH}}`.

## Brief contract

- Count lines with a tool, not by eye.
- Quote strings verbatim (pins, headings, commands).
- Put coverage and facts in tables.
- Cite `file:line` for every consumer and every pin.
- If an inventory item is marked unavailable, leave it unavailable. Do not
  guess.
- End with rules phrased "Do X before Y because Z, as this repo shows".

## Subject

- Repo: `{{REPO_NAME}}`
- README: `{{README_PATH}}`
- Archetype: `{{ARCHETYPE}}`
- Inventory: `{{INVENTORY_PATH}}`
- Root: `{{ROOT}}`

If the inventory file is missing, say so and rebuild the tables from the
repo yourself. Still do not edit files.

## Task

Map every README section to a docs home. Find facts that live only in the
README. Find tests and other files that depend on README strings or anchors.
Verify the command inventory against `--help` and skill frontmatter. Surface
discrepancies (tagline vs package description vs site, unpublished package
vs version badge, hero that contradicts the text, stale counts).

## Deliverable

1. **Coverage map.** README section (heading + line range) to docs anchor
   (file + heading, or "no home").
2. **Orphan facts**, grouped by natural home (CLI reference, CONTRIBUTING,
   CHANGELOG, existing doc, new smallest file). Each fact quoted.
3. **Consumers and pins** with `file:line`. Distinguish: test assertions
   (must stay in README), anchor links (must be repointed), scripts that
   read the file.
4. **Assets.** Images, pixel size if known, whether one can serve as a hero,
   whether any image contradicts the text.
5. **Metadata.** Package name, version, publish state, `files` (does the
   README ship?), CI workflow `name:` values, root entry count.
6. **Verified command or entry inventory**, by archetype. `cli`: every
   shipped binary `--help`. `library`: the exported names. `action-or-plugin`:
   `inputs:` and every skill frontmatter `name`. `service`: the documented
   endpoints or start command. Flag README commands or entries that do not
   exist.
7. **Discrepancies.** Site copy vs tagline, unpublished + version badge,
   derived numbers restated as literals, anything else a rewrite would get
   wrong.

Do not write the README or the docs. The main agent relocates, then drafts.
