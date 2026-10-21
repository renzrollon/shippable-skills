# product-spine

**Act as product owner from inside the repo.** Threads of work on a map, then a one-pager, epics, and briefs that ladder to each other.

```text
/product-spine
/product-spine draft brief
/product-spine review <file>
/product-spine capability "<question>"
```

- **Threads first.** A bare invocation fans out over the repo and proposes features, improvements, and fixes on a mermaid map. Nothing is written until you pick one.
- **Repo-native spine.** A picked thread lands as a live one-pager, epics, and briefs under `docs/product/`, each pointing at the one above it.
- **Review and capability checks.** It says whether a brief or epic is ready to flip, and answers "can the platform do X today" from the project's own primer. It writes artefacts, never code.

You type it. The agent will not start it in the middle of your work.

## Install

```bash
npx skills add renzrollon/shippable-skills
```

Pick the hosts you use, then type `/product-spine`. Claude Code plugin path and the "do not install twice" rule are on the [collection README](../../../README.md).

## More

- [Human docs](../../../docs/productivity/product-spine.md): when to reach for it, common questions, what "working" looks like
- [Agent instructions](./SKILL.md): what the model follows once you invoke it
- [Changelog](./CHANGELOG.md): 0.3.0 briefs replace tasks
