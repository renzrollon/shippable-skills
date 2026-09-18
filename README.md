# Shippable Skills

**Agent skills other engineers can install on Cursor, Copilot, Codex, or Claude Code, gated before they ship.**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](./LICENSE)

```bash
npx skills add renzrollon/shippable-skills
```

Then type `/session-retro` to score this conversation.

- **The lead skill retros the live session.** [session-retro](./skills/productivity/session-retro/) scores the conversation you are still in and folds repeatable steps back into the skills you called.
- **Install the folder, keep the files.** You keep ordinary skill files in your project or home directory, so the next lesson stays. Updates later: `npx skills update`.
- **Gated before they ship.** The release pipeline ([SkillGantry](https://github.com/kevinlin/skill-gantry)) lints the skill, runs its evals, scans it, and proves the archive installs. The stages live in [CONTRIBUTING.md](./CONTRIBUTING.md).

## Install

The `npx` path needs an [Agent Skills](https://skills.sh) host and `npx`. Claude Code may use the plugin instead.

```bash
npx skills add renzrollon/shippable-skills
```

Then type `/session-retro` in any session. First hour: [session-retro](./skills/productivity/session-retro/).

Claude Code can take the same set as a plugin instead. Do not also run the `npx` installer, or every skill lands twice:

```
/plugin marketplace add renzrollon/shippable-skills
/plugin install shippable-skills@shippable-skills
```

## How it works

The host copies the skill folder. You invoke the skill. The model follows `SKILL.md`.

| You type | What happens |
| --- | --- |
| `npx skills add renzrollon/shippable-skills` | Skill files land in the project or home directory you chose |
| `/session-retro` | The host loads [session-retro](./skills/productivity/session-retro/) and runs the retro on this conversation |
| `/session-retro --focus tokens` | Same snapshot, token section only |
| `/session-retro --focus wiring` | Same snapshot, wire-in section only |

You type `/session-retro`. The agent will not start it in the middle of your work.

## Why this

- **A folder you own**, not a prompt you paste. The installer writes files you can open. See [session-retro](./skills/productivity/session-retro/).
- **A gate, then a release.** Lint, evals, security, then an archive that has been installed once. See [CONTRIBUTING.md](./CONTRIBUTING.md#release-gate).
- **A retro with no gather step.** `session-retro` scores the session it is running inside and refuses an on-disk transcript. See [the docs](./docs/productivity/session-retro.md#the-mechanism).
- **Wire-ins that name the file that runs.** The lesson goes into the skill you called, not a new `SKILL.md` drafted on the spot. See [Where wire-ins land](./docs/productivity/session-retro.md#where-wire-ins-land).
- **Host-neutral by construction.** Cursor, Copilot, Codex, Claude Code, and the rest of the [skills.sh](https://skills.sh) hosts. The Claude plugin is an alternative to `npx`, not a second install.

## How it compares

The axis is installable-and-gated versus copy a `SKILL.md` by hand.

[kevinlin/skills](https://github.com/kevinlin/skills) is the public set the same [SkillGantry](https://github.com/kevinlin/skill-gantry) pipeline was built around. It ships a delivery-lifecycle catalog as a Claude Code plugin (`/plugin marketplace add kevinlin/skills`). For a single skill it says to copy the folder.

This repo is the small set you add with `npx skills add renzrollon/shippable-skills`. The lead skill is a live-session retro, not a spec or review workflow.

The [skills](https://github.com/vercel-labs/skills) CLI is the installer, not a rival collection. [skill-lint](https://github.com/himself65/skill-lint), [skill-up](https://github.com/alibaba/skill-up), and [SkillSpector](https://github.com/NVIDIA/SkillSpector) are the gate tools, not products you install instead of this.

## Status

`session-retro` is the promoted skill. Beta work stays in `skills/in-progress/` and is not in the plugin. The package on npm is not published; install from GitHub via `npx skills add`.

Dated gate results for `session-retro` 0.1.0 (21 Aug 2026) are in its [changelog](./skills/productivity/session-retro/CHANGELOG.md).

## Skills

These split on one axis: who can invoke them. **User-invoked** skills are reachable only when you type them. **Model-invoked** skills can be invoked by you or reached for automatically when the task fits.

### Productivity

**User-invoked**

- **[session-retro](./skills/productivity/session-retro/)**: Retro the current session. Score it against session shapes, flag token waste with next-turn fixes, and propose wire-ins into the skills this conversation actually called.

**Model-invoked**

None yet.

## Docs

| Doc | What it is |
| --- | --- |
| [session-retro](./skills/productivity/session-retro/) | Human README. The URL to share |
| [session-retro docs](./docs/productivity/session-retro.md) | When to reach for it, questions, what working looks like |
| [CONTRIBUTING.md](./CONTRIBUTING.md) | Dev commands, release gate, SkillSpector suppress |
| [CLAUDE.md](./CLAUDE.md) | Bucket rules, invocation polarity, docs contract |

## Development

Clone the repo. Load the skill folder into your host, or run the plugin from this checkout. Validate with `npm run validate`. Details: [CONTRIBUTING.md](./CONTRIBUTING.md#develop).

## License

[MIT](./LICENSE)
