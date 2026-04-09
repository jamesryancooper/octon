#!/usr/bin/env bash
set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/closure-packet-common.sh"

require_yq

release_id="$(resolve_release_id "${1:-}")"
report_path="$(closure_report_path "$release_id" "lab-reference-integrity-report.yml")"
mkdir -p "$(dirname "$report_path")"

errors=0
authored_checked=0
dossier_refs_checked=0
admission_refs_checked=0
proof_refs_checked=0

scenario_path_for_id() {
  local scenario_id="$1"
  yq -r ".entries[] | select(.scenario_id == \"$scenario_id\") | .path // \"\"" "$LAB_SCENARIO_REGISTRY_PATH" | head -n 1
}

index_ref_count_for_id() {
  local scenario_id="$1"
  yq -r "[.entries[] | select(.scenario_id == \"$scenario_id\") | .retained_evidence_refs[]?] | length" "$LAB_SCENARIO_INDEX_PATH" 2>/dev/null
}

while IFS= read -r scenario_id; do
  [[ -n "$scenario_id" ]] || continue
  authored_checked=$((authored_checked + 1))
  scenario_rel="$(scenario_path_for_id "$scenario_id")"
  [[ -n "$scenario_rel" && -f "$ROOT_DIR/$scenario_rel" ]] || {
    errors=$((errors + 1))
    continue
  }
  authored_ref="$(yq -r ".entries[] | select(.scenario_id == \"$scenario_id\") | .authored_scenario_ref // \"\"" "$LAB_SCENARIO_INDEX_PATH" | head -n 1)"
  [[ "$authored_ref" == "$scenario_rel" ]] || {
    errors=$((errors + 1))
    continue
  }
  while IFS= read -r evidence_ref; do
    [[ -n "$evidence_ref" ]] || continue
    proof_refs_checked=$((proof_refs_checked + 1))
    [[ -f "$ROOT_DIR/$evidence_ref" ]] || errors=$((errors + 1))
  done < <(yq -r ".entries[] | select(.scenario_id == \"$scenario_id\") | .retained_evidence_refs[]?" "$LAB_SCENARIO_INDEX_PATH")
  ref_count="$(index_ref_count_for_id "$scenario_id")"
  [[ "$ref_count" != "0" ]] || errors=$((errors + 1))
done < <(
  {
    while IFS= read -r dossier; do
      yq -r '.required_lab_scenarios[]?' "$dossier"
    done < <(supported_dossier_files)
    while IFS= read -r admission; do
      yq -r '.required_lab_scenarios[]?' "$admission"
    done < <(tuple_inventory_files)
  } | awk 'NF' | LC_ALL=C sort -u
)

while IFS= read -r dossier; do
  while IFS= read -r scenario_id; do
    [[ -n "$scenario_id" ]] || continue
    dossier_refs_checked=$((dossier_refs_checked + 1))
    [[ -n "$(scenario_path_for_id "$scenario_id")" ]] || errors=$((errors + 1))
  done < <(yq -r '.required_lab_scenarios[]?' "$dossier")
done < <(supported_dossier_files)

while IFS= read -r admission; do
  while IFS= read -r scenario_id; do
    [[ -n "$scenario_id" ]] || continue
    admission_refs_checked=$((admission_refs_checked + 1))
    [[ -n "$(scenario_path_for_id "$scenario_id")" ]] || errors=$((errors + 1))
  done < <(yq -r '.required_lab_scenarios[]?' "$admission")
done < <(tuple_inventory_files)

status="pass"
if [[ "$errors" != "0" ]]; then
  status="fail"
fi

{
  echo "schema_version: octon-lab-reference-integrity-v1"
  echo "release_id: $release_id"
  echo "status: $status"
  echo "summary:"
  echo "  authored_scenarios_checked: $authored_checked"
  echo "  dossier_refs_checked: $dossier_refs_checked"
  echo "  admission_refs_checked: $admission_refs_checked"
  echo "  proof_refs_checked: $proof_refs_checked"
  echo "  unresolved_refs: $errors"
  echo "violations: []"
  echo "generated_at: \"$(deterministic_generated_at)\""
} >"$report_path"

[[ "$errors" == "0" ]]

