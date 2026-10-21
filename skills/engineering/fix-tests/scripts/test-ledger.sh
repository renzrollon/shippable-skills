#!/usr/bin/env bash
# test-ledger.sh: report what a fix-tests run did to the tests.
#
# Usage: test-ledger.sh [<base>]
#
# <base> is the run snapshot: the commit object `git stash create` printed
# before the first edit, or HEAD when the tree was clean. Default: HEAD.
#
# Diffs the working tree against <base> (tracked files only, -U0) and prints:
#   - removed assertions in test files
#   - added skip, only, or ignore markers (new ones only)
#   - the net test-line delta
#
# Exit codes: 0 no new marker, 1 at least one new marker, 2 usage or git error.
# Exit 0 with removed assertions listed is not a clean bill: each one needs a
# ledger line (file, reason, verdict) or a revert.
#
# Limits: untracked files are invisible to a snapshot and to this script.
# A marker counts as new unless an identical line (ignoring whitespace) was
# removed from the same file in the same diff, so re-indenting is not flagged.

set -u

case "${1:-}" in
  -h|--help)
    awk 'NR > 1 && /^#/ { sub(/^# ?/, ""); print; next } NR > 1 { exit }' "$0"
    exit 0
    ;;
esac

base="${1:-HEAD}"

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "test-ledger: not inside a git repository" >&2
  exit 2
fi
if ! git rev-parse --verify --quiet "${base}^{commit}" >/dev/null 2>&1; then
  echo "test-ledger: cannot resolve base '${base}' to a commit" >&2
  exit 2
fi

if ! diff_out="$(git -c core.quotepath=off diff -U0 --no-color --no-ext-diff --no-renames "$base" --)"; then
  echo "test-ledger: git diff failed against '${base}'" >&2
  exit 2
fi

printf '%s\n' "$diff_out" |
awk -v base="$base" '
function is_test_path(p,  q) {
  q = tolower(p)
  if (q ~ /(^|\/)(tests?|__tests__|specs?|e2e|__mocks__)\//) return 1
  if (q ~ /[._-](test|spec)\.[a-z0-9]+$/) return 1
  if (q ~ /(^|\/)test_[^\/]*\.py$/) return 1
  if (q ~ /_test\.(go|py|rs|rb|exs)$/) return 1
  if (q ~ /(tests?|spec)\.(java|kt|cs|scala|swift|php)$/) return 1
  return 0
}
# Rust keeps unit tests inline, so .rs files are scanned for markers too.
function marker_scope(p) {
  if (is_test_path(p)) return 2
  if (p ~ /\.rs$/) return 1
  return 0
}
function is_js(f) { return f ~ /\.(js|jsx|mjs|cjs|ts|tsx|mts|cts|vue|svelte)$/ }
# JS/TS rules are scoped by extension: .skip( and .only( are ordinary calls
# elsewhere (Rust and Java iterators, for example).
function is_marker(s, f) {
  if (is_js(f)) {
    if (s ~ /(^|[^A-Za-z0-9_])(it|test|describe|context|suite|specify)\.(skip|only)([^A-Za-z0-9_]|$)/) return 1
    if (s ~ /\.(skip|only|skipIf|runIf|fixme)\(/) return 1
    if (s ~ /(^|[^A-Za-z0-9_.])(fit|ftest)\([[:space:]]*[\047"`]/) return 1
  }
  if (s ~ /(^|[^A-Za-z0-9_.])(xit|xdescribe|xtest|xcontext|fdescribe)\(/) return 1
  if (s ~ /@pytest\.mark\.(skip|skipif|xfail)/) return 1
  if (s ~ /(^|[^A-Za-z0-9_])pytest\.(skip|xfail)\(/) return 1
  if (s ~ /@unittest\.(skip|skipIf|skipUnless|expectedFailure)/) return 1
  if (s ~ /self\.skipTest\(/) return 1
  if (s ~ /(^|[^A-Za-z0-9_])[tb]\.Skip(f|Now)?\(/) return 1
  if (s ~ /markTest(Skipped|Incomplete)\(/) return 1
  if (s ~ /XCTSkip/) return 1
  if (s ~ /@tag[[:space:]]*(:skip|skip:)/) return 1
  if (s ~ /#\[ignore/) return 1
  if (s ~ /@Disabled/) return 1
  if (s ~ /@Ignore([^A-Za-z0-9_]|$)/) return 1
  if (s ~ /\[Ignore([^A-Za-z0-9_]|$)/) return 1
  if (s ~ /\[(Fact|Theory)\(.*Skip[[:space:]]*=/) return 1
  if (f ~ /\.rb$/) {
    if (s ~ /^[[:space:]]*(pending|skip|xit|xdescribe|xcontext|xspecify)([^A-Za-z0-9_]|$)/) return 1
    if (s ~ /[,[:space:]](:skip|skip:|:pending|pending:)/) return 1
  }
  return 0
}
function is_assert(s) {
  if (s ~ /(^|[^A-Za-z0-9_])(assert[A-Za-z_]*|verify)([[:space:]]|[(.]|$)/) return 1
  if (s ~ /(^|[^A-Za-z0-9_])expect[[:space:]]*[({.]/) return 1
  if (s ~ /\.should([[:space:].]|$)/) return 1
  if (s ~ /(^|[^A-Za-z0-9_])t\.(Error|Errorf|Fatal|Fatalf)\(/) return 1
  if (s ~ /\.(to|not)[A-Z][A-Za-z]*\(/) return 1
  return 0
}
function norm(s) { gsub(/[[:space:]]+/, "", s); return s }
function trim(s) { sub(/^[[:space:]]+/, "", s); sub(/[[:space:]]+$/, "", s); return s }
function hdr_path(line,  p) {
  p = substr(line, 5)
  sub(/\t.*$/, "", p)
  if (p ~ /^"/) { sub(/^"/, "", p); sub(/"$/, "", p); gsub(/\\"/, "\"", p) }
  sub(/^[ab]\//, "", p)
  return p
}
function flush(  i, k, n, rm_count, ad_count, nrm) {
  if (file == "") { nadd = 0; nrem = 0; return }
  ts = is_test_path(file)
  ms = marker_scope(file)
  delete rm_count; delete ad_count
  for (i = 1; i <= nrem; i++) rm_count[norm(remtxt[i])]++
  for (i = 1; i <= nadd; i++) ad_count[norm(addtxt[i])]++
  if (ms > 0) {
    for (i = 1; i <= nadd; i++) {
      if (!is_marker(addtxt[i], file)) continue
      k = norm(addtxt[i])
      if (rm_count[k] > 0) { rm_count[k]--; continue }
      newm++
      nm_line[newm] = file ":" addno[i] ": " trim(addtxt[i])
    }
  }
  if (ts) {
    for (i = 1; i <= nrem; i++) {
      if (!is_assert(remtxt[i])) continue
      k = norm(remtxt[i])
      if (ad_count[k] > 0) { ad_count[k]--; continue }
      nra++
      ra_line[nra] = file ": " trim(remtxt[i])
    }
    tot_add += nadd
    tot_rem += nrem
  }
  nadd = 0; nrem = 0
}
BEGIN { file = ""; nadd = 0; nrem = 0; newm = 0; nra = 0; tot_add = 0; tot_rem = 0; inhunk = 0 }
/^diff --git / { flush(); file = ""; inhunk = 0; next }
inhunk == 0 && /^--- "?a\// { file = hdr_path($0); next }
inhunk == 0 && /^\+\+\+ "?b\// { file = hdr_path($0); next }
inhunk == 0 && /^(---|\+\+\+) / { next }
/^@@ / {
  inhunk = 1
  s = $0
  sub(/^@@ -[0-9,]+ \+/, "", s)
  sub(/[ ,@].*$/, "", s)
  lineno = s + 0
  next
}
inhunk == 1 && /^\+/ { nadd++; addtxt[nadd] = substr($0, 2); addno[nadd] = lineno; lineno++; next }
inhunk == 1 && /^-/  { nrem++; remtxt[nrem] = substr($0, 2); next }
END {
  flush()
  print "test-ledger (base " base ")"
  print "removed assertions (" nra "):"
  for (i = 1; i <= nra; i++) print "  " ra_line[i]
  print "new skip/only markers (" newm "):"
  for (i = 1; i <= newm; i++) print "  " nm_line[i]
  print "net test lines: +" tot_add " -" tot_rem " (net " (tot_add - tot_rem) ")"
  if (newm > 0) { print "result: FAIL, new skip/only marker"; exit 1 }
  if (nra > 0) { print "result: ok, " nra " removed assertion(s) need a ledger line or a revert"; exit 0 }
  print "result: ok"
  exit 0
}
'
