# bump-release Specification

## Purpose
Bumps the project's version across every version-bearing manifest in lockstep, then commits, tags, pushes, and cuts a release, so a stale version never ships from a manifest nobody checked.

## Requirements

### Requirement: Lockstep manifest discovery
The skill SHALL discover every version-bearing manifest in the repo before editing any of them, covering at least `package.json`, Claude Code plugin and marketplace manifests, `Cargo.toml`, `pyproject.toml`, `pom.xml`, `build.gradle`, `*.csproj`, `*.gemspec`, `setup.py`, `Chart.yaml`, `mix.exs`, and a `__version__` assignment. A filename match alone SHALL NOT qualify a file; the skill MUST confirm the file carries the current version string. Lockfiles (`package-lock.json`, `yarn.lock`, `pnpm-lock.yaml`, `Cargo.lock`, `uv.lock`, `poetry.lock`) SHALL be excluded from the manifest list.

#### Scenario: Manifests disagree on the current version
- **WHEN** two discovered manifests carry different version strings
- **THEN** the skill stops before any edit, lists each manifest with its version, and asks which is authoritative

#### Scenario: Lockfile carries the version
- **WHEN** `package-lock.json` contains the current version string
- **THEN** it is not listed as a manifest to edit, and it is refreshed with the ecosystem's own command after the manifests change

### Requirement: Target version
The skill SHALL accept an explicit version or one of `major`, `minor`, `patch`, `prerelease <id>`, and SHALL default to `patch` when none is given. An explicit version that is not greater than the current version SHALL stop the run before any edit.

#### Scenario: No argument
- **WHEN** the user invokes the skill with no version
- **THEN** the preview proposes the next patch version

#### Scenario: Version goes backwards
- **WHEN** the current version is `1.4.0` and the user asks for `1.3.9`
- **THEN** the skill stops, names both versions, and edits nothing

### Requirement: Clean starting state
The skill SHALL stop before the preview when the working tree has uncommitted changes, and SHALL name the dirty files. When the repo has no `origin` remote, the skill SHALL still commit and tag locally, skip push and release, and say so in the preview.

#### Scenario: Dirty tree
- **WHEN** `git status --porcelain` is non-empty
- **THEN** the skill lists the files and makes no edit

#### Scenario: No remote
- **WHEN** `git remote get-url origin` fails
- **THEN** the preview says push and release will be skipped, and the report lists them as skipped

### Requirement: Preview before any write
The skill SHALL print the target version and the full list of files it will edit, and MUST NOT edit, commit, tag, or push until the user confirms the preview.

#### Scenario: User declines the preview
- **WHEN** the user answers no to the preview
- **THEN** no file, commit, tag, or remote changes, and the skill reports what it would have done

### Requirement: Release automation detection
The skill SHALL stop with an explanation and no edits when the repo uses changesets, lerna version, release-please, or semantic-release, detected from their config files or manifest scripts.

#### Scenario: Repo uses release-please
- **WHEN** `release-please-config.json` or a `release-please` workflow exists
- **THEN** the skill makes no change and names the tool that owns releases

### Requirement: Tag prefix detection
The skill SHALL detect the tag prefix from the repo's existing version tags and default to `v` when no version tag exists.

#### Scenario: Repo tags without a prefix
- **WHEN** the most recent version tag is `1.4.0`
- **THEN** the new tag is `1.5.0`, not `v1.5.0`

#### Scenario: Tag already exists at a different commit
- **WHEN** the target tag already exists and does not point at the new commit
- **THEN** the skill stops and asks before moving or replacing the tag

### Requirement: Push with a missing upstream
The skill SHALL detect when the current branch has no upstream and SHALL push with an explicit upstream set rather than failing.

#### Scenario: Branch has no upstream
- **WHEN** `git rev-parse --abbrev-ref @{upstream}` fails
- **THEN** the skill pushes the branch with `--set-upstream` to `origin` and then pushes the tag

### Requirement: Rejected push
When the branch or tag push is rejected, the skill SHALL NOT force-push or retry with a rewritten history. It SHALL stop, keep the local commit and tag, skip the release, and print the commands to finish by hand.

#### Scenario: Remote is ahead
- **WHEN** the push is rejected as non-fast-forward
- **THEN** the report shows the rejection, the local commit and tag remain, and no release is created

### Requirement: Forge-aware release step
The skill SHALL choose the release command from the origin remote: GitHub hosts use `gh`, GitLab hosts use `glab`. When the forge is unknown, or the CLI is missing or not authenticated, the skill SHALL skip the release, say so, and print the manual command.

#### Scenario: GitLab remote
- **WHEN** `git remote get-url origin` names a GitLab host and `glab` is on PATH
- **THEN** the release is created with `glab release create` against the new tag

#### Scenario: No forge CLI
- **WHEN** neither `gh` nor `glab` is installed
- **THEN** the commit, tag, and push still happen, the release is skipped, and the report names the skipped step

### Requirement: Report
The skill SHALL end with a report naming the old and new version, every file edited, the commit, the tag, the push result, and the release URL or the reason the release was skipped.

#### Scenario: Successful run
- **WHEN** every step completes
- **THEN** the report lists each step with its outcome and the release URL
