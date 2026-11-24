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

Helper scripts are tested with BSD awk (macOS). gawk and busybox awk are
unverified.

Not yet run through the SkillGantry gate.
