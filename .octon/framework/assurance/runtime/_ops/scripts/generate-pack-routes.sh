#!/usr/bin/env bash
set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/closure-packet-common.sh"

require_yq

EFFECTIVE_DIR="$OCTON_DIR/generated/effective/capabilities"
OUT_FILE="$EFFECTIVE_DIR/pack-routes.effective.yml"
LOCK_FILE="$EFFECTIVE_DIR/pack-routes.lock.yml"
RECEIPT_DIR="$OCTON_DIR/state/evidence/validation/publication/capabilities"
SUPPORT_TARGETS="$OCTON_DIR/instance/governance/support-targets.yml"
GOV_REGISTRY="$OCTON_DIR/instance/governance/capability-packs/registry.yml"
RUNTIME_REGISTRY="$OCTON_DIR/instance/capabilities/runtime/packs/registry.yml"
SUPPORT_MATRIX="$OCTON_DIR/generated/effective/governance/support-target-matrix.yml"

mkdir -p "$EFFECTIVE_DIR" "$RECEIPT_DIR"

hash_file() {
  if command -v shasum >/dev/null 2>&1; then
    shasum -a 256 "$1" | awk '{print $1}'
  else
    sha256sum "$1" | awk '{print $1}'
  fi
}

timestamp="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
stamp_id="$(date -u +"%Y-%m-%dT%H-%M-%SZ")"
support_sha="$(hash_file "$SUPPORT_TARGETS")"
gov_sha="$(hash_file "$GOV_REGISTRY")"
runtime_sha="$(hash_file "$RUNTIME_REGISTRY")"
matrix_sha="$(hash_file "$SUPPORT_MATRIX")"
generation_id="pack-routes-${support_sha:0:12}"
receipt_rel=".octon/state/evidence/validation/publication/capabilities/${stamp_id}-${generation_id}.yml"
receipt_abs="$ROOT_DIR/$receipt_rel"

tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT
tmp_out="$tmpdir/pack-routes.effective.yml"
tmp_lock="$tmpdir/pack-routes.lock.yml"

{
  echo 'schema_version: "octon-runtime-pack-routes-effective-v1"'
  echo "generation_id: \"$generation_id\""
  echo "generated_at: \"$timestamp\""
  echo 'publication_status: "published"'
  echo "publication_receipt_path: \"$receipt_rel\""
  echo 'packs:'
  while IFS= read -r pack_id; do
    [[ -n "$pack_id" ]] || continue
    gov_manifest="$OCTON_DIR/instance/governance/capability-packs/$pack_id.yml"
    runtime_admission="$OCTON_DIR/instance/capabilities/runtime/packs/admissions/$pack_id.yml"
    admission_status="$(yq -r ".packs[] | select(.pack_id == \"$pack_id\") | .admission_status // \"\"" "$RUNTIME_REGISTRY")"
    default_route="$(yq -r ".packs[] | select(.pack_id == \"$pack_id\") | .default_route // \"\"" "$RUNTIME_REGISTRY")"
    echo "  - pack_id: \"$pack_id\""
    echo "    admission_status: \"$admission_status\""
    echo "    default_route: \"$default_route\""
    echo "    governance_manifest_ref: \".octon/instance/governance/capability-packs/$pack_id.yml\""
    echo "    runtime_registry_ref: \".octon/instance/capabilities/runtime/packs/registry.yml\""
    echo '    tuple_routes:'
    while IFS= read -r tuple_id; do
      [[ -n "$tuple_id" ]] || continue
      claim_effect="$(yq -r ".tuple_admissions[] | select(.tuple_id == \"$tuple_id\") | .claim_effect // \"\"" "$SUPPORT_TARGETS")"
      route="$(yq -r ".tuple_admissions[] | select(.tuple_id == \"$tuple_id\") | .admission_ref // \"\"" "$SUPPORT_TARGETS")"
      admission_abs="$ROOT_DIR/$route"
      effective_route="$(yq -r '.route // ""' "$admission_abs")"
      requires_mission="$(yq -r '.requires_mission // false' "$admission_abs")"
      echo "      - tuple_id: \"$tuple_id\""
      echo "        claim_effect: \"$claim_effect\""
      echo "        route: \"$effective_route\""
      echo "        requires_mission: $requires_mission"
    done < <(yq -r '.support_target_refs[]? // ""' "$gov_manifest")
  done < <(yq -r '.packs[]?.pack_id // ""' "$GOV_REGISTRY")
} >"$tmp_out"

out_sha="$(hash_file "$tmp_out")"

{
  echo 'schema_version: "octon-runtime-pack-routes-lock-v1"'
  echo "generation_id: \"$generation_id\""
  echo "published_at: \"$timestamp\""
  echo 'publication_status: "published"'
  echo "publication_receipt_path: \"$receipt_rel\""
  echo 'publication_receipt_sha256: ""'
  echo "pack_routes_sha256: \"$out_sha\""
  echo "support_targets_sha256: \"$support_sha\""
  echo "governance_registry_sha256: \"$gov_sha\""
  echo "runtime_registry_sha256: \"$runtime_sha\""
  echo "support_target_matrix_sha256: \"$matrix_sha\""
  echo 'required_inputs:'
  echo '  - ".octon/instance/governance/support-targets.yml"'
  echo '  - ".octon/instance/governance/capability-packs/registry.yml"'
  echo '  - ".octon/instance/capabilities/runtime/packs/registry.yml"'
  echo '  - ".octon/generated/effective/governance/support-target-matrix.yml"'
  while IFS= read -r pack_id; do
    [[ -n "$pack_id" ]] || continue
    echo "  - \".octon/instance/governance/capability-packs/$pack_id.yml\""
    echo "  - \".octon/instance/capabilities/runtime/packs/admissions/$pack_id.yml\""
  done < <(yq -r '.packs[]?.pack_id // ""' "$GOV_REGISTRY")
  echo 'invalidation_conditions:'
  echo '  - support-targets-sha-changed'
  echo '  - governance-pack-registry-sha-changed'
  echo '  - runtime-pack-registry-sha-changed'
  echo '  - support-matrix-sha-changed'
  echo 'published_files:'
  echo '  - path: ".octon/generated/effective/capabilities/pack-routes.effective.yml"'
  echo '  - path: ".octon/generated/effective/capabilities/pack-routes.lock.yml"'
} >"$tmp_lock"

cp "$tmp_out" "$OUT_FILE"
cp "$tmp_lock" "$LOCK_FILE"

{
  echo 'schema_version: "octon-validation-publication-receipt-v1"'
  echo "receipt_id: \"runtime-pack-routes-${stamp_id}-${generation_id}\""
  echo 'publication_family: "runtime-pack-routes"'
  echo "generation_id: \"$generation_id\""
  echo 'result: "published"'
  echo "validated_at: \"$timestamp\""
  echo 'validator_version: "runtime-pack-route-publication-v1"'
  echo 'contract_refs:'
  echo '  - ".octon/framework/engine/runtime/spec/runtime-resolution-v1.md"'
  echo '  - ".octon/instance/governance/contracts/support-pack-admission-alignment.yml"'
  echo 'source_digests:'
  echo "  support_targets_sha256: \"$support_sha\""
  echo "  governance_registry_sha256: \"$gov_sha\""
  echo "  runtime_registry_sha256: \"$runtime_sha\""
  echo "  support_target_matrix_sha256: \"$matrix_sha\""
  echo 'blocked_reasons: []'
  echo 'published_paths:'
  echo '  - ".octon/generated/effective/capabilities/pack-routes.effective.yml"'
  echo '  - ".octon/generated/effective/capabilities/pack-routes.lock.yml"'
  echo 'required_inputs:'
  echo '  - ".octon/instance/governance/support-targets.yml"'
  echo '  - ".octon/instance/governance/capability-packs/registry.yml"'
  echo '  - ".octon/instance/capabilities/runtime/packs/registry.yml"'
  echo '  - ".octon/generated/effective/governance/support-target-matrix.yml"'
} >"$receipt_abs"

receipt_sha="$(hash_file "$receipt_abs")"
yq -i ".publication_receipt_sha256 = \"$receipt_sha\"" "$LOCK_FILE"
