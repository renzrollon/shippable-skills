# bump-release

**Bump the version everywhere it lives.** One pass finds every manifest, edits them in lockstep, then commits, tags, pushes, and cuts the release.

```text
/bump-release
/bump-release minor
/bump-release 1.4.0
/bump-release prerelease beta
```

- **Finds every manifest first.** `package.json`, `.claude-plugin/plugin.json`, `Cargo.toml`, `pyproject.toml` and the rest, so a bump never ships with a stale version hiding in a file nobody remembered.
- **Previews before it writes.** A `## Release preview` lists each file as `old -> new` and waits for your yes. Nothing is edited, committed, tagged, or pushed before it.
- **Defers to release automation.** If changesets, lerna, release-please, or semantic-release owns releases, it names the tool and stops.
- **Never forces.** A rejected push keeps the local commit and tag, prints the commands to finish by hand, and skips the release.

You type it. The agent will not cut a release on its own.

## Install

```bash
npx skills add renzrollon/shippable-skills
```

Pick the hosts you use, then type `/bump-release`. Claude Code plugin path and the "do not install twice" rule are on the [collection README](../../../README.md).

## More

- [Human docs](../../../docs/engineering/bump-release.md): when to reach for it, common questions, what "working" looks like
- [Agent instructions](./SKILL.md): what the model follows once you invoke it
- [Changelog](./CHANGELOG.md)
