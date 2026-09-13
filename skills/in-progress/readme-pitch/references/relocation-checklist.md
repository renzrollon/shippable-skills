# Relocation checklist

Nothing leaves the README until it has a home. Work from brief D's
orphan-fact table. Tick every item; a skipped tick is a lost fact.

## Before any cut

- [ ] Inventory pins file exists (one string per line). Read the assertions;
      they are the contract.
- [ ] Anchor consumers listed (`README(.md)?#` hits in docs, CHANGELOG,
      skills, site).
- [ ] Every orphan-fact group has a destination: an existing heading, or a
      new file still to create.

## Homes

- [ ] Groups with an existing home: extend that doc at the named heading.
      Do not start a parallel file that restates it.
- [ ] Groups with no home: create the smallest number of new files.
      Recurring pair:
      - **CLI and configuration reference** (every subcommand verified
        against `--help`, every environment variable in one table).
      - Root **`CONTRIBUTING.md`** (development commands, conventions,
        release procedure).
- [ ] Dated announcements move to `CHANGELOG.md` (create it if needed), not
      into a new essay.

## Anchors (GitHub slugger, no collapsing)

When you write a new heading, its slug is:

1. Take the heading text (markdown stripped: no backticks, no link markup).
2. Lowercase.
3. Strip punctuation. Keep letters, marks, numbers, connector punctuation
   (underscore), hyphens, and spaces.
4. Trim.
5. Each space becomes a hyphen. **Do not collapse** consecutive hyphens.
   A heading that contains a spaced em dash (U+2014) produces a double
   hyphen: the dash is stripped, both spaces remain.
6. Duplicate headings get `-1`, `-2`, ... suffix (first occurrence unsuffixed).

- [ ] Every old `README.md#<slug>` (or `README#<slug>`) now points at a file
      and heading that exist.
- [ ] Same-file `#<slug>` links inside moved prose were updated too.

Grep that must go quiet for stale README anchors (run from repo root, one
command per call):

```bash
rg -n -g '!node_modules/**' -g '!.git/**' 'README(\.md)?#'
```

## Counts and pins

- [ ] Stale counts removed or derived, never replaced with a new literal.
- [ ] Every pins-file string is still in `README.md` (may have moved to
      another README section, must not have left the file).
- [ ] No test that asserts on README content was edited, weakened, or
      deleted.

## Replacement discipline

Do relocations with **strict single-match** replacements so a target that no
longer matches fails loudly instead of silently skipping.

- Prefer one unique `old_string` per edit.
- Do not `replace_all` unless the string is unique and you intend every hit.
- After the batch, grep each moved fact at its new home. Zero hits is a
  failed relocation, not an optional one.

## After the cuts

- [ ] Run `check-links.mjs` on every touched markdown file.
- [ ] Run `check-pins.sh` on the pins file against `README.md`.
- [ ] Record `MOVED: <file> (<section>), ...` for the Phase 8 block.
