#!/usr/bin/env bash
set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/closure-packet-common.sh"
errors=0
check_file() { [[ -f "$1" ]] || { echo "[ERROR] missing ${1#$ROOT_DIR/}" >&2; errors=$((errors + 1)); }; }
while IFS= read -r run_id; do
  check_file "$(run_contract_path "$run_id")"
  check_file "$(run_manifest_path "$run_id")"
  check_file "$(runtime_state_path "$run_id")"
  check_file "$(rollback_posture_path "$run_id")"
  check_file "$(stage_attempt_path "$run_id")"
  check_file "$(classification_path "$run_id")"
  check_file "$(run_card_path "$run_id")"
  check_file "$(retained_evidence_path "$run_id")"
  check_file "$(measurement_summary_path "$run_id")"
  check_file "$(intervention_log_path "$run_id")"
  check_file "$(replay_manifest_path "$run_id")"
  check_file "$(external_index_path "$run_id")"
done < <(representative_run_ids)
[[ $errors -eq 0 ]]

