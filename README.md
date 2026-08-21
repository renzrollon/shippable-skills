# Shippable Skills

[![skills.sh](https://skills.sh/b/renzrollon/shippable-skills)](https://skills.sh/renzrollon/shippable-skills)

Agent skills that install on Cursor, GitHub Copilot, Codex, Claude Code, and the rest of the [skills.sh](https://skills.sh) hosts. Small, composable, and yours to edit.

## Installation (30-second setup)

Two ways in, two philosophies. **The [Claude Code plugin](https://code.claude.com/docs/en/plugins)** installs the set as a managed, read-only bundle. **[skills.sh](https://skills.sh/renzrollon/shippable-skills)** copies editable skill files into your project or home directory, so you can hack on them. Pick one: installing both leaves you with every skill twice.

### 1. Get the skills

<details>
<summary><b>Cursor, Copilot, Codex, and other agents</b></summary>

```bash
npx skills@latest add renzrollon/shippable-skills
```

Pick the skills you want, and which coding agents to install them on.

Team one-liner (global, no prompts):

```bash
npx skills@latest add renzrollon/shippable-skills -g -a cursor -a github-copilot -a codex -a claude-code -y
```

Updates later: `npx skills update`.

</details>

<details>
<summary><b>Claude Code plugin</b></summary>

```
/plugin marketplace add renzrollon/shippable-skills
/plugin install shippable-skills@shippable-skills
```

Or from a shell:

```bash
claude plugin marketplace add renzrollon/shippable-skills
claude plugins install shippable-skills@shippable-skills
```

</details>

<details>
<summary><b>For tinkerers</b></summary>

Use the same installer, on any agent, including Claude Code:

```bash
npx skills@latest add renzrollon/shippable-skills
```

It writes the skills into your repo as ordinary files you own and can edit. Nothing updates behind your back.

</details>

### 2. Run `/session-retro`

In any session, type `/session-retro` (or pick it from the host's skill picker). It scores the conversation you are still in, flags where tokens went, and writes wire-in notes for the skills that conversation actually called.

## Reference

These split on one axis: who can invoke them. **User-invoked** skills are reachable only when you type them. **Model-invoked** skills can be invoked by you or reached for automatically by the agent when the task fits.

### Productivity

**User-invoked**

- **[session-retro](./skills/productivity/session-retro/SKILL.md)**: Retro the current session. Score it against session shapes, flag token waste with next-turn fixes, and propose wire-ins into the skills this conversation actually called. Docs: [session-retro](./docs/productivity/session-retro.md).

**Model-invoked**

None yet.

## License

[MIT](./LICENSE)
