# gitlab-issue

Share this skill as the folder that holds its human README: [`skills/productivity/gitlab-issue/`](../../skills/productivity/gitlab-issue/).

## What it does

`gitlab-issue` turns a one-line request into one GitLab issue. It reads the
project's OpenSpec capabilities and docs, then writes a body a product owner
can read. A feature has a summary, the reason, who is affected, today's
behaviour, the wanted behaviour, proposed acceptance criteria, and related
items. A bug swaps the middle for the environment, steps, expected and actual.
Developer detail and any long pasted log go last in collapsed `<details>`
blocks.

It does not fill a gap with a guess. A reason, a role, or an environment the
request did not give reads `Not stated`, and the body lists open questions for
whoever triages the issue.

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
| A product owner wants a feature logged | Proposed acceptance criteria as checkboxes, plus overlapping changes |
| You want to review wording first | Say "draft" or "preview" and nothing is created |

Skip it for a passing "we should track this", for questions about existing
issues such as "what issues are open?", for commenting on, closing, or editing
an existing issue, and for issues on GitHub, Jira, or Linear.

## Common questions

**Why is there no index file under `.claude/graph/`?**
The skill never writes into a checkout. The index is printed fresh each run by
a script and lives only in that reply's working context.

**What happens without a checkout?**
It makes a fresh sparse copy in the system temporary directory, reads from it,
and deletes it before replying. The reply says `Context from: fresh copy`. To
pick the project, name it in the request or add one line to the instruction
file, for example `shippable-issue-project: gitlab.example.com/team/billing-export`.

**What happens in a folder with specs but no GitLab project?**
When no project resolves (none named, no `shippable-issue-project:` line, no
origin remote), the skill still reads the current folder's `openspec/` or
`docs/` for context. It fetches nothing and creates nothing, and ends on the
draft with `Not created: no target project`. A folder that is not a git repo,
or has no commit yet, shows `(no commit)` where the commit would go.

**Why does a draft say `Not created:` with one reason when several apply?**
The reply gives the first that applies, in this order: no subject given,
possible security report, draft requested, no target project, then the
creation error. A security report asked for as a draft says
`possible security report`, so you know it would not be filed either way.

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

**Why does the heading say "Acceptance criteria (proposed)"?**
The skill drafts the criteria from a short request, so nobody has agreed them
yet. A feature gets one for the change and one for an edge case or something
that must stay the same. A bug gets one for the fix and one for a neighbouring
case that must still work. Choices the request did not settle are asked under
`Open questions`.

**What does `Not stated` mean?**
The request and the project context did not say. `Why`, `Who is affected`, and
the two `Environment` lines use it. The skill does not make up a reason or work
out an environment from a URL.

**How do I get a type label on every bug or feature?**
Add `shippable-issue-bug-label: type::bug` or
`shippable-issue-feature-label: type::feature` to the instruction file, with
your own label names. Without a line the skill adds no label you did not name.

**What happens when I report a security problem?**
A request that describes a vulnerability or a data exposure is not filed unless
you ask for a confidential issue. You get the draft with
`Not created: possible security report`. Ask again with the word "confidential"
to file it.

**Which tools does it create with?**
A GitLab issue tool the host provides, first. If none exists, `glab`, through
the bundled `scripts/create-issue.sh`. If a host tool errors, it ends on the
draft and never falls through to `glab`, because a timed-out create may have
succeeded. The title, body, and any labels, assignee, or milestone reach the
shell only through files in the temporary directory. The script checks each
value, drops one that could be read as a flag or holds shell characters (for
example `--confidential` or `ui; rm -rf ~`), and the reply names what it
dropped. It removes its files whatever happens.

**Can I stop the agent from filing issues on its own?**
The skill is model-invoked, because product owners and testers ask in plain
chat. Three things keep it from filing by surprise: it needs an explicit ask,
"draft" or "preview" never creates, and a possible security report is held
back. If you never want it to run unasked, turn off implicit use for this one
skill in your host. In Claude Code, for a personal or project install, set
`"skillOverrides": { "gitlab-issue": "user-invocable-only" }` in your
settings, or cycle it in the `/skills` menu. Plugin installs are managed
through `/plugin` instead.

## It's working if

Manual checks:

- A run on a local checkout cites real capabilities that exist under
  `openspec/specs/`.
- A run with no checkout prints `Context from: fresh copy <branch> <commit>`.
- A `glab` creation prints an `Issue created:` URL that opens the new issue.
- A request that names the label `ui; rm -rf ~` creates the issue without it,
  and the reply names the dropped label.
- With `shippable-issue-bug-label: type::bug` in the instruction file, a created
  bug carries that label.
- A security report asked for as confidential is created with the confidential
  flag set.
- A creation through a host tool works and returns the issue URL.
- A host-tool error ends on `## Issue draft` with that error after `Not created:`.
- The `<details>` block renders collapsed in GitLab.
- A feature issue has a `Why` section, and it reads `Not stated` when you gave
  no reason.
- A bug issue has an `Environment` section, and a pasted stack trace sits in a
  collapsed `Logs` block.
- The technical notes open with `Context read at` and the commit.
- A draft in a folder with `openspec/` and no remote cites its capabilities and
  ends with `Not created: no target project`.
- Nothing new appears in the checkout afterwards (`git status` is unchanged).

## Migration plan

Additive only. To use it in a chat agent:

1. Install the collection into the agent's image (`npx skills add renzrollon/shippable-skills`, per the [collection README](../../README.md)).
2. Either run the agent in a checkout of the target project, or add `shippable-issue-project: <host>/<path>` to the agent's instruction file so it fetches a fresh copy per request.
3. For the fetch, make sure `glab` or `git` can already authenticate to the host.

Rollback is removing the skill. Nothing in any target repo changes.
