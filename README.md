# Shippable Skills


Agent skills other developers can install without guessing. Each one is a folder you own, runs on Cursor, Copilot, Codex, Claude Code, and the rest of the [skills.sh](https://skills.sh) hosts, and ships only after [SkillGantry](https://github.com/kevinlin/skill-gantry) has linted it, run its evals, scanned it, and proven the archive actually installs.

The first skill is **[session-retro](./skills/productivity/session-retro/SKILL.md)**: score the conversation you are still in, flag where tokens went, and fold the repeatable bits back into the skills that conversation called.

## Install

```bash
npx skills add renzrollon/shippable-skills
```

Pick the hosts you use. Then type `/session-retro` in any session.

That is the whole setup. The installer writes ordinary skill files into your project or home directory, so you can read them, edit them, and keep the next lesson. Updates later: `npx skills update`.

Claude Code can take the same set as a plugin instead. Do not also run the `npx` installer, or every skill lands twice:

```
/plugin marketplace add renzrollon/shippable-skills
/plugin install shippable-skills@shippable-skills
```

## Why session-retro

Most session tools open yesterday's logs and reconstruct a story from a tool-call histogram. By then the reasoning is gone: you can count the reads, not see why each one happened.

`session-retro` has no gather step. The session it scores is the one it is running inside.

- **A shape and a score** while the moments still have names, not after they collapse into counts.
- **Token findings in relative magnitude**, each tied to a real moment and a different next-turn action. It does not invent per-turn token numbers the host never gave it.
- **Wire-ins** that name the file that actually runs, so the workaround you just improvised becomes part of the skill you called. New procedures get a candidate brief, not a `SKILL.md` drafted on the spot.
- **A hard refuse** if you point it at an on-disk transcript. Re-reading a log would re-pay for context it already holds, which is the waste it exists to flag.

You invoke it. The agent will not start a retro in the middle of your work.

Docs: [session-retro](./docs/productivity/session-retro.md).

## Gated before it ships

This repo is maintained the way [SkillGantry](https://github.com/kevinlin/skill-gantry) maintains a skills collection: `validate → evaluate → security`, then a release that packages the skill and installs its own archive before any consumer sees it. The public skills set that pipeline was built around is [kevinlin/skills](https://github.com/kevinlin/skills). The tools behind each stage are [skill-lint](https://github.com/himself65/skill-lint), [skill-up](https://github.com/alibaba/skill-up), [SkillSpector](https://github.com/NVIDIA/SkillSpector), and the [skills](https://github.com/vercel-labs/skills) installer.

`session-retro` **0.1.0**, run 21 Aug 2026:

| Stage | Tool | Result |
| --- | --- | --- |
| 1 · validate | skill-lint 0.2.0 | passed, 0 findings (11 files) |
| 2 · evaluate | skill-up 0.7.0 | passed, **4/4 cases** |
| 3 · security | SkillSpector 2.5.1 | passed, 0 actionable (1 reviewed suppress) |
| 4 · optimise | SkillHone | skipped (tool still being wired in SkillGantry) |
| 5 · release | skills 1.5.21 | passed, archive verified installable |

Evaluate cases, all PASS:

| Case | What it checks |
| --- | --- |
| `current-session-report` | Default retro opens with a shape, an `N/10` score, and the handoff index |
| `focus-tokens` | Token focus still snapshots the session and never dumps a wiring table |
| `focus-wiring` | Wiring focus stays honest about what this session actually called |
| `refuse-transcript-reread` | A planted on-disk log is refused; canary strings never appear |

The security suppress is SkillSpector rule P2 on an HTML comment in the wire-in template: visible author guidance, not a hidden agent directive. The justification lives in [`.skillspector-baseline.yaml`](./skills/productivity/session-retro/.skillspector-baseline.yaml).

## Skills

These split on one axis: who can invoke them. **User-invoked** skills are reachable only when you type them. **Model-invoked** skills can be invoked by you or reached for automatically when the task fits.

### Productivity

**User-invoked**

- **[session-retro](./skills/productivity/session-retro/SKILL.md)**: Retro the current session. Score it against session shapes, flag token waste with next-turn fixes, and propose wire-ins into the skills this conversation actually called.

**Model-invoked**

None yet.

## License

[MIT](./LICENSE)
