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
  matrix_tuple_count="$(yq -r "[.supported_tuples[] | select(.tuple_id == \"$tuple_id\")] | length" "$matrix" 2>/dev/null || printf '0')"
  matrix_route="$(yq -r "[.supported_tuples[] | select(.tuple_id == \"$tuple_id\") | .route][0] // \"\"" "$matrix" 2>/dev/null || true)"
  matrix_mission="$(yq -r "[.supported_tuples[] | select(.tuple_id == \"$tuple_id\") | (.requires_mission | tostring)][0] // \"\"" "$matrix" 2>/dev/null || true)"
  if [[ "$matrix_tuple_count" == "0" ]]; then
    echo "[ERROR] matrix mismatch for $tuple_id" >&2
    errors=$((errors + 1))
    continue
  fi
  if [[ "$route" != "$matrix_route" || "$requires_mission" != "$matrix_mission" ]]; then
    echo "[ERROR] matrix semantic mismatch for $tuple_id" >&2
    errors=$((errors + 1))
  fi
done < <(tuple_inventory_files)

while IFS= read -r run_id; do
  tuple_id="$(tuple_id_for_run "$run_id")"
  admission_ref="$(admission_ref_for_run "$run_id")"
  contract_path="$(run_contract_path "$run_id")"
  admission_path="$ROOT_DIR/$admission_ref"
  explicit_tuple_id="$(run_contract_support_tuple_id "$run_id")"
  explicit_admission_ref="$(run_contract_support_admission_ref "$run_id")"

  if [[ -n "$explicit_tuple_id" ]]; then
    [[ "$explicit_tuple_id" == "$tuple_id" ]] || {
      echo "[ERROR] run contract tuple id mismatch for $run_id" >&2
      errors=$((errors + 1))
    }
  fi

  if [[ -n "$explicit_admission_ref" ]]; then
    [[ "$explicit_admission_ref" == "$admission_ref" ]] || {
      echo "[ERROR] run contract admission ref mismatch for $run_id" >&2
      errors=$((errors + 1))
    }
  else
    [[ "$(run_contract_support_ref "$run_id")" == ".octon/instance/governance/support-targets.yml" ]] || {
      echo "[ERROR] run contract support target ref mismatch for $run_id" >&2
      errors=$((errors + 1))
    }
  fi
done < <(representative_run_ids)

[[ $errors -eq 0 ]]
