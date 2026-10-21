# Changelog

## 0.1.0 (unreleased)

First release.

- Resolves how the project runs its tests once (managed `shippable:checks`
  block, then cache, then headless discovery) and persists it.
- Baselines the suite, separates pre-existing and flaky failures, clusters the
  rest by error signature, and fixes the shared cause once, source first.
- Asserts `total >= baseline` and `skipped <= baseline` after the fix, and
  reverts only this run's edits when either fails.
- Ships `scripts/test-ledger.sh`, a runnable check for removed assertions and
  new skip or only markers.
