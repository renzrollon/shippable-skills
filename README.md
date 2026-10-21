# Shippable Skills

**Agent skills other engineers can install on Cursor, Copilot, Codex, or Claude Code, gated before they ship.**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](./LICENSE)

```bash
npx skills add renzrollon/shippable-skills
```

Then type `/session-retro` to score this conversation, `/product-spine` to act as product owner for your repo, `/bump-release` to bump every manifest version at once, or `/session-handoff` to save where a session stands before a reset. `fix-tests`, `explore`, and `session-primer` are model-invoked: the agent reaches for them when the task fits.

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
| `/product-spine` | The host loads [product-spine](./skills/productivity/product-spine/) and proposes work threads from the repo |
| `/bump-release` | The host loads [bump-release](./skills/engineering/bump-release/), finds every manifest that carries the version, and waits for your yes before it edits, commits, tags, or pushes |
| `/session-handoff` | The host loads [session-handoff](./skills/productivity/session-handoff/) and writes where this session stands to a handoff file |

You type `/session-retro`, `/product-spine`, `/bump-release`, or `/session-handoff`. The agent will not start any of them in the middle of your work.

The model-invoked skills have no command to type. [fix-tests](./skills/engineering/fix-tests/) loads when tests are failing, [explore](./skills/engineering/explore/) when a question spans several subsystems, and [session-primer](./skills/productivity/session-primer/) at session start or on "where was I". You can still ask for any of them by name.

## Why product-spine

Most PM skill libraries teach a method in chat: a story template, a RICE table, a PRD outline. The artefact, if any, does not live next to the code, and nothing checks that a brief still ladders to a strategy bet.

`product-spine` is repo-native. Bare invocation is an engineer-as-PO coach: it fans out over the repo and proposes Feature / Improvement / Fix threads on a mermaid map. Picking a thread lands it on three files at fixed paths. It refuses to invent the platform.

- **Threads before templates.** What to work on next, grounded in evidence (or marked `thin`), not a blank form. Draft is how a picked thread lands.
- **A greppable ladder** from brief to epic to one-pager initiative, so "every brief serving this bet" and "every brief if we kill this bet" are grep lines, not a hunt through chat.
- **No PRD and no user stories.** The brief's four sections (need, platform pieces, constraints, reasons) are the unit; discovery sits in the epic's sibling folder. Spec and how live in the change, not here.
- **Primer-grounded capability.** "Can users do X today" cites `docs/product/context/platform-primer.md`, or answers `Cannot confirm` if that file is missing.
- **Decisions inline.** Trade-offs land in the brief, the epic, or the one-pager change log. There is no decisions folder.

New files stay `Status: draft` until you flip them. Docs: [product-spine](./docs/productivity/product-spine.md).

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

`session-retro`, `product-spine`, `bump-release`, `fix-tests`, `explore`, `session-handoff`, and `session-primer` are the promoted skills. Beta work stays in `skills/in-progress/` and is not in the plugin. The package on npm is not published; install from GitHub via `npx skills add`.

Dated gate results for `session-retro` 0.1.0 (21 Aug 2026) are in its [changelog](./skills/productivity/session-retro/CHANGELOG.md).

`product-spine` **0.3.0** has not been through this gate yet. That run is the next release step. `bump-release`, `fix-tests`, `explore`, `session-handoff`, and `session-primer` (all 0.1.0) have not been through it either.

## Conventions

Skills that share state agree on a few paths and shapes. Each skill restates the rule it uses inside its own `SKILL.md`, because a skill cannot read another skill's files. This section is where they are documented once.

- **Instruction file.** The first existing of `AGENTS.md`, `CLAUDE.md`, `.github/copilot-instructions.md` at the repo root. A skill may write inside a fenced managed block it owns without asking, and names that write in its report. Any edit outside such a block waits for your yes.
- **Path overrides.** Put `shippable-state-dir: <path>` or `shippable-handoff-dir: <path>` on a line in the instruction file, with the path relative to the repo root. A `--state-dir <path>` or `--handoff-dir <path>` argument, or a directory you name in the request, wins over the file. A path from the file must stay inside the repo: an absolute path or one containing `..` is ignored.
- **State directory.** Your path, else the instruction-file override, else `.claude/` when it exists, else `.agents/`.
- **Handoff directory.** Your path, else the instruction-file override, else the first existing of `.claude/handoff/`, `.agents/handoff/`, `docs/handoff/`. Readers scan every existing one. When none exists, writers create `.agents/handoff/` and advise a gitignore line. If the write is denied, the writer does not retry and puts the content in its reply. Files are named `<kind>-<slug>-<YYYYMMDD-HHMMSS>.md`, where kind is `handoff`, `explore`, `grill`, `wire-in`, or `skill-candidate`. `grill` is reserved for a later skill.
- **Check profile.** How a project runs its tests, typecheck, lint, and build lives in a managed block fenced `<!-- BEGIN shippable:checks -->` and `<!-- END shippable:checks -->` in the instruction file, created in `AGENTS.md` when none exists. The block is authoritative. An optional cache at `<state-dir>/testing/profile.json` mirrors it, and when the two disagree the block wins.
- **Brief files.** An explore brief carries the headings Meta, Problem / Intent, Codebase Findings, Critical Files, Options Considered, Recommended Direction, Assumptions Made, Pending Clarifications, Risks / Gaps. A handoff document carries the sections named in [session-handoff](./skills/productivity/session-handoff/). A skill that reads either picks the newest matching file, takes what it records as settled, and re-checks anything the repo may have changed since.

## Skills

These split on one axis: who can invoke them. **User-invoked** skills are reachable only when you type them. **Model-invoked** skills can be invoked by you or reached for automatically when the task fits.

### Engineering

**User-invoked**

- **[bump-release](./skills/engineering/bump-release/)**: Bump the project's version in every manifest at once, then commit, tag, push, and cut a release, so no manifest keeps a stale version.

**Model-invoked**

- **[fix-tests](./skills/engineering/fix-tests/)**: Discover and persist how a project's tests run, then run the suite and repair failures by root cause: cluster failures by error signature, fix the shared cause once, and assert no test was weakened.
- **[explore](./skills/engineering/explore/)**: Deep read-only reconnaissance before a change is designed. Fans out parallel investigators across subsystems, then synthesizes one picture and, in an autonomous run, writes a durable brief.

### Productivity

**User-invoked**

- **[session-retro](./skills/productivity/session-retro/)**: Retro the current session. Score it against session shapes, flag token waste with next-turn fixes, and propose wire-ins into the skills this conversation actually called.
- **[product-spine](./skills/productivity/product-spine/)**: Help an engineer act as product owner: suggest Feature / Improvement / Fix threads from the repo, then draft, review, and capability-check the one-pager, epics, and briefs that land them. Writes artefacts, never code.
- **[session-handoff](./skills/productivity/session-handoff/)**: Save where this session stands to a handoff file before a context reset, so the next session or agent resumes without re-deriving decisions. Lists stranded work, redacts secrets, and proposes reusable rules for your instruction file.

**Model-invoked**

- **[session-primer](./skills/productivity/session-primer/)**: Brief a fresh session in one read-only pass, from git state, open plan checkboxes, the newest handoff file, and the instruction file. Never edits anything.

## Docs

| Doc | What it is |
| --- | --- |
| [session-retro](./skills/productivity/session-retro/) | Human README. The URL to share |
| [session-retro docs](./docs/productivity/session-retro.md) | When to reach for it, questions, what working looks like |
| [product-spine](./skills/productivity/product-spine/) | Human README. The URL to share |
| [product-spine docs](./docs/productivity/product-spine.md) | When to reach for it, questions, what working looks like |
| [bump-release](./skills/engineering/bump-release/) | Human README. The URL to share |
| [bump-release docs](./docs/engineering/bump-release.md) | When to reach for it, questions, what working looks like |
| [fix-tests](./skills/engineering/fix-tests/) | Human README. The URL to share |
| [fix-tests docs](./docs/engineering/fix-tests.md) | When to reach for it, questions, what working looks like |
| [explore](./skills/engineering/explore/) | Human README. The URL to share |
| [explore docs](./docs/engineering/explore.md) | When to reach for it, questions, what working looks like |
| [session-handoff](./skills/productivity/session-handoff/) | Human README. The URL to share |
| [session-handoff docs](./docs/productivity/session-handoff.md) | When to reach for it, questions, what working looks like |
| [session-primer](./skills/productivity/session-primer/) | Human README. The URL to share |
| [session-primer docs](./docs/productivity/session-primer.md) | When to reach for it, questions, what working looks like |
| [CONTRIBUTING.md](./CONTRIBUTING.md) | Dev commands, release gate, SkillSpector suppress |
| [CLAUDE.md](./CLAUDE.md) | Bucket rules, invocation polarity, docs contract |

## Development

Clone the repo. Load the skill folder into your host, or run the plugin from this checkout. Validate with `npm run validate`. Details: [CONTRIBUTING.md](./CONTRIBUTING.md#develop).

## License

[MIT](./LICENSE)
