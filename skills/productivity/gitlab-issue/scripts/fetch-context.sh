#!/bin/sh
# fetch-context.sh: fetch a sparse, shallow copy of a GitLab project's OpenSpec
# and docs into a new directory. Uses only the authentication that glab or git
# already holds. Never reads, prints or passes a credential.
#
# usage: fetch-context.sh <host> <path> <dest> [branch]
#
# Prints "fetched: <dest> <branch> <commit>" (exit 0) or "fetch failed: <reason>" (exit 1).

LC_ALL=C
export LC_ALL

die() {
  echo "fetch failed: $1"
  exit 1
}

[ $# -ge 3 ] && [ $# -le 4 ] || die "usage: fetch-context.sh <host> <path> <dest> [branch]"
host=$1
path=$2
dest=$3
branch=${4:-}

# Validate every value before any network call.
case $host in
  ''|-*|*[!A-Za-z0-9.-]*) die "invalid host" ;;
esac
case $path in
  ''|-*|/*|*..*|*//*|*[!A-Za-z0-9._/-]*) die "invalid project path" ;;
esac
case $dest in
  ''|-*) die "invalid destination" ;;
esac
if [ -n "$branch" ]; then
  case $branch in
    -*|*..*|*[!A-Za-z0-9._/-]*) die "invalid branch" ;;
  esac
fi

[ -e "$dest" ] && die "destination already exists"

have_glab=0
command -v glab >/dev/null 2>&1 && have_glab=1
command -v git >/dev/null 2>&1 || die "git is not installed"

url="https://$host/$path"
GIT_TERMINAL_PROMPT=0
export GIT_TERMINAL_PROMPT

# $@ for the clone flags, built without eval.
if [ -n "$branch" ]; then
  if [ "$have_glab" = 1 ]; then
    out=$(glab repo clone "$url" "$dest" -- --depth 1 --filter=blob:none --sparse --quiet --branch "$branch" 2>&1)
  else
    out=$(git clone --depth 1 --filter=blob:none --sparse --quiet --branch "$branch" "$url" "$dest" 2>&1)
  fi
else
  if [ "$have_glab" = 1 ]; then
    out=$(glab repo clone "$url" "$dest" -- --depth 1 --filter=blob:none --sparse --quiet 2>&1)
  else
    out=$(git clone --depth 1 --filter=blob:none --sparse --quiet "$url" "$dest" 2>&1)
  fi
fi
code=$?
if [ "$code" -ne 0 ]; then
  reason=${out##*
}
  [ -n "$reason" ] || reason="clone exited $code"
  [ -d "$dest" ] && rm -rf "$dest"
  die "$reason"
fi

if ! out=$(git -C "$dest" sparse-checkout set --no-cone '/openspec/specs/' '/openspec/changes/' '!/openspec/changes/archive/' '/openspec/config.yaml' '/docs/*.md' 2>&1); then
  reason=${out##*
}
  [ -d "$dest" ] && rm -rf "$dest"
  die "${reason:-sparse checkout failed}"
fi

commit=$(git -C "$dest" rev-parse --short HEAD 2>/dev/null)
[ -n "$commit" ] || { rm -rf "$dest"; die "could not read the fetched commit"; }
if [ -z "$branch" ]; then
  branch=$(git -C "$dest" rev-parse --abbrev-ref HEAD 2>/dev/null)
  [ -n "$branch" ] || branch=HEAD
fi
echo "fetched: $dest $branch $commit"
exit 0
