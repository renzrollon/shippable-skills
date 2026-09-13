# pitch-kit

[![Stars](https://img.shields.io/github/stars/example/pitch-kit)](https://github.com/example/pitch-kit)
[![Downloads](https://img.shields.io/npm/dm/pitch-fixture-eval)](https://npmjs.com/package/pitch-fixture-eval)
[![Coverage](https://img.shields.io/codecov/c/github/example/pitch-kit)](https://codecov.io)
[![Chat](https://img.shields.io/discord/0)](https://discord.gg/example)
[![Sponsor](https://img.shields.io/github/sponsors/example)](https://github.com/sponsors/example)
[![npm](https://img.shields.io/npm/v/pitch-fixture-eval)](https://npmjs.com/package/pitch-fixture-eval)
[![CI](https://github.com/example/pitch-kit/actions/workflows/ci.yml/badge.svg)](https://github.com/example/pitch-kit/actions)
[![License](https://img.shields.io/badge/license-MIT-blue)](LICENSE)

> Anniversary note: in 2024 we rewrote the prototype. Please read this whole file.

## Table of contents

- [Install](#install)
- [Quick start](#quick-start)
- [Philosophy](#philosophy)
- [Configuration](#configuration)
- [Architecture](#architecture)
- [CLI reference](#cli-reference)
- [Environment variables](#environment-variables)
- [Hooks](#hooks)
- [Release](#release)
- [FAQ](#faq)
- [Development](#development)
- [License](#license)

## Install

Compatible with Node.js 20.19 or newer

```bash
npm install -g pitch-fixture-eval
npx pitch-kit init
```

That is the first code block, before any image, which is the anti-pattern this fixture exists to correct.

## Quick start

```bash
npx pitch-kit ship
npx pitch-kit doctor
```

## Philosophy

pitch-kit believes a first screen should explain itself. This paragraph is
buried under badges, a table of contents, and an install fence, so a cold
reader never sees it in five seconds. The real product is a CLI that turns a
repository README into a first-screen pitch for people who already know the
domain.

## Configuration

All of this belongs in a CLI reference, not on the first screen.

- SENTINEL_WAVE_CAP: waves default to 4 concurrent agents
- SENTINEL_CONFIG_PATH: config lives at .pitchrc.json
- SENTINEL_CACHE_DIR: cache is .cache/pitch-kit

### Environment variables

| Name | Default | Meaning |
|------|---------|---------|
| PITCH_KIT_HOME | `~/.pitch-kit` | User config root |
| PITCH_KIT_LOG | `info` | Log level |
| PITCH_KIT_CACHE | `.cache/pitch-kit` | Cache directory |

### Hooks

SENTINEL_HOOK_ORDER: pre-commit runs lint then typecheck

Hook files live under `.pitch-kit/hooks/`. They are not part of the first
screen. Document them next to the CLI.

## Architecture

Boxes: parser -> planner -> writer -> verifier. This diagram-in-prose is
the wrong hero. A reader deciding whether to install does not need it.

![pitch-kit demo](docs/assets/demo.png)

The image above is the product running, but it sits after two code fences
and several H2s, so it is not a first-screen hero.

## CLI reference

`pitch-kit init` writes `.pitchrc.json`. `pitch-kit ship` runs the default
flow. `pitch-kit doctor` checks the local setup. Confirm against `--help`.

## Release

SENTINEL_RELEASE_TAG: tags are vMAJOR.MINOR.PATCH

Cut a tag only from main after CI is green. That procedure belongs in
CONTRIBUTING.md.

## Development

Clone, `npm test`, and read this file again. Restated pins follow so the
file stays long without inventing extra unique facts.

## FAQ 1

Q1. Do I still run `npx pitch-kit init` after install? Yes. This restates
the install pin; it is not a new fact.

Dated announcement 1: prototype storage in /tmp was retired. See the
configuration section rather than keeping this in prime space.

## FAQ 2

Q2. Do I still run `npx pitch-kit init` after install? Yes. This restates
the install pin; it is not a new fact.

Dated announcement 2: prototype storage in /tmp was retired. See the
configuration section rather than keeping this in prime space.

## FAQ 3

Q3. Do I still run `npx pitch-kit init` after install? Yes. This restates
the install pin; it is not a new fact.

Dated announcement 3: prototype storage in /tmp was retired. See the
configuration section rather than keeping this in prime space.

## FAQ 4

Q4. Do I still run `npx pitch-kit init` after install? Yes. This restates
the install pin; it is not a new fact.

Dated announcement 4: prototype storage in /tmp was retired. See the
configuration section rather than keeping this in prime space.

## FAQ 5

Q5. Do I still run `npx pitch-kit init` after install? Yes. This restates
the install pin; it is not a new fact.

Dated announcement 5: prototype storage in /tmp was retired. See the
configuration section rather than keeping this in prime space.

## FAQ 6

Q6. Do I still run `npx pitch-kit init` after install? Yes. This restates
the install pin; it is not a new fact.

Dated announcement 6: prototype storage in /tmp was retired. See the
configuration section rather than keeping this in prime space.

## FAQ 7

Q7. Do I still run `npx pitch-kit init` after install? Yes. This restates
the install pin; it is not a new fact.

Dated announcement 7: prototype storage in /tmp was retired. See the
configuration section rather than keeping this in prime space.

## FAQ 8

Q8. Do I still run `npx pitch-kit init` after install? Yes. This restates
the install pin; it is not a new fact.

Dated announcement 8: prototype storage in /tmp was retired. See the
configuration section rather than keeping this in prime space.

## FAQ 9

Q9. Do I still run `npx pitch-kit init` after install? Yes. This restates
the install pin; it is not a new fact.

Dated announcement 9: prototype storage in /tmp was retired. See the
configuration section rather than keeping this in prime space.

## FAQ 10

Q10. Do I still run `npx pitch-kit init` after install? Yes. This restates
the install pin; it is not a new fact.

Dated announcement 10: prototype storage in /tmp was retired. See the
configuration section rather than keeping this in prime space.

## FAQ 11

Q11. Do I still run `npx pitch-kit init` after install? Yes. This restates
the install pin; it is not a new fact.

Dated announcement 11: prototype storage in /tmp was retired. See the
configuration section rather than keeping this in prime space.

## FAQ 12

Q12. Do I still run `npx pitch-kit init` after install? Yes. This restates
the install pin; it is not a new fact.

Dated announcement 12: prototype storage in /tmp was retired. See the
configuration section rather than keeping this in prime space.

## FAQ 13

Q13. Do I still run `npx pitch-kit init` after install? Yes. This restates
the install pin; it is not a new fact.

Dated announcement 13: prototype storage in /tmp was retired. See the
configuration section rather than keeping this in prime space.

## FAQ 14

Q14. Do I still run `npx pitch-kit init` after install? Yes. This restates
the install pin; it is not a new fact.

Dated announcement 14: prototype storage in /tmp was retired. See the
configuration section rather than keeping this in prime space.

## FAQ 15

Q15. Do I still run `npx pitch-kit init` after install? Yes. This restates
the install pin; it is not a new fact.

Dated announcement 15: prototype storage in /tmp was retired. See the
configuration section rather than keeping this in prime space.

## FAQ 16

Q16. Do I still run `npx pitch-kit init` after install? Yes. This restates
the install pin; it is not a new fact.

Dated announcement 16: prototype storage in /tmp was retired. See the
configuration section rather than keeping this in prime space.

## FAQ 17

Q17. Do I still run `npx pitch-kit init` after install? Yes. This restates
the install pin; it is not a new fact.

Dated announcement 17: prototype storage in /tmp was retired. See the
configuration section rather than keeping this in prime space.

## FAQ 18

Q18. Do I still run `npx pitch-kit init` after install? Yes. This restates
the install pin; it is not a new fact.

Dated announcement 18: prototype storage in /tmp was retired. See the
configuration section rather than keeping this in prime space.

## FAQ 19

Q19. Do I still run `npx pitch-kit init` after install? Yes. This restates
the install pin; it is not a new fact.

Dated announcement 19: prototype storage in /tmp was retired. See the
configuration section rather than keeping this in prime space.

## FAQ 20

Q20. Do I still run `npx pitch-kit init` after install? Yes. This restates
the install pin; it is not a new fact.

Dated announcement 20: prototype storage in /tmp was retired. See the
configuration section rather than keeping this in prime space.

## FAQ 21

Q21. Do I still run `npx pitch-kit init` after install? Yes. This restates
the install pin; it is not a new fact.

Dated announcement 21: prototype storage in /tmp was retired. See the
configuration section rather than keeping this in prime space.

## FAQ 22

Q22. Do I still run `npx pitch-kit init` after install? Yes. This restates
the install pin; it is not a new fact.

Dated announcement 22: prototype storage in /tmp was retired. See the
configuration section rather than keeping this in prime space.

## FAQ 20

Q20. Compatible with Node.js 20.19 or newer remains the requirement. Restated.

## FAQ 21

Q21. Compatible with Node.js 20.19 or newer remains the requirement. Restated.

## FAQ 22

Q22. Compatible with Node.js 20.19 or newer remains the requirement. Restated.

## FAQ 23

Q23. Compatible with Node.js 20.19 or newer remains the requirement. Restated.

## FAQ 24

Q24. Compatible with Node.js 20.19 or newer remains the requirement. Restated.

## FAQ 25

Q25. Compatible with Node.js 20.19 or newer remains the requirement. Restated.

## License

License: MIT
