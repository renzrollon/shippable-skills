#!/usr/bin/env bash
# Grep a list of pinned strings against a README.
# Usage: check-pins.sh <pins-file> [README.md]
# pins-file: one string per line; blank lines and # comments skipped.
# Prints PINS KEPT: k/n and exits 1 if any are missing.

set -euo pipefail

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" || "${#}" -lt 1 ]]; then
  echo "Usage: check-pins.sh <pins-file> [README.md]" >&2
  exit 2
fi

PINS_FILE="$1"
README="${2:-README.md}"

if [[ ! -f "$PINS_FILE" ]]; then
  echo "check-pins.sh: pins file not found: $PINS_FILE" >&2
  exit 2
fi

if [[ ! -f "$README" ]]; then
  echo "check-pins.sh: README not found: $README" >&2
  exit 2
fi

total=0
kept=0
missing=()

while IFS= read -r line || [[ -n "$line" ]]; do
  [[ -z "$line" || "$line" == \#* ]] && continue
  total=$((total + 1))
  if grep -F -q -- "$line" "$README"; then
    kept=$((kept + 1))
  else
    missing+=("$line")
  fi
done < "$PINS_FILE"

echo "PINS KEPT: ${kept}/${total}"
if [[ "${#missing[@]}" -gt 0 ]]; then
  for pin in "${missing[@]}"; do
    echo "MISSING: $pin"
  done
  exit 1
fi
exit 0
