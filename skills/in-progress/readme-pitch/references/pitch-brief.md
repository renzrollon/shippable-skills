# Pitch brief

Facts come from the inventory. Decisions come from the maintainer, or from a
recommendation the skill derives from the facts and then names out loud.
This file is the decisions side. Never ask the user for a fact the repo can
settle, and never decide silently.

## The five decisions

One round. At most five questions. Each carries a recommended answer derived
from the inventory so the user can reply by number and letter.

| # | Decision | Derive the recommendation from | Values |
|---|----------|-------------------------------|--------|
| 1 | Reader | package description, existing tagline, site copy, repo topics | free text: who opens this README and what they already know |
| 2 | Archetype | Phase 1 detection, first match in priority order | `cli`, `library`, `service`, `action-or-plugin`, `app`, `research-or-dataset` |
| 3 | Claim | the package description when it states an outcome; else the first sentence the README's own "why" section can defend | one sentence under 20 words, plus the category word a reader would search |
| 4 | Register | the existing tagline's register when it has one; else `outcome` | `problem`, `outcome`, `category`, `host`, `verb`, `deadpan` |
| 5 | Comparison | `named` when `--repos` was given or brief A will run; else `skip` | `named`, `unnamed`, `skip` |

Register meanings: **problem** names the reader's pain; **outcome** names
what they get; **category** names what it is, for search; **host** names
where it runs; **verb** leads with what to do; **deadpan** states the fact
flat.

Comparison meanings: **named** means section 10 names rivals, and every
rival came from `--repos`, this brief, or a research report that fetched
it; **unnamed** means section 10 states the axis and the trade without
naming anyone; **skip** drops section 10.

## Modes

| Mode | What happens | `DECISIONS:` source |
|------|--------------|---------------------|
| default | Take every recommendation. Ask nothing: not one question, not even on a host with a question tool. | `assumed` |
| `--ask` | Print the round below, end the turn, wait. Parse the reply. Unanswered items take the recommendation. | `asked` |
| `--brief <path>` | Read the file (format below). Blank fields take the recommendation. Missing file: say so, use default mode. | `brief <path>` |
| re-run | A `readme-pitch-brief-*.md` already in the handoff dir: the newest one is the recommendation source. `--brief` overrides it. | `brief <path>` in default mode; `asked` with `--ask` |

`--ask` together with `--brief` or a reloaded brief: the round still runs,
with the file's answers as the recommendations.

## The round (`--ask`)

Print this shape, then stop and wait. Do not answer your own questions.
Offer at most two options per question; a question with one defensible
answer gets one option and the recommendation.

```markdown
### Pitch brief for <repo>

**1. Reader.** Who opens this README, and what do they already know?
   a) <recommended, and the fact it came from>
   b) <one alternative the facts also support>
➡️ Recommended: a

**2. Archetype.** Which face of the repo leads the pitch?
   a) <detected> (found <signal> in <file>)
   b) <second match, if any>
➡️ Recommended: a

**3. Claim.** The one sentence the first screen must make true.
   a) <recommended, under 20 words> (category word: <x>)
   b) <alternative>
➡️ Recommended: a

**4. Register.** How the tagline speaks.
   a) problem  b) outcome  c) category  d) host  e) verb  f) deadpan
➡️ Recommended: <letter> (<why, from the facts>)

**5. Comparison.** Does the README name rivals?
   a) named (<rivals from --repos or research>)  b) unnamed  c) skip
➡️ Recommended: <letter> (<why>)

Reply by number and letter (`1a 2a 3b 4b 5c`), or free text per number.
Reply `go` to take every recommendation.
```

## Brief file format

Written to `$HAND/readme-pitch-brief-<timestamp>.md` in every mode. This is
also the format `--brief <path>` reads. The headings are the contract; keep
them exact. A blank section means "take the recommendation".

```markdown
# Pitch brief: <repo>

- created: <ISO-8601>
- source: assumed | asked | brief <path>
- inventory: <path>

## Reader
<one or two sentences>

## Archetype
<cli | library | service | action-or-plugin | app | research-or-dataset>
detected: <signal> in <file>

## Claim
<one sentence, under 20 words>
category word: <x>

## Register
<problem | outcome | category | host | verb | deadpan>

## Comparison
<named | unnamed | skip>
rivals: <owner/repo, ...> | none

## Non-goals
<what the README must not claim; may be empty>
```

## The `DECISIONS:` report line

One line in the Phase 8 block, source token first, then the five decisions
in order:

```
DECISIONS: <assumed | asked | brief <path>> | reader: <...> | archetype: <...> | claim: <...> | register: <...> | compare: <named | unnamed | skip>
```

Evals grep `^DECISIONS: (assumed|asked|brief )`. Keep the claim on the same
line; it is under 20 words by construction.
