#!/bin/sh
# Eval grader: the body's first line is the Jira key. Inside the reply's
# "## Issue draft" block, the last non-empty line before "## Summary" must be
# PROJ-123. Reads $EVAL_FINAL_MESSAGE. Exit 0 pass, 1 fail.
# Self-contained: the eval runner uploads this one file and runs it alone.
LC_ALL=C
export LC_ALL
printf '%s\n' "${EVAL_FINAL_MESSAGE:-}" | awk '
  function clean(s) { gsub(/^[ \t>*_`]+|[ \t*_`]+$/, "", s); return s }
  /^[ \t]*## Issue draft[ \t]*$/ { on = 1; last = ""; next }
  !on { next }
  /^[ \t]*```/ { next }
  { line = clean($0) }
  line ~ /^## Summary/ { seen = 1; got = last; exit }
  line != "" { last = line }
  END {
    if (!on) { print "FAIL: no \"## Issue draft\" heading"; exit 1 }
    if (!seen) { print "FAIL: no \"## Summary\" after the draft heading"; exit 1 }
    if (got != "PROJ-123") { print "FAIL: body line 1 is \"" got "\", want PROJ-123"; exit 1 }
    print "ok: body line 1 is PROJ-123"
  }'
