#!/bin/sh
# Offline tests for fetch-context.sh. No network: git and glab are stubs or absent.
# Run: sh fetch-context.test.sh

here=$(cd "$(dirname "$0")" && pwd)
script="$here/fetch-context.sh"
shbin=$(command -v sh)
tmp=$(mktemp -d "${TMPDIR:-/tmp}/fetch-context-test.XXXXXX") || exit 1
trap 'rm -rf "$tmp"' EXIT

fails=0
pass() { echo "ok: $1"; }
fail() { echo "FAIL: $1"; fails=$((fails + 1)); }
eq() { if [ "$2" = "$3" ]; then pass "$1"; else fail "$1 (got '$2', want '$3')"; fi; }
starts() { case $2 in "$3"*) pass "$1" ;; *) fail "$1 (got '$2')" ;; esac; }

# Stub bin dir: git (always) and optionally glab. Each call is logged to $tmp/calls.
stubs="$tmp/stubs"
mkdir -p "$stubs" "$tmp/empty"
cat > "$stubs/git" <<'STUB'
#!/bin/sh
echo "git $*" >> "$STUB_LOG"
if [ "$1" = clone ]; then
  for a in "$@"; do d=$a; done
  mkdir -p "$d"
  exit 0
fi
if [ "$1" = -C ]; then
  case $3 in
    sparse-checkout) exit 0 ;;
    rev-parse)
      case $4 in
        --short) echo abc1234 ;;
        --abbrev-ref) echo main ;;
      esac
      exit 0 ;;
  esac
fi
exit 0
STUB
cat > "$stubs/glab" <<'STUB'
#!/bin/sh
echo "glab $*" >> "$STUB_LOG"
for a in "$@"; do [ "$a" = -- ] && break; d=$a; done
# destination is the argument before the -- separator
mkdir -p "$d"
exit 0
STUB
chmod +x "$stubs/git" "$stubs/glab"
STUB_LOG="$tmp/calls"
export STUB_LOG

run() { # PATH-dir-list, args...
  p=$1; shift
  env PATH="$p" "$shbin" "$script" "$@"
}

# Rejected arguments make no call at all
for bad in 'a;b' 'a b' 'a$(x)' '../x' 'a..b' '-x'; do
  : > "$STUB_LOG"
  out=$(run "$stubs" gitlab.example.com "$bad" "$tmp/d1" 2>&1); code=$?
  eq "bad path '$bad' exits 1" "$code" 1
  starts "bad path '$bad' message" "$out" "fetch failed: invalid project path"
  eq "bad path '$bad' made no call" "$(cat "$STUB_LOG")" ""
done
: > "$STUB_LOG"
out=$(run "$stubs" 'host;x' group/proj "$tmp/d1"); eq "bad host exits 1" "$?" 1
starts "bad host message" "$out" "fetch failed: invalid host"
out=$(run "$stubs" 'host name' group/proj "$tmp/d1"); starts "host with space" "$out" "fetch failed: invalid host"
out=$(run "$stubs" gitlab.example.com group/proj "$tmp/d1" 'main;x'); starts "bad branch" "$out" "fetch failed: invalid branch"
out=$(run "$stubs" gitlab.example.com group/proj "$tmp/d1" '--upload-pack=x'); starts "option-like branch" "$out" "fetch failed: invalid branch"
eq "no call for any rejected value" "$(cat "$STUB_LOG")" ""
out=$(run "$stubs" gitlab.example.com group/proj); starts "too few args" "$out" "fetch failed: usage"

# Neither glab nor git on PATH
out=$(run "$tmp/empty" gitlab.example.com group/proj "$tmp/d2"); code=$?
eq "no tools exits 1" "$code" 1
starts "no tools message" "$out" "fetch failed:"
[ -e "$tmp/d2" ] && fail "no tools created dest" || pass "no tools created nothing"

# Existing destination is refused
mkdir -p "$tmp/exists"
: > "$STUB_LOG"
out=$(run "$stubs" gitlab.example.com group/proj "$tmp/exists"); code=$?
eq "existing dest exits 1" "$code" 1
eq "existing dest message" "$out" "fetch failed: destination already exists"
eq "existing dest made no call" "$(cat "$STUB_LOG")" ""

# git path (no glab): stubbed success
gitonly="$tmp/gitonly"
mkdir -p "$gitonly"
cp "$stubs/git" "$gitonly/git"
# the stub only needs mkdir, which is an external tool: keep the system PATH after the stubs
sysp=$(dirname "$(command -v mkdir)")
: > "$STUB_LOG"
out=$(run "$gitonly:$sysp" gitlab.example.com group/sub/proj "$tmp/ok1"); code=$?
eq "git fetch exits 0" "$code" 0
eq "git fetch output" "$out" "fetched: $tmp/ok1 main abc1234"
grep -q 'git clone --depth 1 --filter=blob:none --sparse --quiet https://gitlab.example.com/group/sub/proj ' "$STUB_LOG" && pass "git clone flags and url" || fail "git clone flags and url"
grep -q "sparse-checkout set --no-cone /openspec/specs/ /openspec/changes/ !/openspec/changes/archive/ /openspec/config.yaml /docs/\*.md" "$STUB_LOG" && pass "sparse patterns" || fail "sparse patterns"

# glab path with a named branch
: > "$STUB_LOG"
out=$(run "$stubs:$sysp" gitlab.example.com group/proj "$tmp/ok2" release/1.0); code=$?
eq "glab fetch exits 0" "$code" 0
eq "glab fetch output" "$out" "fetched: $tmp/ok2 release/1.0 abc1234"
grep -q 'glab repo clone https://gitlab.example.com/group/proj .* -- --depth 1 --filter=blob:none --sparse --quiet --branch release/1.0' "$STUB_LOG" && pass "glab clone flags" || fail "glab clone flags"

# No credential ever appears in a URL or the script
grep -q '@gitlab' "$STUB_LOG" && fail "credential-style url" || pass "no credential in url"
if grep -n -i 'token' "$script" >/dev/null; then fail "script mentions a token"; else pass "script has no token handling"; fi

if [ "$fails" -eq 0 ]; then echo "all passed"; exit 0; fi
echo "$fails failed"
exit 1
