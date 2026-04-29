#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
VALIDATOR="$SCRIPT_DIR/../scripts/validate-federated-trust-runtime-v6.sh"
ROOT_DIR="${OCTON_ROOT_DIR:-$(cd -- "$SCRIPT_DIR/../../../../../.." && pwd)}"

"$VALIDATOR" --root "$ROOT_DIR" "$@"

tmp="$(mktemp -d)"
trap 'rm -r -f "$tmp"' EXIT
cp -R "$ROOT_DIR/.octon" "$tmp/.octon"

expect_fail() {
  local label="$1"
  if "$VALIDATOR" --root "$tmp" >"$tmp/$label.out" 2>&1; then
    echo "[ERROR] validator accepted negative control: $label" >&2
    cat "$tmp/$label.out" >&2
    exit 1
  fi
  echo "[OK] negative control failed closed: $label"
}

registry="$tmp/.octon/instance/governance/trust/registry.yml"
generated="$tmp/.octon/generated/cognition/projections/materialized/trust/federation-status.yml"
proof="$tmp/.octon/state/control/trust/proof-bundles/proof-octon-v6-mvp.yml"
attestation="$tmp/.octon/state/control/trust/attestations/attestation-octon-v6-mvp.yml"
compact="$tmp/.octon/instance/governance/trust/federation-compacts/octon-local-reference-stage-only.yml"
lease="$tmp/.octon/state/control/trust/delegated-leases/lease-octon-v6-stage-only.yml"
decision="$tmp/.octon/state/control/trust/cross-domain-decisions/decision-octon-v6-proof-acceptance.yml"
certification="$tmp/.octon/state/control/trust/certifications/cert-octon-v6-auditor-verifiable-run.yml"
ledger="$tmp/.octon/state/control/trust/ledger.yml"
adoption="$tmp/.octon/instance/governance/trust/policies/external-project-adoption.yml"
framework_doc="$tmp/.octon/framework/orchestration/practices/federation-lifecycle-standards.md"

cp "$registry" "$tmp/registry.bak"
yq -i '.external_registry_is_authority = true' "$registry"
expect_fail "external-registry-authority"
cp "$tmp/registry.bak" "$registry"

cp "$registry" "$tmp/registry-unregistered.bak"
yq -i '.unregistered_domain_route = "allow"' "$registry"
expect_fail "unregistered-domain-allowed"
cp "$tmp/registry-unregistered.bak" "$registry"

cp "$generated" "$tmp/generated.bak"
yq -i '.authority = "authoritative"' "$generated"
expect_fail "generated-trust-view-authority"
cp "$tmp/generated.bak" "$generated"

cp "$proof" "$tmp/proof-authorizes.bak"
yq -i '.proof_bundle_authorizes_execution = true' "$proof"
expect_fail "proof-authorizes-execution"
cp "$tmp/proof-authorizes.bak" "$proof"

cp "$proof" "$tmp/proof-pending.bak"
yq -i '.validation_results[0].result = "pending-current-run"' "$proof"
expect_fail "accepted-proof-pending-validation"
cp "$tmp/proof-pending.bak" "$proof"

cp "$proof" "$tmp/proof-replaces.bak"
yq -i '.proof_bundle_replaces_run_evidence = true' "$proof"
expect_fail "proof-replaces-run-evidence"
cp "$tmp/proof-replaces.bak" "$proof"

cp "$proof" "$tmp/proof-missing-digest.bak"
yq -i '.evidence_digests[0].path = ".octon/state/evidence/trust/missing-digest.yml"' "$proof"
expect_fail "proof-missing-digest-path"
cp "$tmp/proof-missing-digest.bak" "$proof"

cp "$proof" "$tmp/proof-digest-mismatch.bak"
yq -i '.evidence_digests[0].digest = "0000000000000000000000000000000000000000000000000000000000000000"' "$proof"
expect_fail "proof-digest-mismatch"
cp "$tmp/proof-digest-mismatch.bak" "$proof"

cp "$proof" "$tmp/proof-digest-out-of-scope.bak"
yq -i '.evidence_digests[0].path = ".octon/generated/cognition/projections/materialized/trust/proof-review-status.yml"' "$proof"
expect_fail "proof-digest-out-of-scope"
cp "$tmp/proof-digest-out-of-scope.bak" "$proof"

cp "$proof" "$tmp/proof-stale.bak"
yq -i '.freshness_status = "stale"' "$proof"
expect_fail "proof-stale"
cp "$tmp/proof-stale.bak" "$proof"

cp "$attestation" "$tmp/attestation-authorizes.bak"
yq -i '.attestation_authorizes_execution = true' "$attestation"
expect_fail "attestation-authorizes-execution"
cp "$tmp/attestation-authorizes.bak" "$attestation"

cp "$attestation" "$tmp/attestation-revoked.bak"
yq -i '.revocation_status = "revoked"' "$attestation"
expect_fail "accepted-attestation-revoked"
cp "$tmp/attestation-revoked.bak" "$attestation"

cp "$compact" "$tmp/compact-override.bak"
yq -i '.compact_overrides_local_authority = true' "$compact"
expect_fail "compact-overrides-local-authority"
cp "$tmp/compact-override.bak" "$compact"

cp "$compact" "$tmp/compact-approval.bak"
yq -i '.local_approval_refs = []' "$compact"
expect_fail "compact-missing-local-approval"
cp "$tmp/compact-approval.bak" "$compact"

cp "$lease" "$tmp/lease-permanent.bak"
yq -i '.permanent_authority = true' "$lease"
expect_fail "lease-permanent-authority"
cp "$tmp/lease-permanent.bak" "$lease"

cp "$lease" "$tmp/lease-bypass.bak"
yq -i '.execution_authorization_bypass_allowed = true' "$lease"
expect_fail "lease-bypasses-execution-authorization"
cp "$tmp/lease-bypass.bak" "$lease"

cp "$decision" "$tmp/decision-authorizes.bak"
yq -i '.external_approval_is_local_authority = true' "$decision"
expect_fail "external-approval-local-authority"
cp "$tmp/decision-authorizes.bak" "$decision"

cp "$certification" "$tmp/certification-support.bak"
yq -i '.certification_widens_support_claims = true' "$certification"
expect_fail "certification-widens-support"
cp "$tmp/certification-support.bak" "$certification"

cp "$ledger" "$tmp/ledger-authority.bak"
yq -i '.ledger_authorizes_execution = true' "$ledger"
expect_fail "ledger-authorizes-execution"
cp "$tmp/ledger-authority.bak" "$ledger"

cp "$adoption" "$tmp/adoption.bak"
yq -i '.blind_copy_full_octon_allowed = true' "$adoption"
expect_fail "adoption-allows-blind-copy"
cp "$tmp/adoption.bak" "$adoption"

cp "$framework_doc" "$tmp/framework-doc.bak"
printf '\nForbidden proposal path: %s\n' ".octon/inputs/exploratory/proposals/architecture/octon-compatibility-and-federated-trust-runtime-v6" >>"$framework_doc"
expect_fail "durable-proposal-path-dependency"
cp "$tmp/framework-doc.bak" "$framework_doc"

echo "[OK] Federated Trust Runtime v6 negative controls passed."
