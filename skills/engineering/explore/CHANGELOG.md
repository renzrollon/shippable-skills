# Changelog

## 0.1.0 (unreleased)

First release.

- Fans out two to five read-only investigators with disjoint scopes when a
  question spans subsystems, compares options, or changes a shared value; stays
  single-threaded otherwise.
- Prints an `investigation: fan-out | sequential | single` marker every run.
  Hosts without a subagent tool run the same scopes sequentially.
- Synthesizes one picture, names gaps, and surfaces contradictions.
- Autonomous mode asks nothing and writes a nine-section brief once.
- Never writes code.
