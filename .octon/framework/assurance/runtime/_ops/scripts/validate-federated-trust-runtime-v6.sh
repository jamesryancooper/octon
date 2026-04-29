#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../../" && pwd)"
OCTON_DIR="${OCTON_DIR_OVERRIDE:-$DEFAULT_OCTON_DIR}"
ROOT_DIR="${OCTON_ROOT_DIR:-$(cd -- "$OCTON_DIR/.." && pwd)}"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --root)
      ROOT_DIR="$2"
      OCTON_DIR="${OCTON_DIR_OVERRIDE:-$ROOT_DIR/.octon}"
      shift 2
      ;;
    -h|--help)
      echo "Usage: validate-federated-trust-runtime-v6.sh [--root <repo-root>]"
      exit 0
      ;;
    *)
      echo "[ERROR] unknown argument: $1" >&2
      exit 2
      ;;
  esac
done

errors=0

fail() {
  echo "[ERROR] $1"
  errors=$((errors + 1))
}

pass() {
  echo "[OK] $1"
}

rel() {
  local path="$1"
  printf '%s\n' "${path#$ROOT_DIR/}"
}

require_file() {
  local file="$1"
  [[ -f "$file" ]] && pass "found $(rel "$file")" || fail "missing $(rel "$file")"
}

require_dir() {
  local dir="$1"
  [[ -d "$dir" ]] && pass "found $(rel "$dir")" || fail "missing $(rel "$dir")"
}

require_grep() {
  local pattern="$1"
  local file="$2"
  local label="$3"
  grep -q -- "$pattern" "$file" && pass "$label" || fail "$label"
}

require_proof_digest_refs_verified() {
  local proof="$1"
  local label="$2"
  if python3 - "$ROOT_DIR" "$proof" <<'PY' >/dev/null 2>&1
import hashlib
import os
import sys

import yaml

root, proof_path = sys.argv[1], sys.argv[2]
with open(proof_path, "r", encoding="utf-8") as fh:
    proof = yaml.safe_load(fh)

if proof.get("freshness_status") != "fresh":
    raise SystemExit("proof freshness_status is not fresh")
if proof.get("revocation_status") != "unrevoked":
    raise SystemExit("proof revocation_status is not unrevoked")
if proof.get("digest_verification") != "verified":
    raise SystemExit("proof digest_verification is not verified")

root_real = os.path.realpath(root)

def resolve_repo_file(rel, kind):
    if not isinstance(rel, str) or not rel:
        raise SystemExit(f"{kind} path is required")
    normalized = rel.replace("\\", "/")
    if os.path.isabs(rel) or ".." in normalized.split("/"):
        raise SystemExit(f"{kind} escapes repo scope: {rel}")
    if not normalized.startswith(".octon/"):
        raise SystemExit(f"{kind} is outside .octon: {rel}")
    if normalized.startswith(".octon/inputs/") or normalized.startswith(".octon/generated/"):
        raise SystemExit(f"{kind} is outside proof-verifiable authority/control/evidence scope: {rel}")
    path = os.path.realpath(os.path.join(root, rel))
    if not path.startswith(root_real + os.sep):
        raise SystemExit(f"{kind} resolves outside repo: {rel}")
    if not os.path.isfile(path):
        raise SystemExit(f"{kind} is missing or unreadable: {rel}")
    return path

digests = proof.get("evidence_digests")
if not isinstance(digests, list) or not digests:
    raise SystemExit("evidence_digests must be a non-empty list")
for item in digests:
    if item.get("digest_algorithm") != "sha256":
        raise SystemExit("evidence digest algorithm must be sha256")
    path = resolve_repo_file(item.get("path"), "evidence digest")
    with open(path, "rb") as fh:
        actual = hashlib.sha256(fh.read()).hexdigest()
    if actual != item.get("digest"):
        raise SystemExit(f"digest mismatch for {item.get('path')}")

refs = proof.get("revocation_refs")
if not isinstance(refs, list) or not refs:
    raise SystemExit("revocation_refs must be a non-empty list")
for ref in refs:
    path = resolve_repo_file(ref, "revocation ref")
    with open(path, "r", encoding="utf-8") as fh:
        revocation = yaml.safe_load(fh)
    schema = revocation.get("schema_version")
    if schema not in {"proof-revocation-v1", "trust-revocation-v1"}:
        raise SystemExit(f"unknown revocation schema for {ref}")
    if revocation.get("route_on_match") != "deny" or revocation.get("fail_closed") is not True:
        raise SystemExit(f"revocation ref does not fail closed: {ref}")
    if schema == "proof-revocation-v1" and revocation.get("status") in {"revoked", "expired", "stale"}:
        subject_ref = revocation.get("subject_ref")
        subject_kind = revocation.get("subject_kind")
        candidates = {
            proof.get("bundle_id"),
            f".octon/state/control/trust/proof-bundles/{proof.get('bundle_id')}.yml",
            f".octon/state/control/trust/local-acceptance/acceptance-{proof.get('bundle_id')}.yml",
        }
        if subject_kind in {"portable_proof_bundle", "local_acceptance"} and subject_ref in candidates:
            raise SystemExit(f"proof revocation matches bundle: {ref}")
PY
  then
    pass "$label digest and revocation refs verify fail-closed"
  else
    fail "$label digest and revocation refs must verify fail-closed"
  fi
}

require_json_schema() {
  local file="$1"
  local label="$2"
  require_file "$file"
  [[ -f "$file" ]] || return 0
  jq -e 'type == "object" and has("$schema") and has("$id") and has("title") and (has("type") or has("allOf") or has("anyOf") or has("oneOf"))' "$file" >/dev/null 2>&1 \
    && pass "$label is a JSON Schema" \
    || fail "$label must be a JSON Schema"
}

require_schema_valid() {
  local file="$1"
  local schema="$2"
  local label="$3"
  [[ -f "$file" && -f "$schema" ]] || return 0
  if python3 - "$file" "$schema" <<'PY' >/dev/null 2>&1
import json
import sys

import jsonschema
import yaml

data_path, schema_path = sys.argv[1], sys.argv[2]
with open(data_path, "r", encoding="utf-8") as fh:
    data = yaml.safe_load(fh)
with open(schema_path, "r", encoding="utf-8") as fh:
    schema = json.load(fh)
jsonschema.Draft202012Validator.check_schema(schema)
jsonschema.Draft202012Validator(schema).validate(data)
PY
  then
    pass "$label validates against schema"
  else
    fail "$label must validate against $(rel "$schema")"
  fi
}

require_yaml_schema() {
  local file="$1"
  local schema="$2"
  require_file "$file"
  [[ -f "$file" ]] || return 0
  yq -e '.' "$file" >/dev/null 2>&1 || {
    fail "$(rel "$file") must parse as YAML"
    return 0
  }
  [[ "$(yq -r '.schema_version // ""' "$file")" == "$schema" ]] \
    && pass "$(rel "$file") schema_version is $schema" \
    || fail "$(rel "$file") schema_version must be $schema"
}

require_yq() {
  local file="$1"
  local expr="$2"
  local label="$3"
  yq -e "$expr" "$file" >/dev/null 2>&1 && pass "$label" || fail "$label"
}

require_jq() {
  local file="$1"
  local expr="$2"
  local label="$3"
  jq -e "$expr" "$file" >/dev/null 2>&1 && pass "$label" || fail "$label"
}

check_tools() {
  command -v yq >/dev/null 2>&1 || fail "yq is required"
  command -v jq >/dev/null 2>&1 || fail "jq is required"
  command -v python3 >/dev/null 2>&1 || fail "python3 is required"
}

check_contracts() {
  echo "== v6 Contract Validation =="
  local schemas=(
    octon-compatibility-profile-v1
    external-project-compatibility-inspection-v1
    external-project-adoption-posture-v1
    trust-domain-v1
    trust-domain-hook-v1
    trust-registry-v1
    federation-compact-v1
    attestation-envelope-v1
    portable-proof-bundle-v1
    local-proof-acceptance-v1
    proof-acceptance-v1
    proof-revocation-v1
    delegated-authority-lease-v1
    cross-domain-decision-request-v1
    certification-profile-v1
    federation-ledger-v1
  )
  local schema
  for schema in "${schemas[@]}"; do
    require_json_schema "$OCTON_DIR/framework/engine/runtime/spec/${schema}.schema.json" "$schema runtime schema"
  done

  require_jq "$OCTON_DIR/framework/engine/runtime/spec/octon-compatibility-profile-v1.schema.json" '.properties.participation_tier.enum | index("external_evidence_source") and index("octon_compatible_emitter") and index("octon_mediated_connector") and index("octon_enabled_repo") and index("octon_federation_peer")' "compatibility schema enumerates all v6 participation tiers"
  require_jq "$OCTON_DIR/framework/engine/runtime/spec/federation-compact-v1.schema.json" '.additionalProperties == false and (.required | index("status") and index("approval_authority_ref") and index("recertification_due_at") and index("compact_widens_support_claims") and index("compact_mutates_local_authority")) and (.properties.accepted_proof_types.minItems == 1) and (.properties.local_approval_refs.minItems == 1)' "compact schema is lifecycle-bound and fail-closed"
  require_jq "$OCTON_DIR/framework/engine/runtime/spec/attestation-envelope-v1.schema.json" '.additionalProperties == false and (.required | index("verification_status") and index("freshness_status") and index("revocation_status") and index("local_acceptance_evidence_refs") and index("consumer_verification_requirements") and index("attestation_replaces_local_authority") and index("attestation_widens_support_claims"))' "attestation schema requires verification, revocation, and non-authority fields"
  require_jq "$OCTON_DIR/framework/engine/runtime/spec/portable-proof-bundle-v1.schema.json" '.additionalProperties == false and (.required | index("import_export_controls") and index("consumer_verification_requirements") and index("verification_status") and index("freshness_status") and index("revocation_status") and index("digest_verification") and index("proof_bundle_replaces_run_evidence") and index("proof_bundle_widens_support_claims"))' "proof bundle schema models import/export and acceptance controls"
  require_jq "$OCTON_DIR/framework/engine/runtime/spec/delegated-authority-lease-v1.schema.json" '.additionalProperties == false and (.required | index("status") and index("support_target_ref") and index("capability_pack_registry_ref") and index("revocation_authority_refs") and index("lease_consumption_route") and index("run_contract_bypass_allowed") and index("execution_authorization_bypass_allowed"))' "delegated lease schema requires lifecycle, support, capability, and bypass-denial fields"
  require_jq "$OCTON_DIR/framework/engine/runtime/spec/certification-profile-v1.schema.json" '.properties.certification_class.enum | index("connector-read-only") and index("connector-live-effectful") and index("release-staging") and index("release-production") and index("cross-repo-migration") and index("auditor-verifiable-run") and index("support-target-live-claim")' "certification schema enumerates MVP classes"

  require_file "$OCTON_DIR/framework/orchestration/practices/octon-adoption-standards.md"
  require_file "$OCTON_DIR/framework/orchestration/practices/portable-proof-interop-standards.md"
  require_file "$OCTON_DIR/framework/orchestration/practices/federation-lifecycle-standards.md"
  require_yq "$OCTON_DIR/framework/constitution/contracts/registry.yml" '.integration_surfaces.octon_compatibility_and_federated_trust_runtime_v6_contracts.rule | test("federates proof, not authority")' "constitutional registry captures v6 durable rule"
  require_yq "$OCTON_DIR/framework/cognition/_meta/architecture/contract-registry.yml" '.path_families.octon_compatibility_and_federated_trust_runtime_v6.forbidden_consumers[] | select(. == "external attestations as execution authorization")' "architecture registry forbids external attestation authorization"
  require_yq "$OCTON_DIR/framework/constitution/obligations/fail-closed.yml" '.rules[] | select(.id == "FCR-037" and .route == "DENY")' "fail-closed obligations deny invalid trust artifacts"
  require_yq "$OCTON_DIR/framework/constitution/obligations/fail-closed.yml" '.rules[] | select(.id == "FCR-038" and .route == "DENY")' "fail-closed obligations deny external execution authority"
  require_yq "$OCTON_DIR/framework/constitution/obligations/evidence.yml" '.retained_evidence_roots[] | select(. == ".octon/state/evidence/trust/**")' "trust evidence root is retained"
  require_yq "$OCTON_DIR/framework/constitution/obligations/evidence.yml" '.obligations[] | select(.id == "EVI-033")' "trust evidence obligation exists"
}

check_roots_and_authority() {
  echo "== v6 Root Placement and Authority Validation =="
  require_dir "$OCTON_DIR/instance/governance/trust"
  require_dir "$OCTON_DIR/state/control/trust"
  require_dir "$OCTON_DIR/state/evidence/trust"
  require_dir "$OCTON_DIR/state/continuity/trust"
  require_dir "$OCTON_DIR/generated/cognition/projections/materialized/trust"

  require_yaml_schema "$OCTON_DIR/instance/governance/trust/compatibility-profile.yml" "octon-compatibility-profile-set-v1"
  require_yq "$OCTON_DIR/instance/governance/trust/compatibility-profile.yml" '([.profiles[].participation_tier] | unique | length) == 5' "compatibility profile set covers five participation tiers"
  require_yq "$OCTON_DIR/instance/governance/trust/compatibility-profile.yml" '[(.profiles[] | select(.external_artifacts_authorize_execution != false or .non_octon_system_can_be_federation_peer != false))] | length == 0' "compatibility profiles do not mint external authority"

  require_yaml_schema "$OCTON_DIR/instance/governance/trust/policies/external-project-adoption.yml" "external-project-adoption-policy-v1"
  require_yq "$OCTON_DIR/instance/governance/trust/policies/external-project-adoption.yml" '.blind_copy_full_octon_allowed == false and .generated_rebuild_required == true and (.forbidden_adoption_shortcuts[] | select(. == "blind full .octon copy from another project"))' "adoption policy blocks blind full-state copy"
  require_yaml_schema "$OCTON_DIR/state/evidence/trust/external-project-adoption/adoption-octon-v6-policy/preflight.yml" "external-project-adoption-preflight-v1"
  require_yq "$OCTON_DIR/state/evidence/trust/external-project-adoption/adoption-octon-v6-policy/preflight.yml" '.blind_copy_full_octon_allowed == false and .state_copy_as_authority_allowed == false and .generated_rebuild_required == true' "adoption preflight is fail-closed"

  require_schema_valid "$OCTON_DIR/state/control/trust/external-projects/octon-local/inspection.yml" "$OCTON_DIR/framework/engine/runtime/spec/external-project-compatibility-inspection-v1.schema.json" "External Project Compatibility Inspection"
  require_schema_valid "$OCTON_DIR/state/control/trust/external-projects/octon-local/adoption-status.yml" "$OCTON_DIR/framework/engine/runtime/spec/external-project-adoption-posture-v1.schema.json" "External Project Adoption Posture"
  require_schema_valid "$OCTON_DIR/state/control/trust/local-acceptance/acceptance-proof-octon-v6-mvp.yml" "$OCTON_DIR/framework/engine/runtime/spec/local-proof-acceptance-v1.schema.json" "Local Proof Acceptance"
  require_schema_valid "$OCTON_DIR/state/control/trust/revocations/revocation-proof-octon-v6-interop.yml" "$OCTON_DIR/framework/engine/runtime/spec/proof-revocation-v1.schema.json" "Proof Revocation"
  require_yq "$OCTON_DIR/instance/governance/trust/trust-domain-hooks.yml" '.registry_runtime_deferred == true and .federation_runtime_deferred == true and .external_registry_is_authority == false and .hooks[0].hook_authorizes_execution == false' "trust-domain hook is deferred and non-authoritative"

  require_yaml_schema "$OCTON_DIR/instance/governance/trust/registry.yml" "trust-registry-v1"
  require_schema_valid "$OCTON_DIR/instance/governance/trust/registry.yml" "$OCTON_DIR/framework/engine/runtime/spec/trust-registry-v1.schema.json" "Trust Registry"
  require_yq "$OCTON_DIR/instance/governance/trust/registry.yml" '.local_registry_is_authority == true and .external_registry_is_authority == false and .unregistered_domain_route == "deny"' "Trust Registry is local authority and denies unregistered domains"
  require_yq "$OCTON_DIR/instance/governance/trust/registry.yml" '(.accepted_proof_formats[] | select(. == "portable-proof-bundle-v1")) and (.accepted_proof_formats[] | select(. == "attestation-envelope-v1"))' "Trust Registry accepts MVP proof formats"

  local domain_ref
  while IFS= read -r domain_ref; do
    [[ -f "$ROOT_DIR/$domain_ref" ]] && pass "registered domain resolves: $domain_ref" || fail "registered domain missing: $domain_ref"
  done < <(yq -r '.accepted_domains[].domain_ref' "$OCTON_DIR/instance/governance/trust/registry.yml")
}

check_trust_artifacts() {
  echo "== v6 Trust Artifact Validation =="
  local compact="$OCTON_DIR/instance/governance/trust/federation-compacts/octon-local-reference-stage-only.yml"
  local attestation="$OCTON_DIR/state/control/trust/attestations/attestation-octon-v6-mvp.yml"
  local proof="$OCTON_DIR/state/control/trust/proof-bundles/proof-octon-v6-mvp.yml"
  local lease="$OCTON_DIR/state/control/trust/delegated-leases/lease-octon-v6-stage-only.yml"
  local decision="$OCTON_DIR/state/control/trust/cross-domain-decisions/decision-octon-v6-proof-acceptance.yml"
  local certification="$OCTON_DIR/state/control/trust/certifications/cert-octon-v6-auditor-verifiable-run.yml"
  local ledger="$OCTON_DIR/state/control/trust/ledger.yml"

  require_yaml_schema "$compact" "federation-compact-v1"
  require_schema_valid "$compact" "$OCTON_DIR/framework/engine/runtime/spec/federation-compact-v1.schema.json" "Federation Compact"
  require_yq "$compact" '.status == "stage_only" and .compact_authorizes_execution == false and .compact_overrides_local_authority == false and .compact_widens_support_claims == false and .compact_mutates_local_authority == false and (.local_approval_refs | length >= 1)' "compact coordinates trust only"

  require_yaml_schema "$attestation" "attestation-envelope-v1"
  require_schema_valid "$attestation" "$OCTON_DIR/framework/engine/runtime/spec/attestation-envelope-v1.schema.json" "Attestation Envelope"
  require_yq "$attestation" '.local_acceptance == "accepted" and .verification_status == "verified" and .freshness_status == "fresh" and .revocation_status == "unrevoked" and .attestation_authorizes_execution == false and .attestation_replaces_local_authority == false and .attestation_widens_support_claims == false' "attestation acceptance is verified evidence only"

  require_yaml_schema "$proof" "portable-proof-bundle-v1"
  require_schema_valid "$proof" "$OCTON_DIR/framework/engine/runtime/spec/portable-proof-bundle-v1.schema.json" "Portable Proof Bundle"
  require_yq "$proof" '.local_acceptance == "accepted" and .verification_status == "verified" and .freshness_status == "fresh" and .revocation_status == "unrevoked" and .digest_verification == "verified" and .proof_bundle_authorizes_execution == false and .proof_bundle_replaces_run_evidence == false and .proof_bundle_widens_support_claims == false' "proof bundle acceptance is verified evidence only"
  require_proof_digest_refs_verified "$proof" "Portable Proof Bundle"
  require_yq "$proof" '[(.validation_results[] | select(.result == "pending-current-run"))] | length == 0' "accepted proof has completed validation results"
  require_yq "$proof" '.import_export_controls.disclosure_boundary != null and (.consumer_verification_requirements | length >= 1)' "proof import/export posture is explicit"

  require_yaml_schema "$lease" "delegated-authority-lease-v1"
  require_schema_valid "$lease" "$OCTON_DIR/framework/engine/runtime/spec/delegated-authority-lease-v1.schema.json" "Delegated Authority Lease"
  require_yq "$lease" '.status == "stage_only" and .lease_consumption_route == "local-authorization-input-only" and .lease_authorizes_execution == false and .permanent_authority == false and .run_contract_bypass_allowed == false and .execution_authorization_bypass_allowed == false and .support_claim_widening_allowed == false and .capability_widening_allowed == false' "delegated lease is scoped local-authorization input only"
  require_yq "$lease" '.expires_at != null and (.revocation_conditions | length >= 1) and (.revocation_authority_refs | length >= 1)' "delegated lease has expiry and revocation behavior"

  require_yaml_schema "$decision" "cross-domain-decision-request-v1"
  require_schema_valid "$decision" "$OCTON_DIR/framework/engine/runtime/spec/cross-domain-decision-request-v1.schema.json" "Cross-Domain Decision Request"
  require_yq "$decision" '.host_state_is_authority == false and .external_approval_is_local_authority == false and .decision_authorizes_execution == false' "cross-domain decision preserves local authority"

  require_yaml_schema "$certification" "trust-certification-status-v1"
  require_yq "$certification" '.certification_authorizes_execution == false and .certification_widens_support_claims == false' "certification result cannot authorize execution or widen support"
  require_schema_valid "$OCTON_DIR/instance/governance/trust/certification-profiles/auditor-verifiable-run.yml" "$OCTON_DIR/framework/engine/runtime/spec/certification-profile-v1.schema.json" "Auditor certification profile"
  require_schema_valid "$OCTON_DIR/instance/governance/trust/certification-profiles/support-target-live-claim.yml" "$OCTON_DIR/framework/engine/runtime/spec/certification-profile-v1.schema.json" "Support-target certification profile"

  require_yaml_schema "$ledger" "federation-ledger-v1"
  require_schema_valid "$ledger" "$OCTON_DIR/framework/engine/runtime/spec/federation-ledger-v1.schema.json" "Federation Ledger"
  require_yq "$ledger" '.ledger_replaces_source_evidence == false and .ledger_authorizes_execution == false and (.trust_domains | length >= 1) and (.compacts | length >= 1) and (.attestations | length >= 1) and (.proof_bundles | length >= 1) and (.delegated_leases | length >= 1) and (.cross_domain_decisions | length >= 1) and (.certifications | length >= 1) and (.revocations | length >= 1) and (.recertifications | length >= 1)' "ledger is an index, not control or evidence replacement"
}

check_generated_and_runtime() {
  echo "== v6 Generated and Runtime Boundary Validation =="
  local generated
  for generated in "$OCTON_DIR"/generated/cognition/projections/materialized/trust/*.yml; do
    require_yq "$generated" '.authority == "non-authoritative" and .generated_projection_authorizes_execution == false' "$(rel "$generated") is non-authoritative"
  done
  require_yq "$OCTON_DIR/instance/governance/non-authority-register.yml" '.entries[] | select(.surface_id == "trust-operator-read-models" and .authority_mode == "derived-non-authority")' "trust generated views are registered non-authority"
  require_yq "$OCTON_DIR/octon.yml" '.resolution.runtime_inputs.trust_registry == ".octon/instance/governance/trust/registry.yml" and .resolution.runtime_inputs.trust_control_root == ".octon/state/control/trust" and .resolution.runtime_inputs.trust_evidence_root == ".octon/state/evidence/trust"' "root manifest declares trust runtime inputs"

  local main="$OCTON_DIR/framework/engine/runtime/crates/kernel/src/main.rs"
  local trust_rs="$OCTON_DIR/framework/engine/runtime/crates/kernel/src/commands/trust.rs"
  require_grep 'Adopt(AdoptCmd)' "$main" "CLI includes octon adopt"
  require_grep 'Compatibility' "$main" "CLI includes compatibility command group"
  require_grep 'TrustProofCmd' "$main" "CLI includes proof command group"
  require_grep 'AttestCmd' "$main" "CLI includes attestation command group"
  require_grep 'DelegateLeaseCmd' "$main" "CLI includes delegated lease command group"
  require_grep 'FederationCmd' "$main" "CLI includes federation command group"
  require_grep 'fn proof_import' "$trust_rs" "runtime implements proof import"
  require_grep 'fn attest_accept_or_reject' "$trust_rs" "runtime implements attestation accept/reject"
  require_grep 'material_execution_authorized.: false' "$trust_rs" "adoption runtime records no material execution authorization"

  if grep -R --exclude-dir=target --exclude-dir=.tmp -n '.octon/inputs/exploratory/proposals/' \
    "$OCTON_DIR/framework/orchestration/practices/octon-adoption-standards.md" \
    "$OCTON_DIR/framework/orchestration/practices/portable-proof-interop-standards.md" \
    "$OCTON_DIR/framework/orchestration/practices/federated-proof-interop-standards.md" \
    "$OCTON_DIR/framework/orchestration/practices/federation-lifecycle-standards.md" \
    "$OCTON_DIR/instance/governance/trust" \
    "$OCTON_DIR/state/control/trust" \
    "$OCTON_DIR/generated/cognition/projections/materialized/trust" >/tmp/octon-v6-proposal-deps.$$ 2>/dev/null; then
    fail "selected v6 runtime, policy, control, or generated trust surfaces must not depend on proposal packet paths"
    cat /tmp/octon-v6-proposal-deps.$$
  else
    pass "no durable dependency on v6 proposal packet path"
  fi
  rm -f /tmp/octon-v6-proposal-deps.$$
}

check_tools
check_contracts
check_roots_and_authority
check_trust_artifacts
check_generated_and_runtime

if (( errors > 0 )); then
  echo "[FAIL] Federated Trust Runtime v6 validation failed with $errors error(s)."
  exit 1
fi

echo "[OK] Federated Trust Runtime v6 validation passed."
