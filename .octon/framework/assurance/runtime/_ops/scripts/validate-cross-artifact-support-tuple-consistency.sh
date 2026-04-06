#!/usr/bin/env bash
set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/closure-packet-common.sh"
errors=0
for key in model_tier workload_tier language_resource_tier locale_tier; do
  while IFS= read -r run_id; do
    c="$(tuple_value_from_contract "$run_id" "$key")"
    m="$(tuple_value_from_manifest "$run_id" "$key")"
    r="$(tuple_value_from_run_card "$run_id" "$key")"
    [[ "$c" == "$m" && "$m" == "$r" ]] || {
      echo "[ERROR] $run_id tuple mismatch for $key: contract=$c manifest=$m run-card=$r" >&2
      errors=$((errors + 1))
    }
  done < <(representative_run_ids)
done
[[ $errors -eq 0 ]]

