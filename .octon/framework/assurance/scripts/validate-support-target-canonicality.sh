#!/usr/bin/env bash
set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/../runtime/_ops/scripts/closure-packet-common.sh"

require_yq

matrix="$OCTON_DIR/generated/effective/governance/support-target-matrix.yml"
support_targets="$OCTON_DIR/instance/governance/support-targets.yml"
errors=0

while IFS= read -r admission; do
  [[ -f "$admission" ]] || continue
  tuple_id="$(yq -r '.tuple_id' "$admission")"
  if ! yq -e ".tuple_admissions[] | select(.tuple_id == \"$tuple_id\")" "$support_targets" >/dev/null 2>&1; then
    continue
  fi
  route="$(yq -r '.route // ""' "$admission")"
  requires_mission="$(yq -r '.requires_mission // false' "$admission")"
  matrix_route="$(yq -r ".supported_tuples[] | select(.tuple_id == \"$tuple_id\") | .route" "$matrix" 2>/dev/null || true)"
  matrix_mission="$(yq -r ".supported_tuples[] | select(.tuple_id == \"$tuple_id\") | .requires_mission" "$matrix" 2>/dev/null || true)"
  [[ "$route" == "$matrix_route" && "$requires_mission" == "$matrix_mission" ]] || {
    echo "[ERROR] matrix mismatch for $tuple_id" >&2
    errors=$((errors + 1))
  }
done < <(tuple_inventory_files)

while IFS= read -r run_id; do
  tuple_id="$(tuple_id_for_run "$run_id")"
  admission_ref="$(admission_ref_for_run "$run_id")"
  [[ "$(yq -r '.support_target_tuple_id // ""' "$(run_contract_path "$run_id")")" == "$tuple_id" ]] || {
    echo "[ERROR] run contract tuple id mismatch for $run_id" >&2
    errors=$((errors + 1))
  }
  [[ "$(yq -r '.support_target_admission_ref // ""' "$(run_contract_path "$run_id")")" == "$admission_ref" ]] || {
    echo "[ERROR] run contract admission ref mismatch for $run_id" >&2
    errors=$((errors + 1))
  }
done < <(representative_run_ids)

[[ $errors -eq 0 ]]
