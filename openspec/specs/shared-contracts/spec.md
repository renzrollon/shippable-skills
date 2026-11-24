# shared-contracts Specification

## Purpose
Defines the conventions several skills share (instruction file, state directory, handoff directory, check profile, brief files) so every writer and reader agrees on paths and shapes.

## Requirements

### Requirement: Instruction file
The instruction file SHALL be the first existing of `AGENTS.md`, `CLAUDE.md`, `.github/copilot-instructions.md` at the repo root. A path override in it SHALL be a line of the form `shippable-state-dir: <path>` or `shippable-handoff-dir: <path>`, with `<path>` relative to the repo root. A user-passed path SHALL be a `--state-dir <path>` or `--handoff-dir <path>` argument, or a directory the user names in the request. A skill MAY write inside a fenced managed block it owns without asking and SHALL name that write in its report; any edit outside such a block SHALL wait for the user's yes.

#### Scenario: Override line present
- **WHEN** `AGENTS.md` contains the line `shippable-handoff-dir: notes/handoff`
- **THEN** every handoff writer and reader uses `notes/handoff/`

#### Scenario: Edit outside the managed block
- **WHEN** a skill wants to add a line to the instruction file outside a managed block
- **THEN** it shows the line and writes nothing until the user says yes

### Requirement: State directory
A skill that needs a state directory SHALL use a user-passed path, else the instruction-file override, else `.claude/` when that directory exists, else `.agents/`. Every consuming skill SHALL restate this rule in its own `SKILL.md`.

#### Scenario: Repo has no .claude directory
- **WHEN** neither a user path nor an instruction-file override is given and `.claude/` is absent
- **THEN** the skill uses `.agents/` and creates it if needed

### Requirement: Handoff directory
A skill that writes or reads handoff files SHALL resolve the directory as: a user-passed path, else the instruction-file override, else the first existing of `.claude/handoff/`, `.agents/handoff/`, `docs/handoff/`. Writers SHALL write to the resolved directory; readers SHALL scan every existing one of the three plus any override. When none exists and no path is given, writers SHALL create `.agents/handoff/` whatever the state directory is, and advise a gitignore line. A writer SHALL attempt the create and the write once; on denial or error it SHALL NOT retry or guess another location, and SHALL put the content in its chat reply instead. Files SHALL be named `<kind>-<slug>-<YYYYMMDD-HHMMSS>.md` with kind one of `handoff`, `explore`, `grill`, `wire-in`, `skill-candidate`; `grill` is reserved for a later skill.

#### Scenario: Both .agents and docs handoff dirs exist
- **WHEN** `.agents/handoff/` and `docs/handoff/` both exist and `.claude/handoff/` does not
- **THEN** a writer uses `.agents/handoff/` and a reader considers files from both

#### Scenario: Repo has .claude but no handoff dir
- **WHEN** `.claude/` exists and none of the three handoff directories exists
- **THEN** a writer creates `.agents/handoff/`, which is where `session-retro` writes today

#### Scenario: session-retro follows the contract
- **WHEN** `session-retro` writes a wire-in or skill-candidate file
- **THEN** it lands in the directory this rule resolves, under the same naming

#### Scenario: Write denied
- **WHEN** the create or the write is denied by the host
- **THEN** the writer does not retry and its reply carries the content inline

### Requirement: Check profile
The check profile SHALL live as a managed block fenced `<!-- BEGIN shippable:checks -->` and `<!-- END shippable:checks -->` in the instruction file, created in `AGENTS.md` when no instruction file exists, and rewritten idempotently. Fields are unit (command, cwd, filter syntax, single-file syntax, timeout, prerequisites), typecheck, lint, build, e2e (opt-in), known flaky, discovered-from. The managed block is authoritative. An optional JSON cache at `<state-dir>/testing/profile.json` SHALL mirror the block, hold only fields the writer looked for, and preserve unknown keys. A check that was looked for and not found SHALL be `null` in the cache with an explanation under a top-level `notes` object keyed by field name, and SHALL read `none found (<where it looked>)` in the block. An absent key means the check was not looked for. When the cache and the block disagree, the block wins and the cache is rewritten from it. A denied write of either SHALL NOT stop the run; the profile is printed in the report instead.

#### Scenario: Second run preserves foreign keys
- **WHEN** the cache already contains a key the writer does not know
- **THEN** the key survives the rewrite unchanged

#### Scenario: Second run with nothing new
- **WHEN** discovery finds exactly what the block already records
- **THEN** the block and the cache are byte-identical after the run

#### Scenario: Lint not found
- **WHEN** discovery finds no lint command
- **THEN** `lint` is `null` in the cache, `notes.lint` says where it looked, and the block reads `none found` with the same places

#### Scenario: Human edited the block
- **WHEN** the block's unit command differs from the cache's
- **THEN** the block's command runs and the cache is rewritten to match

### Requirement: Brief file contracts
An explore brief SHALL carry the headings Meta, Problem / Intent, Codebase Findings, Critical Files, Options Considered, Recommended Direction, Assumptions Made, Pending Clarifications, Risks / Gaps. A handoff document SHALL carry the sections named in the `session-handoff` capability. A consumer of either SHALL restate a four-line consume rule: which file it reads, how it picks the newest matching one, what it takes as settled, and what it re-checks.

#### Scenario: Consumer picks the newest matching brief
- **WHEN** two explore briefs exist and one's Meta topic overlaps the request
- **THEN** the consumer reads that one and ignores the other
