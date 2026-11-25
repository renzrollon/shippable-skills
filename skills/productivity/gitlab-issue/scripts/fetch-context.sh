#!/bin/sh
# fetch-context.sh: fetch a sparse, shallow copy of a GitLab project's OpenSpec
# and docs into a new directory. Uses only the authentication that glab or git
# already holds. Never reads, prints or passes a credential, and never waits on
# a prompt.
#
# usage: fetch-context.sh <host> <path> <dest> [branch]
#
# Prints "fetched: <dest> <branch> <commit>" (exit 0) or "fetch failed: <reason>" (exit 1).

LC_ALL=C
export LC_ALL

die() {
  printf 'fetch failed: %s\n' "$1"
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

# -L too: a broken symlink fails -e but would still be followed.
if [ -e "$dest" ] || [ -L "$dest" ]; then die "destination already exists"; fi

command -v git >/dev/null 2>&1 || die "git is not installed"

# Never wait on a prompt: no terminal or credential-manager prompt for git,
# none for glab, ssh in batch mode unless the user configured their own ssh
# command, and stdin closed on every network call.
GIT_TERMINAL_PROMPT=0
GCM_INTERACTIVE=never
GLAB_NO_PROMPT=1
export GIT_TERMINAL_PROMPT GCM_INTERACTIVE GLAB_NO_PROMPT
if [ -z "${GIT_SSH_COMMAND:-}" ] && [ -z "$(git config --get core.sshCommand 2>/dev/null)" ]; then
  GIT_SSH_COMMAND="ssh -o BatchMode=yes"
  export GIT_SSH_COMMAND
fi

# glab only when it is signed in to this host; otherwise git, with whatever
# credential helper git already has.
have_glab=0
if command -v glab >/dev/null 2>&1 && glab auth status --hostname "$host" >/dev/null 2>&1 </dev/null; then
  have_glab=1
fi

url="https://$host/$path"

# Clone flags are written out per case, with no eval.
if [ -n "$branch" ]; then
  if [ "$have_glab" = 1 ]; then
    out=$(glab repo clone "$url" "$dest" -- --depth 1 --filter=blob:none --sparse --quiet --branch "$branch" 2>&1 </dev/null)
  else
    out=$(git clone --depth 1 --filter=blob:none --sparse --quiet --branch "$branch" "$url" "$dest" 2>&1 </dev/null)
  fi
else
  if [ "$have_glab" = 1 ]; then
    out=$(glab repo clone "$url" "$dest" -- --depth 1 --filter=blob:none --sparse --quiet 2>&1 </dev/null)
  else
    out=$(git clone --depth 1 --filter=blob:none --sparse --quiet "$url" "$dest" 2>&1 </dev/null)
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

if ! out=$(git -C "$dest" sparse-checkout set --no-cone '/openspec/specs/' '/openspec/changes/' '!/openspec/changes/archive/' '/openspec/config.yaml' '/docs/*.md' 2>&1 </dev/null); then
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
printf 'fetched: %s %s %s\n' "$dest" "$branch" "$commit"
exit 0
