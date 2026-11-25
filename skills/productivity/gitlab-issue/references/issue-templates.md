# Issue title and body

This file is the one source for what goes in an issue. Read it whole before writing.

Contents:

- [Rules for every body](#rules-for-every-body)
- [Title](#title)
- [Feature or change](#feature-or-change)
- [Bug](#bug)
- [Example: feature](#example-feature)
- [Example: bug](#example-bug)

## Rules for every body

- **Two readers.** Above the `<details>` blocks the reader is a product owner or QA tester, so write plain words. Nothing you add from the repo goes there as a file path, route, table or column name, environment variable name, or code. Paraphrase a technical Purpose: when it names a database table, describe the behaviour without the table name.
- **Requester text as given.** Steps, URLs, paths and error text the requester supplied stay exactly as given, even when they look technical.
- **Never guess.** A section the request and the context cannot fill reads `Not stated`. That covers `Why`, `Who is affected`, and both `Environment` lines. Do not make up a reason, and do not work out an environment from a URL or from the repo.
- **Fixed sections.** Section names and their order are fixed. `Open questions` and `Logs` appear only when they have content. Every other section is always present.
- **Jira key.** If the request has a Jira-style key such as `PROJ-123`, the first line of the body is that key. Otherwise there is no such line.
- **No context.** With no project context, cite no capability or path, write Related as `Not checked (no project context)`, and leave the technical notes block out.
- **No footer.** Add no authorship footer.

## Title

One plain line naming the change, or for a bug the symptom. A bug title starts with `Bug: `. A feature title has no prefix. A title the requester gives is kept exactly as given, with `Bug: ` added in front for a bug that lacks it.

## Feature or change

```
PROJ-123
## Summary
## Why
## Who is affected
## Today
## Wanted
## Acceptance criteria (proposed)
## Open questions
## Related
<details><summary>Technical notes (for developers)</summary>

</details>
```

- **Summary**: one plain sentence saying what is asked for. The reason goes under Why, not here.
- **Why**: the problem or goal behind the request. Use only a reason the request gives. With none, `Not stated`.
- **Who is affected**: a persona from the index, else the role in the request, else `Not stated`.
- **Today**: how it behaves now, in plain words. When an outline scenario covers behaviour the request changes, name that behaviour and its capability here.
- **Wanted**: the change, in plain words.
- **Acceptance criteria (proposed)**: checkboxes, each `- [ ] WHEN ... THEN ...`, at least two. One states the new behaviour. One states an edge case or a behaviour that must stay the same. Name a role in the WHEN only when `Who is affected` names one, and use that same role. The heading keeps the word `(proposed)` because you drafted these from a short request and nobody has agreed them yet.
- **Open questions**: checkboxes, one per gap someone must close before work starts. Ask for the reason when `Why` reads `Not stated`. Add one for each choice you made in the criteria that the request does not settle. Ask only, do not answer. Leave the section out when there are none.
- **Related**: matched capability names, any active change that overlaps, and any known-issue or backlog title that may be a duplicate with its doc path. A possible duplicate never stops the issue. With context and no match, write `None found`. With no context, write `Not checked (no project context)`.
- **Technical notes**: first a line `Context read at` followed by the commit in backticks, or by `(no commit)` when the context directory had none. Then requirement titles, then repo-relative spec and docs paths in backticks, such as `openspec/specs/<name>/spec.md` and `docs/<file>.md` under a heading name. No code, no invented file names, no web links built from a guessed branch. With no context, leave the block out.

## Bug

````
PROJ-123
## Summary
## Who is affected
## Environment
## Steps to reproduce
## Expected
## Actual
## Acceptance criteria (proposed)
## Open questions
## Related
<details><summary>Logs</summary>

```text
<pasted output, unchanged>
```

</details>
<details><summary>Technical notes (for developers)</summary>

</details>
````

- **Environment**: two lines. `- Seen in:` is where the requester saw it (environment, browser, device or version), as given. `- Worked before:` is yes with when, or no, as the request says. Each reads `Not stated` when the request does not say.
- **Steps to reproduce**: the requester's steps as given. With none, write that the requester did not give steps. Never invent them.
- **Expected**: what should happen. When an outline scenario specifies different behaviour, name that behaviour and its capability here.
- **Actual**: what happens. An error message of five lines or fewer stays here exactly as given.
- **Acceptance criteria (proposed)**: at least two checkboxes. One states the fixed behaviour. One states a neighbouring case that must still work after the fix.
- **Open questions**: ask for the steps when the requester gave none, and ask where it was seen and whether it worked before when an `Environment` line reads `Not stated`. The feature rules cover the rest.
- **Logs**: only when the requester pasted output longer than five lines (log lines, a stack trace, console output). Put it unchanged in a fenced `text` block inside this `<details>` block, placed before the technical notes, and write `Log attached below.` under Actual. With no such output, leave the block out.
- The other sections follow the feature rules. A bug has no `Why` section.

## Example: feature

Request: `create a gitlab issue for PROJ-123: let admins export only the filtered invoices, month-end checks take too long with the full file`

Title: `Export only the filtered invoices`

```
PROJ-123
## Summary
Let admins download only the invoices that match the filters on screen.

## Why
Month-end checks take too long because admins have to trim the full file by hand.

## Who is affected
Billing admin

## Today
The export (capability billing-export) always downloads every invoice, whatever filters are applied.

## Wanted
The download covers only the rows the admin currently sees.

## Acceptance criteria (proposed)
- [ ] WHEN a billing admin exports with a date filter THEN only invoices in that range are in the file
- [ ] WHEN a billing admin exports with no filter THEN every invoice is in the file, as today

## Open questions
- [ ] Should the file keep the sort order shown on screen? The request does not say.

## Related
- Capability: billing-export
- Possible duplicate: "Export ignores filters" (docs/KNOWN_ISSUES.md)

<details><summary>Technical notes (for developers)</summary>

- Context read at `3f2a91c`
- Requirement: Download current view
- `openspec/specs/billing-export/spec.md`
- `docs/KNOWN_ISSUES.md`, "Export ignores filters"

</details>
```

## Example: bug

Request: `log a bug: the delete confirmation box keeps the old text. Open https://app.example.com/items, delete the first item and confirm, then delete the second item`

Title: `Bug: delete confirmation box keeps the old text`

```
## Summary
The confirmation box shows the previous item's text when a second item is deleted.

## Who is affected
Not stated

## Environment
- Seen in: Not stated
- Worked before: Not stated

## Steps to reproduce
1. Open https://app.example.com/items
2. Delete the first item and confirm
3. Delete the second item

## Expected
The box starts empty for each deletion (capability item-delete, scenario "Fresh confirmation").

## Actual
The box still holds the text typed for the first deletion.

## Acceptance criteria (proposed)
- [ ] WHEN a second item is deleted THEN the confirmation box is empty
- [ ] WHEN the first item is deleted THEN the box still asks for the confirmation text

## Open questions
- [ ] Where was this seen (environment and browser), and did it work before?

## Related
- Capability: item-delete

<details><summary>Technical notes (for developers)</summary>

- Context read at `3f2a91c`
- Requirement: Confirm before delete
- `openspec/specs/item-delete/spec.md`

</details>
```
