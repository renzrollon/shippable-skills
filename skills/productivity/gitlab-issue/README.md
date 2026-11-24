# gitlab-issue

**Turn a one-line request into a GitLab issue that knows your project.** It reads the project's OpenSpec specs and docs, writes the issue in plain language, and collapses developer detail at the end.

```text
create a gitlab issue: export fails for large invoices
raise a bug on GitLab for the login timeout
draft an issue for bulk refunds
```

- **Grounded.** Capability names, changes, and paths come from the project's own files, never invented.
- **Readable first.** Product owners read the top. Technical notes sit in a collapsed `<details>` block.
- **Shows its gaps.** Anything the request left out reads `Not stated`, the criteria are marked proposed, and open questions are listed for whoever triages.
- **Safe to run.** No tokens handled, no files written into your checkout, and wording like "draft" creates nothing.
- **Creates where it can.** A host issue tool first, then `glab`, else it hands back the draft.

The agent reaches for it when you explicitly ask to file, raise, log, or draft an issue. It stays out of the way for questions such as "what issues are open?".

## Install

```bash
npx skills add renzrollon/shippable-skills
```

Pick the hosts you use. Claude Code plugin path and the "do not install twice" rule are on the [collection README](../../../README.md).

## More

- [Human docs](../../../docs/productivity/gitlab-issue.md): when to reach for it, common questions, what "working" looks like
- [Agent instructions](./SKILL.md): what the model follows once it runs
- [Changelog](./CHANGELOG.md)
