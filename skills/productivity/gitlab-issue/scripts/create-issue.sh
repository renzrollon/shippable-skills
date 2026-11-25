#!/bin/sh
# create-issue.sh: create one GitLab issue with glab from files, so no
# requester text reaches a command line. Uses only the login glab already
# holds. Never reads, prints or passes a credential.
#
# usage: create-issue.sh <host> <path> <work-dir>
#
# <work-dir> is a directory under the system temporary directory holding:
#   title  the issue title (first line used)
#   body   the issue description
#   meta   optional, one "key: value" per line:
#            label: <label>         (any number)
#            assignee: <username>   (any number)
#            milestone: <title>     (one)
#            confidential: yes
#
# Prints one "dropped: <key> <value>" line per rejected metadata value, then
# "created: <url>" (exit 0) or "create failed: <reason>" (exit 1). Once the
# work dir is accepted, title, body and meta are removed on every exit, and
# the work dir too when that leaves it empty.

LC_ALL=C
export LC_ALL

fail() {
  printf 'create failed: %s\n' "$1"
  exit 1
}

[ $# -eq 3 ] || fail "usage: create-issue.sh <host> <path> <work-dir>"
host=$1
path=$2
dir=$3

# The work dir must sit strictly below the system temporary directory, so a
# wrong argument can never read or remove files in a checkout.
case $dir in
  ''|-*) fail "invalid work dir" ;;
esac
[ -d "$dir" ] || fail "work dir not found"
real=$(cd "$dir" 2>/dev/null && pwd -P) || fail "work dir not readable"
inside=0
for t in "${TMPDIR:-/tmp}" /tmp; do
  troot=$(cd "$t" 2>/dev/null && pwd -P) || continue
  case $real in
    "$troot"/?*) inside=1 ;;
  esac
done
[ "$inside" = 1 ] || fail "work dir must be under the system temporary directory"

cleanup() {
  rm -f "$real/title" "$real/body" "$real/meta"
  rmdir "$real" 2>/dev/null
  return 0
}
trap cleanup EXIT
trap 'exit 1' HUP INT TERM

# Same host and path rules as fetch-context.sh.
case $host in
  ''|-*|*[!A-Za-z0-9.-]*) fail "invalid host" ;;
esac
case $path in
  ''|-*|/*|*..*|*//*|*[!A-Za-z0-9._/-]*) fail "invalid project path" ;;
esac

cr=$(printf '\r')
[ -f "$real/title" ] || fail "no title file"
title=""
IFS= read -r title < "$real/title" || [ -n "$title" ]
title=${title%"$cr"}
case $title in
  *[![:space:]]*) ;;
  *) fail "empty title" ;;
esac
[ -f "$real/body" ] || fail "no body file"
body=$(cat "$real/body")
case $body in
  *[![:space:]]*) ;;
  *) fail "empty body" ;;
esac

label_ok() { # label or milestone
  case $1 in
    ''|[!A-Za-z0-9]*|*[!A-Za-z0-9\ ._:/-]*) return 1 ;;
  esac
  [ "${#1}" -le 64 ]
}
assignee_ok() {
  case $1 in
    ''|[!A-Za-z0-9_]*|*[!A-Za-z0-9._-]*) return 1 ;;
  esac
  [ "${#1}" -le 64 ]
}
trim() { # strip leading and trailing spaces and tabs
  t=$1
  t=${t#"${t%%[![:blank:]]*}"}
  t=${t%"${t##*[![:blank:]]}"}
  printf '%s' "$t"
}

# Flags for glab, built in "$@" without eval. Every value uses the
# --flag=value form, so none can be read as another option.
set -- issue create "--repo=https://$host/$path" "--title=$title" "--description=$body" --yes --no-editor
milestone=""
if [ -f "$real/meta" ]; then
  while IFS= read -r line || [ -n "$line" ]; do
    line=${line%"$cr"}
    case $line in
      ''|'#'*) continue ;;
    esac
    case $line in
      *:*) key=$(trim "${line%%:*}"); value=$(trim "${line#*:}") ;;
      *) printf 'dropped: %s\n' "$line"; continue ;;
    esac
    case $key in
      label)
        if label_ok "$value"; then set -- "$@" "--label=$value"; else printf 'dropped: label %s\n' "$value"; fi ;;
      milestone)
        if [ -z "$milestone" ] && label_ok "$value"; then
          milestone=$value
          set -- "$@" "--milestone=$value"
        else
          printf 'dropped: milestone %s\n' "$value"
        fi ;;
      assignee)
        if assignee_ok "$value"; then set -- "$@" "--assignee=$value"; else printf 'dropped: assignee %s\n' "$value"; fi ;;
      confidential)
        if [ "$value" = yes ]; then set -- "$@" --confidential; else printf 'dropped: confidential %s\n' "$value"; fi ;;
      *)
        printf 'dropped: %s %s\n' "$key" "$value" ;;
    esac
  done < "$real/meta"
fi

command -v glab >/dev/null 2>&1 || fail "glab not installed"
GLAB_NO_PROMPT=1
export GLAB_NO_PROMPT
glab auth status --hostname "$host" >/dev/null 2>&1 </dev/null || fail "glab not signed in to $host"

out=$(glab "$@" 2>&1 </dev/null)
code=$?
if [ "$code" -ne 0 ]; then
  reason=$(printf '%s\n' "$out" | awk 'NF { last = $0 } END { print last }')
  fail "glab: ${reason:-exited $code}"
fi
url=$(printf '%s\n' "$out" | grep -o -E 'https?://[^[:space:]]+/-/(issues|work_items)/[0-9]+' | tail -n 1)
printf 'created: %s\n' "${url:-url not shown}"
exit 0
