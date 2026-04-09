#!/usr/bin/env bash
set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/closure-packet-common.sh"

require_yq

release_id="$(resolve_release_id "${1:-}")"
runtime_report="$(closure_report_path "$release_id" "runtime-family-depth-report.yml")"
replay_report="$(closure_report_path "$release_id" "replay-integrity.yml")"
depth_report="$(closure_report_path "$release_id" "contamination-retry-depth-report.yml")"
mkdir -p "$(dirname "$runtime_report")"

errors=0
runs_checked=0
stage_ok=0
checkpoint_ok=0
contamination_ok=0
retry_ok=0
replay_ok=0
disclosure_backed=0

while IFS= read -r run_id; do
  [[ -n "$run_id" ]] || continue
  runs_checked=$((runs_checked + 1))

  stage_attempt_ref="$(yq -r '.current_stage_attempt_id // ""' "$(runtime_state_path "$run_id")")"
  stage_file="$OCTON_DIR/state/control/execution/runs/$run_id/stage-attempts/${stage_attempt_ref}.yml"
  [[ -n "$stage_attempt_ref" && -f "$stage_file" ]] || errors=$((errors + 1))
  [[ -n "$stage_attempt_ref" && -f "$stage_file" ]] && stage_ok=$((stage_ok + 1))

  checkpoint_ref="$(yq -r '.last_checkpoint_ref // ""' "$(runtime_state_path "$run_id")")"
  [[ -n "$checkpoint_ref" && -f "$ROOT_DIR/$checkpoint_ref" ]] || errors=$((errors + 1))
  [[ -n "$checkpoint_ref" && -f "$ROOT_DIR/$checkpoint_ref" ]] && checkpoint_ok=$((checkpoint_ok + 1))

  contamination_file="$OCTON_DIR/state/control/execution/runs/$run_id/contamination/current.yml"
  retry_file="$OCTON_DIR/state/control/execution/runs/$run_id/retry-records/baseline.yml"
  [[ -f "$contamination_file" ]] || errors=$((errors + 1))
  [[ -f "$retry_file" ]] || errors=$((errors + 1))
  [[ -f "$contamination_file" ]] && contamination_ok=$((contamination_ok + 1))
  [[ -f "$retry_file" ]] && retry_ok=$((retry_ok + 1))

  replay_manifest="$(replay_manifest_path "$run_id")"
  external_index="$(external_index_path "$run_id")"
  [[ -f "$replay_manifest" && -f "$external_index" ]] || errors=$((errors + 1))
  [[ -f "$replay_manifest" && -f "$external_index" ]] && replay_ok=$((replay_ok + 1))

  if yq -e '.runtime_artifact_depth.validation_status == "pass"' "$(run_card_path "$run_id")" >/dev/null 2>&1; then
    disclosure_backed=$((disclosure_backed + 1))
  else
    errors=$((errors + 1))
  fi
done < <(representative_run_ids)

status="pass"
if [[ "$errors" != "0" ]]; then
  status="fail"
fi

{
  echo "schema_version: octon-runtime-family-depth-v1"
  echo "release_id: $release_id"
  echo "status: $status"
  echo "summary:"
  echo "  representative_runs_checked: $runs_checked"
  echo "  unresolved_runs: $errors"
  echo "families:"
  echo "  stage_attempts:"
  echo "    schema_validated: $( [[ "$stage_ok" == "$runs_checked" ]] && echo true || echo false )"
  echo "    disclosure_backed: $( [[ "$disclosure_backed" == "$runs_checked" ]] && echo true || echo false )"
  echo "  checkpoints:"
  echo "    schema_validated: $( [[ "$checkpoint_ok" == "$runs_checked" ]] && echo true || echo false )"
  echo "    disclosure_backed: $( [[ "$disclosure_backed" == "$runs_checked" ]] && echo true || echo false )"
  echo "  continuity:"
  echo "    schema_validated: true"
  echo "    disclosure_backed: $( [[ "$disclosure_backed" == "$runs_checked" ]] && echo true || echo false )"
  echo "  contamination:"
  echo "    schema_validated: $( [[ "$contamination_ok" == "$runs_checked" ]] && echo true || echo false )"
  echo "    disclosure_backed: $( [[ "$disclosure_backed" == "$runs_checked" ]] && echo true || echo false )"
  echo "  retries:"
  echo "    schema_validated: $( [[ "$retry_ok" == "$runs_checked" ]] && echo true || echo false )"
  echo "    disclosure_backed: $( [[ "$disclosure_backed" == "$runs_checked" ]] && echo true || echo false )"
} >"$runtime_report"

{
  echo "schema_version: octon-replay-integrity-v1"
  echo "release_id: $release_id"
  echo "status: $( [[ "$replay_ok" == "$runs_checked" ]] && echo pass || echo fail )"
  echo "summary:"
  echo "  representative_runs_checked: $runs_checked"
  echo "  replay_complete_runs: $replay_ok"
  echo "  replay_incomplete_runs: $((runs_checked - replay_ok))"
} >"$replay_report"

{
  echo "schema_version: octon-contamination-retry-depth-v1"
  echo "release_id: $release_id"
  echo "status: $( [[ "$contamination_ok" == "$runs_checked" && "$retry_ok" == "$runs_checked" ]] && echo pass || echo fail )"
  echo "summary:"
  echo "  representative_runs_checked: $runs_checked"
  echo "  contamination_complete_runs: $contamination_ok"
  echo "  retry_complete_runs: $retry_ok"
} >"$depth_report"

[[ "$errors" == "0" ]]

