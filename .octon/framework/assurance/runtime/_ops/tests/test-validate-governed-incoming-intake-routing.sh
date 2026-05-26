#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../../../../.." && pwd)"

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

spec_path() {
  local fixture_root="$1"
  printf '%s\n' "$fixture_root/.octon/framework/engine/governance/inputs/additive/governed-incoming-intake-routing-fixtures.yml"
}

create_fixture_repo() {
  local fixture_root
  fixture_root="$(mktemp -d "${TMPDIR:-/tmp}/governed-intake-routing.XXXXXX")"
  CLEANUP_DIRS+=("$fixture_root")
  mkdir -p "$fixture_root/.octon/framework/assurance/runtime/_ops/scripts"
  mkdir -p "$fixture_root/.octon/framework/engine/governance/inputs/additive"
  mkdir -p "$fixture_root/.octon/framework/product/contracts"
  mkdir -p "$fixture_root/.octon/inputs/additive/extensions/octon-proposal-lifecycle/context/intake-admission"
  mkdir -p "$fixture_root/.octon/inputs/additive/.incoming"
  mkdir -p "$fixture_root/.octon/inputs/additive/.archive"
  mkdir -p "$fixture_root/.octon/inputs/additive/extensions"

  cp "$REPO_ROOT/.octon/framework/assurance/runtime/_ops/scripts/validate-governed-incoming-intake-routing.sh" \
    "$fixture_root/.octon/framework/assurance/runtime/_ops/scripts/validate-governed-incoming-intake-routing.sh"
  cp "$REPO_ROOT/.octon/framework/assurance/runtime/_ops/scripts/validate-incoming-intake-unit.sh" \
    "$fixture_root/.octon/framework/assurance/runtime/_ops/scripts/validate-incoming-intake-unit.sh"
  cp "$REPO_ROOT/.octon/framework/engine/governance/inputs/additive/governed-incoming-intake-routing-fixtures.yml" \
    "$(spec_path "$fixture_root")"
  cp "$REPO_ROOT/.octon/framework/product/contracts/governed-incoming-intake-route-decision-v1.schema.json" \
    "$fixture_root/.octon/framework/product/contracts/governed-incoming-intake-route-decision-v1.schema.json"
  cp "$REPO_ROOT/.octon/framework/product/contracts/governed-incoming-intake-handoff-v1.schema.json" \
    "$fixture_root/.octon/framework/product/contracts/governed-incoming-intake-handoff-v1.schema.json"
  cp "$REPO_ROOT/.octon/framework/product/contracts/target-owned-intake-admission-contract-v1.schema.json" \
    "$fixture_root/.octon/framework/product/contracts/target-owned-intake-admission-contract-v1.schema.json"
  cp "$REPO_ROOT/.octon/framework/product/contracts/lifecycle-interaction-request-v1.schema.json" \
    "$fixture_root/.octon/framework/product/contracts/lifecycle-interaction-request-v1.schema.json"
  cp "$REPO_ROOT/.octon/framework/product/contracts/lifecycle-interaction-return-v1.schema.json" \
    "$fixture_root/.octon/framework/product/contracts/lifecycle-interaction-return-v1.schema.json"
  cp "$REPO_ROOT/.octon/inputs/additive/extensions/octon-proposal-lifecycle/context/intake-admission/proposal-packet-intake-admission.contract.yml" \
    "$fixture_root/.octon/inputs/additive/extensions/octon-proposal-lifecycle/context/intake-admission/proposal-packet-intake-admission.contract.yml"
  cp "$REPO_ROOT/.octon/inputs/additive/extensions/octon-proposal-lifecycle/context/intake-admission/proposal-program-intake-admission.contract.yml" \
    "$fixture_root/.octon/inputs/additive/extensions/octon-proposal-lifecycle/context/intake-admission/proposal-program-intake-admission.contract.yml"
  chmod +x "$fixture_root/.octon/framework/assurance/runtime/_ops/scripts/validate-governed-incoming-intake-routing.sh"
  chmod +x "$fixture_root/.octon/framework/assurance/runtime/_ops/scripts/validate-incoming-intake-unit.sh"

  write_observed_invalid_rust_intake "$fixture_root"
  write_synthetic_intakes "$fixture_root"
  printf '%s\n' "$fixture_root"
}

run_routing_validator() {
  local fixture_root="$1"
  shift
  OCTON_DIR_OVERRIDE="$fixture_root/.octon" OCTON_ROOT_DIR="$fixture_root" \
    bash "$fixture_root/.octon/framework/assurance/runtime/_ops/scripts/validate-governed-incoming-intake-routing.sh" "$@" >/dev/null 2>&1
}

write_intake_unit() {
  local fixture_root="$1"
  local intake_id="$2"
  local provenance_status="${3:-declared}"
  local risk_secret="${4:-no}"
  local intake
  intake="$fixture_root/.octon/inputs/additive/.incoming/$intake_id"
  mkdir -p "$intake/payload"
  cat >"$intake/intake.yml" <<EOF
schema_version: "octon-additive-incoming-intake-unit-v1"
intake_id: "$intake_id"
authority_mode: "non_authoritative"
status: "unclassified"
staged_at: "2026-05-22T00:00:00Z"
submitted_by:
  type: "human"
  name: "fixture"
reason: "governed incoming intake routing fixture"
next_step: "classify-route"
route_hint: "unknown"
payload:
  root: "payload/"
  form: "directory"
provenance:
  status: "$provenance_status"
  origin_class: "unknown"
  imported_from: "unknown"
  origin_uri: null
  source_digest_sha256: null
  attestation_refs: []
risk:
  contains_executable: "no"
  contains_binary: "no"
  contains_secret_or_private_data: "$risk_secret"
  redistribution_risk: "unknown"
  size_class: "small"
EOF
  printf '# Payload\n' >"$intake/payload/README.md"
}

write_observed_invalid_rust_intake() {
  local fixture_root="$1"
  local intake_id="octon-rust-skill-pack-rust-source-authority"
  local intake="$fixture_root/.octon/inputs/additive/.incoming/$intake_id"
  mkdir -p "$intake/payload/rust-source-authority"
  cat >"$intake/intake.yml" <<EOF
schema_version: "octon-additive-incoming-intake-unit-v1"
intake_id: "$intake_id"
authority_mode: "non_authoritative"
status: "unclassified"
staged_at: "2026-05-22T00:00:00Z"
submitted_by:
  type: "human"
  name: "fixture"
reason: "observed invalid envelope fixture"
next_step: "classify-route"
route_hint: "unknown"
payload:
  root: "payload/"
  form: "directory"
provenance:
  status: "declared"
  origin_class: "unknown"
  imported_from: "unknown"
  origin_uri: null
  source_digest_sha256: null
  attestation_refs: []
risk:
  contains_executable: "no"
  contains_binary: "no"
  contains_secret_or_private_data: "no"
  redistribution_risk: "unknown"
  size_class: "small"
EOF
  printf '# Rust Source Authority\n' >"$intake/payload/rust-source-authority/README.md"
  printf 'staged\n' >"$intake/intake-status.yml"
  printf 'noise\n' >"$intake/.DS_Store"
}

write_synthetic_intakes() {
  local fixture_root="$1"
  local id
  for id in \
    "simple-extension-pack-single-unit" \
    "simple-core-skill-single-unit" \
    "multi-skill-program" \
    "governance-plus-runtime-program" \
    "ambiguous-packet-vs-program" \
    "unsafe-provenance-or-license" \
    "secret-or-private-data" \
    "malicious-authority-confusion" \
    "stale-target-return" \
    "parent-program-evidence-used-for-child-receipt" \
    "lifecycle-receipt-as-authorization" \
    "requested-route-mismatch" \
    "scope-digest-drift" \
    "direct-target-without-contract"; do
    case "$id" in
      unsafe-provenance-or-license)
        write_intake_unit "$fixture_root" "$id" "unverified" "no"
        ;;
      secret-or-private-data)
        write_intake_unit "$fixture_root" "$id" "declared" "yes"
        ;;
      *)
        write_intake_unit "$fixture_root" "$id" "declared" "no"
        ;;
    esac
  done
}

case_accepts_valid_fixture_matrix() {
  local fixture_root
  fixture_root="$(create_fixture_repo)"
  run_routing_validator "$fixture_root" --require-synthetic-intakes
}

case_missing_required_fixture_fails() {
  local fixture_root
  fixture_root="$(create_fixture_repo)"
  yq -i 'del(.fixtures[] | select(.fixture_id == "malicious-authority-confusion"))' "$(spec_path "$fixture_root")"
  ! run_routing_validator "$fixture_root" --require-synthetic-intakes
}

case_route_mismatch_fails() {
  local fixture_root
  fixture_root="$(create_fixture_repo)"
  yq -i '(.fixtures[] | select(.fixture_id == "simple-core-skill-single-unit") | .expected_route) = "coordinated-program-handoff"' "$(spec_path "$fixture_root")"
  ! run_routing_validator "$fixture_root" --require-synthetic-intakes
}

case_direct_target_contract_claim_fails() {
  local fixture_root
  fixture_root="$(create_fixture_repo)"
  yq -i '(.fixtures[] | select(.fixture_id == "direct-target-without-contract") | .classification_signals.target_owned_intake_contract) = "present"' "$(spec_path "$fixture_root")"
  ! run_routing_validator "$fixture_root" --require-synthetic-intakes
}

case_missing_forbidden_handoff_authorization_fails() {
  local fixture_root
  fixture_root="$(create_fixture_repo)"
  yq -i '(.fixtures[] | select(.fixture_id == "simple-extension-pack-single-unit") | .authority_boundary.forbidden_transfer) |= map(select(. != "repo-hygiene-deletion"))' "$(spec_path "$fixture_root")"
  ! run_routing_validator "$fixture_root" --require-synthetic-intakes
}

case_parent_program_receipt_substitution_fails() {
  local fixture_root
  fixture_root="$(create_fixture_repo)"
  yq -i '(.fixtures[] | select(.fixture_id == "multi-skill-program") | .program_receipt_boundary.parent_program_evidence_satisfies_child_receipts) = true' "$(spec_path "$fixture_root")"
  ! run_routing_validator "$fixture_root" --require-synthetic-intakes
}

case_missing_raw_authority_negative_control_fails() {
  local fixture_root
  fixture_root="$(create_fixture_repo)"
  yq -i '(.required_negative_controls) |= map(select(. != "raw-intake-as-authority"))' "$(spec_path "$fixture_root")"
  ! run_routing_validator "$fixture_root" --require-synthetic-intakes
}

case_missing_packet_admission_contract_fails() {
  local fixture_root
  fixture_root="$(create_fixture_repo)"
  rm -f "$fixture_root/.octon/inputs/additive/extensions/octon-proposal-lifecycle/context/intake-admission/proposal-packet-intake-admission.contract.yml"
  ! run_routing_validator "$fixture_root" --require-synthetic-intakes
}

case_weakened_target_admission_boundary_fails() {
  local fixture_root contract
  fixture_root="$(create_fixture_repo)"
  contract="$fixture_root/.octon/inputs/additive/extensions/octon-proposal-lifecycle/context/intake-admission/proposal-packet-intake-admission.contract.yml"
  yq -i '(.authority_boundary.forbidden_transfer) |= map(select(. != "worktree-cleanup-authorization"))' "$contract"
  ! run_routing_validator "$fixture_root" --require-synthetic-intakes
}

case_missing_blocked_denial_evidence_fails() {
  local fixture_root
  fixture_root="$(create_fixture_repo)"
  yq -i '(.fixtures[] | select(.fixture_id == "unsafe-provenance-or-license") | .denial_evidence) = []' "$(spec_path "$fixture_root")"
  ! run_routing_validator "$fixture_root" --require-synthetic-intakes
}

case_missing_stale_return_denial_evidence_fails() {
  local fixture_root
  fixture_root="$(create_fixture_repo)"
  yq -i '(.fixtures[] | select(.fixture_id == "stale-target-return") | .denial_evidence) |= map(select(. != "target-return-digest-mismatch"))' "$(spec_path "$fixture_root")"
  ! run_routing_validator "$fixture_root" --require-synthetic-intakes
}

case_missing_malicious_denied_claim_fails() {
  local fixture_root
  fixture_root="$(create_fixture_repo)"
  yq -i '(.fixtures[] | select(.fixture_id == "malicious-authority-confusion") | .denied_authority_claims) |= map(select(. != "generated-output-as-authority"))' "$(spec_path "$fixture_root")"
  ! run_routing_validator "$fixture_root" --require-synthetic-intakes
}

case_envelope_must_fail_before_classification() {
  local fixture_root intake
  fixture_root="$(create_fixture_repo)"
  intake="$fixture_root/.octon/inputs/additive/.incoming/octon-rust-skill-pack-rust-source-authority"
  rm -f "$intake/.DS_Store" "$intake/intake-status.yml"
  ! run_routing_validator "$fixture_root" --require-synthetic-intakes
}

assert_success "accepts valid governed incoming intake routing fixture matrix" case_accepts_valid_fixture_matrix
assert_success "fails when required malicious authority fixture is missing" case_missing_required_fixture_fails
assert_success "fails when derived route does not match expected route" case_route_mismatch_fails
assert_success "fails when direct target claims a current target-owned contract" case_direct_target_contract_claim_fails
assert_success "fails when advisory handoff authorization boundary is weakened" case_missing_forbidden_handoff_authorization_fails
assert_success "fails when parent program evidence can satisfy child packet receipts" case_parent_program_receipt_substitution_fails
assert_success "fails when raw intake authority negative control is missing" case_missing_raw_authority_negative_control_fails
assert_success "fails when proposal packet admission contract is missing" case_missing_packet_admission_contract_fails
assert_success "fails when target admission authority boundary is weakened" case_weakened_target_admission_boundary_fails
assert_success "fails when blocked route denial evidence is missing" case_missing_blocked_denial_evidence_fails
assert_success "fails when stale target return denial evidence is missing" case_missing_stale_return_denial_evidence_fails
assert_success "fails when malicious authority-confusion denied claim is missing" case_missing_malicious_denied_claim_fails
assert_success "fails when observed invalid envelope unexpectedly passes validation" case_envelope_must_fail_before_classification

if [[ "$fail_count" -gt 0 ]]; then
  echo "$fail_count governed incoming intake routing validator tests failed" >&2
  exit 1
fi

echo "$pass_count governed incoming intake routing validator tests passed"
