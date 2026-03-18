#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
COGNITION_DIR="$(cd -- "$SCRIPT_DIR/../../.." && pwd)"
SYNC_SCRIPT="$SCRIPT_DIR/sync-runtime-artifacts.sh"
FIXTURE_TEST_SCRIPT="$SCRIPT_DIR/test-sync-runtime-artifacts-fixtures.sh"

errors=0
warnings=0

fail() {
  echo "[ERROR] $1"
  errors=$((errors + 1))
}

warn() {
  echo "[WARN] $1"
  warnings=$((warnings + 1))
}

pass() {
  echo "[OK] $1"
}

matches_pattern() {
  local pattern="$1"
  local file="$2"
  if command -v rg >/dev/null 2>&1; then
    rg -q -- "$pattern" "$file"
  else
    grep -Eq -- "$pattern" "$file"
  fi
}

extract_ids() {
  local file="$1"
  awk '
    /^[[:space:]]+- id:[[:space:]]*/ {
      line=$0
      sub(/^[[:space:]]+- id:[[:space:]]*/, "", line)
      gsub(/"/, "", line)
      print line
    }
  ' "$file"
}

check_sorted_and_unique() {
  local file="$1"
  local label="$2"
  local enforce_sorted="${3:-true}"
  local ids

  if [[ ! -f "$file" ]]; then
    fail "missing file for sorted/unique check: ${file#$COGNITION_DIR/}"
    return
  fi

  ids="$(extract_ids "$file")"
  if [[ -z "$ids" ]]; then
    pass "$label has no id records (allowed)"
    return
  fi

  local dupes
  dupes="$(printf '%s\n' "$ids" | sort | uniq -d || true)"
  if [[ -n "$dupes" ]]; then
    fail "$label contains duplicate ids: $(echo "$dupes" | paste -sd ', ' -)"
  else
    pass "$label ids are unique"
  fi

  if [[ "$enforce_sorted" != "true" ]]; then
    pass "$label order enforcement skipped"
    return
  fi

  local sorted
  sorted="$(printf '%s\n' "$ids" | sort)"
  if [[ "$sorted" != "$ids" ]]; then
    fail "$label ids must be sorted lexicographically"
  else
    pass "$label ids are sorted"
  fi
}

check_decisions_summary_contract() {
  local summary="$COGNITION_DIR/runtime/context/decisions.md"
  if [[ ! -f "$summary" ]]; then
    fail "missing generated decisions summary: runtime/context/decisions.md"
    return
  fi

  if matches_pattern '^mutability:[[:space:]]*generated$' "$summary"; then
    pass "decisions summary mutability contract is generated"
  else
    fail "decisions summary must declare mutability: generated"
  fi

  if matches_pattern '^generated_from:' "$summary"; then
    pass "decisions summary generated_from contract present"
  else
    fail "decisions summary missing generated_from contract"
  fi
}

date_to_epoch() {
  local raw_date="$1"
  if date -u -j -f "%Y-%m-%d" "$raw_date" +"%s" >/dev/null 2>&1; then
    date -u -j -f "%Y-%m-%d" "$raw_date" +"%s"
    return
  fi
  if date -u -d "$raw_date" +"%s" >/dev/null 2>&1; then
    date -u -d "$raw_date" +"%s"
    return
  fi
  return 1
}

check_evaluation_digest_freshness() {
  local digest_index="$COGNITION_DIR/runtime/evaluations/digests/index.yml"
  local latest_digest_date
  local now_epoch
  local digest_epoch
  local age_days
  local freshness_threshold_days=10

  if [[ ! -f "$digest_index" ]]; then
    warn "cannot evaluate digest freshness; missing file: runtime/evaluations/digests/index.yml"
    return
  fi

  latest_digest_date="$(
    awk '
      /^[[:space:]]+digest_date:[[:space:]]*/ {
        line=$0
        sub(/^[[:space:]]+digest_date:[[:space:]]*/, "", line)
        gsub(/"/, "", line)
        if (line ~ /^[0-9]{4}-[0-9]{2}-[0-9]{2}$/) print line
      }
    ' "$digest_index" | sort | tail -n 1
  )"

  if [[ -z "$latest_digest_date" ]]; then
    warn "runtime evaluation digest freshness unknown; no digest_date records found"
    return
  fi

  if ! digest_epoch="$(date_to_epoch "$latest_digest_date")"; then
    warn "unable to parse latest digest_date for freshness check: $latest_digest_date"
    return
  fi

  now_epoch="$(date -u +"%s")"
  age_days=$(( (now_epoch - digest_epoch) / 86400 ))

  if (( age_days > freshness_threshold_days )); then
    warn "latest evaluation digest is stale (${age_days}d old, latest=${latest_digest_date}, threshold=${freshness_threshold_days}d)"
  else
    pass "evaluation digest freshness within threshold (${age_days}d old)"
  fi
}

main() {
  echo "== Validate Generated Cognition Runtime Artifacts =="

  if [[ ! -f "$SYNC_SCRIPT" ]]; then
    fail "missing sync script: ${SYNC_SCRIPT#$COGNITION_DIR/}"
  elif bash "$SYNC_SCRIPT" --check; then
    pass "generated artifact sync check passed"
  else
    fail "generated artifact sync check failed"
  fi

  if [[ ! -f "$FIXTURE_TEST_SCRIPT" ]]; then
    fail "missing sync fixture test script: ${FIXTURE_TEST_SCRIPT#$COGNITION_DIR/}"
  elif bash "$FIXTURE_TEST_SCRIPT"; then
    pass "sync fixture tests passed"
  else
    fail "sync fixture tests failed"
  fi

  check_sorted_and_unique "$COGNITION_DIR/runtime/decisions/index.yml" "runtime decision index"
  check_sorted_and_unique "$COGNITION_DIR/runtime/migrations/index.yml" "runtime migration index" false
  check_sorted_and_unique "$COGNITION_DIR/runtime/audits/index.yml" "runtime audit index" false
  check_sorted_and_unique "$COGNITION_DIR/runtime/evaluations/actions/open-actions.yml" "evaluation open-action ledger"
  check_decisions_summary_contract
  check_evaluation_digest_freshness

  echo "Validation summary: errors=$errors warnings=$warnings"
  if [[ $errors -gt 0 ]]; then
    exit 1
  fi
}

main "$@"
