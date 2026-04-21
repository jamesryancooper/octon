#!/usr/bin/env bash
set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/../runtime/_ops/scripts/closure-packet-common.sh"

require_yq
errors=0

while IFS= read -r run_id; do
  contract="$(run_contract_path "$run_id")"
  expected_mission="$(requires_mission_for_run "$run_id")"
  expected_ref="$(admission_ref_for_run "$run_id")"
  actual_mission="$(yq -r '.requires_mission // false' "$contract")"
  if [[ "$expected_mission" == "true" && "$actual_mission" != "true" ]]; then
    echo "[ERROR] requires_mission mismatch for $run_id" >&2
    errors=$((errors + 1))
  fi
  explicit_ref="$(run_contract_support_admission_ref "$run_id")"
  if [[ -n "$explicit_ref" ]]; then
    [[ "$explicit_ref" == "$expected_ref" ]] || {
      echo "[ERROR] admission ref mismatch for $run_id" >&2
      errors=$((errors + 1))
    }
  else
    [[ "$(run_contract_support_ref "$run_id")" == ".octon/instance/governance/support-targets.yml" ]] || {
      echo "[ERROR] support target declaration ref mismatch for $run_id" >&2
      errors=$((errors + 1))
    }
  fi
done < <(representative_run_ids)

[[ $errors -eq 0 ]]
