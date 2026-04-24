#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../.." && pwd)"
OCTON_DIR="${OCTON_DIR_OVERRIDE:-$DEFAULT_OCTON_DIR}"
ROOT_DIR="${OCTON_ROOT_DIR:-$(cd -- "$OCTON_DIR/.." && pwd)}"
CONFIG_FILE="$OCTON_DIR/instance/governance/closure/uec-packet-certification-runs.yml"
HIDDEN_REPAIR_FILE="$OCTON_DIR/state/evidence/validation/publication/unified-execution-constitution-closure/hidden-repair-detection.yml"

fail() {
  echo "[ERROR] $*" >&2
  exit 1
}

ok() {
  echo "[OK] $*"
}

require_tools() {
  local tool
  for tool in "$@"; do
    command -v "$tool" >/dev/null 2>&1 || fail "missing required tool: $tool"
  done
}

run_root() { printf '%s/state/control/execution/runs/%s' "$OCTON_DIR" "$1"; }
evidence_root() { printf '%s/state/evidence/runs/%s' "$OCTON_DIR" "$1"; }
run_manifest() { printf '%s/run-manifest.yml' "$(run_root "$1")"; }
replay_manifest() { printf '%s/replay/manifest.yml' "$(evidence_root "$1")"; }
replay_pointers() { printf '%s/replay-pointers.yml' "$(evidence_root "$1")"; }
trace_pointers() { printf '%s/trace-pointers.yml' "$(evidence_root "$1")"; }
classification_file() { printf '%s/evidence-classification.yml' "$(evidence_root "$1")"; }
external_index_file() { printf '%s/state/evidence/external-index/runs/%s.yml' "$OCTON_DIR" "$1"; }
intervention_log() { printf '%s/interventions/log.yml' "$(evidence_root "$1")"; }
measurement_summary() { printf '%s/measurements/summary.yml' "$(evidence_root "$1")"; }

role_run_id() {
  local role="$1"
  yq -r ".run_roles.${role}.run_id" "$CONFIG_FILE"
}

all_run_ids() {
  yq -r '.run_roles | to_entries[] | .value.run_id' "$CONFIG_FILE" | awk '!seen[$0]++'
}

repo_ref_path() {
  local ref="$1"
  printf '%s/%s\n' "$ROOT_DIR" "$ref"
}

require_file() {
  local path="$1"
  local label="$2"
  [[ -f "$path" ]] || fail "missing $label: $path"
}

require_repo_ref() {
  local ref="$1"
  local label="$2"
  [[ -n "$ref" && "$ref" != "null" ]] || fail "missing $label ref"
  require_file "$(repo_ref_path "$ref")" "$label"
}

yaml_value() {
  local path="$1"
  local expr="$2"
  yq -r "$expr // \"\"" "$path"
}

yaml_eq() {
  local path="$1"
  local expr="$2"
  local expected="$3"
  local label="$4"
  local actual
  actual="$(yaml_value "$path" "$expr")"
  [[ "$actual" == "$expected" ]] || fail "$label mismatch in $path: expected '$expected', got '$actual'"
}

json_eq() {
  local path="$1"
  local expr="$2"
  local expected="$3"
  local label="$4"
  local actual
  actual="$(jq -r "$expr // \"\"" "$path")"
  [[ "$actual" == "$expected" ]] || fail "$label mismatch in $path: expected '$expected', got '$actual'"
}

require_yaml_array_contains() {
  local path="$1"
  local expr="$2"
  local expected="$3"
  local label="$4"
  yq -o=json '.' "$path" | jq -e --arg expected "$expected" "$expr | index(\$expected)" >/dev/null \
    || fail "$label missing '$expected' in $path"
}

sha256_file() {
  shasum -a 256 "$1" | awk '{print "sha256:" $1}'
}

verify_event_ledger() {
  local run_id="$1"
  local run_dir events_file manifest_file event_count manifest_count ledger_ref expected_ledger
  run_dir="$(run_root "$run_id")"
  events_file="$run_dir/events.ndjson"
  manifest_file="$run_dir/events.manifest.yml"

  require_file "$events_file" "canonical events.ndjson for $run_id"
  require_file "$manifest_file" "canonical events.manifest.yml for $run_id"

  event_count="$(
    jq -Rcs 'split("\n") | map(select(length > 0) | fromjson) | length' "$events_file"
  )" || fail "run $run_id has an unparsable canonical events.ndjson; repair through the runtime-owned journal append path"
  [[ "$event_count" -gt 0 ]] || fail "run $run_id has an empty canonical events.ndjson; repair through the runtime-owned journal append path"

  jq -Rcs --arg run_id "$run_id" '
    split("\n")
    | map(select(length > 0) | fromjson)
    | all(.run_id == $run_id and (.event_id // "") != "" and (.event_type // "") != "")
  ' "$events_file" | grep -qx true \
    || fail "run $run_id has journal events missing run_id, event_id, or event_type; repair through the runtime-owned journal append path"

  manifest_count="$(yaml_value "$manifest_file" '.event_count // .last_event_ref.sequence')"
  [[ "$manifest_count" == "$event_count" ]] \
    || fail "run $run_id journal manifest event count ($manifest_count) does not match events.ndjson ($event_count)"
  ledger_ref="$(yaml_value "$manifest_file" '.ledger_ref')"
  expected_ledger=".octon/state/control/execution/runs/$run_id/events.ndjson"
  [[ "$ledger_ref" == "$expected_ledger" ]] \
    || fail "run $run_id journal manifest ledger_ref ($ledger_ref) does not match $expected_ledger"
  ok "verified existing runtime-owned run journal for $run_id"
}

verify_authority_bundle() {
  local run_id="$1"
  local manifest authority_root budget index decision_ref grant_ref request_ref
  manifest="$(run_manifest "$run_id")"
  authority_root="$(run_root "$run_id")/authority"
  budget="$authority_root/budget-ledger.yml"
  index="$authority_root/index.yml"

  require_file "$manifest" "run manifest for $run_id"
  require_file "$budget" "authority budget ledger for $run_id"
  require_file "$index" "authority bundle index for $run_id"

  yaml_eq "$budget" '.schema_version' 'budget-ledger-v1' "budget ledger schema"
  yaml_eq "$budget" '.run_id' "$run_id" "budget ledger run_id"
  for field in '.budget_dimensions' '.thresholds' '.escalation_point' '.block_point' '.overrun_behavior' '.updated_at'; do
    [[ -n "$(yaml_value "$budget" "$field")" ]] || fail "budget ledger missing $field for $run_id"
  done

  request_ref="$(yaml_value "$manifest" '.approval_request_ref')"
  decision_ref="$(yaml_value "$manifest" '.decision_artifact_ref')"
  grant_ref="$(yaml_value "$manifest" '.authority_grant_bundle_ref')"
  [[ -z "$request_ref" || "$request_ref" == "null" ]] || require_repo_ref "$request_ref" "approval request for $run_id"
  require_repo_ref "$decision_ref" "authority decision for $run_id"
  require_repo_ref "$grant_ref" "authority grant bundle for $run_id"

  yaml_eq "$index" '.schema_version' 'authority-run-bundle-index-v1' "authority index schema"
  yaml_eq "$index" '.run_id' "$run_id" "authority index run_id"
  yaml_eq "$index" '.decision_ref' "$decision_ref" "authority index decision_ref"
  yaml_eq "$index" '.grant_bundle_ref' "$grant_ref" "authority index grant_bundle_ref"

  require_file "$authority_root/decision.yml" "materialized authority decision for $run_id"
  require_file "$authority_root/decisions/decision.yml" "materialized authority decision copy for $run_id"
  require_file "$authority_root/grant-bundle.yml" "materialized grant bundle for $run_id"
  require_file "$authority_root/grants/grant-bundle.yml" "materialized grant bundle copy for $run_id"
  yaml_eq "$authority_root/decision.yml" '.schema_version' 'authority-decision-artifact-v2' "decision schema"
  yaml_eq "$authority_root/grant-bundle.yml" '.schema_version' 'authority-grant-bundle-v2' "grant schema"
  yaml_eq "$authority_root/grant-bundle.yml" '.budget_ledger_ref' ".octon/state/control/execution/runs/$run_id/authority/budget-ledger.yml" "grant budget ledger ref"

  require_file "$authority_root/leases/index.yml" "authority lease index for $run_id"
  require_file "$authority_root/revocations/index.yml" "authority revocation index for $run_id"
  yaml_eq "$authority_root/leases/index.yml" '.schema_version' 'authority-run-lease-index-v1' "lease index schema"
  yaml_eq "$authority_root/leases/index.yml" '.run_id' "$run_id" "lease index run_id"
  yaml_eq "$authority_root/revocations/index.yml" '.schema_version' 'authority-run-revocation-index-v1' "revocation index schema"
  yaml_eq "$authority_root/revocations/index.yml" '.run_id' "$run_id" "revocation index run_id"
  ok "verified authority auxiliary evidence for $run_id"
}

verify_class_c_replay() {
  local run_id="$1"
  local manifest replay_file trace_file classification idx idx_ref replay_digest trace_digest actual_replay actual_trace
  manifest="$(replay_manifest "$run_id")"
  replay_file="$(replay_pointers "$run_id")"
  trace_file="$(trace_pointers "$run_id")"
  classification="$(classification_file "$run_id")"
  idx="$(external_index_file "$run_id")"
  idx_ref=".octon/state/evidence/external-index/runs/$run_id.yml"

  require_file "$manifest" "replay manifest for $run_id"
  require_file "$replay_file" "replay pointers for $run_id"
  require_file "$trace_file" "trace pointers for $run_id"
  require_file "$classification" "evidence classification for $run_id"
  require_file "$idx" "external evidence index for $run_id"

  yaml_eq "$manifest" '.schema_version' 'replay-manifest-v2' "replay manifest schema"
  yaml_eq "$manifest" '.run_id' "$run_id" "replay manifest run_id"
  yaml_eq "$manifest" '.replay_payload_class' 'external-immutable' "replay payload class"
  require_yaml_array_contains "$manifest" '(.external_index_refs // [])' "$idx_ref" "replay manifest external index refs"
  require_yaml_array_contains "$manifest" '(.class_c_refs // [])' "$idx_ref" "replay manifest class C refs"
  yaml_eq "$replay_file" '.schema_version' 'replay-pointer-v2' "replay pointer schema"
  yaml_eq "$replay_file" '.run_id' "$run_id" "replay pointer run_id"
  require_yaml_array_contains "$replay_file" '(.external_index_refs // [])' "$idx_ref" "replay pointer external index refs"
  yaml_eq "$trace_file" '.schema_version' 'trace-pointer-v2' "trace pointer schema"
  yaml_eq "$trace_file" '.run_id' "$run_id" "trace pointer run_id"
  require_yaml_array_contains "$trace_file" '(.external_index_refs // [])' "$idx_ref" "trace pointer external index refs"
  [[ -n "$(yaml_value "$classification" '.updated_at')" ]] || fail "evidence classification missing updated_at for $run_id"

  yaml_eq "$idx" '.schema_version' 'external-replay-index-v1' "external index schema"
  yaml_eq "$idx" '.run_id' "$run_id" "external index run_id"
  replay_digest="$(sha256_file "$manifest")"
  trace_digest="$(sha256_file "$trace_file")"
  actual_replay="$(yq -r '.entries[] | select(.artifact_kind == "replay-payload") | .content_digest' "$idx")"
  actual_trace="$(yq -r '.entries[] | select(.artifact_kind == "trace-payload") | .content_digest' "$idx")"
  [[ "$actual_replay" == "$replay_digest" ]] \
    || fail "external replay index digest mismatch for $run_id: expected $replay_digest, got $actual_replay"
  [[ "$actual_trace" == "$trace_digest" ]] \
    || fail "external trace index digest mismatch for $run_id: expected $trace_digest, got $actual_trace"
  ok "verified replay/external evidence for $run_id"
}

verify_intervention_control() {
  local run_id="$1"
  local record_path log_path summary_path hidden_ref record_ref
  record_path="$(evidence_root "$run_id")/interventions/records/manual-review-override.yml"
  log_path="$(intervention_log "$run_id")"
  summary_path="$(measurement_summary "$run_id")"
  hidden_ref=".octon/state/evidence/validation/publication/unified-execution-constitution-closure/hidden-repair-detection.yml"
  record_ref=".octon/state/evidence/runs/$run_id/interventions/records/manual-review-override.yml"

  require_file "$record_path" "manual intervention record for $run_id"
  require_file "$log_path" "intervention log for $run_id"
  require_file "$summary_path" "measurement summary for $run_id"
  require_file "$HIDDEN_REPAIR_FILE" "hidden repair detection evidence"
  yaml_eq "$record_path" '.schema_version' 'intervention-record-v1' "intervention record schema"
  yaml_eq "$record_path" '.disclosed' 'true' "intervention record disclosed flag"
  yq -e '.interventions[] | select(.kind == "manual-review-override" and .disclosed == true)' "$log_path" >/dev/null \
    || fail "intervention log lacks disclosed manual-review-override for $run_id"
  yq -e '.metrics[] | select(.metric_id == "intervention-count" and .value == 1)' "$summary_path" >/dev/null \
    || fail "measurement summary lacks intervention-count=1 for $run_id"
  yaml_eq "$HIDDEN_REPAIR_FILE" '.status' 'pass' "hidden repair status"
  yaml_eq "$HIDDEN_REPAIR_FILE" '.run_id' "$run_id" "hidden repair run_id"
  require_yaml_array_contains "$HIDDEN_REPAIR_FILE" '(.evidence_refs // [])' ".octon/state/evidence/runs/$run_id/interventions/log.yml" "hidden repair evidence refs"
  require_yaml_array_contains "$HIDDEN_REPAIR_FILE" '(.evidence_refs // [])' "$record_ref" "hidden repair evidence refs"
  ok "verified hidden-repair intervention disclosure via $hidden_ref"
}

main() {
  require_tools yq jq shasum awk
  [[ -f "$CONFIG_FILE" ]] || fail "missing config: $CONFIG_FILE"

  while IFS= read -r run_id; do
    [[ -n "$run_id" ]] || continue
    verify_event_ledger "$run_id"
    verify_authority_bundle "$run_id"
    verify_class_c_replay "$run_id"
  done < <(all_run_ids)

  verify_intervention_control "$(role_run_id intervention_control)"
}

main "$@"
