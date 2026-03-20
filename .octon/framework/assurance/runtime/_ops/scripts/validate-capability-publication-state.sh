#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../../" && pwd)"
OCTON_DIR="${OCTON_DIR_OVERRIDE:-$DEFAULT_OCTON_DIR}"
ROOT_DIR="${OCTON_ROOT_DIR:-$(cd -- "$OCTON_DIR/.." && pwd)}"

ROOT_MANIFEST="$OCTON_DIR/octon.yml"
EXTENSIONS_CATALOG="$OCTON_DIR/generated/effective/extensions/catalog.effective.yml"
COMMANDS_MANIFEST="$OCTON_DIR/framework/capabilities/runtime/commands/manifest.yml"
SKILLS_MANIFEST="$OCTON_DIR/framework/capabilities/runtime/skills/manifest.yml"
SERVICES_MANIFEST="$OCTON_DIR/framework/capabilities/runtime/services/manifest.yml"
TOOLS_MANIFEST="$OCTON_DIR/framework/capabilities/runtime/tools/manifest.yml"
INSTANCE_CAPABILITIES_DIR="$OCTON_DIR/instance/capabilities/runtime"
EFFECTIVE_DIR="$OCTON_DIR/generated/effective/capabilities"
ROUTING_FILE="$EFFECTIVE_DIR/routing.effective.yml"
ARTIFACT_MAP_FILE="$EFFECTIVE_DIR/artifact-map.yml"
GENERATION_LOCK_FILE="$EFFECTIVE_DIR/generation.lock.yml"
LEGACY_SERVICE_POLICY="$EFFECTIVE_DIR/deny-by-default-policy.catalog.yml"
LEGACY_SKILL_POLICY="$EFFECTIVE_DIR/skills-deny-by-default-policy.catalog.yml"

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

hash_directory_payload() {
  local dir="$1"
  local include_pattern="${2:-}"
  local payload=""
  local file rel sha
  while IFS= read -r file; do
    [[ -n "$file" ]] || continue
    rel="${file#$ROOT_DIR/}"
    sha="$(hash_file "$file")"
    payload+="${rel} ${sha}"$'\n'
  done < <(
    if [[ -n "$include_pattern" ]]; then
      find "$dir" -type f ! -name '.gitkeep' $include_pattern | sort
    else
      find "$dir" -type f ! -name '.gitkeep' | sort
    fi
  )
  if command -v shasum >/dev/null 2>&1; then
    printf '%s' "$payload" | shasum -a 256 | awk '{print $1}'
  else
    printf '%s' "$payload" | sha256sum | awk '{print $1}'
  fi
}

hash_extension_capability_inputs() {
  local payload=""
  local commands_root skills_root file rel sha
  while IFS=$'\t' read -r commands_root skills_root; do
    [[ -n "$commands_root$skills_root" ]] || continue
    if [[ -n "$commands_root" && "$commands_root" != "null" && -d "$ROOT_DIR/$commands_root" ]]; then
      while IFS= read -r file; do
        [[ -n "$file" ]] || continue
        rel="${file#$ROOT_DIR/}"
        sha="$(hash_file "$file")"
        payload+="${rel} ${sha}"$'\n'
      done < <(find "$ROOT_DIR/$commands_root" -type f | sort)
    fi
    if [[ -n "$skills_root" && "$skills_root" != "null" && -d "$ROOT_DIR/$skills_root" ]]; then
      while IFS= read -r file; do
        [[ -n "$file" ]] || continue
        rel="${file#$ROOT_DIR/}"
        sha="$(hash_file "$file")"
        payload+="${rel} ${sha}"$'\n'
      done < <(find "$ROOT_DIR/$skills_root" -type f | sort)
    fi
  done < <(yq -r '.packs[]? | [.content_roots.commands // "", .content_roots.skills // ""] | @tsv' "$EXTENSIONS_CATALOG" 2>/dev/null || true)
  if command -v shasum >/dev/null 2>&1; then
    printf '%s' "$payload" | shasum -a 256 | awk '{print $1}'
  else
    printf '%s' "$payload" | sha256sum | awk '{print $1}'
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
  require_yaml_file "$ROUTING_FILE"
  require_yaml_file "$ARTIFACT_MAP_FILE"
  require_yaml_file "$GENERATION_LOCK_FILE"

  [[ ! -e "$LEGACY_SERVICE_POLICY" ]] && pass "legacy service policy catalog removed from runtime-facing capability surface" || fail "legacy service policy catalog still exists in generated/effective/capabilities"
  [[ ! -e "$LEGACY_SKILL_POLICY" ]] && pass "legacy skill policy catalog removed from runtime-facing capability surface" || fail "legacy skill policy catalog still exists in generated/effective/capabilities"

  [[ "$(yq -r '.schema_version // ""' "$ROUTING_FILE")" == "octon-capability-routing-effective-v1" ]] && pass "routing schema version valid" || fail "routing schema_version invalid"
  [[ "$(yq -r '.schema_version // ""' "$ARTIFACT_MAP_FILE")" == "octon-capability-routing-artifact-map-v1" ]] && pass "artifact map schema version valid" || fail "artifact map schema_version invalid"
  [[ "$(yq -r '.schema_version // ""' "$GENERATION_LOCK_FILE")" == "octon-capability-routing-generation-lock-v1" ]] && pass "generation lock schema version valid" || fail "generation lock schema_version invalid"

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
  [[ "$(yq -r '.publication_status // ""' "$ROUTING_FILE")" == "published" ]] && pass "routing publication_status valid" || fail "routing publication_status invalid"

  local root_sha extensions_sha
  local commands_sha skills_sha services_sha tools_sha instance_sha extension_inputs_sha
  root_sha="$(hash_file "$ROOT_MANIFEST")"
  extensions_sha="$(hash_file "$EXTENSIONS_CATALOG")"
  commands_sha="$(hash_file "$COMMANDS_MANIFEST")"
  skills_sha="$(hash_file "$SKILLS_MANIFEST")"
  services_sha="$(hash_file "$SERVICES_MANIFEST")"
  tools_sha="$(hash_file "$TOOLS_MANIFEST")"
  instance_sha="$(
    {
      find "$INSTANCE_CAPABILITIES_DIR/commands" -type f -name '*.md' ! -name 'README.md' 2>/dev/null
      find "$INSTANCE_CAPABILITIES_DIR/skills" -type f -name 'SKILL.md' 2>/dev/null
    } | sort | while IFS= read -r file; do
      rel="${file#$ROOT_DIR/}"
      sha="$(hash_file "$file")"
      printf '%s %s\n' "$rel" "$sha"
    done | if command -v shasum >/dev/null 2>&1; then shasum -a 256 | awk '{print $1}'; else sha256sum | awk '{print $1}'; fi
  )"
  extension_inputs_sha="$(hash_extension_capability_inputs)"
  [[ "$(yq -r '.source.root_manifest_sha256 // ""' "$ROUTING_FILE")" == "$root_sha" ]] && pass "routing root manifest hash current" || fail "routing root manifest hash stale"
  [[ "$(yq -r '.root_manifest_sha256 // ""' "$GENERATION_LOCK_FILE")" == "$root_sha" ]] && pass "generation lock root manifest hash current" || fail "generation lock root manifest hash stale"
  [[ "$(yq -r '.source.extensions_catalog_sha256 // ""' "$ROUTING_FILE")" == "$extensions_sha" ]] && pass "routing extensions catalog hash current" || fail "routing extensions catalog hash stale"
  [[ "$(yq -r '.extensions_catalog_sha256 // ""' "$GENERATION_LOCK_FILE")" == "$extensions_sha" ]] && pass "generation lock extensions catalog hash current" || fail "generation lock extensions catalog hash stale"
  [[ "$(yq -r '.source.framework_commands_manifest_sha256 // ""' "$ROUTING_FILE")" == "$commands_sha" ]] && pass "routing commands manifest hash current" || fail "routing commands manifest hash stale"
  [[ "$(yq -r '.framework_commands_manifest_sha256 // ""' "$GENERATION_LOCK_FILE")" == "$commands_sha" ]] && pass "generation lock commands manifest hash current" || fail "generation lock commands manifest hash stale"
  [[ "$(yq -r '.source.framework_skills_manifest_sha256 // ""' "$ROUTING_FILE")" == "$skills_sha" ]] && pass "routing skills manifest hash current" || fail "routing skills manifest hash stale"
  [[ "$(yq -r '.framework_skills_manifest_sha256 // ""' "$GENERATION_LOCK_FILE")" == "$skills_sha" ]] && pass "generation lock skills manifest hash current" || fail "generation lock skills manifest hash stale"
  [[ "$(yq -r '.source.framework_services_manifest_sha256 // ""' "$ROUTING_FILE")" == "$services_sha" ]] && pass "routing services manifest hash current" || fail "routing services manifest hash stale"
  [[ "$(yq -r '.framework_services_manifest_sha256 // ""' "$GENERATION_LOCK_FILE")" == "$services_sha" ]] && pass "generation lock services manifest hash current" || fail "generation lock services manifest hash stale"
  [[ "$(yq -r '.source.framework_tools_manifest_sha256 // ""' "$ROUTING_FILE")" == "$tools_sha" ]] && pass "routing tools manifest hash current" || fail "routing tools manifest hash stale"
  [[ "$(yq -r '.framework_tools_manifest_sha256 // ""' "$GENERATION_LOCK_FILE")" == "$tools_sha" ]] && pass "generation lock tools manifest hash current" || fail "generation lock tools manifest hash stale"
  [[ "$(yq -r '.source.instance_capabilities_sha256 // ""' "$ROUTING_FILE")" == "$instance_sha" ]] && pass "routing instance capabilities digest current" || fail "routing instance capabilities digest stale"
  [[ "$(yq -r '.instance_capabilities_sha256 // ""' "$GENERATION_LOCK_FILE")" == "$instance_sha" ]] && pass "generation lock instance capabilities digest current" || fail "generation lock instance capabilities digest stale"
  [[ "$(yq -r '.source.extensions_capability_inputs_sha256 // ""' "$ROUTING_FILE")" == "$extension_inputs_sha" ]] && pass "routing extension capability input digest current" || fail "routing extension capability input digest stale"
  [[ "$(yq -r '.extensions_capability_inputs_sha256 // ""' "$GENERATION_LOCK_FILE")" == "$extension_inputs_sha" ]] && pass "generation lock extension capability input digest current" || fail "generation lock extension capability input digest stale"

  local artifact_ids_from_routing artifact_ids_from_map
  artifact_ids_from_routing="$(yq -r '.routing_candidates[]?.artifact_map_id // ""' "$ROUTING_FILE" | awk 'NF' | LC_ALL=C sort)"
  artifact_ids_from_map="$(yq -r '.artifacts[]?.artifact_map_id // ""' "$ARTIFACT_MAP_FILE" | awk 'NF' | LC_ALL=C sort)"
  [[ "$artifact_ids_from_routing" == "$artifact_ids_from_map" ]] && pass "artifact map ids match published routing candidates" || fail "artifact map ids do not match published routing candidates"

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

  if rg -n 'inputs/additive|inputs/exploratory' "$ROUTING_FILE" "$ARTIFACT_MAP_FILE" "$GENERATION_LOCK_FILE" >/dev/null 2>&1; then
    fail "capability publication must not embed raw inputs/** paths"
  else
    pass "capability publication avoids raw inputs/** paths"
  fi

  echo "Validation summary: errors=$errors"
  if [[ $errors -gt 0 ]]; then
    exit 1
  fi
}

main "$@"
