#!/usr/bin/env bash
set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/closure-packet-common.sh"

require_yq

RUNTIME_RESOLUTION="$OCTON_DIR/instance/governance/runtime-resolution.yml"
SUPPORT_TARGETS="$OCTON_DIR/instance/governance/support-targets.yml"
SUPPORT_MATRIX="$OCTON_DIR/generated/effective/governance/support-target-matrix.yml"
PACK_ROUTES="$OCTON_DIR/generated/effective/capabilities/pack-routes.effective.yml"
PACK_LOCK="$OCTON_DIR/generated/effective/capabilities/pack-routes.lock.yml"
EXT_CATALOG="$OCTON_DIR/generated/effective/extensions/catalog.effective.yml"
EXT_LOCK="$OCTON_DIR/generated/effective/extensions/generation.lock.yml"
CAP_ROUTING="$OCTON_DIR/generated/effective/capabilities/routing.effective.yml"
CAP_ROUTING_LOCK="$OCTON_DIR/generated/effective/capabilities/generation.lock.yml"
ACTIVE_STATE="$OCTON_DIR/state/control/extensions/active.yml"
OUT_DIR="$OCTON_DIR/generated/effective/runtime"
OUT_FILE="$OUT_DIR/route-bundle.yml"
LOCK_FILE="$OUT_DIR/route-bundle.lock.yml"
RECEIPT_DIR="$OCTON_DIR/state/evidence/validation/publication/runtime"

mkdir -p "$OUT_DIR" "$RECEIPT_DIR"

hash_file() {
  if command -v shasum >/dev/null 2>&1; then
    shasum -a 256 "$1" | awk '{print $1}'
  else
    sha256sum "$1" | awk '{print $1}'
  fi
}

timestamp="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
stamp_id="$(date -u +"%Y-%m-%dT%H-%M-%SZ")"
resolution_sha="$(hash_file "$RUNTIME_RESOLUTION")"
root_sha="$(hash_file "$OCTON_DIR/octon.yml")"
matrix_sha="$(hash_file "$SUPPORT_MATRIX")"
pack_sha="$(hash_file "$PACK_ROUTES")"
pack_lock_sha="$(hash_file "$PACK_LOCK")"
ext_catalog_sha="$(hash_file "$EXT_CATALOG")"
ext_lock_sha="$(hash_file "$EXT_LOCK")"
cap_routing_sha=""
cap_routing_lock_sha=""
if [[ -f "$CAP_ROUTING" ]]; then
  cap_routing_sha="$(hash_file "$CAP_ROUTING")"
fi
if [[ -f "$CAP_ROUTING_LOCK" ]]; then
  cap_routing_lock_sha="$(hash_file "$CAP_ROUTING_LOCK")"
fi
generation_id="runtime-route-bundle-${resolution_sha:0:12}"
receipt_rel=".octon/state/evidence/validation/publication/runtime/${stamp_id}-${generation_id}.yml"
receipt_abs="$ROOT_DIR/$receipt_rel"

tmpdir="$(mktemp -d)"
cleanup_tmpdir() {
  local dir="$1"
  [[ -d "$dir" ]] || return 0
  find "$dir" -depth -mindepth 1 \( -type f -o -type l \) -exec rm -f {} +
  find "$dir" -depth -type d -empty -exec rmdir {} +
}
trap 'cleanup_tmpdir "$tmpdir"' EXIT
tmp_out="$tmpdir/route-bundle.yml"
tmp_lock="$tmpdir/route-bundle.lock.yml"

extension_generation_id="$(yq -r '.generation_id // ""' "$ACTIVE_STATE")"
extension_status="$(yq -r '.status // .publication_status // "published"' "$ACTIVE_STATE")"
quarantine_count="$(yq -r '.records | length' "$OCTON_DIR/state/control/extensions/quarantine.yml")"

{
  echo 'schema_version: "octon-runtime-effective-route-bundle-v1"'
  echo "generation_id: \"$generation_id\""
  echo "generated_at: \"$timestamp\""
  echo 'publication_status: "published"'
  echo "publication_receipt_path: \"$receipt_rel\""
  echo 'source_refs:'
  echo '  root_manifest_ref: ".octon/octon.yml"'
  echo '  runtime_resolution_ref: ".octon/instance/governance/runtime-resolution.yml"'
  echo '  support_target_matrix_ref: ".octon/generated/effective/governance/support-target-matrix.yml"'
  echo '  pack_routes_effective_ref: ".octon/generated/effective/capabilities/pack-routes.effective.yml"'
  echo '  pack_routes_lock_ref: ".octon/generated/effective/capabilities/pack-routes.lock.yml"'
  echo '  extensions_catalog_ref: ".octon/generated/effective/extensions/catalog.effective.yml"'
  echo '  extensions_generation_lock_ref: ".octon/generated/effective/extensions/generation.lock.yml"'
  echo 'routes:'
  while IFS= read -r tuple_id; do
    [[ -n "$tuple_id" ]] || continue
    admission_ref="$(yq -r ".tuple_admissions[] | select(.tuple_id == \"$tuple_id\") | .admission_ref // \"\"" "$SUPPORT_TARGETS")"
    claim_effect="$(yq -r ".tuple_admissions[] | select(.tuple_id == \"$tuple_id\") | .claim_effect // \"\"" "$SUPPORT_TARGETS")"
    admission_abs="$ROOT_DIR/$admission_ref"
    echo "  - tuple_id: \"$tuple_id\""
    echo '    tuple:'
    echo "      model_tier: \"$(yq -r '.tuple.model_tier // ""' "$admission_abs")\""
    echo "      workload_tier: \"$(yq -r '.tuple.workload_tier // ""' "$admission_abs")\""
    echo "      language_resource_tier: \"$(yq -r '.tuple.language_resource_tier // ""' "$admission_abs")\""
    echo "      locale_tier: \"$(yq -r '.tuple.locale_tier // ""' "$admission_abs")\""
    echo "      host_adapter: \"$(yq -r '.tuple.host_adapter // ""' "$admission_abs")\""
    echo "      model_adapter: \"$(yq -r '.tuple.model_adapter // ""' "$admission_abs")\""
    echo "    claim_effect: \"$claim_effect\""
    echo "    route: \"$(yq -r '.route // ""' "$admission_abs")\""
    echo "    requires_mission: $(yq -r '.requires_mission // false' "$admission_abs")"
    echo '    allowed_capability_packs:'
    while IFS= read -r pack_id; do
      [[ -n "$pack_id" ]] || continue
      echo "      - \"$pack_id\""
    done < <(yq -r '.allowed_capability_packs[]? // ""' "$admission_abs")
  done < <(yq -r '.tuple_admissions[]?.tuple_id // ""' "$SUPPORT_TARGETS")
  echo 'extensions:'
  echo "  generation_id: \"$extension_generation_id\""
  echo "  status: \"$extension_status\""
  echo "  quarantine_count: $quarantine_count"
} >"$tmp_out"

out_sha="$(hash_file "$tmp_out")"

{
  echo 'schema_version: "octon-runtime-effective-route-bundle-lock-v3"'
  echo "generation_id: \"$generation_id\""
  echo "published_at: \"$timestamp\""
  echo 'publication_status: "published"'
  echo "publication_receipt_path: \"$receipt_rel\""
  echo 'publication_receipt_sha256: ""'
  echo 'route_bundle_ref: ".octon/generated/effective/runtime/route-bundle.yml"'
  echo "route_bundle_sha256: \"$out_sha\""
  echo 'source_digests:'
  echo "  runtime_resolution_sha256: \"$resolution_sha\""
  echo "  root_manifest_sha256: \"$root_sha\""
  echo "  support_target_matrix_sha256: \"$matrix_sha\""
  echo "  pack_routes_effective_sha256: \"$pack_sha\""
  echo "  pack_routes_lock_sha256: \"$pack_lock_sha\""
  echo "  extensions_catalog_sha256: \"$ext_catalog_sha\""
  echo "  extensions_generation_lock_sha256: \"$ext_lock_sha\""
  if [[ -n "$cap_routing_sha" ]]; then
    echo "  capability_routing_sha256: \"$cap_routing_sha\""
  fi
  if [[ -n "$cap_routing_lock_sha" ]]; then
    echo "  capability_routing_lock_sha256: \"$cap_routing_lock_sha\""
  fi
  echo 'freshness:'
  echo '  mode: "digest_bound"'
  echo '  invalidation_conditions:'
  echo '    - "runtime-resolution-sha-changed"'
  echo '    - "root-manifest-sha-changed"'
  echo '    - "support-target-matrix-sha-changed"'
  echo '    - "pack-routes-sha-changed"'
  echo '    - "extensions-publication-sha-changed"'
  if [[ -n "$cap_routing_sha" ]]; then
    echo '    - "capability-routing-sha-changed"'
  fi
  echo 'allowed_consumers:'
  echo '  - "runtime_resolver"'
  echo '  - "validators"'
  echo 'forbidden_consumers:'
  echo '  - "direct_runtime_raw_path_read"'
  echo '  - "generated_cognition_as_authority"'
  echo 'non_authority_classification: "derived-runtime-handle"'
  echo 'required_inputs:'
  echo '  - ".octon/octon.yml"'
  echo '  - ".octon/instance/governance/runtime-resolution.yml"'
  echo '  - ".octon/generated/effective/governance/support-target-matrix.yml"'
  echo '  - ".octon/generated/effective/capabilities/pack-routes.effective.yml"'
  echo '  - ".octon/generated/effective/capabilities/pack-routes.lock.yml"'
  echo '  - ".octon/generated/effective/extensions/catalog.effective.yml"'
  echo '  - ".octon/generated/effective/extensions/generation.lock.yml"'
  echo '  - ".octon/state/control/extensions/active.yml"'
  echo '  - ".octon/state/control/extensions/quarantine.yml"'
  if [[ -n "$cap_routing_sha" ]]; then
    echo '  - ".octon/generated/effective/capabilities/routing.effective.yml"'
  fi
  if [[ -n "$cap_routing_lock_sha" ]]; then
    echo '  - ".octon/generated/effective/capabilities/generation.lock.yml"'
  fi
  echo 'published_files:'
  echo '  - path: ".octon/generated/effective/runtime/route-bundle.yml"'
  echo '  - path: ".octon/generated/effective/runtime/route-bundle.lock.yml"'
  echo 'dependency_handles:'
  echo '  - artifact_kind: "support_matrix"'
  echo '    output_ref: ".octon/generated/effective/governance/support-target-matrix.yml"'
  echo '    lock_ref: null'
  echo '    requirement: "required"'
  echo '    purpose: "route-bundle publication input only"'
  echo '  - artifact_kind: "pack_routes"'
  echo '    output_ref: ".octon/generated/effective/capabilities/pack-routes.effective.yml"'
  echo '    lock_ref: ".octon/generated/effective/capabilities/pack-routes.lock.yml"'
  echo '    requirement: "required"'
  echo '    purpose: "capability-pack route narrowing"'
  echo '  - artifact_kind: "extension_catalog"'
  echo '    output_ref: ".octon/generated/effective/extensions/catalog.effective.yml"'
  echo '    lock_ref: ".octon/generated/effective/extensions/generation.lock.yml"'
  echo '    requirement: "required"'
  echo '    purpose: "extension publication state"'
  echo '  - artifact_kind: "extension_generation_lock"'
  echo '    output_ref: ".octon/generated/effective/extensions/generation.lock.yml"'
  echo '    lock_ref: null'
  echo '    requirement: "required"'
  echo '    purpose: "extension generation freshness and receipt linkage"'
  if [[ -n "$cap_routing_sha" ]]; then
    echo '  - artifact_kind: "capability_routing"'
    echo '    output_ref: ".octon/generated/effective/capabilities/routing.effective.yml"'
    if [[ -n "$cap_routing_lock_sha" ]]; then
      echo '    lock_ref: ".octon/generated/effective/capabilities/generation.lock.yml"'
    else
      echo '    lock_ref: null'
    fi
    echo '    requirement: "optional"'
    echo '    purpose: "host and capability routing publication state"'
  fi
} >"$tmp_lock"

cp "$tmp_out" "$OUT_FILE"
cp "$tmp_lock" "$LOCK_FILE"

{
  echo 'schema_version: "octon-validation-publication-receipt-v1"'
  echo "receipt_id: \"runtime-route-bundle-${stamp_id}-${generation_id}\""
  echo 'publication_family: "runtime-route-bundle"'
  echo "generation_id: \"$generation_id\""
  echo 'result: "published"'
  echo "validated_at: \"$timestamp\""
  echo 'validator_version: "runtime-route-bundle-publication-v1"'
  echo 'contract_refs:'
  echo '  - ".octon/framework/engine/runtime/spec/runtime-resolution-v1.md"'
  echo '  - ".octon/framework/engine/runtime/spec/runtime-effective-route-bundle-v1.schema.json"'
  echo 'source_digests:'
  echo "  runtime_resolution_sha256: \"$resolution_sha\""
  echo "  root_manifest_sha256: \"$root_sha\""
  echo "  support_target_matrix_sha256: \"$matrix_sha\""
  echo "  pack_routes_effective_sha256: \"$pack_sha\""
  echo "  pack_routes_lock_sha256: \"$pack_lock_sha\""
  echo "  extensions_catalog_sha256: \"$ext_catalog_sha\""
  echo "  extensions_generation_lock_sha256: \"$ext_lock_sha\""
  echo 'blocked_reasons: []'
  echo 'published_paths:'
  echo '  - ".octon/generated/effective/runtime/route-bundle.yml"'
  echo '  - ".octon/generated/effective/runtime/route-bundle.lock.yml"'
  echo 'required_inputs:'
  echo '  - ".octon/octon.yml"'
  echo '  - ".octon/instance/governance/runtime-resolution.yml"'
  echo '  - ".octon/generated/effective/governance/support-target-matrix.yml"'
  echo '  - ".octon/generated/effective/capabilities/pack-routes.effective.yml"'
  echo '  - ".octon/generated/effective/capabilities/pack-routes.lock.yml"'
  echo '  - ".octon/generated/effective/extensions/catalog.effective.yml"'
  echo '  - ".octon/generated/effective/extensions/generation.lock.yml"'
  echo '  - ".octon/state/control/extensions/active.yml"'
  echo '  - ".octon/state/control/extensions/quarantine.yml"'
} >"$receipt_abs"

receipt_sha="$(hash_file "$receipt_abs")"
yq -i ".publication_receipt_sha256 = \"$receipt_sha\"" "$LOCK_FILE"
