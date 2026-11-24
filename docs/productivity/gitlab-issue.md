# gitlab-issue

Share this skill as the folder that holds its human README: [`skills/productivity/gitlab-issue/`](../../skills/productivity/gitlab-issue/).

## What it does

`gitlab-issue` turns a one-line request into one GitLab issue. It reads the
project's OpenSpec capabilities and docs, then writes a body a product owner
can read: summary, who is affected, steps or current behaviour, expected
behaviour, acceptance criteria, and related items. Developer detail goes last in
a collapsed `<details>` block.

Every capability name, change name, and path comes from what the helper scripts
printed in that run. A request that matches nothing gets no invented citation.
It ends with fixed lines: `Issue created: <url>` or `## Issue draft` with a
`Not created:` reason, then `Context from:`, `Context used:`, and
`Possible duplicates:`.

## When to reach for it

The agent runs it when you explicitly ask: "create a gitlab issue", "raise a bug
on GitLab", "log a bug", "draft an issue".

| Situation | Why this skill |
| --- | --- |
| A tester reports a bug in chat | A titled `Bug: ` issue with the matching capability named |
| A product owner wants a feature logged | Acceptance criteria as checkboxes, plus overlapping changes |
| You want to review wording first | Say "draft" or "preview" and nothing is created |

Skip it for a passing "we should track this" and for questions about existing
issues such as "what issues are open?".

## Common questions

**Why is there no index file under `.claude/graph/`?**
The skill never writes into a checkout. The index is printed fresh each run by
a script and lives only in that reply's working context.

**What happens without a checkout?**
It makes a fresh sparse copy in the system temporary directory, reads from it,
and deletes it before replying. The reply says `Context from: fresh copy`. To
pick the project, name it in the request or add one line to the instruction
file, for example `shippable-issue-project: gitlab.example.com/team/billing-export`.

**How do tokens stay out of it?**
The skill never reads, prints, or passes a token, and never puts a credential in
a URL or command. It relies only on a login that `glab` or `git` already holds.
When the agent's token lives only in its MCP integration, export a token for
`glab` in the agent's environment (for example `GITLAB_TOKEN`), or sign `git`
in, before the run.

**How do technical notes stay out of the way?**
Above the `<details>` block there are no file paths, routes, table or column
names, or code taken from the repo. A Purpose line that names a table is
paraphrased. Requester-supplied text stays exactly as given.

**Which tools does it create with?**
A GitLab issue tool the host provides, first. If none exists, `glab`. If a host
tool errors, it ends on the draft and never falls through to `glab`, because a
timed-out create may have succeeded. Titles and bodies reach the shell only
through files.

## It's working if

Manual checks:

- A run on a local checkout cites real capabilities that exist under
  `openspec/specs/`.
- A run with no checkout prints `Context from: fresh copy <branch> <commit>`.
- A `glab` creation prints an `Issue created:` URL that opens the new issue.
- A creation through a host tool works and returns the issue URL.
- A host-tool error ends on `## Issue draft` with that error after `Not created:`.
- The `<details>` block renders collapsed in GitLab.
- Nothing new appears in the checkout afterwards (`git status` is unchanged).

## Migration plan

Additive only. To use it in a chat agent:

1. Install the collection into the agent's image (`npx skills add renzrollon/shippable-skills`, per the [collection README](../../README.md)).
2. Either run the agent in a checkout of the target project, or add `shippable-issue-project: <host>/<path>` to the agent's instruction file so it fetches a fresh copy per request.
3. For the fetch, make sure `glab` or `git` can already authenticate to the host.

Rollback is removing the skill. Nothing in any target repo changes.
