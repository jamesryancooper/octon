#!/usr/bin/env bash
set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/closure-packet-common.sh"
release_id="$(resolve_release_id "${1:-}")"
out="$(release_root "$release_id")/closure/cross-artifact-consistency.yml"
mkdir -p "$(dirname "$out")"
status="pass"
{
  echo "schema_version: cross-artifact-consistency-v1"
  echo "release_id: $release_id"
  echo "generated_at: \"$(deterministic_generated_at)\""
  echo "runs:"
  while IFS= read -r run_id; do
    mismatch="false"
    for key in model_tier workload_tier language_resource_tier locale_tier; do
      c="$(tuple_value_from_contract "$run_id" "$key")"
      m="$(tuple_value_from_manifest "$run_id" "$key")"
      r="$(tuple_value_from_run_card "$run_id" "$key")"
      [[ "$c" == "$m" && "$m" == "$r" ]] || mismatch="true"
    done
    claim_status="$(yq -r '.claim_status' "$(run_card_path "$run_id")")"
    expected="$(dossier_status_for_run "$run_id")"
    [[ "$claim_status" == "$expected" ]] || mismatch="true"
    [[ "$mismatch" == "false" ]] || status="fail"
    echo "  - run_id: $run_id"
    echo "    status: $( [[ "$mismatch" == "false" ]] && echo pass || echo fail )"
  done < <(representative_run_ids)
  echo "status: $status"
} >"$out"
