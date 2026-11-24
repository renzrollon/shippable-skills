# explore Specification

## Purpose
Read-only reconnaissance that thinks before anyone designs a change: fans out investigators when a question spans subsystems, synthesizes one picture, and writes a durable brief.

## Requirements

### Requirement: Never implements
The skill MUST NOT write code or edit source files. When asked to implement, it SHALL say so and point at the project's spec or planning skill. Writing an explore brief or a design note is allowed.

#### Scenario: Asked to implement mid-explore
- **WHEN** the user says "just build it"
- **THEN** the skill declines to edit code and names the skill or step that implements

### Requirement: Conversational and autonomous modes
The skill SHALL run conversationally by default and SHALL switch to autonomous mode on `--autonomous`, "no questions", "don't ask me", or "pursue all threads". In autonomous mode it MUST NOT ask the user anything and SHALL record defaults under Assumptions Made and unknowns under Pending Clarifications.

#### Scenario: Autonomous run hits a product question
- **WHEN** an ambiguity cannot be resolved from the repo in autonomous mode
- **THEN** the brief lists it under Pending Clarifications with a `needs_human` row and the run continues

### Requirement: Fan-out on breadth
The skill SHALL fan out two to five read-only investigators with disjoint scopes when the question touches multiple subsystems, compares options, needs cross-file tracing, or alters what a shared value means. Each investigator SHALL return JSON only with keys `files`, `how`, `connections`, `gaps`. A single-file question SHALL stay single-threaded.

#### Scenario: Shared value change
- **WHEN** the question is about normalizing or deduplicating a value read in more than one place
- **THEN** the skill runs one investigator per disjoint layer and flags every reader still consuming the raw form

#### Scenario: Single-file question
- **WHEN** the question names one file and asks what it does
- **THEN** no investigators are spawned

### Requirement: Sequential fallback
When the host exposes no subagent tool, the skill SHALL run the same scopes itself, one after another, and SHALL say so with the `investigation: sequential` line in the reply and in the brief.

#### Scenario: No subagent tool
- **WHEN** the host cannot spawn agents
- **THEN** every planned scope is still investigated and the brief header reads `investigation: sequential`

### Requirement: Synthesis
After investigation the skill SHALL merge overlapping findings, name gaps no investigator covered, surface contradictions between investigators, and offer a direction. Raw investigator output MUST NOT be pasted into the reply.

#### Scenario: Two investigators disagree
- **WHEN** two returns describe the same path differently
- **THEN** the synthesis states the disagreement and which evidence supports each side

### Requirement: Explore brief
In autonomous mode the skill SHALL write a brief to the directory the shared-contracts Handoff directory requirement resolves, named `explore-<slug>-<YYYYMMDD-HHMMSS>.md` with the headings Meta, Problem / Intent, Codebase Findings, Critical Files, Options Considered, Recommended Direction, Assumptions Made, Pending Clarifications, Risks / Gaps, and an optional decision table with columns `id | question | class | resolution | evidence` and classes `needs_human` or `agent_resolved`. Findings SHALL cite `path:line` spans and SHALL NOT inventory every file touched. The brief's Meta SHALL include a line `investigation: fan-out`, `investigation: sequential`, or `investigation: single`. The chat reply SHALL give the brief path, the same `investigation:` line, and a three to five line summary. On a denied write the skill SHALL NOT retry and SHALL print the brief in the reply.

#### Scenario: Brief written
- **WHEN** an autonomous run finishes
- **THEN** a brief with every required heading exists in the handoff directory and the reply names its path
