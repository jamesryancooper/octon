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

create_fixture() {
  mktemp -d "${TMPDIR:-/tmp}/octon-decision-drafter.XXXXXX"
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
    "$root/.octon/framework/cognition/_meta/architecture/inputs/additive/extensions/schemas" \
    "$root/.octon/framework/cognition/_meta/architecture/generated/effective/extensions/schemas" \
    "$root/.octon/framework/cognition/_meta/architecture/state/evidence/validation/publication/schemas" \
    "$root/.octon/framework/cognition/_meta/architecture/state/evidence/validation/compatibility/schemas" \
    "$root/.octon/framework/engine/governance/extensions" \
    "$root/.octon/inputs/additive/extensions" \
    "$root/.octon/inputs/exploratory/proposals" \
    "$root/.octon/instance" \
    "$root/.octon/state/control/execution/runs" \
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
  copy_file "$root" ".octon/framework/constitution/contracts/runtime/rollback-posture-v1.schema.json"
  copy_file "$root" ".octon/instance/charter/workspace.md"
  copy_file "$root" ".octon/instance/charter/workspace.yml"
  copy_file "$root" ".octon/instance/cognition/decisions/index.yml"
  copy_file "$root" ".octon/instance/cognition/context/shared/migrations/index.yml"
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
  copy_file "$root" ".octon/framework/engine/governance/extensions/boundary-contract.md"
  copy_file "$root" ".octon/state/evidence/decisions/repo/reports/README.md"
  copy_file "$root" ".octon/state/evidence/migration/README.md"
  copy_file "$root" ".octon/state/evidence/control/execution/README.md"
  copy_file "$root" ".octon/state/evidence/validation/publication/extensions/README.md"

  cp -R "$REPO_ROOT/.octon/inputs/additive/extensions/octon-decision-drafter" \
    "$root/.octon/inputs/additive/extensions/"

  cat >"$root/.octon/instance/extensions.yml" <<'EOF'
schema_version: "octon-instance-extensions-v2"
selection:
  enabled:
    - pack_id: "octon-decision-drafter"
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

  chmod +x \
    "$root/.octon/framework/orchestration/runtime/_ops/scripts/extensions-common.sh" \
    "$root/.octon/framework/orchestration/runtime/_ops/scripts/publish-extension-state.sh" \
    "$root/.octon/framework/orchestration/runtime/_ops/scripts/resolve-extension-route.sh" \
    "$root/.octon/framework/orchestration/runtime/_ops/scripts/resolve-extension-prompt-bundle.sh" \
    "$root/.octon/framework/assurance/runtime/_ops/scripts/validate-extension-pack-contract.sh" \
    "$root/.octon/framework/assurance/runtime/_ops/scripts/validate-extension-publication-state.sh" \
    "$root/.octon/framework/assurance/runtime/_ops/scripts/validate-extension-local-tests.sh" \
    "$root/.octon/framework/capabilities/_ops/scripts/publish-capability-routing.sh" \
    "$root/.octon/framework/assurance/runtime/_ops/scripts/validate-capability-publication-state.sh"
}

publish_state() {
  local root="$1"
  OCTON_DIR_OVERRIDE="$root/.octon" OCTON_ROOT_DIR="$root" \
    bash "$root/.octon/framework/orchestration/runtime/_ops/scripts/publish-extension-state.sh" >/dev/null
}

resolve_route() {
  local root="$1" inputs_json="$2"
  OCTON_DIR_OVERRIDE="$root/.octon" OCTON_ROOT_DIR="$root" \
    bash "$root/.octon/framework/orchestration/runtime/_ops/scripts/resolve-extension-route.sh" \
      --pack-id octon-decision-drafter \
      --dispatcher-id octon-decision-drafter \
      --inputs-json "$inputs_json"
}

resolve_bundle() {
  local root="$1" prompt_set_id="$2" mode="$3"
  OCTON_DIR_OVERRIDE="$root/.octon" OCTON_ROOT_DIR="$root" \
    bash "$root/.octon/framework/orchestration/runtime/_ops/scripts/resolve-extension-prompt-bundle.sh" \
      --pack-id octon-decision-drafter \
      --prompt-set-id "$prompt_set_id" \
      --alignment-mode "$mode"
}

setup_published_fixture() {
  local root
  root="$(create_fixture)"
  CLEANUP_DIRS+=("$root")
  write_fixture "$root"
  publish_state "$root"
  printf '%s\n' "$root"
}

case_adr_ref_routes_to_adr_update() {
  local root result
  root="$(setup_published_fixture)"
  result="$(resolve_route "$root" '{"adr_ref":"./docs/adr-001.md","diff_range":"HEAD~1..HEAD","evidence_refs":".octon/state/evidence/control/execution/authority-decision.yml"}')"
  [[ "$(jq -r '.status' <<<"$result")" == "resolved" ]]
  [[ "$(jq -r '.selected_route_id' <<<"$result")" == "adr-update" ]]
  [[ "$(jq -r '.selected_execution_binding.prompt_set_id' <<<"$result")" == "octon-decision-drafter-adr-update" ]]
}

case_migration_plan_routes_to_migration_rationale() {
  local root result
  root="$(setup_published_fixture)"
  result="$(resolve_route "$root" '{"migration_plan_ref":"./migration/plan.md","diff_source":"./artifacts/change.diff","evidence_refs":".octon/state/evidence/migration/2026-03-20-migration-rollout-review/evidence.md"}')"
  [[ "$(jq -r '.status' <<<"$result")" == "resolved" ]]
  [[ "$(jq -r '.selected_route_id' <<<"$result")" == "migration-rationale" ]]
}

case_rollback_ref_routes_to_rollback_notes() {
  local root result
  root="$(setup_published_fixture)"
  result="$(resolve_route "$root" '{"rollback_posture_ref":"./runs/example/rollback-posture.yml","diff_range":"HEAD~1..HEAD","evidence_refs":".octon/state/evidence/control/execution/authority-grant.yml"}')"
  [[ "$(jq -r '.status' <<<"$result")" == "resolved" ]]
  [[ "$(jq -r '.selected_route_id' <<<"$result")" == "rollback-notes" ]]
}

case_default_change_receipt_route_requires_grounding() {
  local root result
  root="$(setup_published_fixture)"
  result="$(resolve_route "$root" '{"diff_range":"HEAD~1..HEAD","evidence_refs":".octon/state/evidence/validation/publication/extensions/2026-04-15T22-58-40Z-extensions-f66caee9e62b.yml"}')"
  [[ "$(jq -r '.status' <<<"$result")" == "resolved" ]]
  [[ "$(jq -r '.selected_route_id' <<<"$result")" == "change-receipt" ]]
}

case_conflicting_target_refs_escalate() {
  local root result reasons
  root="$(setup_published_fixture)"
  result="$(resolve_route "$root" '{"adr_ref":"./docs/adr-001.md","migration_plan_ref":"./migration/plan.md","diff_range":"HEAD~1..HEAD"}')"
  reasons="$(jq -r '.reason_codes[]?' <<<"$result")"
  [[ "$(jq -r '.status' <<<"$result")" == "escalate" ]]
  grep -Fxq "conflicting-target-refs" <<<"$reasons"
}

case_conflicting_diff_sources_escalate() {
  local root result reasons
  root="$(setup_published_fixture)"
  result="$(resolve_route "$root" '{"evidence_refs":".octon/state/evidence/control/execution/authority-decision.yml","diff_range":"HEAD~1..HEAD","diff_source":"./artifacts/change.diff"}')"
  reasons="$(jq -r '.reason_codes[]?' <<<"$result")"
  [[ "$(jq -r '.status' <<<"$result")" == "escalate" ]]
  grep -Fxq "conflicting-diff-source" <<<"$reasons"
}

case_patch_suggestion_without_target_escalates() {
  local root result reasons
  root="$(setup_published_fixture)"
  result="$(resolve_route "$root" '{"migration_plan_ref":"./migration/plan.md","diff_source":"./artifacts/change.diff","output_mode":"patch-suggestion"}')"
  reasons="$(jq -r '.reason_codes[]?' <<<"$result")"
  [[ "$(jq -r '.status' <<<"$result")" == "escalate" ]]
  grep -Fxq "patch-suggestion-missing-target" <<<"$reasons"
}

case_missing_diff_source_escalates() {
  local root result reasons
  root="$(setup_published_fixture)"
  result="$(resolve_route "$root" '{"evidence_refs":".octon/state/evidence/control/execution/authority-decision.yml"}')"
  reasons="$(jq -r '.reason_codes[]?' <<<"$result")"
  [[ "$(jq -r '.status' <<<"$result")" == "escalate" ]]
  grep -Fxq "missing-diff-source" <<<"$reasons"
}

case_stale_prompt_bundle_blocks_in_auto_and_degrades_in_skip() {
  local root auto_result skip_result auto_reasons skip_reasons prompt_file
  root="$(setup_published_fixture)"
  prompt_file="$root/.octon/inputs/additive/extensions/octon-decision-drafter/prompts/change-receipt/stages/03-draft-change-receipt.md"
  printf '\n<!-- drift -->\n' >>"$prompt_file"

  auto_result="$(resolve_bundle "$root" "octon-decision-drafter-change-receipt" "auto")"
  skip_result="$(resolve_bundle "$root" "octon-decision-drafter-change-receipt" "skip")"
  auto_reasons="$(jq -r '.reason_codes[]?' <<<"$auto_result")"
  skip_reasons="$(jq -r '.reason_codes[]?' <<<"$skip_result")"

  [[ "$(jq -r '.status' <<<"$auto_result")" == "blocked" ]]
  [[ "$(jq -r '.safe_to_run' <<<"$auto_result")" == "false" ]]
  grep -Fq "prompt-asset-sha-changed:stages/03-draft-change-receipt.md" <<<"$auto_reasons"

  [[ "$(jq -r '.status' <<<"$skip_result")" == "degraded_skip" ]]
  [[ "$(jq -r '.safe_to_run' <<<"$skip_result")" == "true" ]]
  grep -Fq "prompt-asset-sha-changed:stages/03-draft-change-receipt.md" <<<"$skip_reasons"
}

main() {
  assert_success "adr_ref routes to the adr-update bundle" case_adr_ref_routes_to_adr_update
  assert_success "migration_plan_ref routes to the migration-rationale bundle" case_migration_plan_routes_to_migration_rationale
  assert_success "rollback_posture_ref routes to the rollback-notes bundle" case_rollback_ref_routes_to_rollback_notes
  assert_success "diff plus retained grounding defaults to change-receipt" case_default_change_receipt_route_requires_grounding
  assert_success "conflicting target refs escalate" case_conflicting_target_refs_escalate
  assert_success "conflicting diff sources escalate" case_conflicting_diff_sources_escalate
  assert_success "patch-suggestion without draft_target_path escalates" case_patch_suggestion_without_target_escalates
  assert_success "missing diff source escalates" case_missing_diff_source_escalates
  assert_success "stale prompt bundles block in auto mode and degrade in skip mode" case_stale_prompt_bundle_blocks_in_auto_and_degrades_in_skip

  echo
  echo "Passed: $pass_count"
  echo "Failed: $fail_count"
  [[ "$fail_count" -eq 0 ]]
}

main "$@"
