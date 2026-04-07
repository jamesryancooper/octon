#!/usr/bin/env bash
set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/closure-packet-common.sh"
release_id="$(resolve_release_id "${1:-}")"
manifest="$(release_root "$release_id")/manifest.yml"
recertification_status="$(release_root "$release_id")/closure/recertification-status.yml"
[[ -f "$manifest" ]] || exit 1
yq -e ".authored_input_digests.charter == \"$(sha256_file "$OCTON_DIR/framework/constitution/charter.yml")\"" "$manifest" >/dev/null
yq -e ".authored_input_digests.support_targets == \"$(sha256_file "$OCTON_DIR/instance/governance/support-targets.yml")\"" "$manifest" >/dev/null
yq -e ".input_digests.charter == \"$(sha256_file "$OCTON_DIR/framework/constitution/charter.yml")\"" "$recertification_status" >/dev/null
yq -e ".input_digests.support_targets == \"$(sha256_file "$OCTON_DIR/instance/governance/support-targets.yml")\"" "$recertification_status" >/dev/null
yq -e ".input_digests.workspace_charter == \"$(sha256_file "$OCTON_DIR/instance/charter/workspace.yml")\"" "$recertification_status" >/dev/null
