#!/usr/bin/env bash
set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/closure-packet-common.sh"
require_yq
errors=0
while IFS= read -r run_id; do
  [[ "$(yq -r '.schema_version // ""' "$(run_contract_path "$run_id")")" == "run-contract-v3" ]] || {
    echo "[ERROR] $run_id is not bound to run-contract-v3" >&2
    errors=$((errors + 1))
  }
done < <(representative_run_ids)
[[ $errors -eq 0 ]]

