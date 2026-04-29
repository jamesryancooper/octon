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
      echo "Usage: validate-compatibility-proof-interop-v6.sh [--root <repo-root>]"
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

require_json_schema() {
  local file="$1"
  local label="$2"
  require_file "$file"
  [[ -f "$file" ]] || return 0
  jq -e 'type == "object" and has("$schema") and has("$id") and has("title") and has("type")' "$file" >/dev/null 2>&1 \
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

check_tools() {
  command -v yq >/dev/null 2>&1 || fail "yq is required"
  command -v jq >/dev/null 2>&1 || fail "jq is required"
  command -v python3 >/dev/null 2>&1 || fail "python3 is required"
}

check_contracts() {
  echo "== Compatibility / Proof Interop Contracts =="
  local schemas=(
    octon-compatibility-profile-v1
    external-project-compatibility-inspection-v1
    external-project-adoption-posture-v1
    portable-proof-bundle-v1
    attestation-envelope-v1
    local-proof-acceptance-v1
    proof-acceptance-v1
    proof-revocation-v1
    trust-domain-hook-v1
  )
  local schema
  for schema in "${schemas[@]}"; do
    require_json_schema "$OCTON_DIR/framework/engine/runtime/spec/${schema}.schema.json" "$schema"
  done
  require_file "$OCTON_DIR/framework/engine/runtime/spec/external-project-adoption-v1.md"
  require_file "$OCTON_DIR/framework/orchestration/practices/octon-adoption-standards.md"
  require_file "$OCTON_DIR/framework/orchestration/practices/portable-proof-interop-standards.md"
  require_file "$OCTON_DIR/framework/orchestration/practices/federated-proof-interop-standards.md"

  require_jq "$OCTON_DIR/framework/engine/runtime/spec/octon-compatibility-profile-v1.schema.json" '.properties.participation_tier.enum | index("external_evidence_source") and index("octon_compatible_emitter") and index("octon_mediated_connector") and index("octon_enabled_repo") and index("octon_federation_peer")' "compatibility schema enumerates selected v6 tiers"
  require_jq "$OCTON_DIR/framework/engine/runtime/spec/external-project-compatibility-inspection-v1.schema.json" '.properties.detected_state.enum | index("no_octon") and index("partial_octon") and index("stale_octon") and index("conflicting_octon") and index("octon_shaped_emitter") and index("connector_only_external_system") and index("octon_enabled_repo") and index("federation_ready_peer")' "inspection schema distinguishes external project states"
  require_jq "$OCTON_DIR/framework/engine/runtime/spec/local-proof-acceptance-v1.schema.json" '.properties.acceptance_state.enum | index("accepted_as_evidence") and index("accepted_with_limitations") and index("rejected") and index("expired") and index("revoked") and index("stale") and index("untrusted") and index("scope_mismatch") and index("schema_invalid") and index("decision_gated")' "local acceptance schema covers accepted/rejected/revoked/stale states"
  require_jq "$OCTON_DIR/framework/engine/runtime/spec/proof-revocation-v1.schema.json" '.properties.route_on_match.const == "deny" and .properties.fail_closed.const == true' "proof revocation schema fails closed"
}

check_authority_and_state() {
  echo "== Compatibility / Proof Interop Authority and State =="
  require_yq "$OCTON_DIR/instance/governance/trust/compatibility-profile.yml" '([.profiles[].participation_tier] | unique | length) == 5' "local compatibility profile covers five tiers"
  require_yq "$OCTON_DIR/instance/governance/trust/compatibility-profile.yml" '[(.profiles[] | select(.external_artifacts_authorize_execution != false or .non_octon_system_can_be_federation_peer != false))] | length == 0' "compatibility profiles cannot mint authority"
  require_yq "$OCTON_DIR/instance/governance/trust/policies/external-project-adoption.yml" '.blind_copy_full_octon_allowed == false and .generated_rebuild_required == true and .repo_specific_instance_authority_required == true and .support_target_admission_required == true' "safe adoption policy blocks blind copy and requires local authority"
  require_yq "$OCTON_DIR/instance/governance/trust/policies/proof-bundle-acceptance.yml" '.non_authority_rules.proof_bundle_authorizes_execution == false and .revocation_and_expiry.route_on_revoked == "deny" and .revocation_and_expiry.route_on_expired == "deny"' "proof acceptance policy is evidence-only and revocable"
  require_yq "$OCTON_DIR/instance/governance/trust/policies/attestation-acceptance.yml" '.non_authority_rules.attestation_authorizes_execution == false and .revocation_and_expiry.route_on_revoked == "deny" and .revocation_and_expiry.route_on_expired == "deny"' "attestation acceptance policy is evidence-only and revocable"
  require_yq "$OCTON_DIR/instance/governance/trust/policies/proof-redaction.yml" '.redaction_required_for_export == true and .exported_secret_material_allowed == false' "proof redaction policy blocks secret export"
  require_yq "$OCTON_DIR/instance/governance/trust/trust-domain-hooks.yml" '.registry_runtime_deferred == true and .federation_runtime_deferred == true and .external_registry_is_authority == false and .hooks[0].hook_authorizes_execution == false' "trust-domain hook is deferred and non-authoritative"

  require_schema_valid "$OCTON_DIR/state/control/trust/external-projects/octon-local/inspection.yml" "$OCTON_DIR/framework/engine/runtime/spec/external-project-compatibility-inspection-v1.schema.json" "external project inspection"
  require_schema_valid "$OCTON_DIR/state/control/trust/external-projects/octon-local/adoption-status.yml" "$OCTON_DIR/framework/engine/runtime/spec/external-project-adoption-posture-v1.schema.json" "external project adoption posture"
  require_schema_valid "$OCTON_DIR/state/control/trust/local-acceptance/acceptance-proof-octon-v6-mvp.yml" "$OCTON_DIR/framework/engine/runtime/spec/local-proof-acceptance-v1.schema.json" "proof local acceptance"
  require_schema_valid "$OCTON_DIR/state/control/trust/local-acceptance/acceptance-attestation-octon-v6-mvp.yml" "$OCTON_DIR/framework/engine/runtime/spec/local-proof-acceptance-v1.schema.json" "attestation local acceptance"
  require_schema_valid "$OCTON_DIR/state/control/trust/revocations/revocation-proof-octon-v6-interop.yml" "$OCTON_DIR/framework/engine/runtime/spec/proof-revocation-v1.schema.json" "proof revocation hook"
  require_schema_valid "$OCTON_DIR/state/control/trust/proof-bundles/proof-octon-v6-mvp.yml" "$OCTON_DIR/framework/engine/runtime/spec/portable-proof-bundle-v1.schema.json" "portable proof bundle"
  require_schema_valid "$OCTON_DIR/state/control/trust/attestations/attestation-octon-v6-mvp.yml" "$OCTON_DIR/framework/engine/runtime/spec/attestation-envelope-v1.schema.json" "attestation envelope"
  require_proof_digest_refs_verified "$OCTON_DIR/state/control/trust/proof-bundles/proof-octon-v6-mvp.yml" "portable proof bundle"

  require_yq "$OCTON_DIR/state/control/trust/local-acceptance/acceptance-proof-octon-v6-mvp.yml" '.acceptance_state == "accepted_as_evidence" and .local_acceptance_authorizes_execution == false and .local_acceptance_replaces_local_authority == false and .local_acceptance_widens_support_claims == false' "proof local acceptance remains evidence-only"
  require_yq "$OCTON_DIR/state/control/trust/revocations/revocation-proof-octon-v6-interop.yml" '.route_on_match == "deny" and .fail_closed == true and .revocation_authorizes_execution == false' "proof revocation fails closed"
}

check_generated_and_runtime() {
  echo "== Compatibility / Proof Interop Runtime Boundary =="
  local generated
  for generated in "$OCTON_DIR"/generated/cognition/projections/materialized/trust/*.yml; do
    require_yq "$generated" '.authority == "non-authoritative" and .generated_projection_authorizes_execution == false' "$(rel "$generated") is non-authoritative"
  done

  local main="$OCTON_DIR/framework/engine/runtime/crates/kernel/src/main.rs"
  local trust_rs="$OCTON_DIR/framework/engine/runtime/crates/kernel/src/commands/trust.rs"
  require_grep 'Status,' "$main" "CLI includes trust status"
  require_grep 'Verify(TrustProofPathCmd)' "$main" "CLI includes proof verify"
  require_grep 'Accept(TrustProofPathCmd)' "$main" "CLI includes proof accept"
  require_grep 'Reject(TrustProofPathCmd)' "$main" "CLI includes proof reject"
  require_grep 'Status(TrustProofStatusCmd)' "$main" "CLI includes proof status"
  require_grep 'Status(AttestationStatusCmd)' "$main" "CLI includes attestation status"
  require_grep 'fn proof_verify' "$trust_rs" "runtime implements proof verify"
  require_grep 'fn proof_accept_or_reject' "$trust_rs" "runtime implements proof accept/reject"
  require_grep 'fn write_local_acceptance' "$trust_rs" "runtime writes local acceptance records"
  require_grep 'fn trust_status' "$trust_rs" "runtime implements trust status hook"

  if grep -n '.octon/inputs/exploratory/proposals/' \
    "$OCTON_DIR/framework/engine/runtime/spec/octon-compatibility-profile-v1.schema.json" \
    "$OCTON_DIR/framework/engine/runtime/spec/external-project-compatibility-inspection-v1.schema.json" \
    "$OCTON_DIR/framework/engine/runtime/spec/external-project-adoption-posture-v1.schema.json" \
    "$OCTON_DIR/framework/engine/runtime/spec/portable-proof-bundle-v1.schema.json" \
    "$OCTON_DIR/framework/engine/runtime/spec/attestation-envelope-v1.schema.json" \
    "$OCTON_DIR/framework/engine/runtime/spec/local-proof-acceptance-v1.schema.json" \
    "$OCTON_DIR/framework/engine/runtime/spec/proof-acceptance-v1.schema.json" \
    "$OCTON_DIR/framework/engine/runtime/spec/proof-revocation-v1.schema.json" \
    "$OCTON_DIR/framework/engine/runtime/spec/trust-domain-hook-v1.schema.json" \
    "$OCTON_DIR/framework/orchestration/practices/octon-adoption-standards.md" \
    "$OCTON_DIR/framework/orchestration/practices/portable-proof-interop-standards.md" \
    "$OCTON_DIR/framework/orchestration/practices/federated-proof-interop-standards.md" \
    "$OCTON_DIR/instance/governance/trust/compatibility-profile.yml" \
    "$OCTON_DIR/instance/governance/trust/policies/proof-bundle-acceptance.yml" \
    "$OCTON_DIR/instance/governance/trust/policies/attestation-acceptance.yml" \
    "$OCTON_DIR/instance/governance/trust/policies/external-project-adoption.yml" \
    "$OCTON_DIR/instance/governance/trust/policies/proof-redaction.yml" \
    "$OCTON_DIR/instance/governance/trust/policies/proof-revocation.yml" \
    "$OCTON_DIR/instance/governance/trust/trust-domain-hooks.yml" \
    "$OCTON_DIR/state/control/trust/external-projects/octon-local/inspection.yml" \
    "$OCTON_DIR/state/control/trust/external-projects/octon-local/adoption-status.yml" \
    "$OCTON_DIR/state/control/trust/local-acceptance/acceptance-proof-octon-v6-mvp.yml" \
    "$OCTON_DIR/state/control/trust/local-acceptance/acceptance-attestation-octon-v6-mvp.yml" \
    "$OCTON_DIR/state/control/trust/revocations/revocation-proof-octon-v6-interop.yml" \
    "$OCTON_DIR/generated/cognition/projections/materialized/trust/proof-review-status.yml" \
    >/tmp/octon-v6-interop-proposal-deps.$$ 2>/dev/null; then
    fail "selected v6 runtime, policy, control, or generated trust surfaces must not depend on proposal packet paths"
    cat /tmp/octon-v6-interop-proposal-deps.$$
  else
    pass "no runtime/policy/control/generated dependency on proposal packet paths"
  fi
  rm -f /tmp/octon-v6-interop-proposal-deps.$$
}

check_tools
check_contracts
check_authority_and_state
check_generated_and_runtime

if (( errors > 0 )); then
  echo "[FAIL] Compatibility Proof Interop v6 validation failed with $errors error(s)."
  exit 1
fi

echo "[OK] Compatibility Proof Interop v6 validation passed."
