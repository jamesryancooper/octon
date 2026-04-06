#!/usr/bin/env bash
set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/closure-packet-common.sh"
errors=0
while IFS= read -r run_id; do
  contract_packs="$(sorted_array '.requested_capability_packs[]?' "$(run_contract_path "$run_id")" | paste -sd',' -)"
  card_packs="$(sorted_array '.requested_capability_packs[]?' "$(run_card_path "$run_id")" | paste -sd',' -)"
  dossier="$(dossier_for_run "$run_id")"
  dossier_packs="$(sorted_array '.admitted_capability_packs[]?' "$dossier" | paste -sd',' -)"
  [[ "$contract_packs" == "$card_packs" ]] || {
    echo "[ERROR] $run_id capability-pack mismatch between contract and run-card" >&2
    errors=$((errors + 1))
  }
  while IFS= read -r pack; do
    [[ -z "$pack" || ",$dossier_packs," == *",$pack,"* ]] || {
      echo "[ERROR] $run_id pack $pack not admitted by dossier" >&2
      errors=$((errors + 1))
    }
  done < <(sorted_array '.requested_capability_packs[]?' "$(run_contract_path "$run_id")")
done < <(representative_run_ids)
[[ $errors -eq 0 ]]

