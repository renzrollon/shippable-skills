#!/usr/bin/env bash
# Grade the rewritten pitch-fixture workspace.
# Usage: grade-readme.sh hero|pitch|anchors|sentinels|pins|brief
# cwd: case workspace root. Exit 0 pass, non-zero fail.

set -euo pipefail

mode="${1:-}"
if [[ -z "$mode" ]]; then
  base="$(basename "$0" .sh)"
  mode="${base#grade-}"
fi
if [[ -z "$mode" || "$mode" == "readme" ]]; then
  echo "usage: grade-readme.sh hero|pitch|anchors|sentinels|pins|brief" >&2
  exit 2
fi

python3 - "$mode" <<'PY'
import os
import re
import subprocess
import sys
from pathlib import Path

mode = sys.argv[1]
root = Path(".")
readme_path = root / "README.md"
msg = os.environ.get("EVAL_FINAL_MESSAGE", "")

def die(err):
    print(err)
    sys.exit(1)

def scan_readme():
    if not readme_path.is_file():
        die("README.md is missing")
    lines = readme_path.read_text().splitlines()
    in_fence = False
    hero = code = h2 = None
    for i, line in enumerate(lines, 1):
        stripped = line.strip()
        if stripped.startswith("```"):
            if not in_fence and code is None:
                code = i
            in_fence = not in_fence
            continue
        if in_fence:
            continue
        lower = line.lower()
        if hero is None and ("<img" in lower or stripped.startswith("![")):
            hero = i
        if h2 is None and line.startswith("## "):
            h2 = i
    return hero, code, h2, len(lines)

if mode == "hero":
    if not re.search(
        r"(?m)^HERO: line ([1-9]|1[0-4]), before first code block: yes$",
        msg,
    ):
        die("report HERO line missing, not under 15, or not before the first code block")
    hero, code, h2, n = scan_readme()
    print(f"hero={hero} first_code={code} first_h2={h2} lines={n}")
    if hero is None:
        die("no <img or ![ outside a fence")
    if code is None:
        die("no code fence (usage block is required)")
    if hero >= code:
        die("hero is not before the first code fence")
    sys.exit(0)

if mode == "pitch":
    if not re.search(r"(?m)^PITCH COMPLETE BY: line ([0-9]|[12][0-9]|30)$", msg):
        die("report PITCH COMPLETE BY missing or over 30")
    hero, code, h2, n = scan_readme()
    print(f"hero={hero} first_code={code} first_h2={h2} lines={n}")
    if h2 is None:
        die("no H2 heading")
    if h2 > 30:
        die(f"first H2 is line {h2}, need 30 or lower")
    sys.exit(0)

if mode == "pins":
    if not readme_path.is_file():
        die("README.md is missing")
    text = readme_path.read_text()
    pins = [
        "npx pitch-kit init",
        "Compatible with Node.js 20.19 or newer",
        "License: MIT",
    ]
    missing = [p for p in pins if p not in text]
    if missing:
        die("missing pins: " + " | ".join(missing))
    nlines = len(text.splitlines())
    if nlines > 160:
        die(f"README is {nlines} lines; pins kept on an unpitched file is not a pass")
    test = subprocess.run(
        ["node", "--test", "test/readme.test.mjs"],
        capture_output=True,
        text=True,
    )
    sys.stdout.write(test.stdout)
    sys.stderr.write(test.stderr)
    if test.returncode != 0:
        die("fixture test failed")
    print("pins ok")
    sys.exit(0)

if mode == "sentinels":
    sentinels = [
        "SENTINEL_WAVE_CAP",
        "SENTINEL_CONFIG_PATH",
        "SENTINEL_HOOK_ORDER",
        "SENTINEL_RELEASE_TAG",
        "SENTINEL_CACHE_DIR",
    ]
    # Homes the relocation checklist names: docs/**, and any root markdown
    # file other than README.md (CONTRIBUTING.md, CHANGELOG.md, a CLI
    # reference). A sentinel still only in README.md is a lost fact.
    blobs = []
    docs = root / "docs"
    if docs.is_dir():
        for p in docs.rglob("*"):
            if p.is_file() and p.suffix.lower() in {".md", ".txt"}:
                blobs.append(p.read_text())
    for p in root.glob("*.md"):
        if p.is_file() and p.name.lower() != "readme.md":
            blobs.append(p.read_text())
    hay = "\n".join(blobs)
    missing = [s for s in sentinels if s not in hay]
    if missing:
        die("sentinels not in docs/ or a root .md other than README: " + ", ".join(missing))
    print("sentinels ok")
    sys.exit(0)

if mode == "anchors":
    guide = root / "docs" / "guide.md"
    if not guide.is_file():
        die("docs/guide.md is missing")
    text = guide.read_text()
    if re.search(r"README(\.md)?#configuration\b", text):
        die("docs/guide.md still points at README configuration")
    found = False
    for m in re.finditer(r"\[[^\]]*\]\(([^)]+)\)", text):
        raw = m.group(1).strip()
        if re.match(r"^(https?:|mailto:)", raw):
            continue
        href, _, anchor = raw.partition("#")
        if not href or not anchor:
            continue
        target = (guide.parent / href).resolve()
        try:
            target.relative_to(root.resolve())
        except ValueError:
            continue
        if target.name.lower().startswith("readme"):
            continue
        if not target.is_file():
            continue
        body = target.read_text()
        slugs = []
        for line in body.splitlines():
            atx = re.match(r"^(#{1,6})\s+(.+?)\s*#*\s*$", line)
            if not atx:
                continue
            heading = atx.group(2)
            heading = re.sub(r"!\[([^\]]*)\]\([^)]*\)", r"\1", heading)
            heading = re.sub(r"\[([^\]]+)\]\([^)]*\)", r"\1", heading)
            heading = heading.replace("`", "")
            heading = re.sub(r"[*_]", "", heading)
            heading = re.sub(r"<[^>]+>", "", heading).strip()
            slug = (
                heading.lower()
                .encode("utf-8")
                .decode("utf-8")
            )
            slug = re.sub(r"[^\w\s-]", "", slug, flags=re.UNICODE)
            # Match check-links.mjs: keep letters/marks/numbers/connectors/hyphen/space
            slug = re.sub(r"[^\w\s-]", "", slug)
            slug = slug.strip().replace(" ", "-")
            slugs.append(slug)
        # Prefer the Node checker semantics via a second pass below if needed.
        if anchor in slugs or f'id="{anchor}"' in body or f"id='{anchor}'" in body:
            found = True
            print(f"repointed -> {href}#{anchor}")
            break
    if not found:
        die("docs/guide.md has no relative link to a non-README file#heading that exists")
    sys.exit(0)

if mode == "brief":
    if not re.search(
        r"(?m)^DECISIONS: (assumed|asked|brief \S+) \| reader: .+ \| archetype: "
        r"(cli|library|service|action-or-plugin|app|research-or-dataset) \| claim: .+ \| "
        r"register: (problem|outcome|category|host|verb|deadpan) \| compare: (named|unnamed|skip)",
        msg,
    ):
        die("report DECISIONS line missing or malformed")
    if not re.search(r"(?m)^DECISIONS: assumed \| ", msg):
        die("default mode must report DECISIONS: assumed")
    if not re.search(r"\| archetype: cli \|", msg):
        die("fixture has bin in package.json; archetype must be cli")
    briefs = sorted(
        list((root / ".agents" / "handoff").glob("readme-pitch-brief-*.md"))
        + list((root / ".claude" / "handoff").glob("readme-pitch-brief-*.md"))
    )
    if not briefs:
        die("no readme-pitch-brief-*.md written to the handoff dir")
    text = briefs[-1].read_text()
    for heading in ("## Reader", "## Archetype", "## Claim", "## Register", "## Comparison"):
        if heading not in text:
            die(f"brief {briefs[-1]} is missing {heading}")
    if not re.search(r"(?m)^- source: assumed", text):
        die(f"brief {briefs[-1]} does not record source: assumed")
    if not re.search(r"(?m)^cli\s*$", text):
        die(f"brief {briefs[-1]} does not record archetype cli")
    print(f"brief ok: {briefs[-1]}")
    sys.exit(0)

die(f"unknown mode {mode}")
PY
