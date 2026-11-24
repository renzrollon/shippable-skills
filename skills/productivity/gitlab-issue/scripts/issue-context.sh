#!/bin/sh
# issue-context.sh: read-only context index and capability outline for an
# OpenSpec project. POSIX sh, awk, grep, sed, sort only. No network, no writes.
#
# usage: issue-context.sh index|outline <repo-root> [names...]
#
# Exit 0 on success (absent sources are reported, not failed), 2 on usage error.

LC_ALL=C
export LC_ALL

usage() {
  echo "usage: issue-context.sh index|outline <repo-root> [names...]" >&2
  exit 2
}

mode=${1:-}
root=${2:-}
case $mode in
  index|outline) ;;
  *) usage ;;
esac
[ -n "$root" ] && [ -d "$root" ] || usage
shift 2

# Paragraph under a heading, lines joined with single spaces.
# Args: file, exact heading line. Stops at the first blank line after text or at the next heading.
paragraph() {
  awk -v h="$2" '
    function trim(s) { sub(/^[ \t\r]+/, "", s); sub(/[ \t\r]+$/, "", s); return s }
    !on { if (trim($0) == h) on = 1; next }
    /^#/ { exit }
    {
      line = trim($0)
      if (line == "") { if (n > 0) exit; next }
      out = (n > 0 ? out " " : "") line
      n++
    }
    END { print out }
  ' "$1"
}

# First sentence of stdin text, capped at 200 chars with "..." when cut.
first_sentence() {
  awk '
    {
      s = $0
      i = index(s, ". ")
      if (i > 0) s = substr(s, 1, i)
      if (length(s) > 200) s = substr(s, 1, 200) "..."
      print s
    }
  '
}

# Print "## name N" then the content, or "## name absent".
section() {
  if [ "$2" = 1 ]; then
    if [ -n "$3" ]; then
      n=$(printf '%s\n' "$3" | awk 'END { print NR }')
    else
      n=0
    fi
    echo "## $1 $n"
    [ -n "$3" ] && printf '%s\n' "$3"
  else
    echo "## $1 absent"
  fi
}

# First docs/*.md (name order) with a heading matching the given pattern.
find_doc() {
  for f in "$root"/docs/*.md; do
    [ -f "$f" ] || continue
    if grep -q -E "$1" "$f"; then
      echo "$f"
      return 0
    fi
  done
  return 1
}

if [ "$mode" = index ]; then
  # domain
  dom=""
  dpresent=0
  if [ -f "$root/openspec/config.yaml" ]; then
    dom=$(grep 'Domain:' "$root/openspec/config.yaml" | head -n 1 | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
    [ -n "$dom" ] && dpresent=1
    dom=$(printf '%s' "$dom" | cut -c 1-300)
  fi
  if [ "$dpresent" = 1 ]; then
    echo "## domain"
    printf '%s\n' "$dom"
  else
    echo "## domain absent"
  fi

  # personas
  pers=""
  ppresent=0
  pf=$(find_doc '^#+ .*Persona')
  if [ -n "$pf" ]; then
    ppresent=1
    pers=$(awk '
      function trim(s) { sub(/^[ \t\r]+/, "", s); sub(/[ \t\r]+$/, "", s); return s }
      !on { if ($0 ~ /^#+ .*Persona/) on = 1; next }
      /^##? / { exit }
      /^### / { if (n < 12) { print trim(substr($0, 5)); n++ } }
    ' "$pf")
  fi
  section personas "$ppresent" "$pers"

  # glossary
  glos=""
  gpresent=0
  gf=$(find_doc '^#+ .*Glossary')
  if [ -n "$gf" ]; then
    gpresent=1
    glos=$(awk '
      function trim(s) { sub(/^[ \t\r]+/, "", s); sub(/[ \t\r]+$/, "", s); return s }
      function emit(term, meaning) {
        if (n >= 60) return
        gsub(/\*\*/, "", term)
        term = trim(term)
        meaning = trim(meaning)
        if (term == "") return
        if (length(meaning) > 100) meaning = substr(meaning, 1, 100)
        print term ": " meaning
        n++
      }
      function flush(   c) {
        if (pending != "") {
          split(pending, c, "|")
          emit(c[2], c[3])
        }
        pending = ""
      }
      !on { if ($0 ~ /^#+ .*Glossary/) on = 1; next }
      /^##? / { flush(); exit }
      /^[ \t]*\|/ {
        if ($0 ~ /^[ \t]*\|[ \t:-]+\|/ && $0 !~ /[A-Za-z0-9]/) { pending = ""; next }
        flush()
        pending = $0
        next
      }
      {
        flush()
        if ($0 ~ /^[-*] \*\*/) {
          s = substr($0, 3)
          rest = substr(s, 3)
          j = index(rest, "**")
          if (j > 0) {
            term = substr(rest, 1, j - 1)
            sub(/:$/, "", term)
            meaning = substr(rest, j + 2)
            sub(/^[ \t]*:?[ \t]*/, "", meaning)
            emit(term, meaning)
          }
        }
      }
      END { flush() }
    ' "$gf")
  fi
  section glossary "$gpresent" "$glos"

  # capabilities
  caps=""
  cpresent=0
  if [ -d "$root/openspec/specs" ]; then
    cpresent=1
    for d in "$root"/openspec/specs/*/; do
      [ -d "$d" ] || continue
      name=${d%/}
      name=${name##*/}
      purpose=""
      [ -f "$d/spec.md" ] && purpose=$(paragraph "$d/spec.md" "## Purpose" | first_sentence)
      line="$name | $purpose"
      if [ -z "$caps" ]; then caps=$line; else caps=$caps"
$line"; fi
    done
  fi
  section capabilities "$cpresent" "$caps"

  # active changes
  chg=""
  hpresent=0
  if [ -d "$root/openspec/changes" ]; then
    hpresent=1
    for d in "$root"/openspec/changes/*/; do
      [ -d "$d" ] || continue
      name=${d%/}
      name=${name##*/}
      [ "$name" = archive ] && continue
      why=""
      [ -f "$d/proposal.md" ] && why=$(paragraph "$d/proposal.md" "## Why" | first_sentence)
      line="$name | $why"
      if [ -z "$chg" ]; then chg=$line; else chg=$chg"
$line"; fi
    done
  fi
  section changes "$hpresent" "$chg"

  # known issues and backlog
  known=""
  kpresent=0
  for f in "$root"/docs/*.md; do
    [ -f "$f" ] || continue
    base=${f##*/}
    case $base in
      *KNOWN_ISSUES*|*BACKLOG*) ;;
      *) continue ;;
    esac
    kpresent=1
    titles=$(awk -v p="docs/$base" '
      function trim(s) { sub(/^[ \t\r]+/, "", s); sub(/[ \t\r]+$/, "", s); return s }
      /^## / { if (n < 100) { print p " | " trim(substr($0, 4)); n++ } }
    ' "$f")
    if [ -n "$titles" ]; then
      if [ -z "$known" ]; then known=$titles; else known=$known"
$titles"; fi
    fi
  done
  section known "$kpresent" "$known"
  exit 0
fi

# outline mode
count=0
skipped=""
for name in "$@"; do
  count=$((count + 1))
  if [ "$count" -gt 3 ]; then
    if [ -z "$skipped" ]; then skipped=$name; else skipped="$skipped $name"; fi
    continue
  fi
  if ! printf '%s\n' "$name" | grep -q -E '^[a-z0-9][a-z0-9-]*$'; then
    echo "## rejected $name"
    continue
  fi
  found=0
  spec="$root/openspec/specs/$name/spec.md"
  if [ -f "$spec" ]; then
    found=1
    echo "## capability $name"
    echo "Purpose: $(paragraph "$spec" "## Purpose")"
    awk '
      function trim(s) { sub(/^[ \t\r]+/, "", s); sub(/[ \t\r]+$/, "", s); return s }
      /^### Requirement:/ { t = $0; sub(/^### Requirement:/, "", t); print "- " trim(t); next }
      /^#### Scenario:/ { t = $0; sub(/^#### Scenario:/, "", t); print "  - " trim(t) }
    ' "$spec"
  fi
  if [ "$name" != archive ] && [ -d "$root/openspec/changes/$name" ]; then
    found=1
    echo "## change $name"
    why=""
    [ -f "$root/openspec/changes/$name/proposal.md" ] && why=$(paragraph "$root/openspec/changes/$name/proposal.md" "## Why" | cut -c 1-600)
    echo "Why: $why"
  fi
  [ "$found" = 1 ] || echo "## not-found $name"
done
[ -n "$skipped" ] && echo "## skipped $skipped"
exit 0
