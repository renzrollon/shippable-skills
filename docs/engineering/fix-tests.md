# fix-tests

Share this skill as the folder that holds its human README: [`skills/engineering/fix-tests/`](../../skills/engineering/fix-tests/).

## What it does

`fix-tests` learns how a repo runs its tests, runs the suite, and repairs
failures by **root cause**, without weakening a test to get there.

The usual failure mode of an agent told to "make the tests pass" is to make the
tests pass: skip one, loosen an assertion, raise a timeout over a race. The
suite goes green and means less. This skill makes that move expensive to do
quietly.

1. **Profile.** It resolves the unit command from a managed
   `shippable:checks` block in your instruction file, then a cache, then
   headless discovery of manifests, runner config, and CI files. When nothing is
   discoverable it asks at most four questions, once.
2. **Snapshot and baseline.** It records the dirty tree without touching it
   (`git stash create`) and the baseline counts before any edit.
3. **Triage.** Each failing test is re-run on the default branch in a
   temporary worktree (a failure that fails there too is `pre-existing`), then
   re-run once more to catch flakes.
4. **Cluster and fix.** Failures are grouped by error signature. The biggest
   cluster gets one fix, source first, then only the affected tests re-run.
   It stops at five iterations.
5. **Prove it.** The final run must keep `total >= baseline` and
   `skipped <= baseline`, and `scripts/test-ledger.sh` lists removed assertions
   and new skip or only markers. A failed assert reverts only this run's edits.

It ends with `## Fix-tests report`, and leaves every edit uncommitted.

## When to reach for it

The agent reaches for it when the situation matches; you can also name it with
`/fix-tests`. Flags: `--e2e`, `--from-log <path>`, `--reconfigure`, `--dry-run`,
`--state-dir <path>`.

| Situation | Why this skill |
| --- | --- |
| The suite is red and you do not know why | One baseline, clusters, and a verdict per cluster |
| CI pasted a failure log | `--from-log` treats it as the first evidence |
| You suspect the last fix hid something | The ledger lists removed assertions and new skip markers |
| A new repo with unknown test tooling | Discovery finds the command and stores it |

Skip it for a failure that is not a test run (a crash on startup, a build
error). It says so and stops: it is not a general debugger.

## Common questions

**Does it ever edit a test?**
Yes, when the test asserts the wrong contract (`test-bug`), with a stated reason
and one ledger line per file. It never skips, deletes, narrows, or loosens a
test to reach green. The full list is in `references/forbidden-moves.md`.

**Where does the test setup get stored?**
In a fenced `shippable:checks` block in the first existing of `AGENTS.md`,
`CLAUDE.md`, `.github/copilot-instructions.md` (created in `AGENTS.md` if none
exists), mirrored in `<state-dir>/testing/profile.json`. The block wins, so a
human edit is respected. It writes only inside its own fence.

**What if my working tree is already dirty?**
That is the normal case. The snapshot means edits you made before the run are
neither reported nor reverted as the skill's.

**What about e2e?**
`--e2e` runs the e2e command from the profile and reports failures. It does not
fix them.

**Does it commit?**
Never. It does not stage or push either.

**What if the runner is not installed?**
It records the command anyway, installs nothing, and stops with
`stopped (missing binary: <name>)`.

## It's working if

- The report opens with `profile:` naming where the command came from, and
  `counts:` shows baseline and final totals.
- Each cluster has one verdict from `source-bug`, `test-bug`, `env-config`,
  `flaky`, `pre-existing`, with a fix or a reason.
- `ledger:` is `none`, or lists each edited test file with its reason.
- `status: green` came with `total` not lower and `skipped` not higher than the
  baseline.
- A second run on an unchanged repo reads the stored profile and asks nothing.

### Exercised ecosystems

Be clear about what has been exercised:

- **Run end to end in the eval fixtures:** Node (`package.json` with
  `node --test`) and Maven (`pom.xml` alone yields `mvn test`).
- **Covered by the ledger script's self-test:** skip and only markers across
  JavaScript, Python, Go, Rust, JVM, .NET, and rspec.
- **In the discovery ladder but not exercised:** Gradle, Cargo, Go, Python
  runners, .NET, Ruby, `Makefile` targets, and CI-file inference. Treat their
  first run as a check and correct the stored profile if it is wrong
  (`--reconfigure`).
