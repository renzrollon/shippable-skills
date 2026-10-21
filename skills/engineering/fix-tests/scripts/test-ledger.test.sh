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


# Case 9: ordinary .skip( and .only( calls outside JS/TS tests are not markers
d="$(new_repo iterators)"
(
  cd "$d"
  mkdir -p src
  printf "fn main() {}\n" > src/main.rs
  printf "class FooTest {\n  void a() {}\n}\n" > FooTest.java
  git add -A && git_q commit -q -m base
  printf "fn main() {\n    let a: Vec<String> = std::env::args().skip(1).collect();\n    let mut it = a.iter();\n    it.skip(1);\n}\n" > src/main.rs
  printf "class FooTest {\n  void a() { list.stream().skip(1).count(); }\n}\n" > FooTest.java
  out="$(bash "$ledger" HEAD 2>&1)"; rc=$?
  echo "$rc" > "$d/.rc"; echo "$out" > "$d/.out"
)
check "Rust and Java iterator .skip(1) is not a marker" 0 "result: ok" "$(cat "$d/.rc")" "$(cat "$d/.out")"

# Case 10: skip and focus forms beyond the basics
d="$(new_repo more-markers)"
(
  cd "$d"
  mkdir -p tests
  printf "test('a', () => {})\nfit('b', () => {})\n" > a.test.js
  printf "test('a', () => {})\n" > b.test.ts
  printf "test('a', () => {})\n" > c.test.ts
  printf "<?php\nclass ATest { function t() {} }\n" > ATest.php
  printf "import XCTest\nclass FooTests: XCTestCase { func testA() {} }\n" > FooTests.swift
  printf "defmodule ATest do\n  test \"a\" do\n  end\nend\n" > tests/a_test.exs
  git add -A && git_q commit -q -m base
  printf "test('a', () => {})\nfit('b', () => {})\nfit('c', () => {})\n" > a.test.js
  printf "test.skipIf(true)('a', () => {})\n" > b.test.ts
  printf "test.fixme('a', () => {})\n" > c.test.ts
  printf "<?php\nclass ATest { function t() { \$this->markTestSkipped('later'); } }\n" > ATest.php
  printf "import XCTest\nclass FooTests: XCTestCase { func testA() throws { throw XCTSkip(\"later\") } }\n" > FooTests.swift
  printf "defmodule ATest do\n  @tag :skip\n  test \"a\" do\n  end\nend\n" > tests/a_test.exs
  out="$(bash "$ledger" HEAD 2>&1)"; rc=$?
  echo "$rc" > "$d/.rc"; echo "$out" > "$d/.out"
)
check "fit, skipIf, fixme, markTestSkipped, XCTSkip, @tag :skip are flagged" 1 "new skip/only markers (6)" "$(cat "$d/.rc")" "$(cat "$d/.out")"

# Case 11: a quoted path does not leak its hunks into the next file
d="$(new_repo quoted-path)"
(
  cd "$d"
  mkdir tests
  printf "it('a', () => {})\n" > 'q"x.test.js'
  printf "<?php\nclass ATest {}\n" > tests/ATest.php
  git add -A && git_q commit -q -m base
  printf "it.only('a', () => {})\n" > 'q"x.test.js'
  out="$(bash "$ledger" HEAD 2>&1)"; rc=$?
  echo "$rc" > "$d/.rc"; echo "$out" > "$d/.out"
)
check "marker in a quoted path is attributed to that path" 1 'q"x.test.js:1' "$(cat "$d/.rc")" "$(cat "$d/.out")"

# Case 12: a path with a space still matches the test-path rules
d="$(new_repo spaced-path)"
(
  cd "$d"
  printf "it('a', () => {})\n" > 'my file.test.js'
  git add -A && git_q commit -q -m base
  printf "it.skip('a', () => {})\n" > 'my file.test.js'
  out="$(bash "$ledger" HEAD 2>&1)"; rc=$?
  echo "$rc" > "$d/.rc"; echo "$out" > "$d/.out"
)
check "marker in a path with a space is flagged" 1 "my file.test.js:1" "$(cat "$d/.rc")" "$(cat "$d/.out")"

# Case 13: a commented-out assertion is listed and the result line says it needs a ledger line
d="$(new_repo commented-out)"
(
  cd "$d"
  printf "it('adds', () => {\n  expect(1).toBe(1)\n})\n" > a.test.js
  git add -A && git_q commit -q -m base
  printf "it('adds', () => {\n  // expect(1).toBe(1)\n})\n" > a.test.js
  out="$(bash "$ledger" HEAD 2>&1)"; rc=$?
  echo "$rc" > "$d/.rc"; echo "$out" > "$d/.out"
)
check "commented-out assertion needs a ledger line" 0 "need a ledger line or a revert" "$(cat "$d/.rc")" "$(cat "$d/.out")"

echo
echo "passed $pass, failed $fail"
[ "$fail" -eq 0 ]
