#!/usr/bin/env bash
set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/closure-packet-common.sh"
errors=0
while IFS= read -r run_id; do
  [[ -f "$(intervention_log_path "$run_id")" ]] || {
    echo "[ERROR] missing intervention log for $run_id" >&2
    errors=$((errors + 1))
  }
done < <(representative_run_ids)
[[ $errors -eq 0 ]]

