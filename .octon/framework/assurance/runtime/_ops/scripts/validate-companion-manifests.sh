#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../../" && pwd)"
OCTON_DIR="${OCTON_DIR_OVERRIDE:-$DEFAULT_OCTON_DIR}"
ROOT_DIR="${OCTON_ROOT_DIR:-$(cd -- "$OCTON_DIR/.." && pwd)}"

ROOT_MANIFEST="$OCTON_DIR/octon.yml"
FRAMEWORK_MANIFEST="$OCTON_DIR/framework/manifest.yml"
INSTANCE_MANIFEST="$OCTON_DIR/instance/manifest.yml"
EXTENSIONS_MANIFEST="$OCTON_DIR/instance/extensions.yml"

errors=0

fail() {
  echo "[ERROR] $1"
  errors=$((errors + 1))
}

pass() {
  echo "[OK] $1"
}

require_yaml_file() {
  local file="$1"
  local label="$2"
  if [[ ! -f "$file" ]]; then
    fail "$label"
    return 1
  fi
  pass "$label"
  if yq -e '.' "$file" >/dev/null 2>&1; then
    pass "${file#$ROOT_DIR/} parses as YAML"
    return 0
  fi
  fail "${file#$ROOT_DIR/} must parse as YAML"
  return 1
}

main() {
  echo "== Companion Manifest Validation =="

  require_yaml_file "$ROOT_MANIFEST" "found file: ${ROOT_MANIFEST#$ROOT_DIR/}"
  require_yaml_file "$FRAMEWORK_MANIFEST" "found file: ${FRAMEWORK_MANIFEST#$ROOT_DIR/}"
  require_yaml_file "$INSTANCE_MANIFEST" "found file: ${INSTANCE_MANIFEST#$ROOT_DIR/}"
  require_yaml_file "$EXTENSIONS_MANIFEST" "found file: ${EXTENSIONS_MANIFEST#$ROOT_DIR/}"

  local framework_schema instance_schema root_framework_schema root_instance_schema
  framework_schema="$(yq -r '.schema_version // ""' "$FRAMEWORK_MANIFEST")"
  instance_schema="$(yq -r '.schema_version // ""' "$INSTANCE_MANIFEST")"
  root_framework_schema="$(yq -r '.versioning.harness.supported_schema_versions[]? | select(. == "octon-framework-manifest-v2")' "$ROOT_MANIFEST" 2>/dev/null || true)"
  root_instance_schema="$(yq -r '.versioning.harness.supported_schema_versions[]? | select(. == "octon-instance-manifest-v1")' "$ROOT_MANIFEST" 2>/dev/null || true)"

  [[ "$framework_schema" == "octon-framework-manifest-v2" ]] && pass "framework manifest schema version valid" || fail "framework manifest schema_version must be octon-framework-manifest-v2"
  [[ "$instance_schema" == "octon-instance-manifest-v1" ]] && pass "instance manifest schema version valid" || fail "instance manifest schema_version must be octon-instance-manifest-v1"
  [[ -n "$root_framework_schema" ]] && pass "root manifest supports framework manifest schema v2" || fail "root manifest must support octon-framework-manifest-v2"
  [[ -n "$root_instance_schema" ]] && pass "root manifest supports instance manifest schema v1" || fail "root manifest must support octon-instance-manifest-v1"

  local framework_id instance_framework_id overlay_registry
  framework_id="$(yq -r '.framework_id // ""' "$FRAMEWORK_MANIFEST")"
  instance_framework_id="$(yq -r '.framework_id // ""' "$INSTANCE_MANIFEST")"
  overlay_registry="$(yq -r '.overlay_registry // ""' "$FRAMEWORK_MANIFEST")"

  [[ -n "$framework_id" ]] && pass "framework_id declared" || fail "framework manifest missing framework_id"
  [[ -n "$(yq -r '.release_version // ""' "$FRAMEWORK_MANIFEST")" ]] && pass "framework release version declared" || fail "framework manifest missing release_version"
  [[ -n "$overlay_registry" ]] && pass "overlay registry declared" || fail "framework manifest missing overlay_registry"
  if [[ -n "$overlay_registry" && -f "$ROOT_DIR/$overlay_registry" ]]; then
    pass "overlay registry path resolves"
  else
    fail "overlay registry path must resolve"
  fi

  if yq -e '.supported_instance_schema_versions[] | select(. == "octon-instance-manifest-v1")' "$FRAMEWORK_MANIFEST" >/dev/null 2>&1; then
    pass "framework manifest supports octon-instance-manifest-v1"
  else
    fail "framework manifest must support octon-instance-manifest-v1"
  fi

  if yq -e '.subsystems | length > 0' "$FRAMEWORK_MANIFEST" >/dev/null 2>&1; then
    pass "framework subsystem list declared"
  else
    fail "framework manifest must declare subsystems"
  fi

  if yq -e '.generators | length > 0' "$FRAMEWORK_MANIFEST" >/dev/null 2>&1; then
    pass "framework generator list declared"
  else
    fail "framework manifest must declare generators"
  fi

  if yq -e '.bundled_policy_sets | length > 0' "$FRAMEWORK_MANIFEST" >/dev/null 2>&1; then
    pass "framework bundled_policy_sets declared"
  else
    fail "framework manifest must declare bundled_policy_sets"
  fi

  while IFS= read -r path; do
    [[ -z "$path" ]] && continue
    if [[ -e "$ROOT_DIR/$path" ]]; then
      pass "bundled policy-set path resolves: $path"
    else
      fail "bundled policy-set path missing: $path"
    fi
  done < <(yq -r '.bundled_policy_sets[]?' "$FRAMEWORK_MANIFEST" 2>/dev/null || true)

  [[ -n "$(yq -r '.instance_id // ""' "$INSTANCE_MANIFEST")" ]] && pass "instance_id declared" || fail "instance manifest missing instance_id"
  if [[ -n "$framework_id" && "$instance_framework_id" == "$framework_id" ]]; then
    pass "instance manifest framework_id matches framework manifest"
  else
    fail "instance manifest framework_id must match framework manifest"
  fi

  if yq -e '.enabled_overlay_points | length > 0' "$INSTANCE_MANIFEST" >/dev/null 2>&1; then
    pass "enabled_overlay_points declared"
  else
    fail "instance manifest must declare enabled_overlay_points"
  fi

  local locality_registry locality_manifest
  locality_registry="$(yq -r '.locality.registry_path // ""' "$INSTANCE_MANIFEST")"
  locality_manifest="$(yq -r '.locality.manifest_path // ""' "$INSTANCE_MANIFEST")"
  if [[ -n "$locality_registry" && -f "$ROOT_DIR/$locality_registry" ]]; then
    pass "instance locality registry path resolves"
  else
    fail "instance locality.registry_path must resolve"
  fi
  if [[ -n "$locality_manifest" && -f "$ROOT_DIR/$locality_manifest" ]]; then
    pass "instance locality manifest path resolves"
  else
    fail "instance locality.manifest_path must resolve"
  fi

  if yq -e '.feature_toggles | tag == "!!map"' "$INSTANCE_MANIFEST" >/dev/null 2>&1; then
    pass "instance feature_toggles map declared"
  else
    fail "instance manifest must declare feature_toggles as a map"
  fi

  [[ "$(yq -r '.schema_version // ""' "$EXTENSIONS_MANIFEST")" == "octon-instance-extensions-v1" ]] && pass "instance extensions schema version valid" || fail "instance/extensions.yml must use schema_version octon-instance-extensions-v1"
  if yq -e '.selection.enabled | tag == "!!seq"' "$EXTENSIONS_MANIFEST" >/dev/null 2>&1; then
    pass "instance extension selection.enabled list declared"
  else
    fail "instance/extensions.yml must declare selection.enabled as a list"
  fi
  if yq -e '.sources | tag == "!!map"' "$EXTENSIONS_MANIFEST" >/dev/null 2>&1; then
    pass "instance extension sources map declared"
  else
    fail "instance/extensions.yml must declare sources as a map"
  fi
  if yq -e '.trust | tag == "!!map"' "$EXTENSIONS_MANIFEST" >/dev/null 2>&1; then
    pass "instance extension trust map declared"
  else
    fail "instance/extensions.yml must declare trust as a map"
  fi
  if yq -e '.acknowledgements | tag == "!!seq"' "$EXTENSIONS_MANIFEST" >/dev/null 2>&1; then
    pass "instance extension acknowledgements list declared"
  else
    fail "instance/extensions.yml must declare acknowledgements as a list"
  fi

  echo "Validation summary: errors=$errors"
  if [[ $errors -gt 0 ]]; then
    exit 1
  fi
}

main "$@"
