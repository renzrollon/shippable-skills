# Changelog

## 0.1.0 (unreleased)

First version. Turns a one-line request into a GitLab issue that cites the
project's own OpenSpec capabilities and docs, keeps the top of the body in plain
language, and collapses technical notes at the end. Creates through a host
issue tool, else `glab`, else returns a draft. Works from a local checkout or a
fresh sparse copy.

Helper scripts are tested with BSD awk (macOS). gawk and busybox awk are
unverified.

Not yet run through the SkillGantry gate.
