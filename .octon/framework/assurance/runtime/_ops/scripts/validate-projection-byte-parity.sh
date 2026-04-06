#!/usr/bin/env bash
set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/closure-packet-common.sh"
release_id="$(resolve_release_id "${1:-}")"
root="$(release_root "$release_id")"
cmp -s "$root/harness-card.yml" "$OCTON_DIR/instance/governance/disclosure/harness-card.yml"
cmp -s "$root/closure/gate-status.yml" "$OCTON_DIR/instance/governance/closure/gate-status.yml"
cmp -s "$root/closure/closure-summary.yml" "$OCTON_DIR/instance/governance/closure/closure-summary.yml"

