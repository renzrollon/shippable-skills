# Forbidden moves and verdicts

## Forbidden moves

Never do any of these to turn a red suite green:

- Add a skip or only marker: `.skip`, `.only`, `xit`, `xdescribe`, `test.skip`, `@pytest.mark.skip`, `@unittest.skip`, `t.Skip`, `#[ignore]`, `@Disabled`, `@Ignore`, rspec `pending` or `skip`.
- Delete or comment out an assertion.
- Delete a test.
- Narrow a test glob or runner filter so the failing test no longer runs.
- Raise a timeout to hide a race.
- Blanket-update snapshots (`-u`, `--update-snapshots`) without a per-assertion justification.
- Swallow errors in an empty `try`/`catch` (or equivalent) to silence a failure.
- Rewrite an expected value to the observed value without a one-line justification, and only when the test was wrong.

## Test-file edits

Editing a test file is allowed only when the test asserts the wrong contract (verdict `test-bug`). Each edit carries:

- a stated reason, and
- one ledger line per file in the report: file, reason, cluster verdict.

When bash is available, run `scripts/test-ledger.sh <snapshot>` before the final report. It prints removed assertions, added skip or only markers, and the net test-line delta against the run snapshot, and exits non-zero on a new marker. Markers that predate the snapshot are not the run's and are not reported. Each removed assertion it lists needs a ledger line or a restore, because exit 0 does not clear it. It cannot see untracked files: copy those aside before editing and diff them by hand.

## No-regression assert

After the final full run: total is at least the baseline total, and skipped is at most the baseline skipped. When either fails, stop, print which count moved and by how much, revert only edits made since the run snapshot, and refuse to call the suite green. A lower total always reverts: no ledger line excuses a deleted test. A duplicate or obsolete test is reported under `Test quality notes`, not removed.

## Verdict taxonomy

Give each failure cluster exactly one verdict:

| Verdict | Meaning | Action |
|---------|---------|--------|
| `source-bug` | The implementation is wrong. The default assumption. | Fix the source. |
| `test-bug` | The test asserts the wrong contract. | Fix the test, with reason and ledger line. |
| `env-config` | Missing env var, service, binary, fixture, or setup. | Fix config if in scope, else report what is missing. Never install tooling. |
| `flaky` | Passed on the isolated re-run. | Record in known flaky, do not fix. |
| `pre-existing` | Also fails on the default branch in a temporary worktree. | Report only, not part of this run's fix scope. |

When the worktree check cannot run, the failure stays in scope and the report says the pre-existing check was skipped and why.

## Always

- Baseline counts (total, passed, failed, skipped) before the first edit.
- Source first.
- At most five root-cause iterations, then stop and report what remains.
- Red e2e is reported, never fixed.
- Never commit, push, or stage.
