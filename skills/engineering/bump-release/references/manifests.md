# Manifests, lockfiles, and release automation

Read-only reference for `bump-release` steps 1, 2, and 5.

## Release automation (step 1)

If any row matches, stop with no edits and name the tool.

| Tool | Signals |
|------|---------|
| changesets | `.changeset/` directory, `@changesets/cli` in `devDependencies` |
| lerna version | `lerna.json` and a script or CI step that runs `lerna version` or `lerna publish` |
| release-please | `release-please-config.json`, `.release-please-manifest.json`, or a workflow file that names `release-please` |
| semantic-release | `.releaserc`, `.releaserc.*`, `release.config.*`, a `release` key in `package.json`, a `semantic-release` script or dependency |

A `lerna.json` that only sets `packages` and a fixed `version` for workspace
layout does not count unless a release step uses it.

## Manifest table (step 2)

A file counts only when it carries the current version string in the field
shown. A filename match alone does not qualify.

| File | Version field |
|------|---------------|
| `package.json` (root, and each `workspaces` entry) | `"version"` |
| `.claude-plugin/plugin.json` | `"version"` |
| `.claude-plugin/marketplace.json` | `plugins[].version`, matched by plugin `name` |
| `Cargo.toml` | `[package] version` (or `[workspace.package] version`) |
| `pyproject.toml` | `[project] version` or `[tool.poetry] version` |
| `setup.py` / `setup.cfg` | `version=` / `version =` |
| `pom.xml` | the project's own `<version>`, not a dependency's |
| `build.gradle` / `build.gradle.kts` | `version = "..."`, or `version` in `gradle.properties` |
| `*.csproj` | `<Version>` (or `<VersionPrefix>`) |
| `*.gemspec` | `spec.version`, or the `VERSION` constant it requires |
| `Chart.yaml` | `version:` (chart); `appVersion:` only when the user says so |
| `mix.exs` | `version:` in `project/0` |
| `composer.json` | `"version"` |
| `VERSION`, `VERSION.txt` | whole file |
| a `__version__ = "..."` assignment | the assignment, typically `<pkg>/__init__.py` or `_version.py` |

Charts: `version` is the chart version and `appVersion` the packaged app. Ask
which to bump when they differ, and list the answer in the preview.

## Broader sweep

After the table, run one sweep for anything it missed, excluding dependency
directories (`node_modules`, `vendor`, `.git`, `target`, `dist`, `build`):

```
grep -rn '"version"[[:space:]]*:[[:space:]]*"[0-9]' --include='*.json' --exclude='package-lock.json' --exclude-dir=node_modules --exclude-dir=vendor --exclude-dir=.git --exclude-dir=target --exclude-dir=dist --exclude-dir=build .
grep -rn '__version__[[:space:]]*=' --include='*.py' --exclude-dir=node_modules --exclude-dir=vendor --exclude-dir=.git --exclude-dir=target --exclude-dir=dist --exclude-dir=build .
```

Every hit not already in the table is a candidate. Show it and let the user
confirm or skip it. Never include or exclude one silently.

## Lockfiles (excluded from the manifest list)

| Lockfile | Refresh command (run after the manifests change) |
|----------|--------------------------------------------------|
| `package-lock.json` | `npm install --package-lock-only` |
| `yarn.lock` | `yarn install --mode update-lockfile` (berry) or `yarn install` (classic) |
| `pnpm-lock.yaml` | `pnpm install --lockfile-only` |
| `Cargo.lock` | `cargo update --workspace` |
| `uv.lock` | `uv lock` |
| `poetry.lock` | `poetry lock` |

Stage a refreshed lockfile by name. If the command is not installed, or it
fails, leave the lockfile unstaged and say so in the report. Never hand-edit a
lockfile.

## Version arithmetic

- `patch`: `1.4.0` becomes `1.4.1`.
- `minor`: `1.4.3` becomes `1.5.0`.
- `major`: `1.4.3` becomes `2.0.0`.
- `prerelease <id>`: `1.4.0` becomes `1.5.0-<id>.0`; `1.5.0-<id>.0` becomes
  `1.5.0-<id>.1`; a different id restarts at `.0`.
- An exact version must compare greater than the current one by semver
  precedence. `1.5.0-rc.1` is lower than `1.5.0`.
