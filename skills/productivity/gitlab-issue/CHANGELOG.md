# Changelog

## 0.1.0 (unreleased)

First version. Turns a one-line request into a GitLab issue that cites the
project's own OpenSpec capabilities and docs, keeps the top of the body in plain
language, and collapses technical notes at the end. Creates through a host
issue tool, else `glab`, else returns a draft. Works from a local checkout or a
fresh sparse copy.

The body follows what large public repos ask for in their issue templates. A
feature has a Why section. A bug has an Environment section and puts a long
pasted log in its own collapsed block. Acceptance criteria are headed
`(proposed)` and come in pairs: the change, plus an edge or unchanged case.
Gaps read `Not stated` and are asked about under Open questions. The technical
notes name the commit the context was read at.

A project can set a type label per kind with `shippable-issue-bug-label:` and
`shippable-issue-feature-label:` lines in its instruction file. A request that
looks like a security report is not filed unless it asks for a confidential
issue.

Creating through `glab` goes through a bundled `scripts/create-issue.sh`. It
reads the title, body and metadata from files in the temporary directory,
checks each label, assignee and milestone (a value must start with a letter or
digit, so none can pass as a flag), passes them as `--flag=value`, and removes
its files whatever the outcome. It refuses a work directory outside the
temporary directory.

A folder with `openspec/` or `docs/` but no GitLab project still gives the
draft its context, and a checkout with no commit shows `(no commit)`. When
several `Not created:` reasons apply, the reply gives the first in a fixed
order. The fetch uses `glab` only when it is signed in to the host, else `git`,
and switches off every prompt. The index leaves out folder names the outline
would reject. Both helpers print repo text with `printf`, so a backslash in a
Purpose line is no longer expanded or cut short.

Section rules live only in `references/issue-templates.md`. The evals mount the
fixture repo, add near-miss negatives, and grade line positions with scripts
that have their own offline test.

Helper scripts are tested under macOS `sh`, `dash` and `bash`, with BSD awk.
gawk and busybox awk are unverified.

Not yet run through the SkillGantry gate.
