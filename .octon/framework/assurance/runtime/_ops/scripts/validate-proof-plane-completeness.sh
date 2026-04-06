#!/usr/bin/env bash
set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/closure-packet-common.sh"
errors=0
while IFS= read -r run_id; do
  dossier="$(dossier_for_run "$run_id")"
  while IFS= read -r plane; do
    [[ -z "$plane" ]] && continue
    yq -e ".proof_plane_refs.$plane" "$(run_card_path "$run_id")" >/dev/null 2>&1 || {
      echo "[ERROR] $run_id missing proof plane $plane" >&2
      errors=$((errors + 1))
    }
  done < <(yq -r '.required_proof_planes[]?' "$dossier")
done < <(representative_run_ids)
[[ $errors -eq 0 ]]

