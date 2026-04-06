#!/usr/bin/env bash
set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/closure-packet-common.sh"
errors=0
while IFS= read -r run_id; do
  expected="$(dossier_status_for_run "$run_id")"
  actual="$(yq -r '.claim_status // ""' "$(run_card_path "$run_id")")"
  [[ "$expected" == "$actual" ]] || {
    echo "[ERROR] $run_id claim status mismatch: dossier=$expected run-card=$actual" >&2
    errors=$((errors + 1))
  }
done < <(representative_run_ids)
[[ $errors -eq 0 ]]

