#!/bin/sh
# Offline tests for issue-context.sh. Run: sh issue-context.test.sh
# Fixtures: fixtures/repo-full (specs, changes, archive, docs) and fixtures/repo-docs-only.

here=$(cd "$(dirname "$0")" && pwd)
script="$here/issue-context.sh"
full="$here/fixtures/repo-full"
docsonly="$here/fixtures/repo-docs-only"
tmp=$(mktemp -d "${TMPDIR:-/tmp}/issue-context-test.XXXXXX") || exit 1
trap 'rm -rf "$tmp"' EXIT

fails=0
pass() { echo "ok: $1"; }
fail() { echo "FAIL: $1"; fails=$((fails + 1)); }

has() { # name, text, exact line
  if printf '%s\n' "$2" | grep -q -x -F -- "$3"; then pass "$1"; else fail "$1 (missing line: $3)"; fi
}
hasnt() { # name, text, substring
  if printf '%s\n' "$2" | grep -q -F -- "$3"; then fail "$1 (unexpected: $3)"; else pass "$1"; fi
}
eq() { if [ "$2" = "$3" ]; then pass "$1"; else fail "$1 (got '$2', want '$3')"; fi; }

before=$(find "$here/fixtures" -type f | sort | xargs cksum)

# Deterministic context index
out=$(sh "$script" index "$full"); code=$?
eq "index exits 0" "$code" 0
caps=$(printf '%s\n' "$out" | awk '/^## capabilities/{on=1;next} /^## /{on=0} on')
eq "three capability lines" "$(printf '%s\n' "$caps" | awk 'END{print NR}')" 3
eq "capabilities in folder order" "$(printf '%s\n' "$caps" | cut -d' ' -f1 | tr '\n' ' ')" "csv-export invoice-list user-login "
has "capabilities header count" "$out" "## capabilities 3"
has "first sentence only" "$out" "csv-export | Lets a billing admin download invoices as a CSV file."
hasnt "second sentence dropped" "$out" "The download covers"
has "domain line" "$out" "Domain: Billing exports for small teams, covering invoices, CSV downloads and reminders."
has "personas from ### titles" "$out" "Billing admin"
has "personas header" "$out" "## personas 2"
has "glossary bold term table row" "$out" "Invoice: A bill sent to a customer for work done in a period."
hasnt "glossary skips header row" "$out" "Term:"
has "changes exclude archive" "$out" "## changes 2"
hasnt "archived change hidden" "$out" "old-work"
hasnt "archived why hidden" "$out" "Archived reason"
has "change with why" "$out" "add-dark-mode | Users work late and want a dark theme."
has "change without proposal" "$out" "tidy-footer | "
has "known titles" "$out" "docs/KNOWN_ISSUES.md | Reminder emails arrive twice"

# Glossary list items, backlog, absent sections
out2=$(sh "$script" index "$docsonly"); code=$?
eq "docs-only exits 0" "$code" 0
has "glossary list items" "$out2" "Workspace: A shared area for one team."
has "config without Domain is absent" "$out2" "## domain absent"
has "no specs absent" "$out2" "## capabilities absent"
has "no changes absent" "$out2" "## changes absent"
has "no personas absent" "$out2" "## personas absent"
has "backlog titles" "$out2" "docs/BACKLOG.md | Bulk invoice upload"

mkdir -p "$tmp/nodocs/openspec/specs/only-one"
printf '## Purpose\n\nOne thing.\n' > "$tmp/nodocs/openspec/specs/only-one/spec.md"
out3=$(sh "$script" index "$tmp/nodocs"); code=$?
eq "no docs exits 0" "$code" 0
has "no docs: glossary absent" "$out3" "## glossary absent"
has "no docs: known absent" "$out3" "## known absent"
has "no docs: capability still printed" "$out3" "only-one | One thing."
mkdir -p "$tmp/nopenspec/docs"
printf '# P\n\n## Known issues\n\n## Oops\n' > "$tmp/nopenspec/docs/KNOWN_ISSUES.md"
out4=$(sh "$script" index "$tmp/nopenspec"); code=$?
eq "no openspec exits 0" "$code" 0
has "no openspec: domain absent" "$out4" "## domain absent"
has "no openspec: capabilities absent" "$out4" "## capabilities absent"
has "no openspec: changes absent" "$out4" "## changes absent"
has "no openspec: docs sections print" "$out4" "docs/KNOWN_ISSUES.md | Known issues"

# Script failure falls back (usage errors)
err=$(sh "$script" index "$tmp/does-not-exist" 2>&1 >/dev/null); code=$?
eq "missing root exits 2" "$code" 2
has "missing root usage line" "$err" "usage: issue-context.sh index|outline <repo-root> [names...]"
sh "$script" index "$here/issue-context.sh" >/dev/null 2>&1; eq "file root exits 2" "$?" 2
sh "$script" bogus "$full" >/dev/null 2>&1; eq "unknown mode exits 2" "$?" 2
sh "$script" >/dev/null 2>&1; eq "no args exits 2" "$?" 2

# Capability outline
o=$(sh "$script" outline "$full" csv-export); code=$?
eq "outline exits 0" "$code" 0
has "outline header" "$o" "## capability csv-export"
has "outline full purpose" "$o" "Purpose: Lets a billing admin download invoices as a CSV file. The download covers the filters currently applied."
has "outline requirement" "$o" "- Download current view"
has "outline nested scenario" "$o" "  - Filtered export"
has "outline second requirement" "$o" "- Large exports"
hasnt "outline has no requirement body" "$o" "SHALL"
eq "outline line count" "$(printf '%s\n' "$o" | awk 'END{print NR}')" 7
o=$(sh "$script" outline "$full" add-dark-mode)
has "outline change header" "$o" "## change add-dark-mode"
has "outline change why" "$o" "Why: Users work late and want a dark theme. It also helps on small screens."
o=$(sh "$script" outline "$full" csv-export invoice-list user-login add-dark-mode)
has "fourth name skipped" "$o" "## skipped add-dark-mode"
hasnt "fourth name not outlined" "$o" "## change add-dark-mode"
o=$(sh "$script" outline "$full" nope csv-export)
has "unknown name" "$o" "## not-found nope"
has "others continue" "$o" "## capability csv-export"
o=$(sh "$script" outline "$full" archive)
has "archive is not a change" "$o" "## not-found archive"

# Outline names are validated
mkdir -p "$tmp/trav/openspec/specs" "$tmp/trav/openspec/secrets"
printf '## Purpose\n\nLEAKED\n' > "$tmp/trav/openspec/secrets/spec.md"
o=$(sh "$script" outline "$tmp/trav" ../secrets); code=$?
eq "traversal exits 0" "$code" 0
has "traversal rejected" "$o" "## rejected ../secrets"
hasnt "traversal read nothing" "$o" "LEAKED"
o=$(sh "$script" outline "$full" 'Bad_Name' '-lead' 'a b')
has "uppercase rejected" "$o" "## rejected Bad_Name"
has "leading hyphen rejected" "$o" "## rejected -lead"

after=$(find "$here/fixtures" -type f | sort | xargs cksum)
eq "fixtures unchanged" "$after" "$before"

if [ "$fails" -eq 0 ]; then echo "all passed"; exit 0; fi
echo "$fails failed"
exit 1
