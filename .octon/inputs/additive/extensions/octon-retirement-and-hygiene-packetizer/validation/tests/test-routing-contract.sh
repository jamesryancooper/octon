#!/usr/bin/env bash
set -euo pipefail

TEST_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$TEST_DIR/../fixture-lib.sh"

fixture_root="$(setup_publication_fixture)"
trap 'rm -r -f -- "$fixture_root"' EXIT

run_in_fixture "$fixture_root" bash "$fixture_root/.octon/framework/assurance/runtime/_ops/scripts/validate-extension-pack-contract.sh" >/dev/null
run_in_fixture "$fixture_root" bash "$fixture_root/.octon/framework/orchestration/runtime/_ops/scripts/publish-extension-state.sh" >/dev/null
run_in_fixture "$fixture_root" bash "$fixture_root/.octon/framework/assurance/runtime/_ops/scripts/validate-extension-publication-state.sh" >/dev/null
run_in_fixture "$fixture_root" bash "$fixture_root/.octon/framework/capabilities/_ops/scripts/publish-capability-routing.sh" >/dev/null
run_in_fixture "$fixture_root" bash "$fixture_root/.octon/framework/assurance/runtime/_ops/scripts/validate-capability-publication-state.sh" >/dev/null

resolve_route() {
  local inputs_json="$1"
  run_in_fixture "$fixture_root" \
    bash "$fixture_root/.octon/framework/orchestration/runtime/_ops/scripts/resolve-extension-route.sh" \
      --pack-id "$PACK_ID" \
      --dispatcher-id "$PACK_ID" \
      --inputs-json "$inputs_json"
}

result="$(resolve_route '{"flow":"scan-to-reconciliation"}')"
[[ "$(jq -r '.status' <<<"$result")" == "resolved" ]]
[[ "$(jq -r '.selected_route_id' <<<"$result")" == "scan-to-reconciliation" ]]

result="$(resolve_route '{"gap_scope":"missing"}')"
[[ "$(jq -r '.selected_route_id' <<<"$result")" == "registry-gap-analysis" ]]

result="$(resolve_route '{"packet_attachment":".octon/state/evidence/validation/publication/build-to-delete/current/repo-hygiene-findings.yml"}')"
[[ "$(jq -r '.selected_route_id' <<<"$result")" == "ablation-plan-draft" ]]

result="$(resolve_route '{"proposal_id":"cleanup-draft"}')"
[[ "$(jq -r '.selected_route_id' <<<"$result")" == "audit-to-packet-draft" ]]

result="$(resolve_route '{"audit_dir":".octon/state/evidence/runs/ci/repo-hygiene/demo"}')"
[[ "$(jq -r '.selected_route_id' <<<"$result")" == "audit-to-packet-draft" ]]

result="$(resolve_route '{}')"
[[ "$(jq -r '.selected_route_id' <<<"$result")" == "scan-to-reconciliation" ]]
