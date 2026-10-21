---
name: fix-tests
description: Discover and persist how a project's tests run, then run the suite and repair failures by root cause, clustering failures by error signature, fixing the shared cause once, and asserting no test was weakened. Use when tests are failing, the suite is red, CI pasted a failure log, or someone asks to make the tests pass. Not a general debugger, and not for a failure that is not a test run.
license: MIT
argument-hint: "[--e2e] [--from-log <path>] [--reconfigure] [--dry-run] [--state-dir <path>]"
metadata:
  version: 0.1.0
---

Find out how this repo runs its tests (once), run the suite, and fix failures
by root cause: source first, never by weakening a test.

This skill is **host-neutral**. It runs on Cursor, Copilot, Codex, Claude Code,
and any other Agent Skills host. It needs `git` and whatever runner the project
already uses. It installs nothing.

**Never block on I/O.** A denied or failed write of the profile block or the
cache never stops the run: print the profile in the report instead. Do not retry
a denied call or guess an alternate path.

---

## Output contract (non-negotiable)

**You are running fix-tests right now.** These instructions are in your context
because the skill was invoked, so run the steps in this reply.

End every run with `## Fix-tests report`, at most 14 lines, containing:

1. `profile:` where it came from (block, cache, or discovered) and the unit
   command.
2. `counts:` baseline and final `total / passed / failed / skipped`.
3. One line per cluster: `<signature> | <verdict> | <fix or reason>`, with the
   verdict exactly one of `source-bug`, `test-bug`, `env-config`, `flaky`,
   `pre-existing`.
4. `ledger:` one line per edited test file with its reason, or `none`.
5. `status:` `green`, `red`, `reverted`, or `stopped (<why>)`.
6. `uncommitted:` the edits are in the working tree and nothing was committed.

---

## Input

| Argument | Meaning |
|----------|---------|
| _(none)_ | Resolve the profile, run the **unit** suite, fix what is red |
| `--e2e` | Also run the e2e command. Reported on failure, never fixed. |
| `--from-log <path>` | Use an existing failure log as the first clustering evidence |
| `--reconfigure` | Ignore the stored profile, rediscover, rewrite it |
| `--dry-run` | Cluster and diagnose only. Change no source or test file. |
| `--state-dir <path>` | Override the state directory (see step 0) |

Natural language works ("the suite is red", "make CI green from this log").

---

## Steps

### 0. Resolve the check profile

Restated from the collection's shared conventions. Use these rules as written.

- **Instruction file:** the first existing of `AGENTS.md`, `CLAUDE.md`,
  `.github/copilot-instructions.md`. A line `shippable-state-dir: <path>` in it
  overrides the state directory. Ignore a value that is absolute or contains `..`, and say so.
- **State directory:** a path the user passed (`--state-dir`) or named in the
  request, else the instruction-file
  override, else `.claude/` when it exists, else `.agents/`.
- **Managed block:** `<!-- BEGIN shippable:checks -->` to
  `<!-- END shippable:checks -->` in the instruction file. It is authoritative:
  a human edit wins. Create it in `AGENTS.md` when no instruction file exists.
  You may write inside this fence without asking, and you name the write in the
  report. You never edit outside it.
- **Cache:** `<state-dir>/testing/profile.json`, a mirror of the block. Write
  only fields you looked for, preserve unknown keys, and rewrite from the block
  if they disagree.

Resolve in this order and stop at the first that gives a unit command:

1. The managed block.
2. The cache.
3. Headless discovery.

When a profile with a unit command exists, **ask nothing** and go on.

**Discovery** inspects, in order: `package.json` scripts, `pyproject.toml`,
`tox.ini`, `pytest.ini`, `go.mod`, `Cargo.toml`, `pom.xml`, `build.gradle`,
`*.csproj`, `Gemfile`, a `Makefile` `test` target, runner config files, and CI
workflow files. The full ladder with the command each file implies, and the
profile field list, null rules, and block layout, are in
[references/check-profile.md](references/check-profile.md). Propose, do not ask:
a `pom.xml` alone yields `mvn test`.

**Nothing discoverable.** Only then ask, at most four questions, once: unit
command, working directory, how to run one file, any required service. Persist
the answers. Only this skill interviews the user about test setup.

**Persist.** Write the block and the cache after discovery, idempotently: when
discovery finds exactly what is recorded, both stay byte-identical. A check that
was looked for and not found is `null` in the cache with a `notes.<field>` line,
and reads `none found (<where it looked>)` in the block. An absent key means not
looked for.

**Stale cached command.** If the profile's command no longer exists (a `test`
script that `package.json` no longer defines, a path that is gone), rediscover
without asking, rewrite the block and the cache, and say in the report that the
old command was stale.

**Missing runner binary.** After choosing the unit command, check its first word
is on PATH. If it is not (for example `mvn` is absent), record the command in
the profile anyway, classify the run `env-config`, install nothing, and stop
with `stopped (missing binary: <name>)`.

### 1. Run snapshot (before the first edit)

Record the working tree without changing it:

```
git stash create
```

It prints a commit object for the dirty tree and touches neither tree, index,
nor stash list. If it prints nothing the tree is clean: use `HEAD`. Call this
the **snapshot**. From here on, "this run's edits" means the difference between
the snapshot and the working tree, so edits that were uncommitted before the run
are never reported or reverted as yours. If the directory is not a git
repository, say the ledger and revert are unavailable and continue without
them.

**Untracked files are outside the snapshot.** Neither `git stash create` nor the
ledger script sees them. Record `git ls-files --others --exclude-standard`. Before
editing a file on that list, copy it to the system temp directory. The revert
restores it from that copy, and the ledger for it is manual: run
`diff -u <copy> <file>` and write a ledger line for every removed assertion or
added skip marker.

### 2. Baseline run

Unless `--from-log` supplies the evidence, run the full unit command from the
profile (respect its working directory and timeout). Record before editing:
`total`, `passed`, `failed`, `skipped`, `duration`.

A `--from-log` that does not carry a full `total` and `skipped` (a partial run,
a single file, a cropped paste) cannot anchor the step 6 assert. Run the full
unit command once for the baseline anyway, before any edit, and use the log only
as the first clustering evidence.

If the suite is green, report the counts and make no edit.

With `--e2e` and an e2e command in the profile, record a separate e2e baseline.
Red e2e is reported and the run stops there for e2e: do not retry or debug it.
`--e2e` with no e2e command: say so, do not invent one.

### 3. Pre-existing check

For each failing test, re-run it on the default branch in a temporary worktree
outside the repo:

1. Default branch: the ref `origin/HEAD` itself, falling back to `main`, then
   `master` (the first that `git rev-parse --verify --quiet` accepts). Pass the
   ref, never a branch name read from `git symbolic-ref`: a repository can name
   a branch `$(...)`.
2. `git worktree add --detach <system-temp-dir>/fix-tests-<id> <ref>`.
3. Run the failing tests there with the profile's filter syntax.
4. `git worktree remove --force` the worktree, always, even on error.

A failure that fails the same way there is `pre-existing`: leave it unfixed and
out of scope. If the worktree cannot be created, the failure **stays in scope**
and the report says the pre-existing check was skipped and why. Never touch the
user's tree or index for this check.

### 4. Flake check

Re-run only the remaining failing tests once. A test that passes on re-run is
`flaky`: report its signature, add it to the profile's known flaky list, and
leave it out of the fix loop.

### 5. Cluster, then fix by root cause

Group failures by error signature (same missing import, same type error, same
missing fixture, same environment error, same assertion pattern). Give each
cluster exactly one verdict from `source-bug`, `test-bug`, `env-config`,
`flaky`, `pre-existing`.

```
iterations = 0
WHILE failures remain AND iterations < 5 AND not --dry-run:
  pick the cluster with the most failures
  choose ONE fix, source first
  apply it
  re-run ONLY the affected tests
  iterations += 1
```

- **Source first.** Fix the implementation unless the test demonstrably asserts
  the wrong contract. Then the verdict is `test-bug`.
- **Test edits** need a stated reason and one ledger line per file.
- **Stop at five iterations.** Report the remaining clusters with verdicts and
  name the next action for a human.
- `--dry-run` stops after clustering and prints diagnoses and proposed fixes.
- `env-config` clusters (missing service, bad env var) are reported with what to
  set, not worked around in code.

The forbidden moves list and the verdict definitions are in
[references/forbidden-moves.md](references/forbidden-moves.md). In short, never
weaken a test: no skip or only markers, no deleted or commented-out assertions,
no deleted tests, no narrowed globs, no raised timeouts hiding a race, no
blanket snapshot updates, no swallowed errors, and no rewriting an expected
value to the observed one without a one-line justification.

### 6. Final run and no-regression assert

Run the full unit command again. Then assert both:

- `total >= baseline total`
- `skipped <= baseline skipped`

If either fails: **stop**, print which count moved and by how much, revert only
the edits made since the snapshot (restore each file you changed to its snapshot
content, leaving earlier uncommitted edits alone), and do not call the suite
green. A lower total always reverts: deleting a test is a forbidden move, and
no ledger line excuses it. A test that looks duplicate or obsolete goes under
`Test quality notes`, never into the diff.

### 7. Test ledger

When bash is available, run [scripts/test-ledger.sh](scripts/test-ledger.sh)
with the snapshot as its base, before writing the report:

```
bash <skill-dir>/scripts/test-ledger.sh <snapshot>
```

It lists removed assertions, added skip or only markers, and the net test-line
delta, and exits non-zero on a new marker. A non-zero exit means a forbidden
move got in: undo it, or report `reverted`. Exit 0 does not clear a listed
removed assertion: each one needs a ledger line (file, reason, verdict
`test-bug`) or is restored. A commented-out assertion lists here and exits 0.
The script only sees changes after the snapshot, so a marker that predates the
run is never flagged. It cannot see untracked files (step 1).

### 8. Report

Print `## Fix-tests report` per the output contract. Optional `Test quality
notes`, at most three bullets, observation only, never acted on here.

---

## Rules

- Baseline before any edit. The no-regression assert catches silent deletion.
- Snapshot before the first edit. Revert and ledger both diff against it.
- Never commit, push, or stage anything. The edits stay in the working tree.
- Never weaken a test to get green. A lower skipped count is not worth a
  deleted assertion.
- Stay in the main context for unit fixing: no fan-out, one root cause at a
  time.
- No coverage runs. e2e is opt-in and reported, never fixed.
- Interview about test setup only when nothing is discoverable, at most four
  questions, once.
- Not a general debugger: if the failure is not a test run, say so and stop.

---

## Related

- Profile fields, null rules, block layout, discovery ladder: [references/check-profile.md](references/check-profile.md)
- Forbidden moves and verdicts: [references/forbidden-moves.md](references/forbidden-moves.md)
- Ledger script and its test: [scripts/test-ledger.sh](scripts/test-ledger.sh), [scripts/test-ledger.test.sh](scripts/test-ledger.test.sh)
