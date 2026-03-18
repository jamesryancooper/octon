#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../../" && pwd)"
ROOT_DIR="$(cd -- "$OCTON_DIR/.." && pwd)"

ROOT_MANIFEST="$OCTON_DIR/octon.yml"
EXTENSIONS_MANIFEST="$OCTON_DIR/instance/extensions.yml"
ACTIVE_STATE="$OCTON_DIR/state/control/extensions/active.yml"
QUARANTINE_STATE="$OCTON_DIR/state/control/extensions/quarantine.yml"
EFFECTIVE_DIR="$OCTON_DIR/generated/effective/extensions"
CATALOG_FILE="$EFFECTIVE_DIR/catalog.effective.yml"
ARTIFACT_MAP_FILE="$EFFECTIVE_DIR/artifact-map.yml"
GENERATION_LOCK_FILE="$EFFECTIVE_DIR/generation.lock.yml"

declare -A PACK_STATE=()
declare -A PACK_VERSIONS=()
declare -A PACK_MANIFEST_DIGESTS=()
declare -A PACK_MANIFEST_PATHS=()
declare -a SELECTED_PACKS=()
declare -a RESOLVED_PACKS=()

ERROR_REASON=""
PUBLISHED_AT=""
GENERATION_ID=""

hash_file() {
  local file="$1"
  if command -v shasum >/dev/null 2>&1; then
    shasum -a 256 "$file" | awk '{print $1}'
  else
    sha256sum "$file" | awk '{print $1}'
  fi
}

trim() {
  local value="$1"
  value="${value#"${value%%[![:space:]]*}"}"
  value="${value%"${value##*[![:space:]]}"}"
  printf '%s' "$value"
}

version_to_parts() {
  local version="$1"
  if [[ ! "$version" =~ ^([0-9]+)\.([0-9]+)\.([0-9]+)$ ]]; then
    return 1
  fi
  printf '%s %s %s\n' "${BASH_REMATCH[1]}" "${BASH_REMATCH[2]}" "${BASH_REMATCH[3]}"
}

compare_versions() {
  local left="$1" right="$2"
  local lmaj lmin lpatch rmaj rmin rpatch
  read -r lmaj lmin lpatch < <(version_to_parts "$left") || return 2
  read -r rmaj rmin rpatch < <(version_to_parts "$right") || return 2
  if (( lmaj < rmaj )); then echo -1; return 0; fi
  if (( lmaj > rmaj )); then echo 1; return 0; fi
  if (( lmin < rmin )); then echo -1; return 0; fi
  if (( lmin > rmin )); then echo 1; return 0; fi
  if (( lpatch < rpatch )); then echo -1; return 0; fi
  if (( lpatch > rpatch )); then echo 1; return 0; fi
  echo 0
}

version_satisfies() {
  local version="$1" range="$2"

  if [[ "$range" == "*" ]]; then
    return 0
  fi

  if [[ "$range" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    [[ "$version" == "$range" ]]
    return
  fi

  if [[ "$range" =~ ^\^([0-9]+)\.([0-9]+)\.([0-9]+)$ ]]; then
    local major="${BASH_REMATCH[1]}"
    local minor="${BASH_REMATCH[2]}"
    local patch="${BASH_REMATCH[3]}"
    local lower="${major}.${minor}.${patch}"
    local upper
    if (( major > 0 )); then
      upper="$((major + 1)).0.0"
    elif (( minor > 0 )); then
      upper="0.$((minor + 1)).0"
    else
      upper="0.0.$((patch + 1))"
    fi

    local lower_cmp upper_cmp
    lower_cmp="$(compare_versions "$version" "$lower")" || return 1
    upper_cmp="$(compare_versions "$version" "$upper")" || return 1
    [[ "$lower_cmp" != "-1" && "$upper_cmp" == "-1" ]]
    return
  fi

  return 1
}

unique_sorted() {
  printf '%s\n' "$@" | awk 'NF' | sort -u
}

load_selected_packs() {
  mapfile -t SELECTED_PACKS < <(yq -r '.selection.enabled[]?' "$EXTENSIONS_MANIFEST" 2>/dev/null || true)
}

pack_manifest_path() {
  local pack_id="$1"
  printf '%s\n' "$OCTON_DIR/inputs/additive/extensions/$pack_id/pack.yml"
}

record_failure() {
  ERROR_REASON="$1"
  return 1
}

validate_pack_manifest() {
  local pack_id="$1" manifest="$2"
  local manifest_id pack_version octon_range ext_api

  manifest_id="$(yq -r '.id // ""' "$manifest")"
  pack_version="$(yq -r '.version // ""' "$manifest")"
  octon_range="$(yq -r '.compatibility.octon_version // ""' "$manifest")"
  ext_api="$(yq -r '.compatibility.extensions_api_version // ""' "$manifest")"

  [[ "$manifest_id" == "$pack_id" ]] || record_failure "manifest-id-mismatch:$pack_id"
  [[ -n "$pack_version" ]] || record_failure "missing-version:$pack_id"
  [[ -n "$octon_range" ]] || record_failure "missing-octon-version:$pack_id"
  [[ -n "$ext_api" ]] || record_failure "missing-extensions-api:$pack_id"
  yq -e '.dependencies.requires | tag == "!!seq"' "$manifest" >/dev/null 2>&1 || record_failure "missing-requires:$pack_id"
  yq -e '.dependencies.conflicts | tag == "!!seq"' "$manifest" >/dev/null 2>&1 || record_failure "missing-conflicts:$pack_id"

  version_satisfies "$(yq -r '.versioning.harness.release_version // ""' "$ROOT_MANIFEST")" "$octon_range" \
    || record_failure "compatibility-failure:$pack_id"
  [[ "$ext_api" == "$(yq -r '.versioning.extensions.api_version // ""' "$ROOT_MANIFEST")" ]] \
    || record_failure "extensions-api-mismatch:$pack_id"

  PACK_VERSIONS["$pack_id"]="$pack_version"
  PACK_MANIFEST_DIGESTS["$pack_id"]="$(hash_file "$manifest")"
  PACK_MANIFEST_PATHS["$pack_id"]=".octon/inputs/additive/extensions/$pack_id/pack.yml"
}

resolve_pack() {
  local pack_id="$1"
  local state="${PACK_STATE["$pack_id"]:-}"
  local manifest dep_id dep_range

  if [[ "$state" == "visiting" ]]; then
    record_failure "dependency-cycle:$pack_id"
    return 1
  fi
  if [[ "$state" == "resolved" ]]; then
    return 0
  fi

  manifest="$(pack_manifest_path "$pack_id")"
  [[ -f "$manifest" ]] || {
    record_failure "missing-pack:$pack_id"
    return 1
  }

  validate_pack_manifest "$pack_id" "$manifest" || return 1
  PACK_STATE["$pack_id"]="visiting"

  while IFS=$'\t' read -r dep_id dep_range; do
    [[ -z "$dep_id" ]] && continue
    resolve_pack "$dep_id" || return 1
    version_satisfies "${PACK_VERSIONS["$dep_id"]:-}" "$dep_range" || {
      record_failure "dependency-version-mismatch:$pack_id->$dep_id"
      return 1
    }
  done < <(yq -r '.dependencies.requires[]? | [.id, .version_range] | @tsv' "$manifest")

  PACK_STATE["$pack_id"]="resolved"
  RESOLVED_PACKS+=("$pack_id")
  return 0
}

check_conflicts() {
  local pack_id manifest conflict_id conflict_range
  for pack_id in "${RESOLVED_PACKS[@]}"; do
    manifest="$(pack_manifest_path "$pack_id")"
    while IFS=$'\t' read -r conflict_id conflict_range; do
      [[ -z "$conflict_id" ]] && continue
      if [[ -n "${PACK_STATE["$conflict_id"]:-}" ]]; then
        version_satisfies "${PACK_VERSIONS["$conflict_id"]:-}" "$conflict_range" && {
          record_failure "declared-conflict:$pack_id->$conflict_id"
          return 1
        }
      fi
    done < <(yq -r '.dependencies.conflicts[]? | [.id, .version_range] | @tsv' "$manifest")
  done
}

write_yaml_list() {
  local key="$1"
  shift
  local values=("$@")
  if [[ "${#values[@]}" -eq 0 ]]; then
    printf '%s: []\n' "$key"
    return
  fi
  printf '%s:\n' "$key"
  local value
  for value in "${values[@]}"; do
    printf '  - "%s"\n' "$value"
  done
}

write_effective_files() {
  local desired_sha="$1"
  local root_sha="$2"
  local tmpdir="$3"
  local active_tmp quarantine_tmp catalog_tmp artifact_map_tmp lock_tmp
  local -a active_sorted closure_sorted

  mapfile -t active_sorted < <(unique_sorted "${SELECTED_PACKS[@]}")
  mapfile -t closure_sorted < <(unique_sorted "${RESOLVED_PACKS[@]}")

  active_tmp="$tmpdir/active.yml"
  quarantine_tmp="$tmpdir/quarantine.yml"
  catalog_tmp="$tmpdir/catalog.effective.yml"
  artifact_map_tmp="$tmpdir/artifact-map.yml"
  lock_tmp="$tmpdir/generation.lock.yml"

  {
    printf 'schema_version: "octon-extension-active-state-v1"\n'
    printf 'desired_config_revision:\n'
    printf '  path: ".octon/instance/extensions.yml"\n'
    printf '  sha256: "%s"\n' "$desired_sha"
    write_yaml_list "resolved_active_packs" "${active_sorted[@]}"
    write_yaml_list "dependency_closure" "${closure_sorted[@]}"
    printf 'generation_id: "%s"\n' "$GENERATION_ID"
    printf 'published_effective_catalog: ".octon/generated/effective/extensions/catalog.effective.yml"\n'
    printf 'published_artifact_map: ".octon/generated/effective/extensions/artifact-map.yml"\n'
    printf 'published_generation_lock: ".octon/generated/effective/extensions/generation.lock.yml"\n'
    printf 'validation_timestamp: "%s"\n' "$PUBLISHED_AT"
    printf 'status: "published"\n'
  } >"$active_tmp"

  {
    printf 'schema_version: "octon-extension-quarantine-state-v1"\n'
    printf 'updated_at: "%s"\n' "$PUBLISHED_AT"
    write_yaml_list "blocked_packs"
    write_yaml_list "affected_dependents"
    write_yaml_list "reason_codes"
    write_yaml_list "acknowledgements"
  } >"$quarantine_tmp"

  {
    printf 'schema_version: "octon-extension-effective-catalog-v1"\n'
    printf 'generation_id: "%s"\n' "$GENERATION_ID"
    printf 'published_at: "%s"\n' "$PUBLISHED_AT"
    write_yaml_list "active_packs" "${active_sorted[@]}"
    write_yaml_list "dependency_closure" "${closure_sorted[@]}"
    printf 'source:\n'
    printf '  desired_config_path: ".octon/instance/extensions.yml"\n'
    printf '  desired_config_sha256: "%s"\n' "$desired_sha"
    printf '  root_manifest_path: ".octon/octon.yml"\n'
    printf '  root_manifest_sha256: "%s"\n' "$root_sha"
  } >"$catalog_tmp"

  {
    printf 'schema_version: "octon-extension-artifact-map-v1"\n'
    printf 'generation_id: "%s"\n' "$GENERATION_ID"
    printf 'published_at: "%s"\n' "$PUBLISHED_AT"
    if [[ "${#closure_sorted[@]}" -eq 0 ]]; then
      printf 'artifacts: []\n'
    else
      printf 'artifacts:\n'
      local pack_id
      for pack_id in "${closure_sorted[@]}"; do
        printf '  - pack_id: "%s"\n' "$pack_id"
        printf '    manifest_path: "%s"\n' "${PACK_MANIFEST_PATHS["$pack_id"]}"
        printf '    source_root: ".octon/inputs/additive/extensions/%s/"\n' "$pack_id"
      done
    fi
  } >"$artifact_map_tmp"

  {
    printf 'schema_version: "octon-extension-generation-lock-v1"\n'
    printf 'generation_id: "%s"\n' "$GENERATION_ID"
    printf 'published_at: "%s"\n' "$PUBLISHED_AT"
    printf 'desired_config_sha256: "%s"\n' "$desired_sha"
    printf 'root_manifest_sha256: "%s"\n' "$root_sha"
    if [[ "${#closure_sorted[@]}" -eq 0 ]]; then
      printf 'pack_manifest_digests: []\n'
    else
      printf 'pack_manifest_digests:\n'
      local pack_id
      for pack_id in "${closure_sorted[@]}"; do
        printf '  - pack_id: "%s"\n' "$pack_id"
        printf '    manifest_path: "%s"\n' "${PACK_MANIFEST_PATHS["$pack_id"]}"
        printf '    sha256: "%s"\n' "${PACK_MANIFEST_DIGESTS["$pack_id"]}"
        printf '    version: "%s"\n' "${PACK_VERSIONS["$pack_id"]}"
      done
    fi
  } >"$lock_tmp"

  mkdir -p "$(dirname "$ACTIVE_STATE")" "$EFFECTIVE_DIR"

  # Publish compiled outputs first, then commit the new generation by moving
  # active.yml last. Readers that gate on active state will not observe the new
  # generation until the compiled view and generation lock are already in place.
  mv "$catalog_tmp" "$CATALOG_FILE"
  mv "$artifact_map_tmp" "$ARTIFACT_MAP_FILE"
  mv "$lock_tmp" "$GENERATION_LOCK_FILE"
  mv "$quarantine_tmp" "$QUARANTINE_STATE"
  mv "$active_tmp" "$ACTIVE_STATE"
}

write_quarantine_failure() {
  local tmpdir="$1"
  local desired_sha="$2"
  local quarantine_tmp
  local -a blocked_sorted

  mapfile -t blocked_sorted < <(unique_sorted "${SELECTED_PACKS[@]}")
  quarantine_tmp="$tmpdir/quarantine.yml"
  {
    printf 'schema_version: "octon-extension-quarantine-state-v1"\n'
    printf 'updated_at: "%s"\n' "$PUBLISHED_AT"
    write_yaml_list "blocked_packs" "${blocked_sorted[@]}"
    write_yaml_list "affected_dependents" "${blocked_sorted[@]}"
    write_yaml_list "reason_codes" "$ERROR_REASON"
    write_yaml_list "acknowledgements"
  } >"$quarantine_tmp"

  mkdir -p "$(dirname "$QUARANTINE_STATE")"
  mv "$quarantine_tmp" "$QUARANTINE_STATE"
}

main() {
  PUBLISHED_AT="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  local desired_sha root_sha tmpdir=""
  desired_sha="$(hash_file "$EXTENSIONS_MANIFEST")"
  root_sha="$(hash_file "$ROOT_MANIFEST")"
  GENERATION_ID="extensions-$(printf '%s' "$desired_sha" | cut -c1-12)"

  load_selected_packs
  tmpdir="$(mktemp -d "${TMPDIR:-/tmp}/octon-extension-state.XXXXXX")"
  trap '[[ -n "${tmpdir:-}" ]] && rm -rf "$tmpdir"' EXIT

  local pack_id
  for pack_id in "${SELECTED_PACKS[@]}"; do
    resolve_pack "$pack_id" || break
  done

  if [[ -z "$ERROR_REASON" ]]; then
    check_conflicts || true
  fi

  if [[ -n "$ERROR_REASON" ]]; then
    write_quarantine_failure "$tmpdir" "$desired_sha"
    echo "[ERROR] failed to publish extension state: $ERROR_REASON" >&2
    exit 1
  fi

  write_effective_files "$desired_sha" "$root_sha" "$tmpdir"
  echo "[OK] published extension state: $GENERATION_ID"
}

main "$@"
