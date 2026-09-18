# Contributing

This repo is a skills collection. Promoted skills live in `engineering/` and `productivity/`. Conventions for buckets, docs pages, and invocation polarity are in [CLAUDE.md](./CLAUDE.md).

## Develop

Clone the repo. Edit the skill folder you own. Keep `SKILL.md` under 500 lines. Shared references stay one level deep in that skill's `references/`.

Validate the plugin:

```bash
npm run validate
```

That runs `claude plugin validate . --strict`. Skill-local evals and lint live in each skill's `evals/` and are run by the release pipeline below, not by a root test script.

## Release gate

The collection is maintained the way [SkillGantry](https://github.com/kevinlin/skill-gantry) maintains a skills collection: `validate → evaluate → security`, then a release that packages the skill and installs its own archive before any consumer sees it. The public skills set that pipeline was built around is [kevinlin/skills](https://github.com/kevinlin/skills).

| Stage | Tool |
| --- | --- |
| 1 · validate | [skill-lint](https://github.com/himself65/skill-lint) |
| 2 · evaluate | [skill-up](https://github.com/alibaba/skill-up) |
| 3 · security | [SkillSpector](https://github.com/NVIDIA/SkillSpector) |
| 4 · optimise | SkillHone (optional; skip when the tool is not wired in) |
| 5 · release | [skills](https://github.com/vercel-labs/skills) installer, archive verified installable |

Bump `.claude-plugin/plugin.json` `version` together with `package.json` `version` on release.

## session-retro 0.1.0 gate (21 Aug 2026)

Recorded in [skills/productivity/session-retro/CHANGELOG.md](./skills/productivity/session-retro/CHANGELOG.md). Evaluate cases:

| Case | What it checks |
| --- | --- |
| `current-session-report` | Default retro opens with a shape, an `N/10` score, and the handoff index |
| `focus-tokens` | Token focus still snapshots the session and never dumps a wiring table |
| `focus-wiring` | Wiring focus stays honest about what this session actually called |
| `refuse-transcript-reread` | A planted on-disk log is refused; canary strings never appear |

The SkillSpector suppress on that run is rule P2 on an HTML comment in the wire-in template: visible author guidance, not a hidden agent directive. The baseline file is local-only (gitignored) and is not published with the skill.
