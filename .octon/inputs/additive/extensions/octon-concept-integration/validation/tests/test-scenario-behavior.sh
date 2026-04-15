#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../../../../../.." && pwd)"

pass_count=0
fail_count=0
declare -a CLEANUP_DIRS=()

cleanup() {
  local dir
  for dir in "${CLEANUP_DIRS[@]}"; do
    [[ -n "$dir" ]] && rm -r -f -- "$dir"
  done
}
trap cleanup EXIT

pass() { echo "PASS: $1"; pass_count=$((pass_count + 1)); }
fail() { echo "FAIL: $1" >&2; fail_count=$((fail_count + 1)); }

assert_success() {
  local name="$1"
  shift
  if "$@"; then
    pass "$name"
  else
    fail "$name"
  fi
}

assert_contains() {
  local file="$1" pattern="$2"
  grep -Fq -- "$pattern" "$file"
}

create_fixture() {
  mktemp -d "${TMPDIR:-/tmp}/octon-concept-scenarios.XXXXXX"
}

copy_file() {
  local root="$1" rel="$2"
  mkdir -p "$root/$(dirname "$rel")"
  cp "$REPO_ROOT/$rel" "$root/$rel"
}

write_fixture() {
  local root="$1"
  mkdir -p \
    "$root/.octon/framework/orchestration/runtime/_ops/scripts" \
    "$root/.octon/framework/assurance/runtime/_ops/scripts" \
    "$root/.octon/framework/cognition/_meta/architecture/state/evidence/validation/publication/schemas" \
    "$root/.octon/framework/cognition/_meta/architecture/state/evidence/validation/compatibility/schemas" \
    "$root/.octon/framework/engine/governance/extensions" \
    "$root/.octon/inputs/additive/extensions" \
    "$root/.octon/inputs/exploratory/proposals" \
    "$root/.octon/instance" \
    "$root/.octon/state/control/extensions" \
    "$root/.octon/state/control/skills/checkpoints" \
    "$root/.octon/state/evidence/runs/skills" \
    "$root/.octon/state/evidence/validation/publication/extensions" \
    "$root/.octon/state/evidence/validation/compatibility/extensions" \
    "$root/.octon/state/evidence/validation/extensions" \
    "$root/.octon/generated/effective/extensions" \
    "$root/.octon/generated/effective/capabilities"

  copy_file "$root" "README.md"
  copy_file "$root" ".octon/README.md"
  copy_file "$root" ".octon/octon.yml"
  copy_file "$root" ".octon/framework/manifest.yml"
  copy_file "$root" ".octon/instance/manifest.yml"
  copy_file "$root" ".octon/instance/ingress/AGENTS.md"
  copy_file "$root" ".octon/framework/constitution/CHARTER.md"
  copy_file "$root" ".octon/framework/constitution/charter.yml"
  copy_file "$root" ".octon/framework/constitution/precedence/normative.yml"
  copy_file "$root" ".octon/framework/constitution/precedence/epistemic.yml"
  copy_file "$root" ".octon/framework/constitution/obligations/fail-closed.yml"
  copy_file "$root" ".octon/framework/constitution/obligations/evidence.yml"
  copy_file "$root" ".octon/framework/constitution/ownership/roles.yml"
  copy_file "$root" ".octon/framework/constitution/contracts/registry.yml"
  copy_file "$root" ".octon/instance/charter/workspace.md"
  copy_file "$root" ".octon/instance/charter/workspace.yml"
  copy_file "$root" ".octon/framework/cognition/_meta/architecture/specification.md"
  copy_file "$root" ".octon/framework/cognition/_meta/architecture/state/evidence/validation/publication/schemas/validation-publication-receipt.schema.json"
  copy_file "$root" ".octon/framework/cognition/_meta/architecture/state/evidence/validation/compatibility/schemas/extension-compatibility-receipt.schema.json"
  copy_file "$root" ".octon/framework/engine/governance/extensions/README.md"

  cp -R "$REPO_ROOT/.octon/inputs/additive/extensions/octon-concept-integration" \
    "$root/.octon/inputs/additive/extensions/"

  cat >"$root/.octon/instance/extensions.yml" <<'EOF'
schema_version: "octon-instance-extensions-v2"
selection:
  enabled:
    - pack_id: "octon-concept-integration"
      source_id: "bundled-first-party"
  disabled: []
sources:
  catalog:
    bundled-first-party:
      source_type: "internalized"
      root: ".octon/inputs/additive/extensions"
      allowed_origin_classes:
        - "first_party_bundled"
    first-party-imported:
      source_type: "internalized"
      root: ".octon/inputs/additive/extensions"
      allowed_origin_classes:
        - "first_party_external"
    third-party-imported:
      source_type: "internalized"
      root: ".octon/inputs/additive/extensions"
      allowed_origin_classes:
        - "third_party"
trust:
  default_actions:
    first_party_bundled: "allow"
    first_party_external: "require_acknowledgement"
    third_party: "deny"
  source_overrides: {}
  pack_overrides: {}
acknowledgements: []
EOF

  cat >"$root/.octon/state/control/extensions/active.yml" <<'EOF'
schema_version: "octon-extension-active-state-v4"
desired_config_revision:
  path: ".octon/instance/extensions.yml"
  sha256: "stub"
desired_selected_packs: []
published_active_packs: []
dependency_closure: []
generation_id: "stub"
published_effective_catalog: ".octon/generated/effective/extensions/catalog.effective.yml"
published_artifact_map: ".octon/generated/effective/extensions/artifact-map.yml"
published_generation_lock: ".octon/generated/effective/extensions/generation.lock.yml"
publication_receipt_path: ".octon/state/evidence/validation/publication/extensions/stub.yml"
publication_receipt_sha256: "stub"
compatibility_status: "compatible"
compatibility_receipt_path: ".octon/state/evidence/validation/compatibility/extensions/stub.yml"
compatibility_receipt_sha256: "stub"
invalidation_conditions: []
required_inputs: []
validation_timestamp: "1970-01-01T00:00:00Z"
status: "withdrawn"
EOF

  cat >"$root/.octon/state/control/extensions/quarantine.yml" <<'EOF'
schema_version: "octon-extension-quarantine-state-v3"
updated_at: "1970-01-01T00:00:00Z"
records: []
EOF

  cat >"$root/.octon/generated/effective/extensions/catalog.effective.yml" <<'EOF'
schema_version: "octon-extension-effective-catalog-v5"
generator_version: "stub"
generation_id: "stub"
published_at: "1970-01-01T00:00:00Z"
publication_status: "withdrawn"
publication_receipt_path: ".octon/state/evidence/validation/publication/extensions/stub.yml"
compatibility_status: "compatible"
compatibility_receipt_path: ".octon/state/evidence/validation/compatibility/extensions/stub.yml"
compatibility_receipt_sha256: "stub"
invalidation_conditions: []
desired_selected_packs: []
published_active_packs: []
dependency_closure: []
packs: []
source:
  desired_config_path: ".octon/instance/extensions.yml"
  desired_config_sha256: "stub"
  root_manifest_path: ".octon/octon.yml"
  root_manifest_sha256: "stub"
EOF

  cat >"$root/.octon/generated/effective/extensions/artifact-map.yml" <<'EOF'
schema_version: "octon-extension-artifact-map-v4"
generator_version: "stub"
generation_id: "stub"
published_at: "1970-01-01T00:00:00Z"
artifacts: []
EOF

  cat >"$root/.octon/generated/effective/extensions/generation.lock.yml" <<'EOF'
schema_version: "octon-extension-generation-lock-v5"
generator_version: "stub"
generation_id: "stub"
published_at: "1970-01-01T00:00:00Z"
publication_status: "withdrawn"
publication_receipt_path: ".octon/state/evidence/validation/publication/extensions/stub.yml"
publication_receipt_sha256: "stub"
compatibility_status: "compatible"
compatibility_receipt_path: ".octon/state/evidence/validation/compatibility/extensions/stub.yml"
compatibility_receipt_sha256: "stub"
desired_config_sha256: "stub"
root_manifest_sha256: "stub"
published_files: []
required_inputs: []
invalidation_conditions: []
pack_payload_digests: []
EOF

  copy_file "$root" ".octon/framework/orchestration/runtime/_ops/scripts/extensions-common.sh"
  copy_file "$root" ".octon/framework/orchestration/runtime/_ops/scripts/publish-extension-state.sh"
  copy_file "$root" ".octon/framework/orchestration/runtime/_ops/scripts/resolve-extension-prompt-bundle.sh"
  copy_file "$root" ".octon/framework/assurance/runtime/_ops/scripts/validate-extension-pack-contract.sh"
  copy_file "$root" ".octon/framework/assurance/runtime/_ops/scripts/validate-extension-publication-state.sh"
  copy_file "$root" ".octon/framework/assurance/runtime/_ops/scripts/validate-extension-local-tests.sh"
  copy_file "$root" ".octon/framework/capabilities/_ops/scripts/publish-capability-routing.sh"
  copy_file "$root" ".octon/framework/assurance/runtime/_ops/scripts/validate-capability-publication-state.sh"
  copy_file "$root" ".octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh"
  copy_file "$root" ".octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh"
  copy_file "$root" ".octon/framework/assurance/runtime/_ops/scripts/validate-policy-proposal.sh"
  copy_file "$root" ".octon/framework/assurance/runtime/_ops/scripts/validate-migration-proposal.sh"

  chmod +x \
    "$root/.octon/framework/orchestration/runtime/_ops/scripts/extensions-common.sh" \
    "$root/.octon/framework/orchestration/runtime/_ops/scripts/publish-extension-state.sh" \
    "$root/.octon/framework/orchestration/runtime/_ops/scripts/resolve-extension-prompt-bundle.sh" \
    "$root/.octon/framework/assurance/runtime/_ops/scripts/validate-extension-pack-contract.sh" \
    "$root/.octon/framework/assurance/runtime/_ops/scripts/validate-extension-publication-state.sh" \
    "$root/.octon/framework/assurance/runtime/_ops/scripts/validate-extension-local-tests.sh" \
    "$root/.octon/framework/capabilities/_ops/scripts/publish-capability-routing.sh" \
    "$root/.octon/framework/assurance/runtime/_ops/scripts/validate-capability-publication-state.sh" \
    "$root/.octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh" \
    "$root/.octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh" \
    "$root/.octon/framework/assurance/runtime/_ops/scripts/validate-policy-proposal.sh" \
    "$root/.octon/framework/assurance/runtime/_ops/scripts/validate-migration-proposal.sh"
}

publish_state() {
  local root="$1"
  OCTON_DIR_OVERRIDE="$root/.octon" OCTON_ROOT_DIR="$root" \
    bash "$root/.octon/framework/orchestration/runtime/_ops/scripts/publish-extension-state.sh" >/dev/null
}

resolve_bundle() {
  local root="$1" prompt_set_id="$2" mode="$3"
  OCTON_DIR_OVERRIDE="$root/.octon" OCTON_ROOT_DIR="$root" \
    bash "$root/.octon/framework/orchestration/runtime/_ops/scripts/resolve-extension-prompt-bundle.sh" \
      --pack-id octon-concept-integration \
      --prompt-set-id "$prompt_set_id" \
      --alignment-mode "$mode"
}

case_stale_bundle_prompt_asset_blocks_auto() {
  local fixture out
  fixture="$(create_fixture)"
  CLEANUP_DIRS+=("$fixture")
  write_fixture "$fixture"
  publish_state "$fixture"
  printf '\n<!-- stale fixture mutation -->\n' >> "$fixture/.octon/inputs/additive/extensions/octon-concept-integration/prompts/source-to-architecture-packet/stages/01-extract.md"
  out="$(resolve_bundle "$fixture" octon-concept-integration-source-to-architecture-packet auto)" && return 1
  jq -e '.status == "blocked" and .safe_to_run == false and (.reason_codes | any(startswith("prompt-asset-sha-changed:stages/01-extract.md")))' <<<"$out" >/dev/null
}

case_stale_bundle_shared_reference_degrades_skip() {
  local fixture out
  fixture="$(create_fixture)"
  CLEANUP_DIRS+=("$fixture")
  write_fixture "$fixture"
  publish_state "$fixture"
  printf '\n<!-- stale reference mutation -->\n' >> "$fixture/.octon/inputs/additive/extensions/octon-concept-integration/prompts/shared/managed-artifact-contract.md"
  out="$(resolve_bundle "$fixture" octon-concept-integration-source-to-architecture-packet skip)"
  jq -e '.status == "degraded_skip" and .safe_to_run == true and (.reason_codes | any(startswith("shared-reference-asset-sha-changed:shared/managed-artifact-contract.md")))' <<<"$out" >/dev/null
}

case_stale_bundle_republish_recovers_auto() {
  local fixture first second first_sha second_sha
  fixture="$(create_fixture)"
  CLEANUP_DIRS+=("$fixture")
  write_fixture "$fixture"
  publish_state "$fixture"
  first="$(resolve_bundle "$fixture" octon-concept-integration-source-to-architecture-packet auto)"
  first_sha="$(jq -r '.prompt_bundle_sha256' <<<"$first")"
  printf '\n<!-- prompt asset changed before republish -->\n' >> "$fixture/.octon/inputs/additive/extensions/octon-concept-integration/prompts/source-to-architecture-packet/stages/01-extract.md"
  publish_state "$fixture"
  second="$(resolve_bundle "$fixture" octon-concept-integration-source-to-architecture-packet auto)"
  second_sha="$(jq -r '.prompt_bundle_sha256' <<<"$second")"
  [[ "$first_sha" != "$second_sha" ]]
  jq -e '.status == "fresh" and .safe_to_run == true' <<<"$second" >/dev/null
}

case_packet_drift_contract_requires_detection_before_execution_or_refresh_claims() {
  local implementation_stage refresh_manifest refresh_detect refresh_update
  implementation_stage="$REPO_ROOT/.octon/inputs/additive/extensions/octon-concept-integration/prompts/packet-to-implementation/stages/01-implement-packet.md"
  refresh_manifest="$REPO_ROOT/.octon/inputs/additive/extensions/octon-concept-integration/prompts/packet-refresh-and-supersession/manifest.yml"
  refresh_detect="$REPO_ROOT/.octon/inputs/additive/extensions/octon-concept-integration/prompts/packet-refresh-and-supersession/stages/02-reground-and-detect-drift.md"
  refresh_update="$REPO_ROOT/.octon/inputs/additive/extensions/octon-concept-integration/prompts/packet-refresh-and-supersession/stages/03-refresh-or-supersede-packet.md"

  [[ "$(yq -r '.stages[] | [.order, .stage_id] | @tsv' "$refresh_manifest")" == $'1\tinspect-packet\n2\treground-and-detect-drift\n3\trefresh-or-supersede' ]] || return 1
  assert_contains "$implementation_stage" "detects packet-time repo drift before implementation,"
  assert_contains "$implementation_stage" "Record a **Packet Drift Note** whenever current repo state materially changes the expected execution path."
  assert_contains "$implementation_stage" "If packet drift invalidates the execution basis materially, state that plainly and stop rather than forcing implementation against a stale design."
  assert_contains "$refresh_detect" "Record packet-time drift, already-landed work, stale assumptions, and whether"
  assert_contains "$refresh_update" "supersede when the live repo or packet drift makes in-place refresh"
}

case_multi_source_conflict_contract_requires_normalization_and_resolution_before_packetization() {
  local manifest normalize synthesize build
  manifest="$REPO_ROOT/.octon/inputs/additive/extensions/octon-concept-integration/prompts/multi-source-synthesis-packet/manifest.yml"
  normalize="$REPO_ROOT/.octon/inputs/additive/extensions/octon-concept-integration/prompts/multi-source-synthesis-packet/stages/01-normalize-source-set.md"
  synthesize="$REPO_ROOT/.octon/inputs/additive/extensions/octon-concept-integration/prompts/multi-source-synthesis-packet/stages/02-synthesize-concepts.md"
  build="$REPO_ROOT/.octon/inputs/additive/extensions/octon-concept-integration/prompts/multi-source-synthesis-packet/stages/04-build-synthesis-packet.md"

  [[ "$(yq -r '.stages[] | [.order, .stage_id] | @tsv' "$manifest")" == $'1\tnormalize-source-set\n2\tsynthesize-concepts\n3\tverify-synthesis\n4\tbuild-synthesis-packet' ]] || return 1
  assert_contains "$normalize" "flags obvious overlap, contradiction, or duplicate framing before synthesis."
  assert_contains "$synthesize" "- preserves disagreements where they matter,"
  assert_contains "$synthesize" "- identifies consensus and contested concepts,"
  assert_contains "$build" "traceability back to the normalized source set."
}

case_subsystem_scope_mismatch_contract_prevents_silent_scope_escape() {
  local manifest scope_stage extract_stage verify_stage build_stage registry commands
  manifest="$REPO_ROOT/.octon/inputs/additive/extensions/octon-concept-integration/prompts/subsystem-targeted-integration/manifest.yml"
  scope_stage="$REPO_ROOT/.octon/inputs/additive/extensions/octon-concept-integration/prompts/subsystem-targeted-integration/stages/01-scope-subsystem.md"
  extract_stage="$REPO_ROOT/.octon/inputs/additive/extensions/octon-concept-integration/prompts/subsystem-targeted-integration/stages/02-extract-subsystem-concepts.md"
  verify_stage="$REPO_ROOT/.octon/inputs/additive/extensions/octon-concept-integration/prompts/subsystem-targeted-integration/stages/03-verify-subsystem-fit.md"
  build_stage="$REPO_ROOT/.octon/inputs/additive/extensions/octon-concept-integration/prompts/subsystem-targeted-integration/stages/04-build-subsystem-packet.md"
  registry="$REPO_ROOT/.octon/inputs/additive/extensions/octon-concept-integration/skills/registry.fragment.yml"
  commands="$REPO_ROOT/.octon/inputs/additive/extensions/octon-concept-integration/commands/manifest.fragment.yml"

  [[ "$(yq -r '.stages[] | [.order, .stage_id] | @tsv' "$manifest")" == $'1\tscope-subsystem\n2\textract-subsystem-concepts\n3\tverify-subsystem-fit\n4\tbuild-subsystem-packet' ]] || return 1
  [[ "$(yq -r '.skills."octon-concept-integration-subsystem-targeted-integration".parameters[] | select(.name == "subsystem_scope") | .required' "$registry")" == "true" ]] || return 1
  assert_contains "$commands" "--subsystem-scope <scope>"
  assert_contains "$scope_stage" "- excluded adjacent domains,"
  assert_contains "$scope_stage" "- and the escalation rule for concepts that would escape the declared scope."
  assert_contains "$extract_stage" "reject concepts that"
  assert_contains "$extract_stage" "escaping the declared scope without explicit justification."
  assert_contains "$verify_stage" "records cross-subsystem dependencies"
  assert_contains "$verify_stage" "must be explicit in the final"
  assert_contains "$build_stage" "explicit cross-subsystem"
  assert_contains "$build_stage" "dependency notes when required."
}

main() {
  assert_success "stale bundle prompt asset blocks auto mode" case_stale_bundle_prompt_asset_blocks_auto
  assert_success "stale bundle shared reference degrades skip mode" case_stale_bundle_shared_reference_degrades_skip
  assert_success "republishing a stale bundle restores fresh auto mode" case_stale_bundle_republish_recovers_auto
  assert_success "packet drift scenario requires detection before execution or refresh claims" case_packet_drift_contract_requires_detection_before_execution_or_refresh_claims
  assert_success "multi-source conflict scenario requires normalization and explicit resolution before packetization" case_multi_source_conflict_contract_requires_normalization_and_resolution_before_packetization
  assert_success "subsystem scope mismatch scenario prevents silent scope escape" case_subsystem_scope_mismatch_contract_prevents_silent_scope_escape

  echo
  echo "Passed: $pass_count"
  echo "Failed: $fail_count"
  [[ "$fail_count" -eq 0 ]]
}

main "$@"
