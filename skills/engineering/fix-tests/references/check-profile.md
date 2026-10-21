# Check profile

The check profile records how this project's checks run, so a second run asks nothing. This file holds the field list, the managed block, the JSON cache rules, and the discovery ladder.

## Fields

| Field | Meaning |
|-------|---------|
| `unit` | Command, cwd, filter syntax (subset by name, with a `<pattern>` placeholder), single-file syntax, timeout, prerequisites (dev server, seeded database, browser install). |
| `typecheck` | Command that type-checks, or none. |
| `lint` | Command that lints, or none. |
| `build` | Command that builds, or none. Nullable. |
| `e2e` | Opt-in. Command, cwd, filter and single-file syntax, timeout, prerequisites. Never run unless the user asks and a command is set. |
| `known flaky` | Paths or test-name patterns that flip on re-run. Recorded, not fixed. |
| `discovered-from` | Where each answer came from (`package.json#scripts.test`, `pom.xml`, CI job name, interview). |

Env values are names or placeholders only, never secrets.

## Managed block

The block lives in the instruction file: the first existing of `AGENTS.md`, `CLAUDE.md`, `.github/copilot-instructions.md` at the repo root. When none exists, create `AGENTS.md`.

```markdown
<!-- BEGIN shippable:checks -->
unit: <command> (cwd: <cwd>)
unit filter: <syntax>
unit single file: <syntax>
unit timeout: <ms or none>
typecheck: <command or none found (<where it looked>)>
lint: <command or none found (<where it looked>)>
build: <command or none found (<where it looked>)>
e2e: <command or "opt-in, not configured">
prerequisites: <list or none>
known flaky: <list or none>
discovered-from: <list>
<!-- END shippable:checks -->
```

Rules:

- The block is authoritative. A human edit always wins.
- Both fences present: replace only the interior and leave surrounding prose alone.
- Fences absent: append the block at the end of the file. Never write a second pair.
- A second run that finds exactly what the block records leaves it byte-identical.
- This skill owns the fenced block, so it writes it without asking and names the write in the report. Any edit outside the fence waits for a yes.
- A denied write does not stop the run. Print the profile in the report instead.

## JSON cache

Path: `<state-dir>/testing/profile.json`. The state directory is a path the user passed (`--state-dir`) or named in the request, else a `shippable-state-dir: <path>` line in the instruction file (ignored when absolute or containing `..`), else `.claude/` when it exists, else `.agents/`.

The cache mirrors the block and exists so the profile survives a declined or denied block write.

```json
{
  "unit": { "command": "npm test", "cwd": ".", "filter": "...", "single_file": "...", "timeout_ms": 120000, "prerequisites": [] },
  "typecheck": null,
  "lint": { "command": "npm run lint" },
  "known_flaky": [],
  "discovered_from": ["package.json#scripts.test"],
  "notes": { "typecheck": "looked in package.json scripts, tsconfig.json, CI; found none" }
}
```

- Hold only fields the writer looked for. An absent key means "not looked". `null` means "looked and found nothing".
- Every `null` gets an entry under the top-level `notes` object, keyed by field name, saying where it looked. The block reads `none found (<where it looked>)` for the same field.
- Preserve unknown keys verbatim on rewrite.
- Block and cache disagree: the block wins, and the cache is rewritten from it. Every block line has a cache key: `unit` to `unit.command` and `unit.cwd`, `unit filter` to `unit.filter`, `unit single file` to `unit.single_file`, `unit timeout` to `unit.timeout_ms` (`none` is `null`), `prerequisites` to `unit.prerequisites`, `known flaky` to `known_flaky`, `discovered-from` to `discovered_from`.
- Stale entry: the command names a script the manifest no longer defines, or exits 127 or "not found". Rediscover without asking, rewrite both, and say the old command was stale.

## Discovery ladder

Headless first. Stop when confident enough to write a profile.

1. Manifests and their scripts.
   - Node: `package.json` scripts `test`, `test:unit`, `test:ci`, `typecheck`, `lint`, `build`.
   - Python: `pyproject.toml` (`[tool.pytest]`), `pytest.ini`, `tox.ini`. Command is `pytest` or `tox`.
   - Go: `go.mod`. Command is `go test ./...`.
   - Rust: `Cargo.toml`. Command is `cargo test`.
   - Maven: `pom.xml`. Command is `mvn test`. Single class: `mvn -Dtest=<Class> test`.
   - Gradle: `build.gradle` or `build.gradle.kts`. Command is `./gradlew test` when the wrapper exists, else `gradle test`. Filter: `--tests <pattern>`.
   - dotnet: `*.csproj` or `*.sln`. Command is `dotnet test`. Filter: `--filter <expr>`.
   - Ruby: `Gemfile` with rspec. Command is `bundle exec rspec`. Single file: `bundle exec rspec <path>`.
   - Makefile: a `test` target. Command is `make test`.
2. Runner config files, to infer filter and single-file syntax: `vitest.config.*`, `jest.config.*`, `playwright.config.*`, `.mocharc.*`, `.rspec`, `pytest.ini`. Node's built-in runner is `node --test` with `--test-name-pattern`.
3. CI workflows (`.github/workflows/*`, `.gitlab-ci.yml`, others). Prefer the job that runs unit tests on pull requests. Capture env and prerequisites from it.
4. Ask. Only when no unit command was found, ask at most four questions, once: the unit command, filter or single-file syntax if not inferable, required env or prerequisites, and the e2e command only if the user asked about e2e. Only this skill interviews the user about test setup.

Typecheck, lint, and build come from the same sources (scripts, `tsc`, `mypy`, `ruff`, `eslint`, `cargo clippy`, `go vet`). Never ask for them and never install tooling to obtain one: nothing found means `null` plus a note.

When the proposed binary is not on PATH (for example `mvn` absent), record the command, classify the run `env-config`, install nothing, and stop with the missing binary named.

Every later run is zero-question unless the user asks to reconfigure.
