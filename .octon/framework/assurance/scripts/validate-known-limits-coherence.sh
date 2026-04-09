#!/usr/bin/env bash
set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/../runtime/_ops/scripts/closure-packet-common.sh"

release_id="$(resolve_release_id "${1:-}")"
release_root_path="$(release_root "$release_id")"

blockers="$(yq -r '.open_blocker_count' .octon/generated/effective/closure/blocker-ledger.yml)"
limits="$(yq -r '.known_limits | length' "$release_root_path/harness-card.yml")"
residuals="$(yq -r '((.claim_critical // []) + (.non_critical // [])) | map(select(.status != "closed")) | length' "$release_root_path/closure/residual-ledger.yml" 2>/dev/null || echo 0)"

if [[ "$blockers" != "0" && "$limits" == "0" ]]; then
  echo "[ERROR] known_limits is empty while blocker ledger is non-zero" >&2
  exit 1
fi

if [[ "$residuals" != "0" && "$limits" == "0" ]]; then
  echo "[ERROR] known_limits is empty while residual ledger is non-zero" >&2
  exit 1
fi
