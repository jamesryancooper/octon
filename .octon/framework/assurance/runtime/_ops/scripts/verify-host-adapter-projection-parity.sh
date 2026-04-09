#!/usr/bin/env bash
set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/closure-packet-common.sh"

require_yq

errors=0

while IFS= read -r contract_ref; do
  [[ -n "$contract_ref" ]] || continue
  contract_path="$ROOT_DIR/$contract_ref"
  [[ -f "$contract_path" ]] || {
    errors=$((errors + 1))
    continue
  }
  authority_mode="$(yq -r '.authority_mode // ""' "$contract_path")"
  case "$authority_mode" in
    non_authoritative|projection_only) ;;
    *) errors=$((errors + 1)) ;;
  esac
  boundary_count="$(yq -r '(.non_authoritative_boundaries // []) | length' "$contract_path")"
  [[ "$boundary_count" != "0" ]] || errors=$((errors + 1))
done < <(yq -r '.host_adapters[].contract_ref' "$SUPPORT_TARGETS_DECLARATION")

[[ "$errors" == "0" ]]

