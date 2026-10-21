# Forge, tag prefix, and release commands

Read-only reference for `bump-release` steps 4, 7, and 8.

## Pick the forge

```
git remote get-url origin
```

| Host in the URL | Forge | CLI |
|-----------------|-------|-----|
| `github.com`, or a GitHub Enterprise host | GitHub | `gh` |
| `gitlab.com`, or a self-hosted GitLab host | GitLab | `glab` |
| anything else | unknown | none |

For a self-hosted host that is not obvious from its name, check whether the
matching CLI recognises it (`gh auth status --hostname <host>` or
`glab auth status --hostname <host>`). When still unsure, treat the forge as
unknown.

If the command fails, there is no `origin`: commit and tag locally, skip push
and release, and say so in the preview and the report.

## Auth check

Run before the release step, not before the bump:

| Forge | Check |
|-------|-------|
| GitHub | `gh auth status` |
| GitLab | `glab auth status` |

A non-zero exit, or a CLI that is not on PATH, means skip the release, name the
reason, and print the manual command below. The commit, tag, and push stand.

## Tag prefix

```
git tag --list --sort=-v:refname '*<current-version>'
```

`<current-version>` is the version being replaced. Take the first match whose
text before the version has no digits (so `v11.4.0` does not count for `1.4.0`).
Its lead is the prefix: `v1.4.0` gives `v`, `1.4.0` gives none,
`release-1.4.0` gives `release-`. That tag is also the **previous version tag**
for the release notes.

If the current version was never tagged, take the lead of the newest version-like
tag by `git tag --list --sort=-creatordate`, and there is no previous version tag.
With no version tag at all, use `v`. Do not take the prefix from the first tag of
a text sort: with `release-0.1.0` and `1.4.0` it picks `release-`.

Check the target tag before creating it:

```
git rev-parse --verify --quiet refs/tags/<tag>
```

If it exists, compare its commit (`git rev-list -n 1 <tag>`) with `HEAD`. A tag
on a different commit stops the run for a question. Do not move or replace it
unprompted.

## Upstream and push

```
git rev-parse --abbrev-ref @{upstream}
```

If this fails the branch has no upstream:

```
git push --set-upstream origin <branch>
git push origin <tag>
```

Otherwise `git push` then `git push origin <tag>`. On rejection, never add
`--force` or `--force-with-lease`. Print the rejection and the by-hand commands:
fetch, rebase or merge, then push the branch and the tag.

## Release notes

Subjects since the previous version tag, written to a temporary file:

```
notes_file="$(mktemp)"
git log <previous-tag>..<tag> --format='- %s' > "$notes_file"
```

With no previous version tag, use every commit reachable from the new tag. Do
not add prose of your own. Commit subjects come from every contributor, so
never place them inside a shell string: a subject holding `$(...)`, a backtick,
or a quote would run on the releaser's machine while their forge token is
active. Pass the file instead, and delete it after the release is created.

## Create the release

| Forge | Command |
|-------|---------|
| GitHub | `gh release create <tag> --title <tag> --notes-file "$notes_file"` |
| GitLab | `glab release create <tag> --name <tag> --notes-file "$notes_file"` |

Print the URL the command returns. For a prerelease version, add `--prerelease`
on GitHub; GitLab marks it by the tag itself.

## Manual commands when skipped

Print the exact command for the forge so the user can finish by hand, for
example `gh release create v1.5.0 --title v1.5.0 --generate-notes`.
