#!/bin/sh
# Eval grader: a pasted log over five lines sits in the collapsed Logs block.
# Inside the draft, "Log attached below" comes before "<summary>Logs</summary>",
# and the first trace line comes after it. Reads $EVAL_FINAL_MESSAGE.
# Exit 0 pass, 1 fail.
# Self-contained: the eval runner uploads this one file and runs it alone.
LC_ALL=C
export LC_ALL
printf '%s\n' "${EVAL_FINAL_MESSAGE:-}" | awk '
  function fail(m) { print "FAIL: " m; bad = 1 }
  /^[ \t]*## Issue draft[ \t]*$/ { on = 1; n = 0; logs = 0; trace = 0; note = 0; next }
  !on { next }
  { n++ }
  !logs && /<summary>Logs<\/summary>/ { logs = n }
  !trace && /export-worker\.js:88:13/ { trace = n }
  !note && /Log attached below/ { note = n }
  END {
    if (!on) fail("no \"## Issue draft\" heading")
    else if (!logs) fail("no <summary>Logs</summary> block")
    else {
      if (!trace) fail("trace line missing from the draft")
      else if (trace < logs) fail("trace line appears above the Logs block")
      if (!note) fail("no \"Log attached below\" under Actual")
      else if (note > logs) fail("\"Log attached below\" is not above the Logs block")
    }
    if (!bad) print "ok: log collapsed under Logs"
    exit bad
  }'
