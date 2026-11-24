# fix-tests Specification

## Purpose
Discovers and persists how a project's tests run once, then runs the suite and repairs failures by root cause without weakening a single test.

## Requirements

### Requirement: Check profile resolution
The skill SHALL resolve the check profile from, in order, the managed block in the instruction file, the JSON cache at `<state-dir>/testing/profile.json`, and headless discovery, following the shared-contracts Check profile requirement. Headless discovery SHALL inspect `package.json` scripts, `pyproject.toml`, `tox.ini`, `pytest.ini`, `go.mod`, `Cargo.toml`, `pom.xml`, `build.gradle`, `*.csproj`, `Gemfile`, a `Makefile` `test` target, runner config files, and CI workflows. When no unit command is found, the skill SHALL ask at most four questions, once, and only this skill may interview the user about test setup.

#### Scenario: Profile exists
- **WHEN** a profile with a unit command exists in the cache or the managed block
- **THEN** the skill runs with zero questions

#### Scenario: Maven project with no profile
- **WHEN** no profile exists and `pom.xml` is present
- **THEN** discovery proposes `mvn test` as the unit command without asking

#### Scenario: Nothing discoverable
- **WHEN** no manifest, runner config, or CI file yields a unit command
- **THEN** the skill asks at most four questions and persists the answers

#### Scenario: Cached command no longer exists
- **WHEN** the profile names a `test` script that `package.json` no longer defines
- **THEN** the skill rediscovers without asking, rewrites the block and the cache, and says the old command was stale

#### Scenario: Runner binary missing
- **WHEN** discovery proposes `mvn test` and `mvn` is not on PATH
- **THEN** the skill records the command, classifies the run `env-config`, installs nothing, and stops with the missing binary named

### Requirement: Run snapshot
Before its first edit the skill SHALL record a snapshot of the working tree without changing it: the object `git stash create` prints, or `HEAD` when the tree is clean. Every later "this run's edits" (the test ledger, the no-regression revert) SHALL mean the difference between the snapshot and the working tree, so edits that were uncommitted before the run are never reported or reverted as the run's own.

#### Scenario: Dirty tree before the run
- **WHEN** a test file already had uncommitted edits before the run and the no-regression assert later fails
- **THEN** the revert restores that file to its snapshot content, keeping the earlier edits, and the ledger does not list them

### Requirement: Baseline before any edit
The skill SHALL run the full unit suite and record total, passed, failed, and skipped counts before editing any file. To classify a failure as pre-existing, the skill SHALL re-run that test on the default branch (detected as in `session-primer`) in a temporary worktree outside the repo and remove the worktree afterwards; a failure that also fails there SHALL be reported as `pre-existing` and not absorbed into this run's fix scope. When a worktree cannot be created, the failure SHALL stay in scope and the report SHALL say the pre-existing check was skipped and why.

#### Scenario: Failure also fails on the default branch
- **WHEN** a failing test fails the same way in the temporary worktree
- **THEN** it is reported as `pre-existing`, left unfixed, and the worktree is gone after the run

#### Scenario: Suite is green
- **WHEN** the baseline run has zero failures
- **THEN** the skill reports the counts and makes no edits

### Requirement: Flake check before fixing
The skill SHALL re-run only the failing tests once before clustering; a test that passes on re-run SHALL be classified as flaky and excluded from the fix loop.

#### Scenario: Test passes on re-run
- **WHEN** a failing test passes on the isolated re-run
- **THEN** it is reported as flaky with its signature and not fixed

### Requirement: Cluster and fix by root cause
The skill SHALL group failures by error signature, give each cluster exactly one verdict from `source-bug`, `test-bug`, `env-config`, `flaky`, `pre-existing`, fix the largest cluster with one change, re-run only the affected tests, and stop after at most five root-cause iterations.

#### Scenario: Iteration cap reached
- **WHEN** five iterations complete and failures remain
- **THEN** the skill stops, reports the remaining clusters with verdicts, and names the next action for a human

### Requirement: Never weaken a test
The skill MUST NOT add skip or only markers, delete or comment out assertions, delete a test, narrow a test glob, raise a timeout to hide a race, blanket-update snapshots, swallow errors, or rewrite an expected value to the observed value without a one-line justification. A test file edit SHALL carry a stated reason and one ledger line per file in the report.

#### Scenario: Test edited with reason
- **WHEN** the fix changes a test file because the test asserted the wrong value
- **THEN** the report's ledger names the file, the reason, and the cluster verdict `test-bug`

### Requirement: No-regression assert
After the final full run the skill SHALL assert that the total test count is at least the baseline total and the skipped count is at most the baseline skipped. When the assert fails the skill SHALL stop, print which count moved and by how much, revert only edits made since the run snapshot, and refuse to call the suite green. An explained drop SHALL be reported, not reverted.

#### Scenario: Total dropped unexplained
- **WHEN** the final total is lower than the baseline total and no ledger line explains it
- **THEN** the run's edits are reverted and the report shows both counts

### Requirement: End-to-end failures are reported, never fixed
When e2e is enabled in the profile and the e2e run is red, the skill SHALL report the failures and stop without retrying or debugging.

#### Scenario: Red e2e
- **WHEN** the e2e command exits non-zero
- **THEN** the report lists the failures and no e2e fix is attempted

### Requirement: Never commit
The skill MUST NOT commit, push, or stage files.

#### Scenario: Run completes green
- **WHEN** the suite is green after fixes
- **THEN** the working tree holds the edits uncommitted and the report says so

### Requirement: Test ledger script
The skill SHALL ship a script that takes the run snapshot as its base, diffs test paths against it, and prints removed assertions, added skip or only markers, and the net test-line delta, and the skill SHALL run it before the final report when bash is available. Markers SHALL cover at least `.skip` and `.only` (JS), `xit` and `xdescribe`, `@pytest.mark.skip` and `@unittest.skip`, `t.Skip` (Go), `#[ignore]` (Rust), `@Disabled` and `@Ignore` (JVM), and `pending`/`skip` in rspec.

#### Scenario: Script finds a new skip marker
- **WHEN** the diff adds `.skip` inside a test path
- **THEN** the script prints the file and line and exits non-zero

#### Scenario: Skip marker predates the run
- **WHEN** an uncommitted `.skip` existed before the snapshot and the run adds nothing
- **THEN** the script exits zero
