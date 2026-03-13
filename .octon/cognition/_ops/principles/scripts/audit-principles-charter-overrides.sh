#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../../.." && pwd)"
cd "$ROOT_DIR"

LEDGER_PATH=".octon/cognition/governance/exceptions/principles-charter-overrides.md"
REPORT_DIR=".octon/output/reports/analysis"
TODAY_UTC="$(date -u +%Y-%m-%d)"
NOW_UTC="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
REPORT_PATH="${REPORT_DIR}/${TODAY_UTC}-principles-charter-overrides-audit.md"

mkdir -p "$REPORT_DIR"

if [[ ! -f "$LEDGER_PATH" ]]; then
  cat >"$REPORT_PATH" <<EOF
# Principles Charter Overrides Audit

- generated_utc: ${NOW_UTC}
- status: FAIL
- reason: missing override ledger
- ledger_path: ${LEDGER_PATH}
EOF
  echo "[override-audit] missing override ledger: $LEDGER_PATH"
  exit 1
fi

tmp_summary="$(mktemp)"
cleanup() {
  rm -f "$tmp_summary"
}
trap cleanup EXIT

awk -v today="$TODAY_UTC" '
function trim(x) {
  gsub(/^[[:space:]]+|[[:space:]]+$/, "", x)
  return x
}

function reset_record() {
  date = ""
  rationale = ""
  responsible_owner = ""
  review_date = ""
  override_scope = ""
  review_and_agreement_evidence = ""
  exception_log_ref = ""
  authorized_by = ""
  authorization_source = ""
  break_glass = ""
  status = ""
}

function add_finding(msg) {
  finding_count++
  findings[finding_count] = msg
}

function validate_record(    missing) {
  if (current_id == "") {
    return
  }

  record_count++
  if (current_id !~ /^OVR-[0-9]{4}-[0-9]{2}-[0-9]{2}-[0-9]{3}$/) {
    add_finding(current_id ": invalid id format")
  }

  missing = 0
  if (date == "") { missing++; add_finding(current_id ": missing date") }
  if (rationale == "") { missing++; add_finding(current_id ": missing rationale") }
  if (responsible_owner == "") { missing++; add_finding(current_id ": missing responsible_owner") }
  if (review_date == "") { missing++; add_finding(current_id ": missing review_date") }
  if (override_scope == "") { missing++; add_finding(current_id ": missing override_scope") }
  if (review_and_agreement_evidence == "") { missing++; add_finding(current_id ": missing review_and_agreement_evidence") }
  if (exception_log_ref == "") { missing++; add_finding(current_id ": missing exception_log_ref") }
  if (authorized_by == "") { missing++; add_finding(current_id ": missing authorized_by") }
  if (authorization_source == "") { missing++; add_finding(current_id ": missing authorization_source") }
  if (break_glass == "") { missing++; add_finding(current_id ": missing break_glass") }
  if (status == "") { missing++; add_finding(current_id ": missing status") }

  if (missing > 0) {
    invalid_count++
    return
  }

  if (date !~ /^[0-9]{4}-[0-9]{2}-[0-9]{2}$/) {
    add_finding(current_id ": date must be YYYY-MM-DD")
    invalid_count++
  }

  if (review_date !~ /^[0-9]{4}-[0-9]{2}-[0-9]{2}$/) {
    add_finding(current_id ": review_date must be YYYY-MM-DD")
    invalid_count++
  }

  if (break_glass !~ /^(true|false)$/) {
    add_finding(current_id ": break_glass must be true or false")
    invalid_count++
  }

  if (status !~ /^(active|closed|retired)$/) {
    add_finding(current_id ": status must be active, closed, or retired")
    invalid_count++
  }

  if (status == "active" && review_date < today) {
    stale_count++
    add_finding(current_id ": active override review_date has expired (" review_date ")")
  }
}

BEGIN {
  record_count = 0
  invalid_count = 0
  stale_count = 0
  finding_count = 0
  current_id = ""
  reset_record()
}

/^### OVR-/ {
  validate_record()
  current_id = $2
  reset_record()
  next
}

current_id != "" && /^- / {
  line = $0
  sub(/^- /, "", line)
  split(line, parts, ":")
  key = trim(parts[1])
  value = line
  sub(/^[^:]*:[[:space:]]*/, "", value)
  value = trim(value)

  if (key == "date") date = value
  else if (key == "rationale") rationale = value
  else if (key == "responsible_owner") responsible_owner = value
  else if (key == "review_date") review_date = value
  else if (key == "override_scope") override_scope = value
  else if (key == "review_and_agreement_evidence") review_and_agreement_evidence = value
  else if (key == "exception_log_ref") exception_log_ref = value
  else if (key == "authorized_by") authorized_by = value
  else if (key == "authorization_source") authorization_source = value
  else if (key == "break_glass") break_glass = value
  else if (key == "status") status = value
}

END {
  validate_record()

  print "record_count=" record_count
  print "invalid_count=" invalid_count
  print "stale_count=" stale_count
  print "finding_count=" finding_count
  for (i = 1; i <= finding_count; i++) {
    print "finding_" i "=" findings[i]
  }

  if (record_count == 0) {
    print "finding_" (finding_count + 1) "=no override records found"
    print "finding_count=" (finding_count + 1)
    exit 2
  }

  if (invalid_count > 0 || stale_count > 0) {
    exit 2
  }
}
' "$LEDGER_PATH" >"$tmp_summary" || true

record_count="$(awk -F= '/^record_count=/{print $2}' "$tmp_summary" | tail -n1)"
invalid_count="$(awk -F= '/^invalid_count=/{print $2}' "$tmp_summary" | tail -n1)"
stale_count="$(awk -F= '/^stale_count=/{print $2}' "$tmp_summary" | tail -n1)"
finding_count="$(awk -F= '/^finding_count=/{print $2}' "$tmp_summary" | tail -n1)"

record_count="${record_count:-0}"
invalid_count="${invalid_count:-0}"
stale_count="${stale_count:-0}"
finding_count="${finding_count:-0}"

status="PASS"
if [[ "$invalid_count" -gt 0 || "$stale_count" -gt 0 || "$record_count" -eq 0 ]]; then
  status="FAIL"
fi

{
  echo "# Principles Charter Overrides Audit"
  echo
  echo "- generated_utc: ${NOW_UTC}"
  echo "- status: ${status}"
  echo "- ledger_path: ${LEDGER_PATH}"
  echo "- record_count: ${record_count}"
  echo "- invalid_count: ${invalid_count}"
  echo "- stale_count: ${stale_count}"
  echo
  if [[ "$finding_count" -gt 0 ]]; then
    echo "## Findings"
    echo
    awk -F= '/^finding_[0-9]+=/{print "- " $2}' "$tmp_summary"
  else
    echo "No findings."
  fi
} >"$REPORT_PATH"

echo "[override-audit] report: $REPORT_PATH"

if [[ "$status" != "PASS" ]]; then
  echo "[override-audit] failed: invalid=${invalid_count} stale=${stale_count} records=${record_count}"
  exit 1
fi

echo "[override-audit] passed"
