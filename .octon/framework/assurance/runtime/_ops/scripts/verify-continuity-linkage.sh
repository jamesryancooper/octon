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

while IFS= read -r run_id; do
  [[ -n "$run_id" ]] || continue
  runs_checked=$((runs_checked + 1))

  contract_ref="$(yq -r '.continuity_root_ref // ""' "$(run_contract_path "$run_id")")"
  manifest_ref="$(yq -r '.run_continuity_ref // ""' "$(run_manifest_path "$run_id")")"
  if [[ -n "$contract_ref" && "$contract_ref" == "$manifest_ref" && -f "$ROOT_DIR/$contract_ref" ]]; then
    continuity_ok=$((continuity_ok + 1))
  else
    errors=$((errors + 1))
  fi
done < <(representative_run_ids)

{
  echo "schema_version: octon-continuity-linkage-v1"
  echo "release_id: $release_id"
  echo "status: $( [[ "$errors" == "0" ]] && echo pass || echo fail )"
  echo "summary:"
  echo "  representative_runs_checked: $runs_checked"
  echo "  continuity_linked_runs: $continuity_ok"
  echo "  unresolved_runs: $((runs_checked - continuity_ok))"
} >"$report_path"

[[ "$errors" == "0" ]]

