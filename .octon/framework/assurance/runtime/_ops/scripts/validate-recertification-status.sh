#!/usr/bin/env bash
set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/closure-packet-common.sh"

release_id="$(resolve_release_id "${1:-}")"
status_file="$(release_root "$release_id")/closure/recertification-status.yml"
trigger_log="$OCTON_DIR/instance/governance/closure/recertification-trigger-log.yml"

[[ -f "$status_file" ]] || exit 1
yq -e '.certification_mode == "equally-strong-recertification-rule"' "$status_file" >/dev/null
yq -e '.status == "valid"' "$status_file" >/dev/null
yq -e '.trigger_log_ref == ".octon/instance/governance/closure/recertification-trigger-log.yml"' "$status_file" >/dev/null
yq -e ".active_certificate_ref == \".octon/state/evidence/disclosure/releases/$release_id/closure/closure-certificate.yml\"" "$status_file" >/dev/null
yq -e ".active_harness_card_ref == \".octon/state/evidence/disclosure/releases/$release_id/harness-card.yml\"" "$status_file" >/dev/null
yq -e ".input_digests.charter == \"$(sha256_file "$OCTON_DIR/framework/constitution/charter.yml")\"" "$status_file" >/dev/null
yq -e ".input_digests.support_targets == \"$(sha256_file "$OCTON_DIR/instance/governance/support-targets.yml")\"" "$status_file" >/dev/null
yq -e ".input_digests.workspace_charter == \"$(sha256_file "$OCTON_DIR/instance/charter/workspace.yml")\"" "$status_file" >/dev/null
yq -e '[.triggers[] | select(.status != "clear")] | length == 0' "$trigger_log" >/dev/null
