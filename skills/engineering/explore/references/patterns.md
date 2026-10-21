# Investigation patterns

Guidance, not a procedure. Pick the pattern that matches the question's shape.

## The four patterns

**1. Subsystem mapping.** The question spans several parts of the system. One investigator per stage of the flow. Synthesize a diagram plus narrative.
Example: "How does a file upload get from the browser to storage?" Investigators: client form and request, API handler and validation, storage adapter and post-processing.

**2. Option comparison.** Several viable approaches. One investigator per option, each reporting fit against this codebase, not generic pros and cons. Synthesize a comparison table plus a recommendation.
Example: "Should we cache with an in-process map or an external store?" Investigators: in-process option, external option, each checked against deployment shape and existing config.

**3. Layer sweep.** "Where does X happen?" when X could happen at several layers. One investigator per layer. Synthesize what each layer catches and where the gaps are.
Example: "Where do we validate email addresses?" Investigators: client, API, domain logic, persistence constraints.

**4. Impact analysis.** A change would alter what a value means or who reads it. One investigator per disjoint layer of the blast radius. Synthesize an impact map with severity per area, and flag readers still on the raw form. Mandatory when the fire signals in `invariant-sweep.md` apply.
Example: "We want to lower-case emails before storing them." Investigators: write paths, read and lookup paths, API and auth, frontend, tests and fixtures.

## Fan out when

| Signal | Example |
|--------|---------|
| Multiple subsystems touched | "How does deployment work end to end?" |
| Options to compare | "Which queue should we use?" |
| Cross-file tracing | "What validates the uploaded archive?" |
| Architecture mapping | "Map how auth flows through the system." |
| A shared value changes meaning | Pattern 4, always |

Use two to five investigators. One is not a fan-out. More than five means the decomposition is too fine.

## Stay single-threaded when

| Situation | Why |
|-----------|-----|
| A question that names one file | One reader is faster than a briefing. |
| Back-and-forth conversation | The user is steering. |
| Quick clarification | Not worth the setup. |
| Step B depends on the answer to step A | Parallel work cannot start. |
| The user is thinking out loud | Listen first. |

When unsure, start single-threaded and escalate once the question proves broader than it looked.

## Investigator rules

1. Focused prompts: "trace the flow of Y through files A, B, C", not "explore X".
2. Read-only. Investigators search, read, and report. They never write.
3. Disjoint scopes, so findings merge cleanly. For Pattern 4 this is load-bearing.
4. Locate before reading: search first, then read the relevant spans, not whole files.
5. Return JSON only.
6. Fill every placeholder in the prompt before sending. An unresolved placeholder halts the fan-out.

When the host has no subagent tool, run the same scopes yourself, one after another, and record `investigation: sequential`.

## Prompt template

```
Investigate: [[SPECIFIC_QUESTION]]

Context: [[BROADER_TOPIC]]

Scope: [[FILES_OR_LAYER_THIS_INVESTIGATOR_OWNS]]

Look for:
- [specific thing 1]
- [specific thing 2]

You are read-only. Do not edit anything.

Return JSON only:
{ "files": [{ "path": "", "lines": "" }], "how": "", "connections": [], "gaps": [] }
```

## Return schema

| Key | Type | Meaning |
|-----|------|---------|
| `files` | array of `{ path, lines }` | Files that matter and the spans that matter in them. |
| `how` | string | How it works, in a few sentences. |
| `connections` | array of strings | Other modules, callers, or readers this touches. |
| `gaps` | array of strings | What the investigator could not determine. |

## Synthesis

Never paste raw investigator output. Merge overlapping findings, build one picture (a diagram where structure matters), name the gaps no one covered, surface contradictions with the evidence on each side, and run a completeness check: a layer not swept, a reader not checked, an option not costed. Then offer a direction.
