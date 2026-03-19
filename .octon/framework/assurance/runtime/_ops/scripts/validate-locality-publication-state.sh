#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
OCTON_DIR="${OCTON_DIR_OVERRIDE:-$(cd -- "$SCRIPT_DIR/../../../../../" && pwd)}"
ROOT_DIR="${OCTON_ROOT_DIR:-$(cd -- "$OCTON_DIR/.." && pwd)}"

ROOT_MANIFEST="$OCTON_DIR/octon.yml"
LOCALITY_MANIFEST="$OCTON_DIR/instance/locality/manifest.yml"
LOCALITY_REGISTRY="$OCTON_DIR/instance/locality/registry.yml"
QUARANTINE_STATE="$OCTON_DIR/state/control/locality/quarantine.yml"
SCOPES_EFFECTIVE_FILE="$OCTON_DIR/generated/effective/locality/scopes.effective.yml"
ARTIFACT_MAP_FILE="$OCTON_DIR/generated/effective/locality/artifact-map.yml"
GENERATION_LOCK_FILE="$OCTON_DIR/generated/effective/locality/generation.lock.yml"

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
  echo "== Locality Publication State Validation =="

  require_yaml_file "$LOCALITY_MANIFEST"
  require_yaml_file "$LOCALITY_REGISTRY"
  require_yaml_file "$QUARANTINE_STATE"
  require_yaml_file "$SCOPES_EFFECTIVE_FILE"
  require_yaml_file "$ARTIFACT_MAP_FILE"
  require_yaml_file "$GENERATION_LOCK_FILE"
  require_yaml_file "$ROOT_MANIFEST"

  [[ "$(yq -r '.schema_version // ""' "$QUARANTINE_STATE")" == "octon-locality-quarantine-state-v1" ]] \
    && pass "locality quarantine schema version valid" \
    || fail "locality quarantine schema_version invalid"
  [[ "$(yq -r '.schema_version // ""' "$SCOPES_EFFECTIVE_FILE")" == "octon-locality-effective-scopes-v1" ]] \
    && pass "effective locality schema version valid" \
    || fail "effective locality schema_version invalid"
  [[ "$(yq -r '.schema_version // ""' "$ARTIFACT_MAP_FILE")" == "octon-locality-artifact-map-v1" ]] \
    && pass "locality artifact map schema version valid" \
    || fail "locality artifact map schema_version invalid"
  [[ "$(yq -r '.schema_version // ""' "$GENERATION_LOCK_FILE")" == "octon-locality-generation-lock-v1" ]] \
    && pass "locality generation lock schema version valid" \
    || fail "locality generation lock schema_version invalid"

  local expected_generator_version
  expected_generator_version="$(yq -r '.versioning.harness.release_version // ""' "$ROOT_MANIFEST" 2>/dev/null || true)"
  [[ -n "$expected_generator_version" ]] \
    && pass "root manifest generator version available" \
    || fail "root manifest missing versioning.harness.release_version"
  [[ "$(yq -r '.generator_version // ""' "$SCOPES_EFFECTIVE_FILE")" == "$expected_generator_version" ]] \
    && pass "effective locality generator_version current" \
    || fail "effective locality generator_version missing or stale"
  [[ "$(yq -r '.generator_version // ""' "$ARTIFACT_MAP_FILE")" == "$expected_generator_version" ]] \
    && pass "artifact map generator_version current" \
    || fail "artifact map generator_version missing or stale"
  [[ "$(yq -r '.generator_version // ""' "$GENERATION_LOCK_FILE")" == "$expected_generator_version" ]] \
    && pass "generation lock generator_version current" \
    || fail "generation lock generator_version missing or stale"

  local generation_id
  generation_id="$(yq -r '.generation_id // ""' "$SCOPES_EFFECTIVE_FILE")"
  [[ -n "$generation_id" ]] && pass "effective locality generation_id declared" || fail "effective locality missing generation_id"

  [[ "$(yq -r '.generation_id // ""' "$ARTIFACT_MAP_FILE")" == "$generation_id" ]] \
    && pass "artifact map generation_id matches effective locality" \
    || fail "artifact map generation_id mismatch"
  [[ "$(yq -r '.generation_id // ""' "$GENERATION_LOCK_FILE")" == "$generation_id" ]] \
    && pass "generation lock generation_id matches effective locality" \
    || fail "generation lock generation_id mismatch"

  local manifest_sha registry_sha quarantine_sha
  manifest_sha="$(hash_file "$LOCALITY_MANIFEST")"
  registry_sha="$(hash_file "$LOCALITY_REGISTRY")"
  quarantine_sha="$(hash_file "$QUARANTINE_STATE")"

  [[ "$(yq -r '.source.locality_manifest_sha256 // ""' "$SCOPES_EFFECTIVE_FILE")" == "$manifest_sha" ]] \
    && pass "effective locality manifest hash current" \
    || fail "effective locality manifest hash stale"
  [[ "$(yq -r '.source.locality_registry_sha256 // ""' "$SCOPES_EFFECTIVE_FILE")" == "$registry_sha" ]] \
    && pass "effective locality registry hash current" \
    || fail "effective locality registry hash stale"
  [[ "$(yq -r '.locality_manifest_sha256 // ""' "$GENERATION_LOCK_FILE")" == "$manifest_sha" ]] \
    && pass "generation lock locality manifest hash current" \
    || fail "generation lock locality manifest hash stale"
  [[ "$(yq -r '.locality_registry_sha256 // ""' "$GENERATION_LOCK_FILE")" == "$registry_sha" ]] \
    && pass "generation lock locality registry hash current" \
    || fail "generation lock locality registry hash stale"
  [[ "$(yq -r '.quarantine_sha256 // ""' "$GENERATION_LOCK_FILE")" == "$quarantine_sha" ]] \
    && pass "generation lock quarantine hash current" \
    || fail "generation lock quarantine hash stale"

  if yq -e '.records | length == 0' "$QUARANTINE_STATE" >/dev/null 2>&1; then
    pass "published locality generation has no quarantined scopes"
  else
    fail "published locality generation must not retain active quarantine records"
  fi

  mapfile -t registry_scope_ids < <(yq -r '.scopes[]?.scope_id // ""' "$LOCALITY_REGISTRY" 2>/dev/null | awk 'NF' || true)
  mapfile -t effective_scope_ids < <(yq -r '.scopes[]?.scope_id // ""' "$SCOPES_EFFECTIVE_FILE" 2>/dev/null | awk 'NF' || true)
  mapfile -t artifact_scope_ids < <(yq -r '.artifacts[]?.scope_id // ""' "$ARTIFACT_MAP_FILE" 2>/dev/null | awk 'NF' || true)
  mapfile -t lock_scope_ids < <(yq -r '.scope_manifest_digests[]?.scope_id // ""' "$GENERATION_LOCK_FILE" 2>/dev/null | awk 'NF' || true)

  if [[ "$(printf '%s\n' "${registry_scope_ids[@]}" | sort -u)" == "$(printf '%s\n' "${effective_scope_ids[@]}" | sort -u)" ]]; then
    pass "effective locality scope ids match registry"
  else
    fail "effective locality scope ids do not match registry"
  fi

  if [[ "$(printf '%s\n' "${registry_scope_ids[@]}" | sort -u)" == "$(printf '%s\n' "${artifact_scope_ids[@]}" | sort -u)" ]]; then
    pass "artifact map scope ids match registry"
  else
    fail "artifact map scope ids do not match registry"
  fi

  if [[ "$(printf '%s\n' "${registry_scope_ids[@]}" | sort -u)" == "$(printf '%s\n' "${lock_scope_ids[@]}" | sort -u)" ]]; then
    pass "generation lock scope ids match registry"
  else
    fail "generation lock scope ids do not match registry"
  fi

  local scope_id manifest_path recorded_sha actual_sha active_status
  while IFS=$'\t' read -r scope_id manifest_path recorded_sha; do
    [[ -z "$scope_id" ]] && continue
    actual_sha="$(hash_file "$ROOT_DIR/$manifest_path")"
    [[ "$actual_sha" == "$recorded_sha" ]] \
      && pass "generation lock digest current for $scope_id" \
      || fail "generation lock digest stale for $scope_id"
  done < <(yq -r '.scope_manifest_digests[]? | [.scope_id, .manifest_path, .sha256] | @tsv' "$GENERATION_LOCK_FILE" 2>/dev/null || true)

  while IFS=$'\t' read -r scope_id active_status; do
    [[ -z "$scope_id" ]] && continue
    if [[ "$active_status" == "active" ]]; then
      if yq -e ".active_scope_ids[]? | select(. == \"$scope_id\")" "$SCOPES_EFFECTIVE_FILE" >/dev/null 2>&1; then
        pass "active scope published: $scope_id"
      else
        fail "active scope missing from effective active_scope_ids: $scope_id"
      fi
    fi
  done < <(
    while IFS=$'\t' read -r scope_id manifest_path; do
      [[ -z "$scope_id" ]] && continue
      printf '%s\t%s\n' "$scope_id" "$(yq -r '.status // ""' "$ROOT_DIR/$manifest_path" 2>/dev/null || true)"
    done < <(yq -r '.scopes[]? | [.scope_id // "", .manifest_path // ""] | @tsv' "$LOCALITY_REGISTRY" 2>/dev/null || true)
  )

  echo "Validation summary: errors=$errors"
  if [[ $errors -gt 0 ]]; then
    exit 1
  fi
}

main "$@"
