# OpenSpec layout the skill reads

The skill needs no openspec CLI and no openspec skill. It reads plain Markdown through `scripts/issue-context.sh`. When that script cannot run, the bounded fallback in SKILL.md step 4 reads the same headings by hand.

## Where things live

- `openspec/specs/<name>/spec.md`: one folder per capability. The folder name is the capability name. A name holding anything but lowercase letters, digits and hyphens, or starting with a hyphen, is left out of the index, because the outline would reject it.
- `openspec/changes/<name>/`: one folder per in-flight change, with `proposal.md` and often `design.md`, `tasks.md` and `specs/`. The same name rule applies.
- `openspec/changes/archive/`: finished changes. The skill never reads it, because archived work is already folded into the specs.
- `openspec/config.yaml`: project settings. The skill reads only the line containing `Domain:`.
- `docs/*.md`: top-level docs. The skill reads personas, the glossary, and titles from files whose name contains `KNOWN_ISSUES` or `BACKLOG` (and holds only letters, digits, `.`, `_` and `-`).

## Headings the skill reads

| Heading | Where | What the skill takes |
|---|---|---|
| `## Purpose` | `spec.md` | the first paragraph: first sentence in the index, full paragraph in the outline |
| `### Requirement: <title>` | `spec.md` | the title only |
| `#### Scenario: <title>` | `spec.md` | the title only, nested under its requirement |
| `## Why` | `proposal.md` | the first paragraph: first sentence in the index, up to 600 characters in the outline |

Requirement and scenario bodies are never printed. A title is enough to cite a behaviour, and reading bodies would cost more than the issue needs.

## Missing pieces

A project may have no `openspec/`, no `docs/`, no config line, or no proposal. The index then prints `absent` for that section, or an empty Why, and the skill carries on with what it has. Cite only names the index or outline printed in this run.
