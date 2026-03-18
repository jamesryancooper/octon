#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../../" && pwd)"
ROOT_DIR="$(cd -- "$OCTON_DIR/.." && pwd)"

ROOT_MANIFEST="$OCTON_DIR/octon.yml"
EXTENSIONS_MANIFEST="$OCTON_DIR/instance/extensions.yml"
ACTIVE_STATE="$OCTON_DIR/state/control/extensions/active.yml"
QUARANTINE_STATE="$OCTON_DIR/state/control/extensions/quarantine.yml"
CATALOG_FILE="$OCTON_DIR/generated/effective/extensions/catalog.effective.yml"
ARTIFACT_MAP_FILE="$OCTON_DIR/generated/effective/extensions/artifact-map.yml"
GENERATION_LOCK_FILE="$OCTON_DIR/generated/effective/extensions/generation.lock.yml"

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

list_equals() {
  local file="$1"
  local query="$2"
  shift 2
  local expected=("$@")
  mapfile -t actual < <(yq -r "$query[]?" "$file" 2>/dev/null || true)
  if [[ "${#actual[@]}" -ne "${#expected[@]}" ]]; then
    return 1
  fi
  local i
  for i in "${!expected[@]}"; do
    [[ "${actual[$i]}" == "${expected[$i]}" ]] || return 1
  done
}

main() {
  echo "== Extension Publication State Validation =="

  local file
  for file in "$EXTENSIONS_MANIFEST" "$ACTIVE_STATE" "$QUARANTINE_STATE" "$CATALOG_FILE" "$ARTIFACT_MAP_FILE" "$GENERATION_LOCK_FILE"; do
    if [[ -f "$file" ]]; then
      pass "found file: ${file#$ROOT_DIR/}"
      yq -e '.' "$file" >/dev/null 2>&1 && pass "${file#$ROOT_DIR/} parses as YAML" || fail "${file#$ROOT_DIR/} must parse as YAML"
    else
      fail "missing file: ${file#$ROOT_DIR/}"
    fi
  done

  local desired_sha root_sha generation_id
  desired_sha="$(hash_file "$EXTENSIONS_MANIFEST")"
  root_sha="$(hash_file "$ROOT_MANIFEST")"

  [[ "$(yq -r '.schema_version // ""' "$ACTIVE_STATE")" == "octon-extension-active-state-v1" ]] && pass "active state schema version valid" || fail "active state schema_version invalid"
  [[ "$(yq -r '.schema_version // ""' "$QUARANTINE_STATE")" == "octon-extension-quarantine-state-v1" ]] && pass "quarantine state schema version valid" || fail "quarantine state schema_version invalid"
  [[ "$(yq -r '.schema_version // ""' "$CATALOG_FILE")" == "octon-extension-effective-catalog-v1" ]] && pass "effective catalog schema version valid" || fail "effective catalog schema_version invalid"
  [[ "$(yq -r '.schema_version // ""' "$ARTIFACT_MAP_FILE")" == "octon-extension-artifact-map-v1" ]] && pass "artifact map schema version valid" || fail "artifact map schema_version invalid"
  [[ "$(yq -r '.schema_version // ""' "$GENERATION_LOCK_FILE")" == "octon-extension-generation-lock-v1" ]] && pass "generation lock schema version valid" || fail "generation lock schema_version invalid"

  generation_id="$(yq -r '.generation_id // ""' "$ACTIVE_STATE")"
  [[ -n "$generation_id" ]] && pass "active state generation_id declared" || fail "active state missing generation_id"

  [[ "$(yq -r '.desired_config_revision.path // ""' "$ACTIVE_STATE")" == ".octon/instance/extensions.yml" ]] && pass "active state desired config path valid" || fail "active state desired config path invalid"
  [[ "$(yq -r '.desired_config_revision.sha256 // ""' "$ACTIVE_STATE")" == "$desired_sha" ]] && pass "active state desired config hash current" || fail "active state desired config hash stale"
  [[ "$(yq -r '.status // ""' "$ACTIVE_STATE")" == "published" ]] && pass "active state status is published" || fail "active state status must be published"
  [[ "$(yq -r '.published_effective_catalog // ""' "$ACTIVE_STATE")" == ".octon/generated/effective/extensions/catalog.effective.yml" ]] && pass "active state catalog reference valid" || fail "active state catalog reference invalid"
  [[ "$(yq -r '.published_artifact_map // ""' "$ACTIVE_STATE")" == ".octon/generated/effective/extensions/artifact-map.yml" ]] && pass "active state artifact map reference valid" || fail "active state artifact map reference invalid"
  [[ "$(yq -r '.published_generation_lock // ""' "$ACTIVE_STATE")" == ".octon/generated/effective/extensions/generation.lock.yml" ]] && pass "active state generation lock reference valid" || fail "active state generation lock reference invalid"

  [[ "$(yq -r '.generation_id // ""' "$CATALOG_FILE")" == "$generation_id" ]] && pass "effective catalog generation_id matches active state" || fail "effective catalog generation_id mismatch"
  [[ "$(yq -r '.generation_id // ""' "$ARTIFACT_MAP_FILE")" == "$generation_id" ]] && pass "artifact map generation_id matches active state" || fail "artifact map generation_id mismatch"
  [[ "$(yq -r '.generation_id // ""' "$GENERATION_LOCK_FILE")" == "$generation_id" ]] && pass "generation lock generation_id matches active state" || fail "generation lock generation_id mismatch"

  [[ "$(yq -r '.source.desired_config_sha256 // ""' "$CATALOG_FILE")" == "$desired_sha" ]] && pass "effective catalog desired config hash current" || fail "effective catalog desired config hash stale"
  [[ "$(yq -r '.desired_config_sha256 // ""' "$GENERATION_LOCK_FILE")" == "$desired_sha" ]] && pass "generation lock desired config hash current" || fail "generation lock desired config hash stale"
  [[ "$(yq -r '.source.root_manifest_sha256 // ""' "$CATALOG_FILE")" == "$root_sha" ]] && pass "effective catalog root manifest hash current" || fail "effective catalog root manifest hash stale"
  [[ "$(yq -r '.root_manifest_sha256 // ""' "$GENERATION_LOCK_FILE")" == "$root_sha" ]] && pass "generation lock root manifest hash current" || fail "generation lock root manifest hash stale"

  mapfile -t desired_enabled < <(yq -r '.selection.enabled[]?' "$EXTENSIONS_MANIFEST" 2>/dev/null || true)
  mapfile -t active_packs < <(yq -r '.resolved_active_packs[]?' "$ACTIVE_STATE" 2>/dev/null || true)
  mapfile -t closure < <(yq -r '.dependency_closure[]?' "$ACTIVE_STATE" 2>/dev/null || true)
  mapfile -t catalog_active < <(yq -r '.active_packs[]?' "$CATALOG_FILE" 2>/dev/null || true)
  mapfile -t catalog_closure < <(yq -r '.dependency_closure[]?' "$CATALOG_FILE" 2>/dev/null || true)

  if [[ "$(printf '%s\n' "${desired_enabled[@]}" | awk 'NF' | sort -u)" == "$(printf '%s\n' "${active_packs[@]}" | awk 'NF' | sort -u)" ]]; then
    pass "active state resolved_active_packs match desired selection"
  else
    fail "active state resolved_active_packs do not match desired selection"
  fi

  if [[ "$(printf '%s\n' "${closure[@]}" | awk 'NF' | sort -u)" == "$(printf '%s\n' "${catalog_closure[@]}" | awk 'NF' | sort -u)" ]]; then
    pass "effective catalog dependency_closure matches active state"
  else
    fail "effective catalog dependency_closure does not match active state"
  fi

  if [[ "$(printf '%s\n' "${active_packs[@]}" | awk 'NF' | sort -u)" == "$(printf '%s\n' "${catalog_active[@]}" | awk 'NF' | sort -u)" ]]; then
    pass "effective catalog active_packs match active state"
  else
    fail "effective catalog active_packs do not match active state"
  fi

  if yq -e '.blocked_packs | length == 0' "$QUARANTINE_STATE" >/dev/null 2>&1; then
    pass "quarantine has no blocked packs for published generation"
  else
    fail "quarantine must be empty for the published generation"
  fi

  mapfile -t lock_pack_ids < <(yq -r '.pack_manifest_digests[]?.pack_id' "$GENERATION_LOCK_FILE" 2>/dev/null || true)
  if [[ "$(printf '%s\n' "${lock_pack_ids[@]}" | awk 'NF' | sort -u)" == "$(printf '%s\n' "${closure[@]}" | awk 'NF' | sort -u)" ]]; then
    pass "generation lock pack ids match dependency closure"
  else
    fail "generation lock pack ids do not match dependency closure"
  fi

  while IFS=$'\t' read -r pack_id manifest_path sha256; do
    [[ -z "$pack_id" ]] && continue
    local abs_manifest="$ROOT_DIR/$manifest_path"
    if [[ ! -f "$abs_manifest" ]]; then
      fail "generation lock manifest path missing: $manifest_path"
      continue
    fi
    [[ "$(hash_file "$abs_manifest")" == "$sha256" ]] && pass "generation lock digest current for $pack_id" || fail "generation lock digest stale for $pack_id"
  done < <(yq -r '.pack_manifest_digests[]? | [.pack_id, .manifest_path, .sha256] | @tsv' "$GENERATION_LOCK_FILE")

  echo "Validation summary: errors=$errors"
  if [[ $errors -gt 0 ]]; then
    exit 1
  fi
}

main "$@"
