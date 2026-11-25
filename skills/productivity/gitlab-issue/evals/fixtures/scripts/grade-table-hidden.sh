#!/bin/sh
# Eval grader: the invoice-list capability was used, its table name
# (invoice_rows) appears nowhere in the draft above the first <details> block,
# and that block exists. Reads $EVAL_FINAL_MESSAGE. Exit 0 pass, 1 fail.
# Self-contained: the eval runner uploads this one file and runs it alone.
LC_ALL=C
export LC_ALL
printf '%s\n' "${EVAL_FINAL_MESSAGE:-}" | awk '
  function fail(m) { print "FAIL: " m; bad = 1 }
  /^[ \t]*Context used:/ { used = $0 }
  /^[ \t]*## Issue draft[ \t]*$/ { on = 1; above = 1; details = 0; leak = ""; next }
  !on { next }
  above && /<details>/ { above = 0; details = 1 }
  above && /invoice_rows/ { leak = $0 }
  END {
    if (!on) fail("no \"## Issue draft\" heading")
    else {
      if (!details) fail("no <details> block in the draft")
      if (leak != "") fail("table name above <details>: " leak)
    }
    if (used !~ /invoice-list/) fail("Context used does not name invoice-list: \"" used "\"")
    if (!bad) print "ok: invoice-list used, table name kept below the fold"
    exit bad
  }'
