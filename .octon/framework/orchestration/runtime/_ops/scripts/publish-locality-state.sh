#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../../" && pwd)"
ROOT_DIR="$(cd -- "$OCTON_DIR/.." && pwd)"

ROOT_MANIFEST="$OCTON_DIR/octon.yml"
INSTANCE_MANIFEST="$OCTON_DIR/instance/manifest.yml"
LOCALITY_MANIFEST="$OCTON_DIR/instance/locality/manifest.yml"
LOCALITY_REGISTRY="$OCTON_DIR/instance/locality/registry.yml"
SCOPES_DIR="$OCTON_DIR/instance/locality/scopes"
QUARANTINE_STATE="$OCTON_DIR/state/control/locality/quarantine.yml"
EFFECTIVE_DIR="$OCTON_DIR/generated/effective/locality"
SCOPES_EFFECTIVE_FILE="$EFFECTIVE_DIR/scopes.effective.yml"
ARTIFACT_MAP_FILE="$EFFECTIVE_DIR/artifact-map.yml"
GENERATION_LOCK_FILE="$EFFECTIVE_DIR/generation.lock.yml"
SCOPE_SCHEMA_FILE="$OCTON_DIR/framework/cognition/_meta/architecture/instance/locality/schemas/scope.schema.json"

declare -A SCOPE_MANIFEST_PATHS=()
declare -A SCOPE_MANIFEST_DIGESTS=()
declare -A SCOPE_ROOT_PATHS=()
declare -A SCOPE_DISPLAY_NAMES=()
declare -A SCOPE_OWNERS=()
declare -A SCOPE_STATUSES=()
declare -A SCOPE_TECH_TAGS=()
declare -A SCOPE_LANGUAGE_TAGS=()
declare -A SCOPE_INCLUDE_GLOBS=()
declare -A SCOPE_EXCLUDE_GLOBS=()
declare -A SCOPE_ROUTING_HINTS=()
declare -A SCOPE_MISSION_DEFAULTS=()
declare -a DECLARED_SCOPE_IDS=()
declare -a ACTIVE_SCOPE_IDS=()
declare -a QUARANTINE_RECORDS=()

PUBLISHED_AT=""
GENERATION_ID=""
GENERATOR_VERSION=""

hash_file() {
  local file="$1"
  if command -v shasum >/dev/null 2>&1; then
    shasum -a 256 "$file" | awk '{print $1}'
  else
    sha256sum "$file" | awk '{print $1}'
  fi
}

normalize_path() {
  local path="$1"
  path="${path#./}"
  path="${path%/}"
  if [[ -z "$path" ]]; then
    path="."
  fi
  printf '%s\n' "$path"
}

is_safe_relative_pattern() {
  local pattern="$1"
  [[ -n "$pattern" ]] || return 1
  [[ "$pattern" != /* ]] || return 1
  [[ "$pattern" != *"../"* ]] || return 1
  [[ "$pattern" != "../"* ]] || return 1
  [[ "$pattern" != *"/.." ]] || return 1
  [[ "$pattern" != ".." ]] || return 1
  return 0
}

path_contains() {
  local parent="$1"
  local child="$2"
  if [[ "$parent" == "." ]]; then
    return 0
  fi
  [[ "$child" == "$parent" || "$child" == "$parent/"* ]]
}

glob_anchor_path() {
  local pattern="$1"
  local prefix=""
  local segment
  local IFS='/'
  read -r -a segments <<<"$pattern"
  for segment in "${segments[@]}"; do
    if [[ "$segment" == *'*'* || "$segment" == *'?'* || "$segment" == *'['* || "$segment" == *']'* || "$segment" == *'{'* || "$segment" == *'}'* ]]; then
      break
    fi
    [[ -n "$segment" ]] || continue
    if [[ -z "$prefix" ]]; then
      prefix="$segment"
    else
      prefix="$prefix/$segment"
    fi
  done
  if [[ -z "$prefix" ]]; then
    printf '.\n'
  else
    printf '%s\n' "$prefix"
  fi
}

glob_subordinate_to_root() {
  local root_path="$1"
  local pattern="$2"
  local anchor
  anchor="$(normalize_path "$(glob_anchor_path "$pattern")")"
  path_contains "$root_path" "$anchor"
}

append_quarantine_record() {
  local scope_id="$1"
  local manifest_path="$2"
  local reason_code="$3"
  QUARANTINE_RECORDS+=("$scope_id|$manifest_path|$reason_code")
}

json_compact_or_default() {
  local query="$1"
  local file="$2"
  local default_json="$3"
  local value
  value="$(yq -o=json "$query" "$file" 2>/dev/null || true)"
  if [[ -z "$value" || "$value" == "null" ]]; then
    printf '%s\n' "$default_json"
  else
    printf '%s\n' "$value" | tr -d '\n'
    printf '\n'
  fi
}

yaml_string_list() {
  local query="$1"
  local file="$2"
  yq -r "$query[]?" "$file" 2>/dev/null || true
}

collect_scope() {
  local scope_id="$1"
  local manifest_path="$2"
  local manifest_file="$ROOT_DIR/$manifest_path"

  if [[ ! -f "$manifest_file" ]]; then
    append_quarantine_record "$scope_id" "$manifest_path" "missing-scope-manifest"
    return
  fi

  if ! yq -e '.' "$manifest_file" >/dev/null 2>&1; then
    append_quarantine_record "$scope_id" "$manifest_path" "invalid-scope-yaml"
    return
  fi

  if [[ "$(yq -r '.schema_version // ""' "$manifest_file")" != "octon-locality-scope-v1" ]]; then
    append_quarantine_record "$scope_id" "$manifest_path" "invalid-scope-schema-version"
  fi

  local manifest_scope_id
  manifest_scope_id="$(yq -r '.scope_id // ""' "$manifest_file")"
  if [[ -z "$manifest_scope_id" || "$manifest_scope_id" != "$scope_id" ]]; then
    append_quarantine_record "$scope_id" "$manifest_path" "scope-id-mismatch"
  fi

  local root_path
  root_path="$(yq -r '.root_path // ""' "$manifest_file")"
  if ! yq -e '.root_path | type == "!!str"' "$manifest_file" >/dev/null 2>&1; then
    append_quarantine_record "$scope_id" "$manifest_path" "invalid-root-path-type"
  elif ! is_safe_relative_pattern "$root_path"; then
    append_quarantine_record "$scope_id" "$manifest_path" "invalid-root-path"
  else
    root_path="$(normalize_path "$root_path")"
  fi

  local required_field
  for required_field in display_name owner status; do
    if ! yq -e ".$required_field | type == \"!!str\" and . != \"\"" "$manifest_file" >/dev/null 2>&1; then
      append_quarantine_record "$scope_id" "$manifest_path" "missing-$required_field"
    fi
  done

  if ! yq -e '.tech_tags | type == "!!seq"' "$manifest_file" >/dev/null 2>&1; then
    append_quarantine_record "$scope_id" "$manifest_path" "invalid-tech-tags"
  fi

  if ! yq -e '.language_tags | type == "!!seq"' "$manifest_file" >/dev/null 2>&1; then
    append_quarantine_record "$scope_id" "$manifest_path" "invalid-language-tags"
  fi

  if yq -e 'has("include_globs")' "$manifest_file" >/dev/null 2>&1; then
    if ! yq -e '.include_globs | type == "!!seq"' "$manifest_file" >/dev/null 2>&1; then
      append_quarantine_record "$scope_id" "$manifest_path" "invalid-include-globs"
    else
      local glob
      while IFS= read -r glob; do
        [[ -z "$glob" ]] && continue
        if ! is_safe_relative_pattern "$glob"; then
          append_quarantine_record "$scope_id" "$manifest_path" "invalid-include-glob-pattern"
        elif ! glob_subordinate_to_root "$root_path" "$glob"; then
          append_quarantine_record "$scope_id" "$manifest_path" "include-glob-outside-root"
        fi
      done < <(yaml_string_list '.include_globs' "$manifest_file")
    fi
  fi

  if yq -e 'has("exclude_globs")' "$manifest_file" >/dev/null 2>&1; then
    if ! yq -e '.exclude_globs | type == "!!seq"' "$manifest_file" >/dev/null 2>&1; then
      append_quarantine_record "$scope_id" "$manifest_path" "invalid-exclude-globs"
    else
      local glob
      while IFS= read -r glob; do
        [[ -z "$glob" ]] && continue
        if ! is_safe_relative_pattern "$glob"; then
          append_quarantine_record "$scope_id" "$manifest_path" "invalid-exclude-glob-pattern"
        elif ! glob_subordinate_to_root "$root_path" "$glob"; then
          append_quarantine_record "$scope_id" "$manifest_path" "exclude-glob-outside-root"
        fi
      done < <(yaml_string_list '.exclude_globs' "$manifest_file")
    fi
  fi

  if yq -e 'has("routing_hints")' "$manifest_file" >/dev/null 2>&1; then
    if ! yq -e '.routing_hints | type == "!!map"' "$manifest_file" >/dev/null 2>&1; then
      append_quarantine_record "$scope_id" "$manifest_path" "invalid-routing-hints"
    fi
  fi

  if yq -e 'has("mission_defaults")' "$manifest_file" >/dev/null 2>&1; then
    if ! yq -e '.mission_defaults | type == "!!map"' "$manifest_file" >/dev/null 2>&1; then
      append_quarantine_record "$scope_id" "$manifest_path" "invalid-mission-defaults"
    fi
  fi

  if [[ ! -d "$OCTON_DIR/instance/cognition/context/scopes/$scope_id" ]]; then
    append_quarantine_record "$scope_id" "$manifest_path" "missing-scope-context-directory"
  fi

  DECLARED_SCOPE_IDS+=("$scope_id")
  SCOPE_MANIFEST_PATHS["$scope_id"]="$manifest_path"
  SCOPE_MANIFEST_DIGESTS["$scope_id"]="$(hash_file "$manifest_file")"
  SCOPE_ROOT_PATHS["$scope_id"]="$(normalize_path "$root_path")"
  SCOPE_DISPLAY_NAMES["$scope_id"]="$(yq -r '.display_name // ""' "$manifest_file")"
  SCOPE_OWNERS["$scope_id"]="$(yq -r '.owner // ""' "$manifest_file")"
  SCOPE_STATUSES["$scope_id"]="$(yq -r '.status // ""' "$manifest_file")"
  SCOPE_TECH_TAGS["$scope_id"]="$(json_compact_or_default '.tech_tags' "$manifest_file" '[]')"
  SCOPE_LANGUAGE_TAGS["$scope_id"]="$(json_compact_or_default '.language_tags' "$manifest_file" '[]')"
  SCOPE_INCLUDE_GLOBS["$scope_id"]="$(json_compact_or_default '.include_globs' "$manifest_file" '[]')"
  SCOPE_EXCLUDE_GLOBS["$scope_id"]="$(json_compact_or_default '.exclude_globs' "$manifest_file" '[]')"
  SCOPE_ROUTING_HINTS["$scope_id"]="$(json_compact_or_default '.routing_hints' "$manifest_file" '{}')"
  SCOPE_MISSION_DEFAULTS["$scope_id"]="$(json_compact_or_default '.mission_defaults' "$manifest_file" '{}')"

  if [[ "${SCOPE_STATUSES[$scope_id]}" == "active" ]]; then
    ACTIVE_SCOPE_IDS+=("$scope_id")
  fi
}

write_quarantine_file() {
  local output_file="$1"
  {
    printf 'schema_version: "octon-locality-quarantine-state-v1"\n'
    printf 'updated_at: "%s"\n' "$PUBLISHED_AT"
    if [[ "${#QUARANTINE_RECORDS[@]}" -eq 0 ]]; then
      printf 'records: []\n'
    else
      printf 'records:\n'
      local record scope_id manifest_path reason_code
      for record in "${QUARANTINE_RECORDS[@]}"; do
        IFS='|' read -r scope_id manifest_path reason_code <<<"$record"
        printf '  - scope_id: "%s"\n' "$scope_id"
        printf '    manifest_path: "%s"\n' "$manifest_path"
        printf '    reason_code: "%s"\n' "$reason_code"
        printf '    quarantined_at: "%s"\n' "$PUBLISHED_AT"
      done
    fi
  } >"$output_file"
}

main() {
  mkdir -p "$EFFECTIVE_DIR" "$(dirname "$QUARANTINE_STATE")"
  PUBLISHED_AT="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

  if [[ ! -f "$INSTANCE_MANIFEST" || ! -f "$LOCALITY_MANIFEST" || ! -f "$LOCALITY_REGISTRY" ]]; then
    echo "[ERROR] missing required locality control files" >&2
    exit 1
  fi
  if [[ ! -f "$ROOT_MANIFEST" ]]; then
    echo "[ERROR] missing root manifest: ${ROOT_MANIFEST#$ROOT_DIR/}" >&2
    exit 1
  fi
  if [[ ! -f "$SCOPE_SCHEMA_FILE" ]]; then
    echo "[ERROR] missing locality scope schema contract: ${SCOPE_SCHEMA_FILE#$ROOT_DIR/}" >&2
    exit 1
  fi
  GENERATOR_VERSION="$(yq -r '.versioning.harness.release_version // ""' "$ROOT_MANIFEST" 2>/dev/null || true)"
  if [[ -z "$GENERATOR_VERSION" ]]; then
    echo "[ERROR] root manifest missing versioning.harness.release_version" >&2
    exit 1
  fi

  if [[ "$(yq -r '.locality.registry_path // ""' "$INSTANCE_MANIFEST")" != ".octon/instance/locality/registry.yml" ]]; then
    append_quarantine_record "repo-locality" ".octon/instance/locality/registry.yml" "instance-manifest-registry-path-mismatch"
  fi
  if [[ "$(yq -r '.locality.manifest_path // ""' "$INSTANCE_MANIFEST")" != ".octon/instance/locality/manifest.yml" ]]; then
    append_quarantine_record "repo-locality" ".octon/instance/locality/manifest.yml" "instance-manifest-manifest-path-mismatch"
  fi
  if [[ "$(yq -r '.registry_path // ""' "$LOCALITY_MANIFEST")" != ".octon/instance/locality/registry.yml" ]]; then
    append_quarantine_record "repo-locality" ".octon/instance/locality/manifest.yml" "locality-manifest-registry-path-mismatch"
  fi
  if [[ "$(yq -r '.resolution_mode // ""' "$LOCALITY_MANIFEST")" != "single-active-scope" ]]; then
    append_quarantine_record "repo-locality" ".octon/instance/locality/manifest.yml" "invalid-resolution-mode"
  fi

  if ! yq -e '.scopes | type == "!!seq"' "$LOCALITY_REGISTRY" >/dev/null 2>&1; then
    append_quarantine_record "repo-locality" ".octon/instance/locality/registry.yml" "invalid-registry-scopes"
  else
    local scope_id manifest_path
    while IFS=$'\t' read -r scope_id manifest_path; do
      [[ -z "$scope_id" ]] && continue
      collect_scope "$scope_id" "$manifest_path"
    done < <(yq -r '.scopes[]? | [.scope_id // "", .manifest_path // ""] | @tsv' "$LOCALITY_REGISTRY")
  fi

  local unique_count
  unique_count="$(printf '%s\n' "${DECLARED_SCOPE_IDS[@]}" | awk 'NF' | sort -u | wc -l | tr -d ' ')"
  if [[ "$unique_count" != "${#DECLARED_SCOPE_IDS[@]}" ]]; then
    local duplicate
    while IFS= read -r duplicate; do
      [[ -z "$duplicate" ]] && continue
      append_quarantine_record "$duplicate" "${SCOPE_MANIFEST_PATHS[$duplicate]:-.octon/instance/locality/registry.yml}" "duplicate-scope-id"
    done < <(printf '%s\n' "${DECLARED_SCOPE_IDS[@]}" | awk 'NF' | sort | uniq -d)
  fi

  local i j left_id right_id left_root right_root
  for ((i = 0; i < ${#ACTIVE_SCOPE_IDS[@]}; i += 1)); do
    left_id="${ACTIVE_SCOPE_IDS[$i]}"
    left_root="${SCOPE_ROOT_PATHS[$left_id]}"
    for ((j = i + 1; j < ${#ACTIVE_SCOPE_IDS[@]}; j += 1)); do
      right_id="${ACTIVE_SCOPE_IDS[$j]}"
      right_root="${SCOPE_ROOT_PATHS[$right_id]}"
      if path_contains "$left_root" "$right_root" || path_contains "$right_root" "$left_root"; then
        append_quarantine_record "$left_id" "${SCOPE_MANIFEST_PATHS[$left_id]}" "overlapping-active-scope"
        append_quarantine_record "$right_id" "${SCOPE_MANIFEST_PATHS[$right_id]}" "overlapping-active-scope"
      fi
    done
  done

  local tmpdir quarantine_tmp
  tmpdir="$(mktemp -d "${TMPDIR:-/tmp}/octon-locality-publish.XXXXXX")"
  trap "rm -rf '$tmpdir'" EXIT
  quarantine_tmp="$tmpdir/quarantine.yml"
  write_quarantine_file "$quarantine_tmp"

  if [[ "${#QUARANTINE_RECORDS[@]}" -gt 0 ]]; then
    mv "$quarantine_tmp" "$QUARANTINE_STATE"
    echo "[ERROR] locality publication blocked; quarantined invalid scope state" >&2
    exit 1
  fi

  local manifest_sha registry_sha quarantine_sha input_digest
  manifest_sha="$(hash_file "$LOCALITY_MANIFEST")"
  registry_sha="$(hash_file "$LOCALITY_REGISTRY")"
  quarantine_sha="$(hash_file "$quarantine_tmp")"
  if command -v shasum >/dev/null 2>&1; then
    input_digest="$(printf '%s\n%s\n%s\n' "$manifest_sha" "$registry_sha" "$quarantine_sha" | shasum -a 256 | awk '{print $1}')"
  else
    input_digest="$(printf '%s\n%s\n%s\n' "$manifest_sha" "$registry_sha" "$quarantine_sha" | sha256sum | awk '{print $1}')"
  fi
  GENERATION_ID="locality-${input_digest:0:12}"

  local scopes_tmp artifact_map_tmp lock_tmp
  scopes_tmp="$tmpdir/scopes.effective.yml"
  artifact_map_tmp="$tmpdir/artifact-map.yml"
  lock_tmp="$tmpdir/generation.lock.yml"

  {
    printf 'schema_version: "octon-locality-effective-scopes-v1"\n'
    printf 'generator_version: "%s"\n' "$GENERATOR_VERSION"
    printf 'generation_id: "%s"\n' "$GENERATION_ID"
    printf 'published_at: "%s"\n' "$PUBLISHED_AT"
    printf 'resolution_mode: "single-active-scope"\n'
    printf 'source:\n'
    printf '  locality_manifest_path: ".octon/instance/locality/manifest.yml"\n'
    printf '  locality_manifest_sha256: "%s"\n' "$manifest_sha"
    printf '  locality_registry_path: ".octon/instance/locality/registry.yml"\n'
    printf '  locality_registry_sha256: "%s"\n' "$registry_sha"
    if [[ "${#ACTIVE_SCOPE_IDS[@]}" -eq 0 ]]; then
      printf 'active_scope_ids: []\n'
    else
      printf 'active_scope_ids:\n'
      local scope_id
      for scope_id in "${ACTIVE_SCOPE_IDS[@]}"; do
        printf '  - "%s"\n' "$scope_id"
      done
    fi
    if [[ "${#DECLARED_SCOPE_IDS[@]}" -eq 0 ]]; then
      printf 'scopes: []\n'
    else
      printf 'scopes:\n'
      local scope_id
      for scope_id in "${DECLARED_SCOPE_IDS[@]}"; do
        printf '  - scope_id: "%s"\n' "$scope_id"
        printf '    manifest_path: "%s"\n' "${SCOPE_MANIFEST_PATHS[$scope_id]}"
        printf '    display_name: "%s"\n' "${SCOPE_DISPLAY_NAMES[$scope_id]}"
        printf '    root_path: "%s"\n' "${SCOPE_ROOT_PATHS[$scope_id]}"
        printf '    owner: "%s"\n' "${SCOPE_OWNERS[$scope_id]}"
        printf '    status: "%s"\n' "${SCOPE_STATUSES[$scope_id]}"
        printf '    tech_tags: %s\n' "${SCOPE_TECH_TAGS[$scope_id]}"
        printf '    language_tags: %s\n' "${SCOPE_LANGUAGE_TAGS[$scope_id]}"
        printf '    include_globs: %s\n' "${SCOPE_INCLUDE_GLOBS[$scope_id]}"
        printf '    exclude_globs: %s\n' "${SCOPE_EXCLUDE_GLOBS[$scope_id]}"
        printf '    routing_hints: %s\n' "${SCOPE_ROUTING_HINTS[$scope_id]}"
        printf '    mission_defaults: %s\n' "${SCOPE_MISSION_DEFAULTS[$scope_id]}"
      done
    fi
  } >"$scopes_tmp"

  {
    printf 'schema_version: "octon-locality-artifact-map-v1"\n'
    printf 'generator_version: "%s"\n' "$GENERATOR_VERSION"
    printf 'generation_id: "%s"\n' "$GENERATION_ID"
    printf 'published_at: "%s"\n' "$PUBLISHED_AT"
    if [[ "${#DECLARED_SCOPE_IDS[@]}" -eq 0 ]]; then
      printf 'artifacts: []\n'
    else
      printf 'artifacts:\n'
      local idx=0 scope_id
      for scope_id in "${DECLARED_SCOPE_IDS[@]}"; do
        printf '  - scope_id: "%s"\n' "$scope_id"
        printf '    registry_entry: ".octon/instance/locality/registry.yml#/scopes/%d"\n' "$idx"
        printf '    manifest_path: "%s"\n' "${SCOPE_MANIFEST_PATHS[$scope_id]}"
        printf '    manifest_sha256: "%s"\n' "${SCOPE_MANIFEST_DIGESTS[$scope_id]}"
        idx=$((idx + 1))
      done
    fi
  } >"$artifact_map_tmp"

  {
    printf 'schema_version: "octon-locality-generation-lock-v1"\n'
    printf 'generator_version: "%s"\n' "$GENERATOR_VERSION"
    printf 'generation_id: "%s"\n' "$GENERATION_ID"
    printf 'published_at: "%s"\n' "$PUBLISHED_AT"
    printf 'locality_manifest_sha256: "%s"\n' "$manifest_sha"
    printf 'locality_registry_sha256: "%s"\n' "$registry_sha"
    printf 'quarantine_sha256: "%s"\n' "$quarantine_sha"
    if [[ "${#DECLARED_SCOPE_IDS[@]}" -eq 0 ]]; then
      printf 'scope_manifest_digests: []\n'
    else
      printf 'scope_manifest_digests:\n'
      local scope_id
      for scope_id in "${DECLARED_SCOPE_IDS[@]}"; do
        printf '  - scope_id: "%s"\n' "$scope_id"
        printf '    manifest_path: "%s"\n' "${SCOPE_MANIFEST_PATHS[$scope_id]}"
        printf '    sha256: "%s"\n' "${SCOPE_MANIFEST_DIGESTS[$scope_id]}"
      done
    fi
  } >"$lock_tmp"

  mv "$quarantine_tmp" "$QUARANTINE_STATE"
  mv "$scopes_tmp" "$SCOPES_EFFECTIVE_FILE"
  mv "$artifact_map_tmp" "$ARTIFACT_MAP_FILE"
  mv "$lock_tmp" "$GENERATION_LOCK_FILE"
}

main "$@"
