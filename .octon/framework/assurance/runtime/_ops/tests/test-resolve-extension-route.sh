#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../../../../.." && pwd)"
source "$SCRIPT_DIR/test_packet2_fixture_lib.sh"

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

create_prompt_fixture() {
  mktemp -d "${TMPDIR:-/tmp}/route-resolution-fixture.XXXXXX"
}

copy_file() {
  local root="$1" rel="$2"
  mkdir -p "$root/$(dirname "$rel")"
  cp "$REPO_ROOT/$rel" "$root/$rel"
}

write_prompt_backed_fixture() {
  local root="$1"
  mkdir -p \
    "$root/.octon/framework/orchestration/runtime/_ops/scripts" \
    "$root/.octon/framework/assurance/runtime/_ops/scripts" \
    "$root/.octon/framework/cognition/_meta/architecture/inputs/additive/extensions/schemas" \
    "$root/.octon/framework/cognition/_meta/architecture/generated/effective/extensions/schemas" \
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
  copy_file "$root" ".octon/framework/cognition/_meta/architecture/inputs/additive/extensions/schemas/README.md"
  copy_file "$root" ".octon/framework/cognition/_meta/architecture/inputs/additive/extensions/schemas/extension-pack.schema.json"
  copy_file "$root" ".octon/framework/cognition/_meta/architecture/inputs/additive/extensions/schemas/extension-compatibility-profile.schema.json"
  copy_file "$root" ".octon/framework/cognition/_meta/architecture/inputs/additive/extensions/schemas/extension-routing-contract.schema.json"
  copy_file "$root" ".octon/framework/cognition/_meta/architecture/generated/effective/extensions/schemas/README.md"
  copy_file "$root" ".octon/framework/cognition/_meta/architecture/generated/effective/extensions/schemas/extension-effective-catalog.schema.json"
  copy_file "$root" ".octon/framework/cognition/_meta/architecture/generated/effective/extensions/schemas/extension-artifact-map.schema.json"
  copy_file "$root" ".octon/framework/cognition/_meta/architecture/generated/effective/extensions/schemas/extension-generation-lock.schema.json"
  copy_file "$root" ".octon/framework/cognition/_meta/architecture/generated/effective/extensions/schemas/extension-route-resolution.schema.json"
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
schema_version: "octon-extension-effective-catalog-v6"
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
  copy_file "$root" ".octon/framework/orchestration/runtime/_ops/scripts/resolve-extension-route.sh"
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
    "$root/.octon/framework/orchestration/runtime/_ops/scripts/resolve-extension-route.sh" \
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

resolve_route() {
  local root="$1" dispatcher_id="$2" inputs_json="$3"
  OCTON_DIR_OVERRIDE="$root/.octon" OCTON_ROOT_DIR="$root" \
    bash "$root/.octon/framework/orchestration/runtime/_ops/scripts/resolve-extension-route.sh" \
      --pack-id octon-concept-integration \
      --dispatcher-id "$dispatcher_id" \
      --inputs-json "$inputs_json"
}

build_non_prompt_route_fixture() {
  local root="$1"
  copy_packet2_runtime_scripts "$root"
  write_valid_packet2_fixture "$root"

  mkdir -p "$root/.octon/inputs/additive/extensions/docs/context"
  perl -0pi -e 's/context: null/context: "context\/"/' \
    "$root/.octon/inputs/additive/extensions/docs/pack.yml"
  cat >"$root/.octon/inputs/additive/extensions/docs/context/routing.contract.yml" <<'EOF'
schema_version: "octon-extension-routing-contract-v1"
dispatchers:
  - dispatcher_id: "docs-dispatcher"
    default_route_id: "docs-route"
    accepted_inputs:
      - "bundle"
    disambiguators:
      - input_name: "bundle"
        kind: "route-id"
        allowed_values:
          - "docs-route"
    precedence:
      - "explicit-bundle"
      - "missing-bundle"
    routes:
      - route_id: "docs-route"
        status: "resolved"
        execution_binding_id: "docs-route"
        matchers:
          - matcher_id: "explicit-bundle"
            reason_codes:
              - "explicit-bundle"
            all_of:
              - input_name: "bundle"
                predicate: "equals"
                value: "docs-route"
      - route_id: "missing-bundle"
        status: "escalate"
        matchers:
          - matcher_id: "missing-bundle"
            reason_codes:
              - "missing-routeable-inputs"
            all_of:
              - input_name: "bundle"
                predicate: "absent"
    execution_bindings:
      - binding_id: "docs-route"
        route_id: "docs-route"
        command_capability_id: "docs-command"
EOF

  cat >"$root/.octon/instance/extensions.yml" <<'EOF'
schema_version: "octon-instance-extensions-v2"
selection:
  enabled:
    - pack_id: "docs"
      source_id: "bundled-first-party"
  disabled: []
sources:
  catalog:
    bundled-first-party:
      source_type: "internalized"
      root: ".octon/inputs/additive/extensions"
      allowed_origin_classes:
        - "first_party_bundled"
trust:
  default_actions:
    first_party_bundled: "allow"
  source_overrides: {}
  pack_overrides: {}
acknowledgements: []
EOF

  OCTON_DIR_OVERRIDE="$root/.octon" OCTON_ROOT_DIR="$root" \
    bash "$root/.octon/framework/orchestration/runtime/_ops/scripts/publish-extension-state.sh" >/dev/null
}

resolve_docs_route() {
  local root="$1" inputs_json="$2"
  OCTON_DIR_OVERRIDE="$root/.octon" OCTON_ROOT_DIR="$root" \
    bash "$root/.octon/framework/orchestration/runtime/_ops/scripts/resolve-extension-route.sh" \
      --pack-id docs \
      --dispatcher-id docs-dispatcher \
      --inputs-json "$inputs_json"
}

case_prompt_backed_route_resolves_default_architecture() {
  local fixture out
  fixture="$(create_prompt_fixture)"
  CLEANUP_DIRS+=("$fixture")
  write_prompt_backed_fixture "$fixture"
  publish_state "$fixture"

  out="$(resolve_route "$fixture" octon-concept-integration '{"source_artifact":"https://example.com/source.md"}')"
  jq -e '.status == "resolved" and .selected_route_id == "source-to-architecture-packet" and .selected_execution_binding.prompt_set_id == "octon-concept-integration-source-to-architecture-packet"' <<<"$out" >/dev/null
}

case_prompt_backed_route_escalates_on_conflicting_families() {
  local fixture out
  fixture="$(create_prompt_fixture)"
  CLEANUP_DIRS+=("$fixture")
  write_prompt_backed_fixture "$fixture"
  publish_state "$fixture"

  out="$(resolve_route "$fixture" octon-concept-integration '{"source_artifact":"artifact.md","proposal_packet":"packet.yml"}')" && return 1
  jq -e '.status == "escalate" and (.reason_codes | index("conflicting-input-families")) != null' <<<"$out" >/dev/null
}

case_prompt_backed_route_denies_unsupported_bundle() {
  local fixture out
  fixture="$(create_prompt_fixture)"
  CLEANUP_DIRS+=("$fixture")
  write_prompt_backed_fixture "$fixture"
  publish_state "$fixture"

  out="$(resolve_route "$fixture" octon-concept-integration '{"bundle":"not-a-real-route"}')" && return 1
  jq -e '.status == "deny" and .selected_route_id == "unsupported-route-id" and (.reason_codes | index("unsupported-route-id")) != null' <<<"$out" >/dev/null
}

case_missing_dispatcher_blocks() {
  local fixture out
  fixture="$(create_prompt_fixture)"
  CLEANUP_DIRS+=("$fixture")
  write_prompt_backed_fixture "$fixture"
  publish_state "$fixture"

  out="$(resolve_route "$fixture" missing-dispatcher '{"source_artifact":"artifact.md"}')" && return 1
  jq -e '.status == "blocked" and (.reason_codes | index("missing-dispatcher-entry")) != null' <<<"$out" >/dev/null
}

case_unpublished_extension_blocks() {
  local fixture out
  fixture="$(create_prompt_fixture)"
  CLEANUP_DIRS+=("$fixture")
  write_prompt_backed_fixture "$fixture"
  publish_state "$fixture"

  perl -0pi -e 's/publication_status: "published"/publication_status: "withdrawn"/' \
    "$fixture/.octon/generated/effective/extensions/catalog.effective.yml"
  out="$(resolve_route "$fixture" octon-concept-integration '{"source_artifact":"artifact.md"}')" && return 1
  jq -e '.status == "blocked" and (.reason_codes | index("extension-not-published")) != null' <<<"$out" >/dev/null
}

case_non_prompt_binding_resolves_without_prompt_set() {
  local fixture out
  fixture="$(create_packet2_fixture_repo)"
  CLEANUP_DIRS+=("$fixture")
  build_non_prompt_route_fixture "$fixture"

  out="$(resolve_docs_route "$fixture" '{"bundle":"docs-route"}')"
  jq -e '.status == "resolved" and .selected_route_id == "docs-route" and .selected_execution_binding.command_capability_id == "docs-command" and (.selected_execution_binding | has("prompt_set_id") | not)' <<<"$out" >/dev/null
}

main() {
  assert_success "prompt-backed resolver returns the default architecture route" case_prompt_backed_route_resolves_default_architecture
  assert_success "prompt-backed resolver escalates on conflicting structural inputs" case_prompt_backed_route_escalates_on_conflicting_families
  assert_success "prompt-backed resolver denies unsupported explicit routes" case_prompt_backed_route_denies_unsupported_bundle
  assert_success "resolver blocks when the dispatcher is missing" case_missing_dispatcher_blocks
  assert_success "resolver blocks when the extension publication is withdrawn" case_unpublished_extension_blocks
  assert_success "non-prompt bindings resolve without prompt metadata" case_non_prompt_binding_resolves_without_prompt_set

  echo
  echo "Passed: $pass_count"
  echo "Failed: $fail_count"
  [[ "$fail_count" -eq 0 ]]
}

main "$@"
