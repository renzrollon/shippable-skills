---
name: bump-release
description: Bump the project's version in every manifest at once, then commit, tag, push, and cut a release, so no manifest keeps a stale version.
license: MIT
argument-hint: "[version | major | minor | patch | prerelease <id>]"
disable-model-invocation: true
metadata:
  version: 0.1.0
---

Bump a project's version everywhere it lives, then commit, tag, push, and cut a
release in one pass.

A version usually lives in more than one file. A bump that only touches the
obvious one (`package.json`) ships silently wrong: a repo that is also a Claude
Code plugin keeps its real version in `.claude-plugin/plugin.json`, a Rust crate
in `Cargo.toml`, a Python package in `pyproject.toml`, and whichever tool reads
the version (an updater, a registry, a marketplace) may not be the file you
remembered. This skill finds them all before it edits any.

This skill is **host-neutral**. It runs on Cursor, Copilot, Codex, Claude Code,
and any other Agent Skills host, and it needs only `git`. Release creation uses
`gh` or `glab` when present and is skipped with the manual command printed when
neither is.

**Never block on I/O.** A denied or failed command is reported once with no
retry and no alternate guess. The one exception is the confirmation in step 4:
no write happens without it.

---

## Output contract (non-negotiable)

**You are running bump-release right now.** These instructions are in your
context because the skill was invoked, so run the steps in this reply.

Automation greps for fixed headings, so keep these exact:

1. Before any write, print `## Release preview` with the old version, the new
   version, the tag, the push target (`push: <remote> <branch>`, or `push:
   skipped (<reason>)`), the public release (`release: <forge> <tag>`, or
   `release: skipped (<reason>)`), and one line per file to edit
   (`path  old -> new`). Then ask for confirmation. The one yes covers the edit,
   commit, tag, push, and release, so the preview must name all of them. Nothing
   is edited, committed, tagged, or pushed before a yes.
2. End every run, including a stopped run, with `## Release report` listing:
   old and new version (the new version reads `not resolved` when the run
   stopped before step 3), each file edited, the commit, the tag, the push result,
   and the release URL or the reason the release was skipped. A stopped run
   says which step stopped it and states that no file was edited (or which were,
   if the stop came after edits).

---

## Input

| Argument | Meaning |
|----------|---------|
| _(none)_ | `patch` bump of the current version |
| `1.4.0` | Exact version. Must be greater than the current version. |
| `major` / `minor` / `patch` | Semver bump of the current version |
| `prerelease <id>` | `1.4.0` becomes `1.5.0-<id>.0`; `1.5.0-<id>.0` becomes `1.5.0-<id>.1` |

Natural language works ("cut a minor release", "bump to 2.0.0").

---

## Steps

The order matters. Steps 1 to 3 read files only. No git command runs before
step 4, so a repo that uses release automation, or has no manifest, stops
before git is touched.

### 1. Release automation check

Look for a tool that owns releases: changesets (`.changeset/`), lerna version
(`lerna.json` with a `version` command in use), release-please
(`release-please-config.json`, `.release-please-manifest.json`, or a workflow
that names it), semantic-release (`.releaserc*`, a `release` key in
`package.json`, or a `semantic-release` script). Detection list and file names
are in [references/manifests.md](references/manifests.md).

When one is found, make no edit, name the tool and the file that showed it, and
go to the report. A hand bump would fight the tool.

### 2. Discover every version-bearing manifest

Find all manifests before editing any. The table, the field for each, the
broader sweep, and the lockfile exclusions are in
[references/manifests.md](references/manifests.md).

- A filename match alone does not qualify a file. Confirm the file carries the
  current version string in the expected field.
- Lockfiles (`package-lock.json`, `yarn.lock`, `pnpm-lock.yaml`, `Cargo.lock`,
  `uv.lock`, `poetry.lock`) are never in the manifest list. They are refreshed
  in step 5.
- Any hit from the broader sweep that the table did not name is a candidate the
  user must confirm or skip. Never silently include or exclude one.
- A `marketplace.json` `plugins[]` array is matched by plugin name, not by
  position.

If no manifest carries a version, stop and report that nothing was found.

**Disagreement.** If two manifests carry different current versions, stop before
any edit, list each manifest with its version, and ask which is authoritative.

### 3. Resolve the target version

- Exact version: use it as given. If it is not greater than the current version
  (semver comparison), stop before any edit and name both versions.
- Keyword: apply it to the authoritative current version. No argument means
  `patch`.

### 4. Starting state, then preview

Now, and only now, use git.

1. `git rev-parse --is-inside-work-tree`. If this is not a git repository, stop
   and edit nothing.
2. `git status --porcelain`. If it is non-empty, stop before the preview, list
   the dirty files, and edit nothing. Do not sweep unrelated changes into the
   release commit.
3. Detect the tag prefix from existing version tags and the forge from the
   `origin` remote (commands in [references/forge.md](references/forge.md)).
   Default prefix is `v`. If the target tag already exists, check what it points
   at: on the current `HEAD` it is a finished earlier run; on any other commit,
   stop and ask before moving or replacing it. Never move a tag without that
   answer.
4. `git remote get-url origin`. If it fails, the repo has no remote: the
   preview says push and release will be skipped, and the run still commits and
   tags locally.
5. Print `## Release preview` (see the output contract) and ask. If the answer
   is no, change nothing and report what would have been done.

### 5. Edit, refresh lockfiles, commit

1. Apply every edit from the preview, and only those.
2. Refresh each lockfile that carried the old version with the ecosystem's own
   command ([references/manifests.md](references/manifests.md)). Never hand-edit
   a lockfile. If the refresh command is missing or fails, say so and leave that
   lockfile unstaged.
3. Stage the bumped files and any refreshed lockfile by name. Never `git add -A`
   or `git add .`.
4. Commit with `chore: bump version to <version>`.

### 6. Tag

Create an annotated tag `<prefix><version>` on the new commit. The message is
the tag name.

### 7. Push

Skip when there is no remote.

1. If the current branch has no upstream (`git rev-parse --abbrev-ref @{upstream}`
   fails), push with `git push --set-upstream origin <branch>`. Otherwise
   `git push`.
2. Push the tag by name: `git push origin <tag>`.

**Rejected push.** If either push is rejected (for example non-fast-forward),
do not force-push and do not rewrite history. Stop, keep the local commit and
tag, skip the release, show the rejection, and print the commands to finish by
hand. If the remote reports the repository moved, show the message verbatim and
ask before changing the `origin` URL.

### 8. Release

Skip when there is no remote, when the push failed, or when the forge is
unknown. Otherwise create the release with `gh release create` (GitHub) or
`glab release create` (GitLab) against the new tag, with notes built from the
commit subjects since the previous version tag. See
[references/forge.md](references/forge.md).

If the CLI is missing or not authenticated, skip the release, say which, and
print the manual command. The commit, tag, and push stand.

### 9. Report

Print `## Release report` per the output contract. One line per step with its
outcome. Mark skipped steps as skipped with the reason.

---

## Rules

- Discover first, edit second. No edit before the preview is confirmed.
- No git command before step 4. Automation, manifests, and the target version
  are decided from files alone.
- Stage by name. Never `git add -A` or `git add .`.
- Never force-push, force-move a tag, or retry a rejected push.
- Never invent release notes beyond the commit subjects. If the user wants
  curated notes, ask for them.
- Never change remote configuration as a side effect of a bump.
- A missing forge CLI skips the release only. It never undoes the commit, tag,
  or push.

---

## Related

- Manifest table, lockfile commands, automation list: [references/manifests.md](references/manifests.md)
- Forge commands, auth check, tag prefix: [references/forge.md](references/forge.md)
