# Changelog

## 0.1.0 (unreleased)

First release.

- Finds every version-bearing manifest before editing any, and stops when two
  disagree on the current version.
- Stops, editing nothing, when release automation (changesets, lerna,
  release-please, semantic-release) owns the release.
- Prints `## Release preview` and waits for a yes before any write.
- Commits, tags, pushes, and cuts a release with `gh` or `glab`; skips the
  release with the manual command printed when neither is available.
