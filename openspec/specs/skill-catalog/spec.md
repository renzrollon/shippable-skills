# skill-catalog Specification

## Purpose
States what a promoted skill must carry and where it must be listed, so the plugin, the catalogs, and the docs never disagree about what ships.

## Requirements

### Requirement: Promoted skill folder contents
Every skill under `skills/engineering/` or `skills/productivity/` SHALL contain `SKILL.md` under 500 lines, `README.md`, `CHANGELOG.md`, `.gitignore`, `agents/openai.yaml`, and `evals/eval.yaml` with at least four cases, and SHALL keep any shared reference under its own `references/` one level deep.

#### Scenario: Plugin validation
- **WHEN** `claude plugin validate . --strict` runs
- **THEN** it passes with every promoted skill registered

### Requirement: Invocation polarity in both harnesses
A user-invoked skill SHALL set `disable-model-invocation: true` in `SKILL.md` and `policy.allow_implicit_invocation: false` in `agents/openai.yaml`; a model-invoked skill SHALL omit both. Operative cross-skill calls SHALL read `Call the Skill tool with "name"`, and a user-invoked skill MUST NOT call another user-invoked skill.

#### Scenario: Model-invoked skill
- **WHEN** `fix-tests` is inspected
- **THEN** its frontmatter has no `disable-model-invocation` key and its `openai.yaml` has no `policy` block

### Requirement: Catalog entries
Every promoted skill SHALL appear in the top-level `README.md` Skills section under its bucket and polarity group, in its bucket `README.md`, in the top-level Docs table with two rows, and in `.claude-plugin/plugin.json`'s `skills` array. Non-promoted skills MUST NOT appear in any of these. Catalog links SHALL point at the skill directory, not `SKILL.md`.

#### Scenario: First model-invoked skill
- **WHEN** a model-invoked skill is promoted into a bucket whose group reads `None yet.`
- **THEN** that line is replaced by the entry in both the bucket README and the top-level README

### Requirement: Docs page
Every promoted skill SHALL have `docs/<bucket>/<skill>.md` with the sections What it does, When to reach for it, Common questions, and It's working if. The page MUST NOT host the dual install; the one-line `npx skills add` may appear in the skill README with a link back to the collection README.

#### Scenario: New engineering skill
- **WHEN** `bump-release` is promoted
- **THEN** `docs/engineering/bump-release.md` exists with the four sections

### Requirement: Prose rules
No file in the repo SHALL contain an em-dash, a host plugin-root environment variable, or a `/slash` command as an operative instruction.

#### Scenario: Grep for em-dashes
- **WHEN** the repo is searched for the em-dash character
- **THEN** no tracked prose file matches
