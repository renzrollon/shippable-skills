# session-handoff

**Save where this session stands, before the context goes.** The next session resumes from a file instead of re-deriving every decision.

```text
/session-handoff
/session-handoff auth-refactor
/session-handoff --handoff-dir docs/handoff
```

- **Nine fixed sections.** Progress, decisions, rejected alternatives, files touched, verified versus assumed, do-not-redo, blockers, next steps, and skills to invoke.
- **Stranded work first.** Uncommitted files, unpushed commits, and running jobs are listed before you clear anything.
- **Pointers, not copies.** Specs, plans, and commits are referenced by path or short SHA.
- **Secrets never land.** Tokens, keys, and connection strings are replaced with a placeholder naming their kind.
- **Asks before it teaches your repo.** Up to three reusable rules are proposed as exact lines for your instruction file, and nothing is written without a yes.

You type it. The agent will not start a handoff on its own.

## Install

```bash
npx skills add renzrollon/shippable-skills
```

Pick the hosts you use, then type `/session-handoff`. Claude Code plugin path and the "do not install twice" rule are on the [collection README](../../../README.md).

## More

- [Human docs](../../../docs/productivity/session-handoff.md): when to reach for it, common questions, what "working" looks like
- [Agent instructions](./SKILL.md): what the model follows once you invoke it
- [Changelog](./CHANGELOG.md)
