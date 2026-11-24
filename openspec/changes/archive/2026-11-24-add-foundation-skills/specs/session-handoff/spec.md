## Purpose

Saves the state of a working session to a handoff document before a context reset, so the next session or agent resumes without re-deriving decisions.

## ADDED Requirements

### Requirement: Handoff document contents
The skill SHALL write one handoff file to the directory the shared-contracts Handoff directory requirement resolves, named `handoff-<slug>-<YYYYMMDD-HHMMSS>.md`. Its first line SHALL be the resume stamp `<!-- resume: <slug> | branch <branch> | head <short-sha> | <YYYY-MM-DD HH:MM> -->`, and its sections SHALL be Progress, Decisions Made, Rejected Alternatives, Files Touched, Verified vs Assumed, Do Not Redo, Issues / Blockers, Next Steps, and Skills To Invoke. Sections point at specs, plans, and commits by path instead of copying their contents.

#### Scenario: Handoff written
- **WHEN** the user invokes the skill
- **THEN** a file with every section exists in the handoff directory and the reply prints its path and the resume phrase `Read <path> and continue from its Next Steps.`

#### Scenario: Handoff write denied
- **WHEN** the host denies creating the file
- **THEN** the skill does not retry and prints the handoff in the reply

### Requirement: Stranded-work preflight
Before writing, the skill SHALL check for uncommitted files, unpushed commits, and, when the host exposes them, running background agents, and SHALL list what it finds under Issues / Blockers.

#### Scenario: Unpushed commits
- **WHEN** the branch is ahead of its upstream
- **THEN** the handoff lists the count and the branch name under Issues / Blockers

### Requirement: Secret redaction
The skill MUST NOT write tokens, keys, passwords, or connection strings into the handoff; any such value SHALL be replaced with a placeholder naming its kind.

#### Scenario: Token in conversation
- **WHEN** the session contained an API token
- **THEN** the handoff contains a placeholder and not the token

### Requirement: Reusable constraints proposal
The skill SHALL propose at most three reusable constraints for the project's instruction file, SHALL drop any candidate that names a single file, commit, or incident rather than a rule that applies again, and SHALL write nothing to the instruction file without a yes.

#### Scenario: No durable constraint found
- **WHEN** nothing in the session generalises
- **THEN** the proposal section says so and no edit is offered

### Requirement: User-invoked only
The skill SHALL be invoked only by the user and MUST NOT fire on its own.

#### Scenario: Long session
- **WHEN** the conversation runs long without the user asking for a handoff
- **THEN** the skill does not start
