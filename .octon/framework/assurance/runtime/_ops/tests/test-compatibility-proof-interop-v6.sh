#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
VALIDATOR="$SCRIPT_DIR/../scripts/validate-compatibility-proof-interop-v6.sh"
ROOT_DIR="${OCTON_ROOT_DIR:-$(cd -- "$SCRIPT_DIR/../../../../../.." && pwd)}"
RUNNER="$ROOT_DIR/.octon/framework/engine/runtime/run"

"$VALIDATOR" --root "$ROOT_DIR" "$@"

tmp="$(mktemp -d)"
trap 'rm -r -f "$tmp"' EXIT
test_root="$tmp/root-copy"
mkdir -p "$test_root"
cp -R "$ROOT_DIR/.octon" "$test_root/.octon"
OCTON=(env OCTON_ROOT_DIR="$test_root" "$RUNNER")

expect_fail() {
  local label="$1"
  shift
  if "$@" >"$tmp/$label.out" 2>&1; then
    echo "[ERROR] expected failure: $label" >&2
    cat "$tmp/$label.out" >&2
    exit 1
  fi
  echo "[OK] negative control failed closed: $label"
}

expect_pass_grep() {
  local label="$1"
  local pattern="$2"
  shift 2
  "$@" >"$tmp/$label.out"
  grep -q -- "$pattern" "$tmp/$label.out" || {
    echo "[ERROR] missing pattern for $label: $pattern" >&2
    cat "$tmp/$label.out" >&2
    exit 1
  }
  echo "[OK] $label"
}

no_octon="$tmp/no-octon"
emitter="$tmp/emitter"
partial="$tmp/partial"
connector="$tmp/connector"
valid_repo="$tmp/valid-repo"
mkdir -p "$no_octon" "$emitter" "$partial/.octon/framework" "$connector" \
  "$valid_repo/.octon/framework" \
  "$valid_repo/.octon/instance/charter" \
  "$valid_repo/.octon/state/control" \
  "$valid_repo/.octon/state/evidence" \
  "$valid_repo/.octon/state/continuity"
touch "$emitter/portable-proof-bundle.yml"
touch "$connector/connector-operation.yml"
touch "$valid_repo/.octon/octon.yml" "$valid_repo/.octon/instance/manifest.yml" "$valid_repo/.octon/instance/charter/workspace.yml"

expect_pass_grep "classifies-no-octon" '"participation_tier": "external_evidence_source"' "${OCTON[@]}" compatibility inspect "$no_octon"
expect_pass_grep "classifies-emitter" '"participation_tier": "octon_compatible_emitter"' "${OCTON[@]}" compatibility inspect "$emitter"
expect_pass_grep "classifies-connector" '"participation_tier": "octon_mediated_connector"' "${OCTON[@]}" compatibility inspect "$connector"
expect_pass_grep "classifies-partial" '"detected_state": "stale_octon"' "${OCTON[@]}" compatibility inspect "$partial"
expect_pass_grep "classifies-enabled" '"participation_tier": "octon_enabled_repo"' "${OCTON[@]}" compatibility inspect "$valid_repo"
expect_pass_grep "adoption-preflight" '"blind_copy_full_octon_allowed": false' "${OCTON[@]}" adopt "$no_octon"

proof="$test_root/.octon/state/control/trust/proof-bundles/proof-octon-v6-mvp.yml"
attestation="$test_root/.octon/state/control/trust/attestations/attestation-octon-v6-mvp.yml"

expect_pass_grep "proof-verify" '"verified": true' "${OCTON[@]}" proof verify "$proof"
expect_pass_grep "proof-status" '"proof_bundle_authorizes_execution": false' "${OCTON[@]}" proof status --bundle-id proof-octon-v6-mvp
expect_pass_grep "attest-verify" '"verified": true' "${OCTON[@]}" attest verify "$attestation"
expect_pass_grep "attest-status" '"attestation_authorizes_execution": false' "${OCTON[@]}" attest status --attestation-id attestation-octon-v6-mvp
expect_pass_grep "trust-status" '"hook_authorizes_execution": false' "${OCTON[@]}" trust status

bad_proof="$tmp/bad-proof.yml"
cp "$proof" "$bad_proof"
yq -i '.proof_bundle_authorizes_execution = true' "$bad_proof"
expect_fail "proof-authorizes-execution" "${OCTON[@]}" proof verify "$bad_proof"

bad_import_proof="$tmp/bad-import-proof.yml"
cp "$proof" "$bad_import_proof"
yq -i '.proof_bundle_authorizes_execution = true' "$bad_import_proof"
expect_fail "imported-proof-authorizes-execution" "${OCTON[@]}" proof import "$bad_import_proof" --accept

missing_digest_proof="$tmp/missing-digest-proof.yml"
cp "$proof" "$missing_digest_proof"
yq -i '.evidence_digests[0].path = ".octon/state/evidence/trust/missing-digest.yml"' "$missing_digest_proof"
expect_fail "proof-missing-digest-path" "${OCTON[@]}" proof verify "$missing_digest_proof"

digest_mismatch_proof="$tmp/digest-mismatch-proof.yml"
cp "$proof" "$digest_mismatch_proof"
yq -i '.evidence_digests[0].digest = "0000000000000000000000000000000000000000000000000000000000000000"' "$digest_mismatch_proof"
expect_fail "proof-digest-mismatch" "${OCTON[@]}" proof verify "$digest_mismatch_proof"

out_of_scope_digest_proof="$tmp/out-of-scope-digest-proof.yml"
cp "$proof" "$out_of_scope_digest_proof"
yq -i '.evidence_digests[0].path = ".octon/generated/cognition/projections/materialized/trust/proof-review-status.yml"' "$out_of_scope_digest_proof"
expect_fail "proof-digest-out-of-scope" "${OCTON[@]}" proof verify "$out_of_scope_digest_proof"

stale_proof="$tmp/stale-proof.yml"
cp "$proof" "$stale_proof"
yq -i '.freshness_status = "stale"' "$stale_proof"
expect_fail "stale-proof" "${OCTON[@]}" proof verify "$stale_proof"

expired_proof="$tmp/expired-proof.yml"
cp "$proof" "$expired_proof"
yq -i '.expires_at = "2000-01-01T00:00:00Z"' "$expired_proof"
expect_fail "expired-proof" "${OCTON[@]}" proof verify "$expired_proof"

revoked_proof="$tmp/revoked-proof.yml"
cp "$proof" "$revoked_proof"
yq -i '.revocation_status = "revoked"' "$revoked_proof"
expect_fail "revoked-proof-status" "${OCTON[@]}" proof verify "$revoked_proof"

matching_revoked_proof="$tmp/matching-revoked-proof.yml"
matching_revocation="$test_root/.octon/state/control/trust/revocations/revocation-proof-test-match.yml"
cp "$proof" "$matching_revoked_proof"
cat >"$matching_revocation" <<'YAML'
schema_version: "proof-revocation-v1"
revocation_id: "revocation-proof-test-match"
subject_kind: "portable_proof_bundle"
subject_ref: "proof-octon-v6-mvp"
reason: "negative control"
status: "revoked"
route_on_match: "deny"
fail_closed: true
recorded_at: "2026-04-29T00:00:00Z"
evidence_refs: []
revocation_authorizes_execution: false
YAML
yq -i '.revocation_refs += [".octon/state/control/trust/revocations/revocation-proof-test-match.yml"]' "$matching_revoked_proof"
expect_fail "revoked-proof-matching-ref" "${OCTON[@]}" proof verify "$matching_revoked_proof"

missing_revocation_ref="$tmp/missing-revocation-ref-proof.yml"
cp "$proof" "$missing_revocation_ref"
yq -i '.revocation_refs += [".octon/state/control/trust/revocations/missing-revocation.yml"]' "$missing_revocation_ref"
expect_fail "proof-missing-revocation-ref" "${OCTON[@]}" proof verify "$missing_revocation_ref"

bad_redaction="$tmp/bad-redaction.yml"
cp "$proof" "$bad_redaction"
yq -i '.redaction_manifest.exported_secret_material_allowed = true' "$bad_redaction"
expect_fail "secret-export-proof" "${OCTON[@]}" proof verify "$bad_redaction"

bad_attestation="$tmp/bad-attestation.yml"
cp "$attestation" "$bad_attestation"
yq -i '.attestation_authorizes_execution = true' "$bad_attestation"
expect_fail "attestation-authorizes-execution" "${OCTON[@]}" attest verify "$bad_attestation"

expired_attestation="$tmp/expired-attestation.yml"
cp "$attestation" "$expired_attestation"
yq -i '.expires_at = "2000-01-01T00:00:00Z"' "$expired_attestation"
expect_fail "expired-attestation" "${OCTON[@]}" attest verify "$expired_attestation"

generated="$test_root/.octon/generated/cognition/projections/materialized/trust/proof-review-status.yml"
yq -i '.authority = "authoritative"' "$generated"
expect_fail "generated-proof-view-authority" "$VALIDATOR" --root "$test_root"

echo "[OK] Compatibility Proof Interop v6 behavior tests passed."
