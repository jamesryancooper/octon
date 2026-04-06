#!/usr/bin/env bash
set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/closure-packet-common.sh"
require_yq
yq -e '.execution_binding.stage_attempt_schema_ref == ".octon/framework/constitution/contracts/runtime/stage-attempt-v2.schema.json"' "$OCTON_DIR/instance/charter/workspace.yml" >/dev/null
errors=0
while IFS= read -r run_id; do
  [[ "$(yq -r '.schema_version // ""' "$(stage_attempt_path "$run_id")")" == "stage-attempt-v2" ]] || {
    echo "[ERROR] $run_id stage attempt is not v2" >&2
    errors=$((errors + 1))
  }
done < <(representative_run_ids)
[[ $errors -eq 0 ]]

