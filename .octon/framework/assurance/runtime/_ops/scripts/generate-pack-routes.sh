#!/usr/bin/env bash
set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/closure-packet-common.sh"
source "$OCTON_DIR/framework/assurance/runtime/_ops/scripts/publication-wrapper-common.sh"
source "$OCTON_DIR/framework/assurance/runtime/_ops/scripts/generator-idempotency-common.sh"

enter_publication_runtime_boundary pack-routes

require_yq

EFFECTIVE_DIR="$OCTON_DIR/generated/effective/capabilities"
OUT_FILE="$EFFECTIVE_DIR/pack-routes.effective.yml"
LOCK_FILE="$EFFECTIVE_DIR/pack-routes.lock.yml"
RECEIPT_DIR="$OCTON_DIR/state/evidence/validation/publication/capabilities"
SUPPORT_TARGETS="$OCTON_DIR/instance/governance/support-targets.yml"
GOV_REGISTRY="$OCTON_DIR/instance/governance/capability-packs/registry.yml"
RUNTIME_REGISTRY="$OCTON_DIR/instance/capabilities/runtime/packs/registry.yml"
SUPPORT_MATRIX="$OCTON_DIR/generated/effective/governance/support-target-matrix.yml"
ROOT_MANIFEST="$OCTON_DIR/octon.yml"

mkdir -p "$EFFECTIVE_DIR" "$RECEIPT_DIR"

hash_file() {
  if command -v shasum >/dev/null 2>&1; then
    shasum -a 256 "$1" | awk '{print $1}'
  else
    sha256sum "$1" | awk '{print $1}'
  fi
}

normalize_effective_publication_payload() {
  sed -E \
    -e 's/^generated_at: "?[^"]*"?/generated_at: "__GENERATED_AT__"/' \
    -e 's/^published_at: "?[^"]*"?/published_at: "__PUBLISHED_AT__"/' \
    -e 's#^publication_receipt_path: "?[^"]*"?#publication_receipt_path: "__PUBLICATION_RECEIPT_PATH__"#' \
    -e 's/^publication_receipt_sha256: "?[^"]*"?/publication_receipt_sha256: "__PUBLICATION_RECEIPT_SHA256__"/' \
    -e 's/^pack_routes_sha256: "?[^"]*"?/pack_routes_sha256: "__PACK_ROUTES_SHA256__"/'
}

maybe_reuse_publication_values() {
  local candidate_out="$1"
  local candidate_lock="$2"
  if [[ ! -f "$OUT_FILE" || ! -f "$LOCK_FILE" ]]; then
    return 0
  fi
  if [[ "$(normalize_effective_publication_payload <"$candidate_out")" != "$(normalize_effective_publication_payload <"$OUT_FILE")" ]]; then
    return 0
  fi
  if [[ "$(normalize_effective_publication_payload <"$candidate_lock")" != "$(normalize_effective_publication_payload <"$LOCK_FILE")" ]]; then
    return 0
  fi
  local existing_timestamp existing_receipt
  existing_timestamp="$(yq -r '.generated_at // ""' "$OUT_FILE")"
  existing_receipt="$(yq -r '.publication_receipt_path // ""' "$OUT_FILE")"
  if [[ -n "$existing_timestamp" && -n "$existing_receipt" ]] && octon_churn_receipt_ref_is_compacted "$existing_receipt"; then
    timestamp="$existing_timestamp"
    stamp_id="${timestamp//:/-}"
    receipt_rel="$existing_receipt"
    receipt_abs="$ROOT_DIR/$receipt_rel"
  fi
}

timestamp="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
stamp_id="$(date -u +"%Y-%m-%dT%H-%M-%SZ")"
support_sha="$(hash_file "$SUPPORT_TARGETS")"
gov_sha="$(hash_file "$GOV_REGISTRY")"
runtime_sha="$(hash_file "$RUNTIME_REGISTRY")"
matrix_sha="$(hash_file "$SUPPORT_MATRIX")"
root_sha="$(hash_file "$ROOT_MANIFEST")"
generation_id="pack-routes-${support_sha:0:12}"
receipt_rel=".octon/state/evidence/validation/publication/capabilities/${stamp_id}-${generation_id}.yml"
receipt_abs="$ROOT_DIR/$receipt_rel"

tmpdir="$(mktemp -d)"
cleanup_tmpdir() {
  local dir="$1"
  [[ -d "$dir" ]] || return 0
  find "$dir" -depth -mindepth 1 \( -type f -o -type l \) -exec rm -f {} +
  find "$dir" -depth -type d -empty -exec rmdir {} +
}
trap 'cleanup_tmpdir "$tmpdir"' EXIT
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
  echo "root_manifest_sha256: \"$root_sha\""
  echo "support_targets_sha256: \"$support_sha\""
  echo "governance_registry_sha256: \"$gov_sha\""
  echo "runtime_registry_sha256: \"$runtime_sha\""
  echo "support_target_matrix_sha256: \"$matrix_sha\""
  echo 'freshness:'
  echo '  mode: "digest_bound"'
  echo '  invalidation_conditions:'
  echo '    - "root-manifest-sha-changed"'
  echo '    - "support-targets-sha-changed"'
  echo '    - "governance-pack-registry-sha-changed"'
  echo '    - "runtime-pack-registry-sha-changed"'
  echo '    - "support-matrix-sha-changed"'
  echo 'allowed_consumers:'
  echo '  - "runtime_resolver"'
  echo '  - "validators"'
  echo 'forbidden_consumers:'
  echo '  - "direct_runtime_raw_path_read"'
  echo '  - "generated_cognition_as_authority"'
  echo 'non_authority_classification: "derived-runtime-handle"'
  echo 'required_inputs:'
  echo '  - ".octon/octon.yml"'
  echo '  - ".octon/instance/governance/support-targets.yml"'
  echo '  - ".octon/instance/governance/capability-packs/registry.yml"'
  echo '  - ".octon/instance/capabilities/runtime/packs/registry.yml"'
  echo '  - ".octon/generated/effective/governance/support-target-matrix.yml"'
  while IFS= read -r pack_id; do
    [[ -n "$pack_id" ]] || continue
    echo "  - \".octon/instance/governance/capability-packs/$pack_id.yml\""
    echo "  - \".octon/instance/capabilities/runtime/packs/admissions/$pack_id.yml\""
  done < <(yq -r '.packs[]?.pack_id // ""' "$GOV_REGISTRY")
  echo 'published_files:'
  echo '  - path: ".octon/generated/effective/capabilities/pack-routes.effective.yml"'
  echo '  - path: ".octon/generated/effective/capabilities/pack-routes.lock.yml"'
} >"$tmp_lock"

original_timestamp="$timestamp"
original_receipt_rel="$receipt_rel"
maybe_reuse_publication_values "$tmp_out" "$tmp_lock"
if [[ "$timestamp" != "$original_timestamp" || "$receipt_rel" != "$original_receipt_rel" ]]; then
  OLD_TIMESTAMP="$original_timestamp" NEW_TIMESTAMP="$timestamp" OLD_RECEIPT_REL="$original_receipt_rel" NEW_RECEIPT_REL="$receipt_rel" \
    perl -0pi -e 's/\Q$ENV{OLD_TIMESTAMP}\E/$ENV{NEW_TIMESTAMP}/g; s/\Q$ENV{OLD_RECEIPT_REL}\E/$ENV{NEW_RECEIPT_REL}/g' "$tmp_out" "$tmp_lock"
  out_sha="$(hash_file "$tmp_out")"
  yq -i ".pack_routes_sha256 = \"$out_sha\"" "$tmp_lock"
fi

receipt_tmp="$tmpdir/publication.receipt.yml"

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
  echo "  root_manifest_sha256: \"$root_sha\""
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
} >"$receipt_tmp"

receipt_publish_output="$(octon_churn_publish_compacted_receipt "$ROOT_DIR" ".octon/state/evidence/validation/publication/capabilities" "runtime-pack-routes" "$generation_id" "$receipt_tmp")"
receipt_rel="$(printf '%s\n' "$receipt_publish_output" | awk '$1 == "receipt_path" { print $2; exit }')"
receipt_sha="$(printf '%s\n' "$receipt_publish_output" | awk '$1 == "receipt_sha256" { print $2; exit }')"
receipt_sha="${receipt_sha#sha256:}"
receipt_abs="$ROOT_DIR/$receipt_rel"
yq -i ".publication_receipt_path = \"$receipt_rel\"" "$tmp_out"
yq -i ".publication_receipt_path = \"$receipt_rel\"" "$tmp_lock"
out_sha="$(hash_file "$tmp_out")"
yq -i ".pack_routes_sha256 = \"$out_sha\"" "$tmp_lock"
yq -i ".publication_receipt_sha256 = \"$receipt_sha\"" "$tmp_lock"

octon_churn_write_file_if_changed "$OUT_FILE" "$tmp_out" >/dev/null
octon_churn_write_file_if_changed "$LOCK_FILE" "$tmp_lock" >/dev/null
