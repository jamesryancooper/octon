#!/usr/bin/env bash
set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/closure-packet-common.sh"

require_yq

release_id="$(resolve_release_id "${1:-}")"
report_path="$(closure_report_path "$release_id" "continuity-linkage-report.yml")"
mkdir -p "$(dirname "$report_path")"

errors=0
runs_checked=0
continuity_ok=0
pre_start_skipped=0

is_pre_start_status() {
  case "$1" in
    candidate-submitted | candidate | prepared | not_started | canonical_contract_prepared)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

while IFS= read -r run_contract; do
  [[ -n "$run_contract" ]] || continue
  run_id="$(basename "$(dirname "$run_contract")")"
  run_status="$(yq -r '.status // ""' "$run_contract")"
  manifest_path="$(run_manifest_path "$run_id")"

  if [[ ! -f "$manifest_path" ]]; then
    if is_pre_start_status "$run_status"; then
      pre_start_skipped=$((pre_start_skipped + 1))
      continue
    fi

    runs_checked=$((runs_checked + 1))
    errors=$((errors + 1))
    continue
  fi

  runs_checked=$((runs_checked + 1))
  contract_ref="$(yq -r '.continuity_root_ref // ""' "$run_contract")"
  manifest_ref="$(yq -r '.run_continuity_ref // ""' "$manifest_path")"
  contract_mission_id="$(yq -r '.mission_id // ""' "$run_contract")"

  expected_ref=".octon/state/continuity/runs/$run_id/handoff.yml"
  continuity_ref="$contract_ref"
  if [[ -z "$continuity_ref" ]]; then
    continuity_ref="$manifest_ref"
  fi

  if [[ -n "$continuity_ref" && "$manifest_ref" == "$expected_ref" && "$continuity_ref" == "$expected_ref" && -f "$ROOT_DIR/$expected_ref" ]]; then
    handoff_mission_id="$(yq -r '.mission_id // ""' "$ROOT_DIR/$expected_ref")"
    if [[ "$handoff_mission_id" == "$contract_mission_id" ]]; then
      continuity_ok=$((continuity_ok + 1))
    else
      errors=$((errors + 1))
    fi
  else
    errors=$((errors + 1))
  fi
done < <(find "$OCTON_DIR/state/control/execution/runs" -name run-contract.yml -type f | sort)

{
  echo "schema_version: octon-continuity-linkage-v1"
  echo "release_id: $release_id"
  echo "status: $( [[ "$errors" == "0" ]] && echo pass || echo fail )"
  echo "summary:"
  echo "  representative_runs_checked: $runs_checked"
  echo "  pre_start_contracts_skipped: $pre_start_skipped"
  echo "  continuity_linked_runs: $continuity_ok"
  echo "  unresolved_runs: $((runs_checked - continuity_ok))"
} >"$report_path"

[[ "$errors" == "0" ]]
