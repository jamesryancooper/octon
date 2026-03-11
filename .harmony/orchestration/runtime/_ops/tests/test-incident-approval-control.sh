#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
OPS_DIR="$(cd -- "$SCRIPT_DIR/.." && pwd)"
RUNTIME_DIR="$(cd -- "$OPS_DIR/.." && pwd)"
ORCHESTRATION_DIR="$(cd -- "$RUNTIME_DIR/.." && pwd)"
HARMONY_DIR="$(cd -- "$ORCHESTRATION_DIR/.." && pwd)"
REPO_ROOT="$(cd -- "$HARMONY_DIR/.." && pwd)"

VERIFY_SCRIPT=".harmony/orchestration/runtime/_ops/scripts/verify-approval-artifact.sh"
INCIDENT_SCRIPT=".harmony/orchestration/runtime/_ops/scripts/manage-incident.sh"

pass_count=0
fail_count=0
cleanup_paths=()

cleanup() {
  local path
  for path in "${cleanup_paths[@]}"; do
    [[ -n "$path" ]] && rm -rf "$path"
  done
}
trap cleanup EXIT

pass() {
  echo "PASS: $1"
  pass_count=$((pass_count + 1))
}

fail() {
  echo "FAIL: $1" >&2
  fail_count=$((fail_count + 1))
}

assert_success() {
  local name="$1"
  shift
  if "$@"; then
    pass "$name"
  else
    fail "$name"
  fi
}

create_fixture() {
  local fixture_root
  fixture_root="$(mktemp -d "${TMPDIR:-/tmp}/incident-approval.XXXXXX")"
  cleanup_paths+=("$fixture_root")

  mkdir -p "$fixture_root/.harmony/orchestration/runtime"
  mkdir -p "$fixture_root/.harmony/orchestration/governance"
  mkdir -p "$fixture_root/.harmony/continuity/decisions/approvals"
  mkdir -p "$fixture_root/.harmony/continuity/runs"

  cp -R "$REPO_ROOT/.harmony/orchestration/runtime" "$fixture_root/.harmony/orchestration/"
  cp "$REPO_ROOT/.harmony/orchestration/governance/incidents.md" "$fixture_root/.harmony/orchestration/governance/incidents.md"
  cp "$REPO_ROOT/.harmony/orchestration/governance/approver-authority-registry.json" "$fixture_root/.harmony/orchestration/governance/approver-authority-registry.json"
  cp "$REPO_ROOT/.harmony/continuity/decisions/README.md" "$fixture_root/.harmony/continuity/decisions/README.md"
  cp "$REPO_ROOT/.harmony/continuity/decisions/retention.json" "$fixture_root/.harmony/continuity/decisions/retention.json"
  cp "$REPO_ROOT/.harmony/continuity/decisions/approvals/README.md" "$fixture_root/.harmony/continuity/decisions/approvals/README.md"
  cp "$REPO_ROOT/.harmony/continuity/runs/README.md" "$fixture_root/.harmony/continuity/runs/README.md"

  printf '%s\n' "$fixture_root"
}

write_approval() {
  local fixture_root="$1"
  local approval_id="$2"
  local expires_at="$3"
  local approved_by="${4:-@architect}"
  local action_class="${5:-close-incident}"
  cat > "$fixture_root/.harmony/continuity/decisions/approvals/${approval_id}.json" <<EOF
{
  "approval_id": "${approval_id}",
  "artifact_type": "approval",
  "action_class": "${action_class}",
  "scope": {
    "surface": "incidents",
    "action": "close-incident"
  },
  "approved_by": "${approved_by}",
  "issued_at": "2026-03-10T00:00:00Z",
  "expires_at": "${expires_at}",
  "rationale": "test approval",
  "review_required": false
}
EOF
}

case_valid_close_requires_approval() {
  local fixture_root envs
  fixture_root="$(create_fixture)"
  envs=("HARMONY_DIR_OVERRIDE=$fixture_root/.harmony" "HARMONY_ROOT_DIR=$fixture_root")
  write_approval "$fixture_root" "appr-valid-close" "2027-03-10T00:00:00Z"

  env "${envs[@]}" bash "$REPO_ROOT/$INCIDENT_SCRIPT" open \
    --incident-id inc-test-001 \
    --title "Test Incident" \
    --severity sev2 \
    --owner @architect \
    --summary "Test incident for close path." >/dev/null

  env "${envs[@]}" bash "$REPO_ROOT/$INCIDENT_SCRIPT" close \
    --incident-id inc-test-001 \
    --closed-by @architect \
    --approval-id appr-valid-close \
    --closure-summary "Incident resolved with evidence." \
    --remediation-ref "run:run-test-001" >/dev/null

  [[ -f "$fixture_root/.harmony/orchestration/runtime/incidents/inc-test-001/closure.md" ]]
  yq -r '.status' "$fixture_root/.harmony/orchestration/runtime/incidents/inc-test-001/incident.yml" | grep -qx "closed"
}

case_missing_or_invalid_approval_blocks_close() {
  local fixture_root envs
  fixture_root="$(create_fixture)"
  envs=("HARMONY_DIR_OVERRIDE=$fixture_root/.harmony" "HARMONY_ROOT_DIR=$fixture_root")
  write_approval "$fixture_root" "appr-expired-close" "2000-01-01T00:00:00Z"

  env "${envs[@]}" bash "$REPO_ROOT/$INCIDENT_SCRIPT" open \
    --incident-id inc-test-002 \
    --title "Blocked Close Incident" \
    --severity sev2 \
    --owner @architect \
    --summary "Close should fail without valid approval." >/dev/null

  if env "${envs[@]}" bash "$REPO_ROOT/$INCIDENT_SCRIPT" close \
      --incident-id inc-test-002 \
      --closed-by @architect \
      --approval-id appr-expired-close \
      --closure-summary "Should not close." \
      --remediation-ref "run:run-test-002" >/dev/null 2>&1; then
    return 1
  fi
}

case_scope_mismatch_blocks_approval() {
  local fixture_root envs
  fixture_root="$(create_fixture)"
  envs=("HARMONY_DIR_OVERRIDE=$fixture_root/.harmony" "HARMONY_ROOT_DIR=$fixture_root")
  write_approval "$fixture_root" "appr-scope-mismatch" "2027-03-10T00:00:00Z" "@architect" "incident-severity-downgrade"
  if env "${envs[@]}" bash "$REPO_ROOT/$VERIFY_SCRIPT" --approval-id appr-scope-mismatch --action-class close-incident --surface incidents >/dev/null 2>&1; then
    return 1
  fi
}

assert_success "valid approval allows incident closure" case_valid_close_requires_approval
assert_success "expired approval blocks incident closure" case_missing_or_invalid_approval_blocks_close
assert_success "scope mismatch blocks approval verification" case_scope_mismatch_blocks_approval

if (( fail_count > 0 )); then
  echo "FAILURES: $fail_count" >&2
  exit 1
fi

echo "PASS: $pass_count"
