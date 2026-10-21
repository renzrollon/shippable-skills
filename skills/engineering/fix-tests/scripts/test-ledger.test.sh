#!/usr/bin/env bash
# test-ledger.test.sh: self-test for test-ledger.sh.
# Builds a temporary git repo per case, so it never touches the real tree.
# Exits 0 when every case passes, 1 otherwise.

set -u

here="$(cd "$(dirname "$0")" && pwd)"
ledger="$here/test-ledger.sh"
work="$(mktemp -d "${TMPDIR:-/tmp}/test-ledger.XXXXXX")"
trap 'rm -rf "$work"' EXIT

pass=0
fail=0

git_q() { git -c user.name=ledger -c user.email=ledger@example.invalid -c commit.gpgsign=false "$@"; }

new_repo() {
  local d="$work/$1"
  mkdir -p "$d"
  (cd "$d" && git init -q . && git_q commit -q --allow-empty -m init)
  echo "$d"
}

check() {
  # check <name> <expected-exit> <expected-substring-or-empty> <actual-exit> <output>
  local name="$1" want="$2" needle="$3" got="$4" out="$5" ok=1
  [ "$got" -eq "$want" ] || ok=0
  if [ -n "$needle" ]; then
    case "$out" in *"$needle"*) ;; *) ok=0 ;; esac
  fi
  if [ "$ok" -eq 1 ]; then
    pass=$((pass + 1)); echo "ok   $name"
  else
    fail=$((fail + 1)); echo "FAIL $name (exit $got, wanted $want, needle '$needle')"
    echo "$out" | sed 's/^/     | /'
  fi
}

# Case 1: a new .skip in a JS test
d="$(new_repo skip-js)"
(
  cd "$d"
  printf "it('adds', () => {\n  expect(1 + 1).toBe(2)\n})\n" > a.test.js
  git add -A && git_q commit -q -m base
  snap="HEAD"
  printf "it.skip('adds', () => {\n  expect(1 + 1).toBe(2)\n})\n" > a.test.js
  out="$(bash "$ledger" "$snap" 2>&1)"; rc=$?
  echo "$rc" > "$d/.rc"; echo "$out" > "$d/.out"
)
check "new .skip is flagged" 1 "a.test.js:1" "$(cat "$d/.rc")" "$(cat "$d/.out")"

# Case 2: a new @pytest.mark.skip in a Python test
d="$(new_repo skip-py)"
(
  cd "$d"
  mkdir tests
  printf "def test_adds():\n    assert 1 + 1 == 2\n" > tests/test_math.py
  git add -A && git_q commit -q -m base
  printf "import pytest\n\n@pytest.mark.skip\ndef test_adds():\n    assert 1 + 1 == 2\n" > tests/test_math.py
  out="$(bash "$ledger" HEAD 2>&1)"; rc=$?
  echo "$rc" > "$d/.rc"; echo "$out" > "$d/.out"
)
check "new @pytest.mark.skip is flagged" 1 "tests/test_math.py" "$(cat "$d/.rc")" "$(cat "$d/.out")"

# Case 3: a marker that predates the snapshot is not reported
d="$(new_repo predates)"
(
  cd "$d"
  printf "it('adds', () => {\n  expect(1 + 1).toBe(2)\n})\n" > a.test.js
  printf "export const f = () => 1\n" > src.js
  git add -A && git_q commit -q -m base
  # Uncommitted skip exists BEFORE the run snapshot.
  printf "it.skip('adds', () => {\n  expect(1 + 1).toBe(2)\n})\n" > a.test.js
  snap="$(git_q stash create)"
  [ -n "$snap" ] || snap="HEAD"
  # The run only edits source.
  printf "export const f = () => 2\n" > src.js
  out="$(bash "$ledger" "$snap" 2>&1)"; rc=$?
  echo "$rc" > "$d/.rc"; echo "$out" > "$d/.out"
  # Against HEAD the same skip would be flagged, which proves the snapshot matters.
  out2="$(bash "$ledger" HEAD 2>&1)"; rc2=$?
  echo "$rc2" > "$d/.rc2"
)
check "marker predating the snapshot is ignored" 0 "result: ok" "$(cat "$d/.rc")" "$(cat "$d/.out")"
check "same marker is flagged against HEAD" 1 "" "$(cat "$d/.rc2")" ""

# Case 4: a clean diff
d="$(new_repo clean)"
(
  cd "$d"
  printf "it('adds', () => {\n  expect(1 + 1).toBe(2)\n})\n" > a.test.js
  git add -A && git_q commit -q -m base
  out="$(bash "$ledger" HEAD 2>&1)"; rc=$?
  echo "$rc" > "$d/.rc"; echo "$out" > "$d/.out"
)
check "clean diff exits zero" 0 "net 0" "$(cat "$d/.rc")" "$(cat "$d/.out")"

# Case 5: a removed assertion is reported but is not a failure
d="$(new_repo removed)"
(
  cd "$d"
  printf "it('adds', () => {\n  expect(1 + 1).toBe(2)\n  expect(2 + 2).toBe(4)\n})\n" > a.test.js
  git add -A && git_q commit -q -m base
  printf "it('adds', () => {\n  expect(1 + 1).toBe(2)\n})\n" > a.test.js
  out="$(bash "$ledger" HEAD 2>&1)"; rc=$?
  echo "$rc" > "$d/.rc"; echo "$out" > "$d/.out"
)
check "removed assertion is listed, exit zero" 0 "removed assertions (1)" "$(cat "$d/.rc")" "$(cat "$d/.out")"

# Case 6: re-indenting an existing marker is not a new marker
d="$(new_repo reindent)"
(
  cd "$d"
  printf "describe('x', () => {\n  it.skip('a', () => {})\n})\n" > a.test.js
  git add -A && git_q commit -q -m base
  printf "describe('x', () => {\n    it.skip('a', () => {})\n})\n" > a.test.js
  out="$(bash "$ledger" HEAD 2>&1)"; rc=$?
  echo "$rc" > "$d/.rc"; echo "$out" > "$d/.out"
)
check "re-indented marker is not new" 0 "result: ok" "$(cat "$d/.rc")" "$(cat "$d/.out")"

# Case 7: Go, Rust, JVM markers
d="$(new_repo others)"
(
  cd "$d"
  printf "package x\nfunc TestA(t *testing.T) {\n}\n" > a_test.go
  printf "#[test]\nfn a() {}\n" > lib.rs
  printf "class FooTest {\n  @Test void a() {}\n}\n" > FooTest.java
  git add -A && git_q commit -q -m base
  printf "package x\nfunc TestA(t *testing.T) {\n\tt.Skip(\"later\")\n}\n" > a_test.go
  printf "#[test]\n#[ignore]\nfn a() {}\n" > lib.rs
  printf "class FooTest {\n  @Disabled @Test void a() {}\n}\n" > FooTest.java
  out="$(bash "$ledger" HEAD 2>&1)"; rc=$?
  echo "$rc" > "$d/.rc"; echo "$out" > "$d/.out"
)
check "Go, Rust, and JVM markers are flagged" 1 "new skip/only markers (3)" "$(cat "$d/.rc")" "$(cat "$d/.out")"

# Case 8: not a repository
plain="$work/plain"; mkdir -p "$plain"
out="$(cd "$plain" && GIT_CEILING_DIRECTORIES="$work" bash "$ledger" HEAD 2>&1)"; rc=$?
check "outside a repository exits 2" 2 "not inside a git repository" "$rc" "$out"

echo
echo "passed $pass, failed $fail"
[ "$fail" -eq 0 ]
