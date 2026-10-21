# explore

**Think before anyone designs.** Read-only reconnaissance that fans out when the question is broad, then merges what came back into one picture.

```text
how does auth work end to end across the api and the worker?
what breaks if we lowercase emails on write?
Redis or SQLite for this cache? explore it
explore --autonomous <question>
```

- **Fans out only when it pays.** Two to five investigators with disjoint scopes for multi-subsystem questions, option comparisons, cross-file tracing, and shared-value changes. A single-file question stays single-threaded.
- **Says what it did.** Every run prints `investigation: fan-out`, `sequential`, or `single`. A host with no subagent tool runs the same scopes one after another.
- **Synthesizes, never relays.** Overlaps merged, gaps named, contradictions surfaced with the evidence on each side.
- **Never writes code.** Ask it to build and it declines, then offers to save the finding as a brief.

The agent reaches for it when a question needs mapping first.

## Install

```bash
npx skills add renzrollon/shippable-skills
```

Pick the hosts you use. Claude Code plugin path and the "do not install twice" rule are on the [collection README](../../../README.md).

## More

- [Human docs](../../../docs/engineering/explore.md): when to reach for it, common questions, what "working" looks like
- [Agent instructions](./SKILL.md): what the model follows once it runs
- [Changelog](./CHANGELOG.md)
