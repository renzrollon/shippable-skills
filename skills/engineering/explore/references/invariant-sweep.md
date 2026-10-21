# Invariant sweep

When a change alters an invariant on shared or derived state, the unit of work is the invariant, not the file.

## The problem

Reviews and plans are usually scoped to the diff. That scope is right for most changes and wrong for one class: a change that transforms a value read in more than one place. The updated paths are in the diff. The stale readers are not, so a diff-scoped check cannot see them.

Example: a dedup change lower-cases an email in the write path. A reader that still compares the raw email case-sensitively silently stops matching. Nothing in the diff shows it.

## The rule

The change is not done, and the exploration is not done, until every reader of that value has been enumerated and confirmed to read the canonical form. Two halves:

1. Normalize once at the boundary. State where the single canonical transform lives and assert every consumer reads the canonical form. Scattering it across call sites guarantees one is missed.
2. Sweep the consumers. Enumerate every reader repo-wide, not just in the diff. A reader still on the raw form is part of the change, not scope creep.

## Fire signals

Run the sweep when the change touches a value stored on a shared object, or derived and read elsewhere:

- A session, token, or auth field, a request context, or a principal.
- A cache key, map key, dedup key, or any identity used in a comparison, a set or map, or a `WHERE` or equality check.
- A normalized form of user input: casing, trimming, encoding, Unicode normalization, ID or slug canonicalization.
- Anything the design describes with "normalize", "canonical", "dedupe", "match", or "lookup by".

If none apply (one reader, no shared identity), do not sweep. Sweeping every change defeats the point of scoping.

## Severity

A reader consuming the raw form of a value that the change canonicalizes elsewhere is a blocker. It is a live correctness bug with a data-dependent trigger: it fails only for inputs that differ before and after the transform, which is the set no happy-path test exercises.

## Grep-based sweep

Two layers.

1. Structural. List every reader of the value: the field name, its getter, the map or cache key, the comparison sites.
   ```bash
   grep -rn --exclude-dir=node_modules --exclude-dir=.git "<field-or-symbol>" .
   ```
   Then widen to readers a symbol search misses: bracket access (`obj["field"]`), computed keys, SQL text, templates, generated code, config, and tests. If the host has a code-graph or language-server tool, use it first and still grep afterwards.
2. Semantic. For each reader, decide whether it consumes the canonical or the raw form. A raw-form reader, or a case- or format-sensitive comparison, is a defect.

## When fanning out

Assign one investigator per layer (data, API, business logic, frontend, tests) with disjoint scopes so findings merge without overlap. Each enumerates readers in its layer only. In synthesis, merge and flag every raw-form reader. If a layer went unswept, say so outright: a silent gap reads as "everything was covered".
