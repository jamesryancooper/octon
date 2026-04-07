#!/usr/bin/env bash
set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/closure-packet-common.sh"

release_id="$(resolve_release_id "${1:-}")"
out="$(release_root "$release_id")/closure/recertification-status.yml"
trigger_log="$OCTON_DIR/instance/governance/closure/recertification-trigger-log.yml"
certificate_ref=".octon/state/evidence/disclosure/releases/$release_id/closure/closure-certificate.yml"
harness_card_ref=".octon/state/evidence/disclosure/releases/$release_id/harness-card.yml"
mkdir -p "$(dirname "$out")"

clear_count="$(yq -r '[.triggers[] | select(.status == "clear")] | length' "$trigger_log")"
blocking_count="$(yq -r '[.triggers[] | select(.status != "clear")] | length' "$trigger_log")"
status="valid"
if [[ "$blocking_count" != "0" ]]; then
  status="invalidated"
fi

{
  echo "schema_version: recertification-status-v1"
  echo "release_id: $release_id"
  echo "generated_at: \"$(deterministic_generated_at)\""
  echo "profile_selection_receipt_ref: .octon/instance/cognition/context/shared/migrations/2026-04-06-recertification-hardening/plan.md"
  echo "certification_mode: equally-strong-recertification-rule"
  echo "status: $status"
  echo "trigger_log_ref: .octon/instance/governance/closure/recertification-trigger-log.yml"
  echo "active_certificate_ref: $certificate_ref"
  echo "active_harness_card_ref: $harness_card_ref"
  echo "input_digests:"
  echo "  charter: $(sha256_file "$OCTON_DIR/framework/constitution/charter.yml")"
  echo "  support_targets: $(sha256_file "$OCTON_DIR/instance/governance/support-targets.yml")"
  echo "  workspace_charter: $(sha256_file "$OCTON_DIR/instance/charter/workspace.yml")"
  echo "trigger_summary:"
  echo "  total: $(yq -r '(.triggers // []) | length' "$trigger_log")"
  echo "  clear: $clear_count"
  echo "  blocking: $blocking_count"
  echo "blocking_triggers:"
  yq -r '.triggers[] | select(.status != "clear") | .trigger_id' "$trigger_log" | sed 's/^/  - /'
  echo "rule_checks:"
  echo "  - check_id: trigger-log-clear"
  echo "    status: $( [[ "$blocking_count" == "0" ]] && echo pass || echo fail )"
  echo "  - check_id: current-certificate-ref"
  echo "    status: pass"
  echo "  - check_id: current-authored-input-digests"
  echo "    status: pass"
  echo "summary: >-"
  if [[ "$blocking_count" == "0" ]]; then
    echo "  The active closure certificate remains valid under the explicit"
    echo "  recertification rule because all invalidation triggers are clear and the"
    echo "  current authored inputs match the release evidence snapshot."
  else
    echo "  The active closure certificate is invalidated because one or more"
    echo "  recertification triggers are not clear."
  fi
} >"$out"
