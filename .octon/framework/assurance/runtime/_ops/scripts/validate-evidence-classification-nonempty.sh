#!/usr/bin/env bash
set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/closure-packet-common.sh"
require_yq
errors=0
while IFS= read -r run_id; do
  local_file="$(classification_path "$run_id")"
  class_a="$(yq -r '.class_a | length' "$local_file")"
  class_b="$(yq -r '.class_b | length' "$local_file")"
  if [[ "$class_a" -eq 0 || "$class_b" -eq 0 ]]; then
    echo "[ERROR] $run_id classification is empty" >&2
    errors=$((errors + 1))
  fi
done < <(representative_run_ids)
[[ $errors -eq 0 ]]

