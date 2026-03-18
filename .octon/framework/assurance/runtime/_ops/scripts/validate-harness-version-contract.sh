#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../../" && pwd)"
OCTON_DIR="${OCTON_DIR_OVERRIDE:-$DEFAULT_OCTON_DIR}"
ROOT_DIR="${OCTON_ROOT_DIR:-$(cd -- "$OCTON_DIR/.." && pwd)}"

MANIFEST_FILE="$OCTON_DIR/octon.yml"

errors=0

fail() {
  echo "[ERROR] $1"
  errors=$((errors + 1))
}

pass() {
  echo "[OK] $1"
}

require_file() {
  local file="$1"
  if [[ ! -f "$file" ]]; then
    fail "missing file: ${file#$ROOT_DIR/}"
  else
    pass "found file: ${file#$ROOT_DIR/}"
  fi
}

yaml_value() {
  local query="$1"
  yq -r "$query // \"\"" "$MANIFEST_FILE"
}

main() {
  echo "== Harness Version Contract Validation =="

  require_file "$MANIFEST_FILE"
  if [[ ! -f "$MANIFEST_FILE" ]]; then
    echo "Validation summary: errors=$errors"
    exit 1
  fi

  if yq -e '.' "$MANIFEST_FILE" >/dev/null 2>&1; then
    pass "root manifest parses as YAML"
  else
    fail "root manifest must parse as YAML"
    echo "Validation summary: errors=$errors"
    exit 1
  fi

  local schema_version
  schema_version="$(yaml_value '.schema_version')"
  if [[ "$schema_version" == "octon-root-manifest-v2" ]]; then
    pass "root schema_version detected: $schema_version"
  else
    fail "root schema_version must be octon-root-manifest-v2 (found '${schema_version:-<empty>}')"
  fi

  if [[ "$(yaml_value '.topology.super_root')" == ".octon/" ]]; then
    pass "topology.super_root declared"
  else
    fail "missing or invalid topology.super_root"
  fi

  if yq -e 'has("class_roots") and .class_roots != null' "$MANIFEST_FILE" >/dev/null 2>&1; then
    fail "legacy top-level class_roots key must be removed"
  else
    pass "legacy top-level class_roots key removed"
  fi

  if yq -e 'has("extensions") and .extensions != null' "$MANIFEST_FILE" >/dev/null 2>&1; then
    fail "legacy top-level extensions key must be removed"
  else
    pass "legacy top-level extensions key removed"
  fi

  if yq -e 'has("human_led") and .human_led != null' "$MANIFEST_FILE" >/dev/null 2>&1; then
    fail "legacy top-level human_led key must be removed"
  else
    pass "legacy top-level human_led key removed"
  fi

  local release_version
  release_version="$(yaml_value '.versioning.harness.release_version')"
  if [[ -n "$release_version" ]]; then
    pass "harness release version declared: $release_version"
  else
    fail "missing versioning.harness.release_version"
  fi

  local supported_count
  supported_count="$(yq -r '.versioning.harness.supported_schema_versions | length // 0' "$MANIFEST_FILE")"
  if [[ "$supported_count" -gt 0 ]]; then
    pass "supported schema versions declared ($supported_count)"
  else
    fail "missing versioning.harness.supported_schema_versions"
  fi

  local rejection_mode
  rejection_mode="$(yaml_value '.versioning.harness.rejection_mode')"
  if [[ "$rejection_mode" == "fail-closed" ]]; then
    pass "rejection mode is fail-closed"
  else
    fail "versioning.harness.rejection_mode must be 'fail-closed' (found '${rejection_mode:-<empty>}')"
  fi

  local migration_workflow migration_overview
  migration_workflow="$(yaml_value '.versioning.harness.migration_workflow')"
  migration_overview="$(yaml_value '.versioning.harness.migration_overview')"

  if [[ -z "$migration_workflow" ]]; then
    fail "missing versioning.harness.migration_workflow"
  elif [[ ! -f "$OCTON_DIR/$migration_workflow" ]]; then
    fail "migration_workflow target missing: .octon/$migration_workflow"
  else
    pass "migration workflow path resolves: .octon/$migration_workflow"
  fi

  if [[ -z "$migration_overview" ]]; then
    fail "missing versioning.harness.migration_overview"
  elif [[ ! -f "$OCTON_DIR/$migration_overview" ]]; then
    fail "migration_overview target missing: .octon/$migration_overview"
  else
    pass "migration overview path resolves: .octon/$migration_overview"
  fi

  local deterministic_count
  deterministic_count="$(yq -r '.versioning.harness.deterministic_upgrade_instructions | length // 0' "$MANIFEST_FILE")"
  if [[ "$deterministic_count" -gt 0 ]]; then
    pass "deterministic upgrade instructions declared ($deterministic_count)"
  else
    fail "missing versioning.harness.deterministic_upgrade_instructions"
  fi

  if yq -e '.versioning.harness.supported_schema_versions[] | select(. == "octon-root-manifest-v2")' "$MANIFEST_FILE" >/dev/null 2>&1; then
    pass "schema_version 'octon-root-manifest-v2' is supported"
  else
    fail "supported_schema_versions must include octon-root-manifest-v2"
  fi

  echo "Validation summary: errors=$errors"
  if [[ $errors -gt 0 ]]; then
    exit 1
  fi
}

main "$@"
