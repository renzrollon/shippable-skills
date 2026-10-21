# fix-tests

**Make the red suite green without lying to it.** Discovers how your tests run, then fixes failures by root cause and proves no test was weakened.

```text
the suite is red, make the tests pass
fix the failures in this CI log
/fix-tests --dry-run
/fix-tests --e2e
```

- **Learns the test setup once.** The unit command is found from your manifests and CI files, then stored in a managed block in your instruction file and a cache. After that it asks nothing.
- **Fixes the cause, not each symptom.** Failures are clustered by error signature and each cluster gets one verdict: `source-bug`, `test-bug`, `env-config`, `flaky`, or `pre-existing`.
- **Cannot cheat quietly.** A baseline count, a no-regression assert, and a ledger script catch deleted assertions, new skip or only markers, and shrinking test counts.
- **Leaves the edits uncommitted.** It never stages, commits, or pushes.

The agent reaches for it when tests fail. It is not a general debugger.

## Install

```bash
npx skills add renzrollon/shippable-skills
```

Pick the hosts you use. Claude Code plugin path and the "do not install twice" rule are on the [collection README](../../../README.md).

## More

- [Human docs](../../../docs/engineering/fix-tests.md): when to reach for it, common questions, what "working" looks like
- [Agent instructions](./SKILL.md): what the model follows once it runs
- [Changelog](./CHANGELOG.md)
