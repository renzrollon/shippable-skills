# bump-release

Share this skill as the folder that holds its human README: [`skills/engineering/bump-release/`](../../skills/engineering/bump-release/).

## What it does

`bump-release` changes a project's version in **every** file that carries it,
then commits, tags, pushes, and cuts a release, in one pass.

A version usually lives in more than one place. A repo that is also a Claude
Code plugin keeps its real version in `.claude-plugin/plugin.json`, a Rust crate
in `Cargo.toml`, a Python package in `pyproject.toml`. A bump that touches only
`package.json` ships silently wrong, and whatever reads the other file (an
updater, a registry, a marketplace) sees the old number. The skill finds all of
them before it edits any.

The order is fixed:

1. Check for release automation (changesets, lerna, release-please,
   semantic-release). If one owns releases, stop.
2. Discover every manifest that carries the current version. Stop if two
   disagree.
3. Resolve the target version.
4. Check git state, then print `## Release preview` and wait for a yes.
5. Edit, refresh lockfiles with the ecosystem's own command, commit.
6. Tag, push, and create the release with `gh` or `glab`.
7. Print `## Release report`.

Steps 1 to 3 read files only. No git command runs before step 4.

## When to reach for it

You invoke this by typing `/bump-release`; the agent will not reach for it on
its own. Pass nothing for a patch bump, `major`, `minor`, or `patch`, an exact
version like `1.4.0`, or `prerelease <id>`.

| Situation | Why this skill |
| --- | --- |
| The repo has more than one manifest | Every one is found and edited together |
| You are about to tag a release | Commit, annotated tag, push, and release in one reviewed pass |
| You want to see the change first | The preview lists each file as `old -> new` before any write |
| The release URL should exist when you are done | `gh` or `glab` creates it from the commit subjects |

Skip it when release automation owns your versions (it will name the tool and
stop anyway), or when you want hand-written release notes: it uses commit
subjects only and asks if you want more.

## Common questions

**Does it work outside Claude Code?**
Yes. It is a standard Agent Skills package and needs only `git`. Install from
the [collection README](../../README.md). Release creation uses `gh` or `glab`
when present and prints the manual command when neither is.

**What if my working tree has changes?**
It stops before the preview, lists the dirty files, and edits nothing. A bump
commit should not carry unrelated work.

**What if the push is rejected?**
It never force-pushes. The local commit and tag stay, the release is skipped,
and it prints the commands to finish by hand.

**Does it touch lockfiles?**
Only through the ecosystem's own refresh command, never by hand. If the command
is missing or fails, that lockfile is left unstaged and the report says so.

**What if the tag already exists?**
On the current `HEAD` it is treated as a finished earlier run. Anywhere else it
stops and asks before moving or replacing it.

**What does it use for the tag prefix and the forge?**
The prefix comes from existing version tags (default `v`). The forge comes from
the `origin` remote.

## It's working if

- `## Release preview` listed every manifest you would have named, plus any you
  forgot, before anything changed.
- After the run, no manifest in the repo carries the old version.
- The commit is `chore: bump version to <version>`, stages files by name, and
  the tag points at it.
- `## Release report` has one line per step, and a skipped step says why.
- A refusal (automation, disagreement, dirty tree, not greater) edited nothing
  and said so.

### Manual checks

Run these once after a first release to confirm the result:

```bash
git show --stat HEAD
git tag --list --sort=-v:refname | head -3
git ls-remote --tags origin | tail -3
grep -rn "<old-version>" --include=package.json --include=plugin.json --include=Cargo.toml --include=pyproject.toml .
```

- The last commit touches only manifests and refreshed lockfiles.
- The new tag exists locally and on the remote, and points at that commit.
- The `grep` finds the old version in no manifest.
- On a throwaway clone, run the skill with no remote and confirm it commits and
  tags locally and reports push and release as skipped.
