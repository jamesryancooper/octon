#!/usr/bin/env bash
set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/closure-packet-common.sh"
release_id="$(resolve_release_id "${1:-}")"
gate_status="$(release_root "$release_id")/closure/gate-status.yml"
summary="$(release_root "$release_id")/closure/closure-summary.yml"
! rg -n 'status: red' "$gate_status" >/dev/null 2>&1
yq -e '.claim_status == "complete" and .preclaim_blockers_open == 0' "$summary" >/dev/null
