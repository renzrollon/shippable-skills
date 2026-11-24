# Issue body templates

Two bodies: feature or change, and bug. Section names are fixed. Write the plain-language sections for a product owner or QA tester. Content you add from the repo goes in as plain words: no file paths, routes, table or column names, environment variable names, or code above the `<details>` block. Keep requester-supplied steps, URLs and paths exactly as given.

If the request has a Jira-style key such as `PROJ-123`, the first line of the body is that key. Otherwise there is no such line.

## Feature or change

```
PROJ-123
## Summary
## Who is affected
## Today
## Wanted
## Acceptance criteria
## Related
<details><summary>Technical notes (for developers)</summary>

</details>
```

- **Summary**: two or three plain sentences.
- **Who is affected**: a persona from the index, else the role in the request, else `Not stated`.
- **Today**: how it behaves now, in plain words. When an outline scenario covers behaviour the request changes, name that behaviour and its capability here.
- **Wanted**: the change, in plain words.
- **Acceptance criteria**: checkboxes, each `- [ ] WHEN ... THEN ...`. At least one states the new behaviour.
- **Related**: matched capability names, any active change that overlaps, and any known-issue or backlog title that may be a duplicate with its doc path. A possible duplicate never stops the issue.
- **Technical notes**: requirement titles, then repo-relative spec and docs paths in backticks, such as `openspec/specs/<name>/spec.md` and `docs/<file>.md` under a heading name. No code, no invented file names, no web links.

## Bug

```
PROJ-123
## Summary
## Who is affected
## Steps to reproduce
## Expected
## Actual
## Acceptance criteria
## Related
<details><summary>Technical notes (for developers)</summary>

</details>
```

- **Steps to reproduce**: the requester's steps as given. With none, write that the requester did not give steps. Never invent them.
- **Expected**: what should happen. When an outline scenario specifies different behaviour, name that behaviour and its capability here.
- **Actual**: what happens.
- The other sections follow the feature rules. The title starts with `Bug: `.

## Example: feature

```
PROJ-123
## Summary
Admins want to download only the invoices matching the filters on screen.

## Who is affected
Billing admin

## Today
The export (capability billing-export) always downloads every invoice, whatever filters are applied.

## Wanted
The download covers only the rows the admin currently sees.

## Acceptance criteria
- [ ] WHEN an admin exports with a date filter THEN only invoices in that range are in the file
- [ ] WHEN no filter is applied THEN every invoice is in the file

## Related
- Capability: billing-export
- Possible duplicate: "Export ignores filters" (docs/KNOWN_ISSUES.md)

<details><summary>Technical notes (for developers)</summary>

- Requirement: Download current view
- `openspec/specs/billing-export/spec.md`
- `docs/KNOWN_ISSUES.md`, "Export ignores filters"

</details>
```

## Example: bug

Title: `Bug: delete confirmation box keeps the old text`

```
## Summary
The confirmation box shows the previous item's text when a second item is deleted.

## Who is affected
Not stated

## Steps to reproduce
1. Open https://app.example.com/items
2. Delete the first item and confirm
3. Delete the second item

## Expected
The box starts empty for each deletion (capability item-delete, scenario "Fresh confirmation").

## Actual
The box still holds the text typed for the first deletion.

## Acceptance criteria
- [ ] WHEN a second item is deleted THEN the confirmation box is empty

## Related
- Capability: item-delete

<details><summary>Technical notes (for developers)</summary>

- Requirement: Confirm before delete
- `openspec/specs/item-delete/spec.md`

</details>
```
