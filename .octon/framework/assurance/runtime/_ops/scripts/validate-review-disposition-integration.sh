#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../../" && pwd)"
OCTON_DIR="${OCTON_DIR_OVERRIDE:-$DEFAULT_OCTON_DIR}"
ROOT_DIR="${OCTON_ROOT_DIR:-$(cd -- "$OCTON_DIR/.." && pwd)}"

FINDING_SCHEMA="$OCTON_DIR/framework/constitution/contracts/assurance/review-finding-v1.schema.json"
DISPOSITION_SCHEMA="$OCTON_DIR/framework/constitution/contracts/assurance/review-disposition-v1.schema.json"
POLICY_FILE="$OCTON_DIR/instance/governance/policies/review-disposition.yml"
CONTROL_FILE="$OCTON_DIR/state/control/execution/runs/run-wave4-benchmark-evaluator-20260327/authority/review-dispositions.yml"
FINDINGS_FILE="$OCTON_DIR/state/evidence/runs/run-wave4-benchmark-evaluator-20260327/assurance/review-findings.ndjson"
HELPER="$OCTON_DIR/framework/assurance/evaluators/runtime/_ops/scripts/evaluate-review-dispositions.sh"

errors=0
fail() { echo "[ERROR] $1"; errors=$((errors + 1)); }
pass() { echo "[OK] $1"; }

cleanup_dir() {
  local path="$1"
  find "$path" -type f -delete
  find "$path" -depth -type d -exec rmdir {} + 2>/dev/null || true
}

main() {
  echo "== Review Disposition Integration Validation =="

  for path in "$FINDING_SCHEMA" "$DISPOSITION_SCHEMA" "$POLICY_FILE" "$CONTROL_FILE" "$FINDINGS_FILE" "$HELPER"; do
    [[ -f "$path" || -x "$path" ]] && pass "found ${path#$ROOT_DIR/}" || fail "missing ${path#$ROOT_DIR/}"
  done

  yq -e '.schema_version == "review-dispositions-v1"' "$CONTROL_FILE" >/dev/null 2>&1 \
    && pass "review disposition control file uses review-dispositions-v1" \
    || fail "review disposition control file must use review-dispositions-v1"

  if [[ "$(wc -l < "$FINDINGS_FILE" | tr -d ' ')" -ge 1 ]]; then
    pass "review findings NDJSON is non-empty"
  else
    fail "review findings NDJSON must contain at least one finding"
  fi

  while IFS= read -r line; do
    [[ -n "$line" ]] || continue
    if jq -e '.schema_version == "review-finding-v1" and (.finding_id | length > 0) and (.evidence_refs | length > 0)' >/dev/null <<<"$line"; then
      pass "review finding line is shaped correctly"
    else
      fail "review finding line must match review-finding-v1 shape"
    fi
  done < "$FINDINGS_FILE"

  if "$HELPER" --policy "$POLICY_FILE" --control "$CONTROL_FILE" >/tmp/review-disposition-validation.json 2>/dev/null; then
    if jq -e '.gate_status == "pass" and .unresolved_blocking == 0' /tmp/review-disposition-validation.json >/dev/null 2>&1; then
      pass "live review disposition exemplar passes gating"
    else
      fail "live review disposition exemplar must pass gating"
    fi
  else
    fail "live review disposition exemplar should not block"
  fi
  rm -f /tmp/review-disposition-validation.json

  local tmpdir accepted_file blocked_file deferred_file rejected_nonblocking_file
  tmpdir="$(mktemp -d)"
  accepted_file="$tmpdir/accepted.yml"
  blocked_file="$tmpdir/blocked.yml"
  deferred_file="$tmpdir/deferred.yml"
  rejected_nonblocking_file="$tmpdir/rejected-nonblocking.yml"

  cat > "$accepted_file" <<'EOF'
schema_version: "review-dispositions-v1"
run_id: "fixture"
policy_ref: ".octon/instance/governance/policies/review-disposition.yml"
entries:
  - schema_version: "review-disposition-v1"
    finding_id: "fixture-accepted"
    subject_ref: "fixture://run"
    disposition: "accepted"
    blocking: false
    rationale: "accepted"
    follow_up_ref: null
    evidence_refs:
      - "fixture://evidence"
    decided_at: "2026-04-11T00:00:00Z"
    decided_by: "operator://fixture"
EOF

  cat > "$blocked_file" <<'EOF'
schema_version: "review-dispositions-v1"
run_id: "fixture"
policy_ref: ".octon/instance/governance/policies/review-disposition.yml"
entries:
  - schema_version: "review-disposition-v1"
    finding_id: "fixture-blocked"
    subject_ref: "fixture://run"
    disposition: "blocked"
    blocking: true
    rationale: "blocked"
    follow_up_ref: null
    evidence_refs:
      - "fixture://evidence"
    decided_at: "2026-04-11T00:00:00Z"
    decided_by: "operator://fixture"
EOF

  cat > "$deferred_file" <<'EOF'
schema_version: "review-dispositions-v1"
run_id: "fixture"
policy_ref: ".octon/instance/governance/policies/review-disposition.yml"
entries:
  - schema_version: "review-disposition-v1"
    finding_id: "fixture-deferred"
    subject_ref: "fixture://run"
    disposition: "deferred"
    blocking: false
    rationale: "deferred"
    follow_up_ref: null
    evidence_refs:
      - "fixture://evidence"
    decided_at: "2026-04-11T00:00:00Z"
    decided_by: "operator://fixture"
EOF

  cat > "$rejected_nonblocking_file" <<'EOF'
schema_version: "review-dispositions-v1"
run_id: "fixture"
policy_ref: ".octon/instance/governance/policies/review-disposition.yml"
entries:
  - schema_version: "review-disposition-v1"
    finding_id: "fixture-rejected"
    subject_ref: "fixture://run"
    disposition: "rejected"
    blocking: false
    rationale: "rejected"
    follow_up_ref: null
    evidence_refs:
      - "fixture://evidence"
    decided_at: "2026-04-11T00:00:00Z"
    decided_by: "operator://fixture"
EOF

  if "$HELPER" --policy "$POLICY_FILE" --control "$accepted_file" >/dev/null 2>&1; then
    pass "accepted fixture passes"
  else
    fail "accepted fixture should pass"
  fi

  if "$HELPER" --policy "$POLICY_FILE" --control "$blocked_file" >/dev/null 2>&1; then
    fail "blocked fixture must fail closed"
  else
    pass "blocked fixture fails closed"
  fi

  if "$HELPER" --policy "$POLICY_FILE" --control "$deferred_file" >/dev/null 2>&1; then
    fail "deferred fixture without follow-up must fail closed"
  else
    pass "deferred fixture without follow-up fails closed"
  fi

  if "$HELPER" --policy "$POLICY_FILE" --control "$rejected_nonblocking_file" >/dev/null 2>&1; then
    fail "non-progressing rejected fixture must fail closed even when blocking is false"
  else
    pass "non-progressing rejected fixture fails closed even when blocking is false"
  fi

  cleanup_dir "$tmpdir"

  echo "Validation summary: errors=$errors"
  [[ $errors -eq 0 ]]
}

main "$@"
