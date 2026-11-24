## Purpose

Gives a fresh session a short, fixed-format briefing from git state, open plan items, the newest handoff, and the instruction file, so work resumes without exploratory warm-up.

## ADDED Requirements

### Requirement: One read-only sweep
The skill SHALL gather state in one read-only pass of plain commands, one command per call issued in parallel where the host allows, with no `;` or `&&` chaining: current branch and its default-branch distance, working-tree status, the last five commits, unchecked `- [ ]` items in plan documents, the newest `handoff-*.md` across every handoff directory the shared-contracts Handoff directory requirement lets a reader scan, and the instruction file. The skill MUST NOT edit any file or run a command that changes state.

#### Scenario: Fresh clone
- **WHEN** no handoff and no plan document exist
- **THEN** the briefing still reports branch, status, and recent commits, and reads `Resume from: fresh start`

#### Scenario: Handoffs in two directories
- **WHEN** `.agents/handoff/` and `docs/handoff/` both hold `handoff-*.md` files
- **THEN** `Resume from` names the newest of them by the timestamp in its filename

### Requirement: Briefing format
The briefing SHALL be a `## Session Briefing` block of five to eight lines covering Branch, Last activity, Uncommitted, Open items, Resume from, and Next step, and SHALL stay under twenty lines in total. It MUST NOT paste the handoff or the instruction file.

#### Scenario: Handoff exists
- **WHEN** the newest handoff file is less than seven days old
- **THEN** `Resume from` names the file and the stamp from its first line (the `session-handoff` resume stamp), and `Next step` comes from its Next Steps section

### Requirement: Default branch detection
The distance line SHALL compare against the remote's default branch, detected from `origin/HEAD` and falling back to `main` then `master`.

#### Scenario: Default branch is develop
- **WHEN** `origin/HEAD` points at `develop`
- **THEN** the distance is counted against `develop`

### Requirement: Model-invoked triggers
The skill SHALL be reachable by the model on "where was I", "catch me up", "continue where we left off", "what's the state of this repo", and SHALL NOT trigger on questions that name a specific file or feature.

#### Scenario: Specific question
- **WHEN** the user asks how the payment module works
- **THEN** the primer does not run
