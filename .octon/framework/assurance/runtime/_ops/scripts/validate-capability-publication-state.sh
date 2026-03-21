#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../../" && pwd)"
OCTON_DIR="${OCTON_DIR_OVERRIDE:-$DEFAULT_OCTON_DIR}"
ROOT_DIR="${OCTON_ROOT_DIR:-$(cd -- "$OCTON_DIR/.." && pwd)}"

ROOT_MANIFEST="$OCTON_DIR/octon.yml"
EXTENSIONS_CATALOG="$OCTON_DIR/generated/effective/extensions/catalog.effective.yml"
EXTENSIONS_LOCK="$OCTON_DIR/generated/effective/extensions/generation.lock.yml"
LOCALITY_SCOPES="$OCTON_DIR/generated/effective/locality/scopes.effective.yml"
LOCALITY_LOCK="$OCTON_DIR/generated/effective/locality/generation.lock.yml"
COMMANDS_MANIFEST="$OCTON_DIR/framework/capabilities/runtime/commands/manifest.yml"
SKILLS_MANIFEST="$OCTON_DIR/framework/capabilities/runtime/skills/manifest.yml"
SKILLS_REGISTRY="$OCTON_DIR/framework/capabilities/runtime/skills/registry.yml"
SERVICES_MANIFEST="$OCTON_DIR/framework/capabilities/runtime/services/manifest.yml"
TOOLS_MANIFEST="$OCTON_DIR/framework/capabilities/runtime/tools/manifest.yml"
INSTANCE_COMMANDS_MANIFEST="$OCTON_DIR/instance/capabilities/runtime/commands/manifest.yml"
INSTANCE_SKILLS_MANIFEST="$OCTON_DIR/instance/capabilities/runtime/skills/manifest.yml"
EFFECTIVE_DIR="$OCTON_DIR/generated/effective/capabilities"
ROUTING_FILE="$EFFECTIVE_DIR/routing.effective.yml"
ARTIFACT_MAP_FILE="$EFFECTIVE_DIR/artifact-map.yml"
GENERATION_LOCK_FILE="$EFFECTIVE_DIR/generation.lock.yml"

errors=0

fail() {
  echo "[ERROR] $1"
  errors=$((errors + 1))
}

pass() {
  echo "[OK] $1"
}

hash_file() {
  local file="$1"
  if command -v shasum >/dev/null 2>&1; then
    shasum -a 256 "$file" | awk '{print $1}'
  else
    sha256sum "$file" | awk '{print $1}'
  fi
}

require_yaml_file() {
  local file="$1"
  if [[ ! -f "$file" ]]; then
    fail "missing file: ${file#$ROOT_DIR/}"
    return 1
  fi
  pass "found file: ${file#$ROOT_DIR/}"
  if yq -e '.' "$file" >/dev/null 2>&1; then
    pass "${file#$ROOT_DIR/} parses as YAML"
  else
    fail "${file#$ROOT_DIR/} must parse as YAML"
  fi
}

main() {
  echo "== Capability Publication State Validation =="

  require_yaml_file "$ROOT_MANIFEST"
  require_yaml_file "$EXTENSIONS_CATALOG"
  require_yaml_file "$EXTENSIONS_LOCK"
  require_yaml_file "$LOCALITY_SCOPES"
  require_yaml_file "$LOCALITY_LOCK"
  require_yaml_file "$ROUTING_FILE"
  require_yaml_file "$ARTIFACT_MAP_FILE"
  require_yaml_file "$GENERATION_LOCK_FILE"

  [[ "$(yq -r '.schema_version // ""' "$ROUTING_FILE")" == "octon-capability-routing-effective-v3" ]] && pass "routing schema version valid" || fail "routing schema_version invalid"
  [[ "$(yq -r '.schema_version // ""' "$ARTIFACT_MAP_FILE")" == "octon-capability-routing-artifact-map-v3" ]] && pass "artifact map schema version valid" || fail "artifact map schema_version invalid"
  [[ "$(yq -r '.schema_version // ""' "$GENERATION_LOCK_FILE")" == "octon-capability-routing-generation-lock-v3" ]] && pass "generation lock schema version valid" || fail "generation lock schema_version invalid"

  local expected_generator_version
  expected_generator_version="$(yq -r '.versioning.harness.release_version // ""' "$ROOT_MANIFEST")"
  [[ -n "$expected_generator_version" ]] && pass "root manifest generator version available" || fail "root manifest missing versioning.harness.release_version"
  [[ "$(yq -r '.generator_version // ""' "$ROUTING_FILE")" == "$expected_generator_version" ]] && pass "routing generator_version current" || fail "routing generator_version missing or stale"
  [[ "$(yq -r '.generator_version // ""' "$ARTIFACT_MAP_FILE")" == "$expected_generator_version" ]] && pass "artifact map generator_version current" || fail "artifact map generator_version missing or stale"
  [[ "$(yq -r '.generator_version // ""' "$GENERATION_LOCK_FILE")" == "$expected_generator_version" ]] && pass "generation lock generator_version current" || fail "generation lock generator_version missing or stale"

  local generation_id
  generation_id="$(yq -r '.generation_id // ""' "$ROUTING_FILE")"
  [[ -n "$generation_id" ]] && pass "routing generation_id declared" || fail "routing generation_id missing"
  [[ "$(yq -r '.generation_id // ""' "$ARTIFACT_MAP_FILE")" == "$generation_id" ]] && pass "artifact map generation_id matches routing" || fail "artifact map generation_id mismatch"
  [[ "$(yq -r '.generation_id // ""' "$GENERATION_LOCK_FILE")" == "$generation_id" ]] && pass "generation lock generation_id matches routing" || fail "generation lock generation_id mismatch"
  local routing_status locality_status extensions_status receipt_rel receipt_abs receipt_sha
  routing_status="$(yq -r '.publication_status // ""' "$ROUTING_FILE")"
  locality_status="$(yq -r '.routing_context.locality_publication_status // ""' "$ROUTING_FILE")"
  extensions_status="$(yq -r '.routing_context.extension_publication_status // ""' "$ROUTING_FILE")"
  case "$routing_status" in
    published|published_with_quarantine)
      pass "routing publication_status valid"
      ;;
    *)
      fail "routing publication_status invalid"
      ;;
  esac
  if [[ "$locality_status" == "published" && "$extensions_status" == "published" && "$routing_status" == "published" ]]; then
    pass "routing publication status matches clean upstream state"
  elif [[ "$routing_status" == "published_with_quarantine" && ( "$locality_status" != "published" || "$extensions_status" != "published" ) ]]; then
    pass "routing publication status matches degraded upstream state"
  else
    fail "routing publication status does not match upstream locality/extensions state"
  fi
  receipt_rel="$(yq -r '.publication_receipt_path // ""' "$ROUTING_FILE")"
  receipt_abs="$ROOT_DIR/$receipt_rel"
  [[ -n "$receipt_rel" ]] && pass "routing publication receipt path declared" || fail "routing publication receipt path missing"
  if [[ -f "$receipt_abs" ]]; then
    pass "routing publication receipt file exists"
    yq -e '.' "$receipt_abs" >/dev/null 2>&1 && pass "routing publication receipt parses as YAML" || fail "routing publication receipt must parse as YAML"
  else
    fail "routing publication receipt file missing"
  fi
  [[ "$(yq -r '.schema_version // ""' "$receipt_abs" 2>/dev/null)" == "octon-validation-publication-receipt-v1" ]] && pass "routing publication receipt schema version valid" || fail "routing publication receipt schema version invalid"
  [[ "$(yq -r '.publication_family // ""' "$receipt_abs" 2>/dev/null)" == "capabilities" ]] && pass "routing publication receipt family valid" || fail "routing publication receipt family invalid"
  [[ "$(yq -r '.generation_id // ""' "$receipt_abs" 2>/dev/null)" == "$generation_id" ]] && pass "routing publication receipt generation id matches" || fail "routing publication receipt generation id mismatch"
  [[ "$(yq -r '.result // ""' "$receipt_abs" 2>/dev/null)" == "$routing_status" ]] && pass "routing publication receipt result matches" || fail "routing publication receipt result mismatch"
  yq -e '.contract_refs | length > 0' "$receipt_abs" >/dev/null 2>&1 && pass "routing publication receipt contract refs declared" || fail "routing publication receipt contract refs missing"
  receipt_sha="$(hash_file "$receipt_abs")"
  [[ "$(yq -r '.publication_receipt_path // ""' "$GENERATION_LOCK_FILE")" == "$receipt_rel" ]] && pass "generation lock receipt path matches routing" || fail "generation lock receipt path mismatch"
  [[ "$(yq -r '.publication_receipt_sha256 // ""' "$GENERATION_LOCK_FILE")" == "$receipt_sha" ]] && pass "generation lock receipt hash current" || fail "generation lock receipt hash stale"
  [[ "$(yq -r '.publication_status // ""' "$GENERATION_LOCK_FILE")" == "$routing_status" ]] && pass "generation lock publication status matches routing" || fail "generation lock publication status mismatch"

  local root_sha commands_sha skills_sha skills_registry_sha services_sha tools_sha instance_commands_sha instance_skills_sha locality_scopes_sha locality_lock_sha locality_generation_id extensions_sha extensions_lock_sha extensions_generation_id
  root_sha="$(hash_file "$ROOT_MANIFEST")"
  commands_sha="$(hash_file "$COMMANDS_MANIFEST")"
  skills_sha="$(hash_file "$SKILLS_MANIFEST")"
  skills_registry_sha="$(hash_file "$SKILLS_REGISTRY")"
  services_sha="$(hash_file "$SERVICES_MANIFEST")"
  tools_sha="$(hash_file "$TOOLS_MANIFEST")"
  instance_commands_sha="$(hash_file "$INSTANCE_COMMANDS_MANIFEST")"
  instance_skills_sha="$(hash_file "$INSTANCE_SKILLS_MANIFEST")"
  locality_scopes_sha="$(hash_file "$LOCALITY_SCOPES")"
  locality_lock_sha="$(hash_file "$LOCALITY_LOCK")"
  locality_generation_id="$(yq -r '.generation_id // ""' "$LOCALITY_LOCK")"
  extensions_sha="$(hash_file "$EXTENSIONS_CATALOG")"
  extensions_lock_sha="$(hash_file "$EXTENSIONS_LOCK")"
  extensions_generation_id="$(yq -r '.generation_id // ""' "$EXTENSIONS_LOCK")"

  [[ "$(yq -r '.source.root_manifest_sha256 // ""' "$ROUTING_FILE")" == "$root_sha" ]] && pass "routing root manifest hash current" || fail "routing root manifest hash stale"
  [[ "$(yq -r '.root_manifest_sha256 // ""' "$GENERATION_LOCK_FILE")" == "$root_sha" ]] && pass "generation lock root manifest hash current" || fail "generation lock root manifest hash stale"
  [[ "$(yq -r '.source.framework_commands_manifest_sha256 // ""' "$ROUTING_FILE")" == "$commands_sha" ]] && pass "routing commands manifest hash current" || fail "routing commands manifest hash stale"
  [[ "$(yq -r '.framework_commands_manifest_sha256 // ""' "$GENERATION_LOCK_FILE")" == "$commands_sha" ]] && pass "generation lock commands manifest hash current" || fail "generation lock commands manifest hash stale"
  [[ "$(yq -r '.source.framework_skills_manifest_sha256 // ""' "$ROUTING_FILE")" == "$skills_sha" ]] && pass "routing skills manifest hash current" || fail "routing skills manifest hash stale"
  [[ "$(yq -r '.framework_skills_manifest_sha256 // ""' "$GENERATION_LOCK_FILE")" == "$skills_sha" ]] && pass "generation lock skills manifest hash current" || fail "generation lock skills manifest hash stale"
  [[ "$(yq -r '.source.framework_skills_registry_sha256 // ""' "$ROUTING_FILE")" == "$skills_registry_sha" ]] && pass "routing skills registry hash current" || fail "routing skills registry hash stale"
  [[ "$(yq -r '.framework_skills_registry_sha256 // ""' "$GENERATION_LOCK_FILE")" == "$skills_registry_sha" ]] && pass "generation lock skills registry hash current" || fail "generation lock skills registry hash stale"
  [[ "$(yq -r '.source.framework_services_manifest_sha256 // ""' "$ROUTING_FILE")" == "$services_sha" ]] && pass "routing services manifest hash current" || fail "routing services manifest hash stale"
  [[ "$(yq -r '.framework_services_manifest_sha256 // ""' "$GENERATION_LOCK_FILE")" == "$services_sha" ]] && pass "generation lock services manifest hash current" || fail "generation lock services manifest hash stale"
  [[ "$(yq -r '.source.framework_tools_manifest_sha256 // ""' "$ROUTING_FILE")" == "$tools_sha" ]] && pass "routing tools manifest hash current" || fail "routing tools manifest hash stale"
  [[ "$(yq -r '.framework_tools_manifest_sha256 // ""' "$GENERATION_LOCK_FILE")" == "$tools_sha" ]] && pass "generation lock tools manifest hash current" || fail "generation lock tools manifest hash stale"
  [[ "$(yq -r '.source.instance_commands_manifest_sha256 // ""' "$ROUTING_FILE")" == "$instance_commands_sha" ]] && pass "routing instance commands manifest hash current" || fail "routing instance commands manifest hash stale"
  [[ "$(yq -r '.instance_commands_manifest_sha256 // ""' "$GENERATION_LOCK_FILE")" == "$instance_commands_sha" ]] && pass "generation lock instance commands manifest hash current" || fail "generation lock instance commands manifest hash stale"
  [[ "$(yq -r '.source.instance_skills_manifest_sha256 // ""' "$ROUTING_FILE")" == "$instance_skills_sha" ]] && pass "routing instance skills manifest hash current" || fail "routing instance skills manifest hash stale"
  [[ "$(yq -r '.instance_skills_manifest_sha256 // ""' "$GENERATION_LOCK_FILE")" == "$instance_skills_sha" ]] && pass "generation lock instance skills manifest hash current" || fail "generation lock instance skills manifest hash stale"
  [[ "$(yq -r '.source.locality_scopes_effective_sha256 // ""' "$ROUTING_FILE")" == "$locality_scopes_sha" ]] && pass "routing locality scopes hash current" || fail "routing locality scopes hash stale"
  [[ "$(yq -r '.locality_scopes_sha256 // ""' "$GENERATION_LOCK_FILE")" == "$locality_scopes_sha" ]] && pass "generation lock locality scopes hash current" || fail "generation lock locality scopes hash stale"
  [[ "$(yq -r '.source.locality_generation_lock_sha256 // ""' "$ROUTING_FILE")" == "$locality_lock_sha" ]] && pass "routing locality lock hash current" || fail "routing locality lock hash stale"
  [[ "$(yq -r '.locality_generation_lock_sha256 // ""' "$GENERATION_LOCK_FILE")" == "$locality_lock_sha" ]] && pass "generation lock locality lock hash current" || fail "generation lock locality lock hash stale"
  [[ "$(yq -r '.routing_context.locality_generation_id // ""' "$ROUTING_FILE")" == "$locality_generation_id" ]] && pass "routing locality generation id current" || fail "routing locality generation id stale"
  [[ "$(yq -r '.locality_generation_id // ""' "$GENERATION_LOCK_FILE")" == "$locality_generation_id" ]] && pass "generation lock locality generation id current" || fail "generation lock locality generation id stale"
  [[ "$(yq -r '.source.extensions_catalog_sha256 // ""' "$ROUTING_FILE")" == "$extensions_sha" ]] && pass "routing extensions catalog hash current" || fail "routing extensions catalog hash stale"
  [[ "$(yq -r '.extensions_catalog_sha256 // ""' "$GENERATION_LOCK_FILE")" == "$extensions_sha" ]] && pass "generation lock extensions catalog hash current" || fail "generation lock extensions catalog hash stale"
  [[ "$(yq -r '.source.extensions_generation_lock_sha256 // ""' "$ROUTING_FILE")" == "$extensions_lock_sha" ]] && pass "routing extensions lock hash current" || fail "routing extensions lock hash stale"
  [[ "$(yq -r '.extensions_generation_lock_sha256 // ""' "$GENERATION_LOCK_FILE")" == "$extensions_lock_sha" ]] && pass "generation lock extensions lock hash current" || fail "generation lock extensions lock hash stale"
  [[ "$(yq -r '.routing_context.extension_generation_id // ""' "$ROUTING_FILE")" == "$extensions_generation_id" ]] && pass "routing extensions generation id current" || fail "routing extensions generation id stale"
  [[ "$(yq -r '.extensions_generation_id // ""' "$GENERATION_LOCK_FILE")" == "$extensions_generation_id" ]] && pass "generation lock extensions generation id current" || fail "generation lock extensions generation id stale"

  [[ "$(yq -r '.routing_context.selector_schema_version // ""' "$ROUTING_FILE")" == "octon-capability-routing-selectors-v1" ]] && pass "routing selector schema version valid" || fail "routing selector schema version invalid"
  [[ "$(yq -r '.routing_context.host_projection_mode // ""' "$ROUTING_FILE")" == "materialized-copy-v1" ]] && pass "routing host projection mode valid" || fail "routing host projection mode invalid"

  local candidate_count artifact_count resolution_count
  candidate_count="$(yq -r '.routing_candidates | length' "$ROUTING_FILE")"
  artifact_count="$(yq -r '.artifacts | length' "$ARTIFACT_MAP_FILE")"
  resolution_count="$(yq -r '.resolution_order | length' "$ROUTING_FILE")"
  [[ "$candidate_count" == "$artifact_count" ]] && pass "artifact map count matches routing candidates" || fail "artifact map count mismatch"
  [[ "$candidate_count" == "$resolution_count" ]] && pass "resolution order count matches routing candidates" || fail "resolution order count mismatch"

  local artifact_ids_from_routing artifact_ids_from_map resolution_from_candidates resolution_order
  artifact_ids_from_routing="$(yq -r '.routing_candidates[]?.artifact_map_id // ""' "$ROUTING_FILE" | awk 'NF' | LC_ALL=C sort)"
  artifact_ids_from_map="$(yq -r '.artifacts[]?.artifact_map_id // ""' "$ARTIFACT_MAP_FILE" | awk 'NF' | LC_ALL=C sort)"
  [[ "$artifact_ids_from_routing" == "$artifact_ids_from_map" ]] && pass "artifact map ids match published routing candidates" || fail "artifact map ids do not match published routing candidates"

  resolution_from_candidates="$(yq -r '.routing_candidates[]?.effective_id // ""' "$ROUTING_FILE" | awk 'NF')"
  resolution_order="$(yq -r '.resolution_order[]? // ""' "$ROUTING_FILE" | awk 'NF')"
  [[ "$resolution_from_candidates" == "$resolution_order" ]] && pass "resolution order matches routing candidate order" || fail "resolution order mismatch"

  local file_set
  file_set="$(yq -r '.published_files[]?.path // ""' "$GENERATION_LOCK_FILE" | awk 'NF' | LC_ALL=C sort)"
  if [[ "$file_set" == $'.octon/generated/effective/capabilities/artifact-map.yml\n.octon/generated/effective/capabilities/generation.lock.yml\n.octon/generated/effective/capabilities/routing.effective.yml' ]]; then
    pass "generation lock published_files set valid"
  else
    fail "generation lock published_files set invalid"
  fi

  local source_path source_sha
  while IFS=$'\t' read -r source_path source_sha; do
    [[ -n "$source_path" ]] || continue
    if [[ ! -f "$ROOT_DIR/$source_path" ]]; then
      fail "capability source path missing: $source_path"
      continue
    fi
    [[ "$(hash_file "$ROOT_DIR/$source_path")" == "$source_sha" ]] && pass "capability source digest current for $source_path" || fail "capability source digest stale for $source_path"
  done < <(yq -r '.artifacts[]? | [.source_path, .source_sha256] | @tsv' "$ARTIFACT_MAP_FILE" 2>/dev/null || true)

  local field_query
  for field_query in \
    '.routing_candidates[]?.host_adapters' \
    '.routing_candidates[]?.selectors' \
    '.routing_candidates[]?.fingerprints' \
    '.routing_candidates[]?.scope_relevance' \
    '.routing_candidates[]?.precedence_tier' \
    '.routing_candidates[]?.stable_sort_key'
  do
    if yq -e "$field_query" "$ROUTING_FILE" >/dev/null 2>&1; then
      pass "routing candidate field present for query: $field_query"
    else
      fail "routing candidate field missing for query: $field_query"
    fi
  done

  local active_scope_ids_json inactive_scope_hits
  active_scope_ids_json="$(yq -o=json '.' "$LOCALITY_SCOPES" | jq -c 'if has("active_scope_ids") then (.active_scope_ids // []) else ((.scopes // []) | map(select((.status // "active") == "active") | .scope_id)) end')"
  inactive_scope_hits="$(yq -o=json '.' "$ROUTING_FILE" | jq -r --argjson active "$active_scope_ids_json" '
    [
      .routing_candidates[]?
      | .effective_id as $effective_id
      | (
          (.scope_relevance.matching_scope_ids // [])
          + (.scope_relevance.preferred_domain_match_scope_ids // [])
          + (.scope_relevance.preferred_kind_match_scope_ids // [])
        )[]?
      | select($active | index(.) | not)
      | "\($effective_id)\t\(.)"
    ] | unique[]?
  ')"
  if [[ -z "$inactive_scope_hits" ]]; then
    pass "routing scope relevance limited to active scopes"
  else
    fail "routing scope relevance references inactive scopes: $inactive_scope_hits"
  fi

  if rg -n 'inputs/additive|inputs/exploratory' "$ROUTING_FILE" "$ARTIFACT_MAP_FILE" "$GENERATION_LOCK_FILE" >/dev/null 2>&1; then
    fail "capability publication must not embed raw inputs/** paths"
  else
    pass "capability publication avoids raw inputs/** paths"
  fi

  if yq -e '.invalidation_conditions | length > 0' "$ROUTING_FILE" >/dev/null 2>&1 \
    && yq -e '.invalidation_conditions | length > 0' "$GENERATION_LOCK_FILE" >/dev/null 2>&1; then
    pass "capability publication family declares invalidation conditions"
  else
    fail "capability publication family must declare invalidation conditions"
  fi

  if yq -e '.required_inputs[]? | select(. == ".octon/generated/effective/locality/generation.lock.yml")' "$GENERATION_LOCK_FILE" >/dev/null 2>&1 \
    && yq -e '.required_inputs[]? | select(. == ".octon/generated/effective/extensions/generation.lock.yml")' "$GENERATION_LOCK_FILE" >/dev/null 2>&1; then
    pass "generation lock required inputs include effective upstream locks"
  else
    fail "generation lock required inputs missing effective upstream locks"
  fi

  echo "Validation summary: errors=$errors"
  if [[ $errors -gt 0 ]]; then
    exit 1
  fi
}

main "$@"
