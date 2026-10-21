# Shippable Skills

Skills are organized into bucket folders under `skills/`:

- `engineering/`: daily code work (bump-release, fix-tests, explore)
- `productivity/`: daily non-code workflow tools
- `misc/`: kept around but rarely used, not promoted
- `in-progress/`: beta, not shipped in the plugin
- `deprecated/`: no longer used

Every skill in `engineering/` or `productivity/` (the **promoted** buckets) must have a reference in the top-level `README.md` and an entry in `.claude-plugin/plugin.json`'s `skills` array. Skills in `misc/`, `in-progress/`, and `deprecated/` must not appear in either.

`.claude-plugin/plugin.json`'s `version` tracks `package.json`'s version: bump both together on release.

Each promoted skill must have a human `README.md` beside its `SKILL.md`. That folder URL is the page you share. Catalog entries in the top-level `README.md` and in each bucket `README.md` link the skill name to the skill directory, not to `SKILL.md`.

Promoted bucket READMEs and the top-level README group entries into **User-invoked** and **Model-invoked**.

Skills in `engineering/` and `productivity/` also have a human-facing docs page at `docs/<bucket>/<skill>.md`. When you add, rename, or change the behaviour of a promoted skill, create or re-sync its docs page. Four sections make a page finished: **What it does**, **When to reach for it**, **Common questions**, and **It's working if**. The full install (npx plus the Claude Code plugin path) lives only in the top-level `README.md`. A skill-folder `README.md` may repeat the one-line `npx skills add` command and link back to the collection README. Docs pages do not host that dual install.

Every `SKILL.md` is either user-invoked (`disable-model-invocation: true` plus `policy.allow_implicit_invocation: false` in `agents/openai.yaml`) or model-invoked (omit both). Keep the two harnesses in sync: a skill is user-invoked in both or neither.

A user-invoked skill may invoke model-invoked skills, but never another user-invoked one. Operative instructions name the Skill tool (`Call the Skill tool with "name"`), not a `/slash` that assumes one host.

Each skill carries an `agents/openai.yaml` beside its `SKILL.md` (Codex picker metadata). Shared reference docs live inside the skill that owns them (`references/`), one level deep from `SKILL.md`.

Keep `SKILL.md` under 500 lines. The description is human-facing for user-invoked skills (no "Use when the user says..." trigger lists) and model-facing for model-invoked skills (rich trigger phrasing).

This repo must stay host-neutral. Do not depend on a host plugin-root env var, a single plugin PATH, or one vendor's tool names. Discover skills from the common project and home directories; map host tool aliases when tallying.

No em-dashes anywhere in this repo's prose (`SKILL.md` files, docs, `README.md`, `CLAUDE.md`, comments). Where a sentence reaches for one, rewrite it instead with a comma, colon, period, parentheses, or a conjunction.
