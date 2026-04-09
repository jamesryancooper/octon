#!/usr/bin/env bash
set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/../runtime/_ops/scripts/closure-packet-common.sh"

release_id="$(resolve_release_id "${1:-}")"

if rg -n "exceptions/leases.yml|revocations/grants.yml" \
  .octon/state/control/execution/runs/uec-global-* \
  .octon/state/control/execution/runs/uec-safe-stage-* \
  .octon/state/evidence/runs/uec-global-* \
  .octon/state/evidence/runs/uec-safe-stage-* \
  .octon/state/evidence/disclosure/runs/uec-global-* \
  .octon/state/evidence/disclosure/runs/uec-safe-stage-* \
  ".octon/state/evidence/disclosure/releases/$release_id" >/dev/null 2>&1; then
  echo "[ERROR] active authority/runtime/evidence/disclosure surfaces still reference compatibility aggregates" >&2
  exit 1
fi
