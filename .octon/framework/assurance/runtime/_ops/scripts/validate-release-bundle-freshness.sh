#!/usr/bin/env bash
set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/closure-packet-common.sh"
release_id="$(resolve_release_id "${1:-}")"
manifest="$(release_root "$release_id")/manifest.yml"
[[ -f "$manifest" ]] || exit 1
yq -e ".authored_input_digests.charter == \"$(sha256_file "$OCTON_DIR/framework/constitution/charter.yml")\"" "$manifest" >/dev/null
yq -e ".authored_input_digests.support_targets == \"$(sha256_file "$OCTON_DIR/instance/governance/support-targets.yml")\"" "$manifest" >/dev/null

