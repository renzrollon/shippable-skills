#!/bin/sh
# Offline tests for create-issue.sh. No network: glab is a stub or absent.
# Run: sh create-issue.test.sh

here=$(cd "$(dirname "$0")" && pwd)
script="$here/create-issue.sh"
shbin=$(command -v sh)
tmp=$(mktemp -d "${TMPDIR:-/tmp}/create-issue-test.XXXXXX") || exit 1
trap 'rm -rf "$tmp"' EXIT

fails=0
pass() { echo "ok: $1"; }
fail() { echo "FAIL: $1"; fails=$((fails + 1)); }
eq() { if [ "$2" = "$3" ]; then pass "$1"; else fail "$1 (got '$2', want '$3')"; fi; }
starts() { case $2 in "$3"*) pass "$1" ;; *) fail "$1 (got '$2')" ;; esac; }
gone() { if [ -e "$2" ]; then fail "$1 (still there: $2)"; else pass "$1"; fi; }

# Only the tools the script needs, so a real glab on the system PATH is never found.
tools="$tmp/tools"
mkdir -p "$tools"
for t in cat awk grep tail rm rmdir mkdir; do ln -s "$(command -v "$t")" "$tools/$t"; done

# glab stub: logs "<cmd> <subcmd>" per call; on issue create, writes each argument to its own file.
stubs="$tmp/stubs"
mkdir -p "$stubs"
cat > "$stubs/glab" <<'STUB'
#!/bin/sh
printf '%s %s\n' "$1" "$2" >> "$STUB_LOG"
if [ "$1" = auth ]; then exit "${STUB_AUTH:-0}"; fi
if [ "$1" = issue ] && [ "$2" = create ]; then
  rm -rf "$STUB_ARGS"
  mkdir -p "$STUB_ARGS"
  n=0
  for a in "$@"; do n=$((n + 1)); printf '%s' "$a" > "$STUB_ARGS/$n"; done
  printf '%s' "$n" > "$STUB_ARGS/count"
  if [ "${STUB_CREATE:-0}" != 0 ]; then echo "- Creating issue"; echo "ERROR: 403 Forbidden"; exit 1; fi
  echo "- Creating issue in team/billing-export"
  echo "#7 Rename field (just now)"
  echo " https://gitlab.example.com/team/billing-export/-/issues/7"
fi
exit 0
STUB
chmod +x "$stubs/glab"
STUB_LOG="$tmp/calls"
STUB_ARGS="$tmp/args"
export STUB_LOG STUB_ARGS

run() { # PATH, args...
  p=$1; shift
  env PATH="$p" "$shbin" "$script" "$@"
}
arg() { cat "$STUB_ARGS/$1" 2>/dev/null; }

# A fresh work dir under $tmp, with a title and a body.
n=0
work() {
  n=$((n + 1))
  w="$tmp/w$n"
  mkdir -p "$w"
  printf '%s\n' "$1" > "$w/title"
  printf '## Summary\nLine one.\n\n- [ ] WHEN a THEN b\n' > "$w/body"
}

# Usage and refused work dirs make no call
: > "$STUB_LOG"
out=$(run "$stubs:$tools"); code=$?
eq "no args exits 1" "$code" 1
starts "no args message" "$out" "create failed: usage"
out=$(run "$stubs:$tools" gitlab.example.com team/proj "$tmp/missing")
eq "missing work dir" "$out" "create failed: work dir not found"
out=$(run "$stubs:$tools" gitlab.example.com team/proj -x)
eq "option-like work dir" "$out" "create failed: invalid work dir"
real_here=$(cd "$here" && pwd -P)
case $real_here in
  "$(cd "${TMPDIR:-/tmp}" && pwd -P)"/*|"$(cd /tmp && pwd -P)"/*) pass "outside-temp check skipped (repo is under a temp dir)" ;;
  *)
    out=$(run "$stubs:$tools" gitlab.example.com team/proj "$here")
    eq "work dir outside temp refused" "$out" "create failed: work dir must be under the system temporary directory"
    [ -f "$here/create-issue.sh" ] && pass "refused dir untouched" || fail "refused dir untouched" ;;
esac
w0="$tmp/w-root"
mkdir -p "$w0"
case $(cd "$w0" && pwd -P) in
  "$(cd /tmp && pwd -P)"/*) pass "temp root check skipped (scratch dir is under /tmp)" ;;
  *)
    out=$(env TMPDIR="$w0" PATH="$stubs:$tools" "$shbin" "$script" gitlab.example.com team/proj "$w0")
    eq "temp root itself refused" "$out" "create failed: work dir must be under the system temporary directory" ;;
esac
eq "no call for refused input" "$(cat "$STUB_LOG")" ""

# Bad host or path: refused, files still removed
for bad in 'host;x' 'host name' '-host'; do
  work "T"
  out=$(run "$stubs:$tools" "$bad" team/proj "$w")
  eq "bad host '$bad'" "$out" "create failed: invalid host"
  gone "bad host '$bad' removes work dir" "$w"
done
for bad in '../x' 'a b' '-x' '/abs' 'a//b' 'a$(x)'; do
  work "T"
  out=$(run "$stubs:$tools" gitlab.example.com "$bad" "$w")
  eq "bad path '$bad'" "$out" "create failed: invalid project path"
  gone "bad path '$bad' removes work dir" "$w"
done
eq "no call for a bad host or path" "$(cat "$STUB_LOG")" ""

# Title and body checks
work "T"; rm "$w/title"
eq "no title file" "$(run "$stubs:$tools" gitlab.example.com team/proj "$w")" "create failed: no title file"
gone "no title removes work dir" "$w"
work "   "
eq "blank title" "$(run "$stubs:$tools" gitlab.example.com team/proj "$w")" "create failed: empty title"
work "T"; printf '\n\n' > "$w/body"
eq "blank body" "$(run "$stubs:$tools" gitlab.example.com team/proj "$w")" "create failed: empty body"

# glab missing: dropped values are still named, files removed
work "T"
printf 'label: ui; rm -rf ~\n' > "$w/meta"
out=$(run "$tools" gitlab.example.com team/proj "$w"); code=$?
eq "no glab exits 1" "$code" 1
eq "no glab output" "$out" "dropped: label ui; rm -rf ~
create failed: glab not installed"
gone "no glab removes work dir" "$w"

# glab not signed in: no create call
: > "$STUB_LOG"
work "T"
out=$(env STUB_AUTH=1 PATH="$stubs:$tools" "$shbin" "$script" gitlab.example.com team/proj "$w"); code=$?
eq "not signed in exits 1" "$code" 1
eq "not signed in message" "$out" "create failed: glab not signed in to gitlab.example.com"
eq "only auth status called" "$(cat "$STUB_LOG")" "auth status"

# Success with metadata: exact argv, literal title, dropped values named
: > "$STUB_LOG"
work 'Rename $(whoami) `id` field'
cat > "$w/meta" <<'META'
label: frontend
label: type::bug
label: ui; rm -rf ~
label: --confidential
assignee: jdoe
assignee: -x
milestone: v1.2
milestone: v2
confidential: yes
priority: high
no colon here
META
out=$(run "$stubs:$tools" gitlab.example.com team/billing-export "$w"); code=$?
eq "create exits 0" "$code" 0
eq "create output" "$out" "dropped: label ui; rm -rf ~
dropped: label --confidential
dropped: assignee -x
dropped: milestone v2
dropped: priority high
dropped: no colon here
created: https://gitlab.example.com/team/billing-export/-/issues/7"
eq "calls" "$(cat "$STUB_LOG")" "auth status
issue create"
eq "argv count" "$(arg count)" 12
eq "argv repo" "$(arg 3)" "--repo=https://gitlab.example.com/team/billing-export"
eq "argv title literal" "$(arg 4)" '--title=Rename $(whoami) `id` field'
eq "argv body intact" "$(arg 5)" "--description=## Summary
Line one.

- [ ] WHEN a THEN b"
eq "argv non-interactive" "$(arg 6) $(arg 7)" "--yes --no-editor"
eq "argv labels" "$(arg 8) $(arg 9)" "--label=frontend --label=type::bug"
eq "argv assignee" "$(arg 10)" "--assignee=jdoe"
eq "argv milestone" "$(arg 11)" "--milestone=v1.2"
eq "argv confidential" "$(arg 12)" "--confidential"
gone "success removes work dir" "$w"

# No meta: no metadata flags
work "Plain"
out=$(run "$stubs:$tools" gitlab.example.com team/proj "$w")
eq "no meta output" "$out" "created: https://gitlab.example.com/team/billing-export/-/issues/7"
eq "no meta argv count" "$(arg count)" 7

# Length limit, CRLF, spaces and confidential values
work "T"
l64=$(printf '%064d' 0 | tr 0 a)
printf 'label: %s\nlabel: %sb\nlabel: needs review\r\nassignee: _bot.x\nconfidential: no\n' "$l64" "$l64" > "$w/meta"
out=$(run "$stubs:$tools" gitlab.example.com team/proj "$w")
eq "limits output" "$out" "dropped: label ${l64}b
dropped: confidential no
created: https://gitlab.example.com/team/billing-export/-/issues/7"
eq "64-char label kept" "$(arg 8)" "--label=$l64"
eq "CRLF label kept" "$(arg 9)" "--label=needs review"
eq "underscore assignee kept" "$(arg 10)" "--assignee=_bot.x"
eq "no confidential flag" "$(arg count)" 10

# glab create fails: reason from its last line, files removed
work "T"
out=$(env STUB_CREATE=1 PATH="$stubs:$tools" "$shbin" "$script" gitlab.example.com team/proj "$w"); code=$?
eq "create failure exits 1" "$code" 1
eq "create failure reason" "$out" "create failed: glab: ERROR: 403 Forbidden"
gone "create failure removes work dir" "$w"

# Only the three input files are removed
work "T"
printf 'keep\n' > "$w/other.txt"
run "$stubs:$tools" gitlab.example.com team/proj "$w" >/dev/null
[ -f "$w/other.txt" ] && pass "other files kept" || fail "other files kept"
gone "title removed" "$w/title"
gone "body removed" "$w/body"

if grep -n -i 'token' "$script" >/dev/null; then fail "script mentions a token"; else pass "script has no token handling"; fi

if [ "$fails" -eq 0 ]; then echo "all passed"; exit 0; fi
echo "$fails failed"
exit 1
