# session-primer

**Start a session already oriented.** One read-only sweep, one short briefing: where you are, what is open, and what to do next.

```text
where was I
catch me up
brief me
```

- **Fixed format.** A `## Session Briefing` block of five to eight lines: branch, last activity, uncommitted files, open plan items, resume point, next step.
- **Reads the right sources.** Git state, plan docs with unchecked boxes, the newest handoff file across every handoff directory, and your instruction file.
- **Read-only.** It never edits, fetches, stages, or switches branches.

The agent reaches for it at session start or when you ask to be caught up. It stays out of the way when your question names a specific file or feature.

## Install

```bash
npx skills add renzrollon/shippable-skills
```

Pick the hosts you use. Claude Code plugin path and the "do not install twice" rule are on the [collection README](../../../README.md).

## More

- [Human docs](../../../docs/productivity/session-primer.md): when to reach for it, common questions, what "working" looks like
- [Agent instructions](./SKILL.md): what the model follows once it runs
- [Changelog](./CHANGELOG.md)
