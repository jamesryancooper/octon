#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../.." && pwd)"
OCTON_DIR="${OCTON_DIR_OVERRIDE:-$DEFAULT_OCTON_DIR}"
ROOT_DIR="${OCTON_ROOT_DIR:-$(cd -- "$OCTON_DIR/.." && pwd)}"
CONFIG_FILE="$OCTON_DIR/instance/governance/closure/uec-packet-certification-runs.yml"
HIDDEN_REPAIR_FILE="$OCTON_DIR/state/evidence/validation/publication/unified-execution-constitution-closure/hidden-repair-detection.yml"

errors=0

fail() { echo "[ERROR] $1"; errors=$((errors + 1)); }
pass() { echo "[OK] $1"; }

require_file() {
  local path="$1"
  [[ -f "$path" ]] && pass "found ${path#$ROOT_DIR/}" || fail "missing ${path#$ROOT_DIR/}"
}

role_run_id() {
  local role="$1"
  yq -r ".run_roles.${role}.run_id" "$CONFIG_FILE"
}

run_root() { printf '%s/state/control/execution/runs/%s' "$OCTON_DIR" "$1"; }
evidence_root() { printf '%s/state/evidence/runs/%s' "$OCTON_DIR" "$1"; }

validate_event_ledger() {
  local run_id="$1"
  local run_dir="$(
    run_root "$run_id"
  )"
  local ledger="$run_dir/events.ndjson"
  local manifest="$run_dir/events.manifest.yml"
  require_file "$ledger"
  require_file "$manifest"

  jq -Rcs 'split("\n") | map(select(length > 0) | fromjson) | length > 0' "$ledger" >/dev/null 2>&1 \
    && pass "$run_id event ledger parses as NDJSON" \
    || fail "$run_id event ledger parses as NDJSON"

  for event_type in run-created stage-started checkpoint-created disclosure-generated run-closed; do
    jq -Rcs --arg event_type "$event_type" 'split("\n") | map(select(length > 0) | fromjson) | any(.event_type == $event_type)' "$ledger" >/dev/null 2>&1 \
      && pass "$run_id ledger includes $event_type" \
      || fail "$run_id ledger includes $event_type"
  done
}

validate_authority_root() {
  local run_id="$1"
  local authority_root="$(run_root "$run_id")/authority"
  require_file "$authority_root/index.yml"
  require_file "$authority_root/decisions/decision.yml"
  require_file "$authority_root/grants/grant-bundle.yml"
}

main() {
  require_file "$CONFIG_FILE"
  require_file "$OCTON_DIR/framework/constitution/contracts/runtime/run-event-v1.schema.json"
  require_file "$OCTON_DIR/framework/constitution/contracts/runtime/run-event-ledger-v1.schema.json"
  require_file "$OCTON_DIR/framework/constitution/contracts/runtime/checkpoint-v2.schema.json"
  require_file "$OCTON_DIR/framework/constitution/contracts/runtime/state-reconstruction-v1.md"
  require_file "$OCTON_DIR/framework/constitution/contracts/retention/evidence-retention-contract-v1.schema.json"

  local supported_run authority_run external_run intervention_run
  supported_run="$(role_run_id supported_run_only)"
  authority_run="$(role_run_id authority_exercise)"
  external_run="$(role_run_id external_evidence)"
  intervention_run="$(role_run_id intervention_control)"

  validate_event_ledger "$supported_run"
  validate_event_ledger "$authority_run"
  validate_event_ledger "$intervention_run"
  validate_authority_root "$supported_run"
  validate_authority_root "$authority_run"

  require_file "$(run_root "$authority_run")/authority/leases/index.yml"
  require_file "$(run_root "$authority_run")/authority/revocations/index.yml"
  yq -e '.leases | length > 0' "$(run_root "$authority_run")/authority/leases/index.yml" >/dev/null 2>&1 \
    && pass "$authority_run has per-run lease bundle" \
    || fail "$authority_run has per-run lease bundle"
  yq -e '.revocations | length > 0' "$(run_root "$authority_run")/authority/revocations/index.yml" >/dev/null 2>&1 \
    && pass "$authority_run has per-run revocation bundle" \
    || fail "$authority_run has per-run revocation bundle"

  jq -Rcs 'split("\n") | map(select(length > 0) | fromjson) | any(.event_type == "lease-issued")' "$(run_root "$authority_run")/events.ndjson" >/dev/null 2>&1 \
    && pass "$authority_run ledger includes lease-issued" \
    || fail "$authority_run ledger includes lease-issued"
  jq -Rcs 'split("\n") | map(select(length > 0) | fromjson) | any(.event_type == "revocation-activated")' "$(run_root "$authority_run")/events.ndjson" >/dev/null 2>&1 \
    && pass "$authority_run ledger includes revocation-activated" \
    || fail "$authority_run ledger includes revocation-activated"
  jq -Rcs 'split("\n") | map(select(length > 0) | fromjson) | any(.event_type == "authority-denied")' "$(run_root "$authority_run")/events.ndjson" >/dev/null 2>&1 \
    && pass "$authority_run ledger includes authority-denied" \
    || fail "$authority_run ledger includes authority-denied"

  require_file "$OCTON_DIR/state/evidence/external-index/runs/${external_run}.yml"
  yq -e '.entries[] | select(.evidence_class == "C" and .storage_class == "external-immutable")' "$OCTON_DIR/state/evidence/external-index/runs/${external_run}.yml" >/dev/null 2>&1 \
    && pass "$external_run retains Class C external immutable evidence" \
    || fail "$external_run retains Class C external immutable evidence"

  require_file "$(evidence_root "$intervention_run")/interventions/records/manual-review-override.yml"
  yq -e '.interventions | length > 0' "$(evidence_root "$intervention_run")/interventions/log.yml" >/dev/null 2>&1 \
    && pass "$intervention_run retains a non-zero intervention log" \
    || fail "$intervention_run retains a non-zero intervention log"
  yq -e '.metrics[] | select(.metric_id == "intervention-count" and .value >= 1)' "$(evidence_root "$intervention_run")/measurements/summary.yml" >/dev/null 2>&1 \
    && pass "$intervention_run measurement summary records non-zero intervention count" \
    || fail "$intervention_run measurement summary records non-zero intervention count"

  require_file "$HIDDEN_REPAIR_FILE"
  yq -e '.status == "pass"' "$HIDDEN_REPAIR_FILE" >/dev/null 2>&1 \
    && pass "hidden-repair detection proof passes" \
    || fail "hidden-repair detection proof passes"

  echo "Validation summary: errors=$errors"
  [[ $errors -eq 0 ]]
}

main "$@"
