#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
OCTON_DIR="${OCTON_DIR_OVERRIDE:-$(cd -- "$SCRIPT_DIR/../../../../../" && pwd)}"
ROOT_DIR="${OCTON_ROOT_DIR:-$(cd -- "$OCTON_DIR/.." && pwd)}"

INSTANCE_MANIFEST="$OCTON_DIR/instance/manifest.yml"
LOCALITY_MANIFEST="$OCTON_DIR/instance/locality/manifest.yml"
LOCALITY_REGISTRY="$OCTON_DIR/instance/locality/registry.yml"
SCOPES_DIR="$OCTON_DIR/instance/locality/scopes"
SCOPE_CONTEXT_DIR="$OCTON_DIR/instance/cognition/context/scopes"
BLOCKED_SCOPE_CONTINUITY_DIR="$OCTON_DIR/state/continuity/scopes"
SCOPE_SCHEMA_DIR="$OCTON_DIR/framework/cognition/_meta/architecture/instance/locality/schemas"
SCOPE_SCHEMA_README="$SCOPE_SCHEMA_DIR/README.md"
SCOPE_SCHEMA_FILE="$SCOPE_SCHEMA_DIR/scope.schema.json"

declare -A ACTIVE_ROOTS=()
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

validate_scope_manifest() {
  local scope_id="$1"
  local manifest_path="$2"
  local manifest_file="$ROOT_DIR/$manifest_path"

  if [[ ! -f "$manifest_file" ]]; then
    fail "registry scope '$scope_id' manifest missing: $manifest_path"
    return
  fi

  if ! yq -e '.' "$manifest_file" >/dev/null 2>&1; then
    fail "scope manifest must parse as YAML: $manifest_path"
    return
  fi

  [[ "$(yq -r '.schema_version // ""' "$manifest_file")" == "octon-locality-scope-v1" ]] \
    && pass "scope '$scope_id' schema version valid" \
    || fail "scope '$scope_id' schema_version must be octon-locality-scope-v1"

  local manifest_scope_id
  manifest_scope_id="$(yq -r '.scope_id // ""' "$manifest_file")"
  [[ "$manifest_scope_id" == "$scope_id" ]] \
    && pass "scope '$scope_id' manifest scope_id matches registry" \
    || fail "scope '$scope_id' manifest scope_id must match registry entry"

  local field
  for field in display_name owner status; do
    if yq -e ".$field | type == \"!!str\" and . != \"\"" "$manifest_file" >/dev/null 2>&1; then
      pass "scope '$scope_id' declares $field"
    else
      fail "scope '$scope_id' missing required field: $field"
    fi
  done

  if yq -e '.root_path | type == "!!str" and . != ""' "$manifest_file" >/dev/null 2>&1; then
    local root_path
    root_path="$(yq -r '.root_path // ""' "$manifest_file")"
    if is_safe_relative_pattern "$root_path"; then
      root_path="$(normalize_path "$root_path")"
      pass "scope '$scope_id' root_path is a safe repo-relative path"
      ACTIVE_ROOTS["$scope_id"]="$root_path"
    else
      fail "scope '$scope_id' root_path must stay inside the repo root"
    fi
  else
    fail "scope '$scope_id' missing required field: root_path"
  fi

  if yq -e '.tech_tags | type == "!!seq"' "$manifest_file" >/dev/null 2>&1; then
    pass "scope '$scope_id' tech_tags list valid"
  else
    fail "scope '$scope_id' tech_tags must be a list"
  fi

  if yq -e '.language_tags | type == "!!seq"' "$manifest_file" >/dev/null 2>&1; then
    pass "scope '$scope_id' language_tags list valid"
  else
    fail "scope '$scope_id' language_tags must be a list"
  fi

  local collection glob
  for collection in include_globs exclude_globs; do
    if yq -e "has(\"$collection\")" "$manifest_file" >/dev/null 2>&1; then
      if yq -e ".$collection | type == \"!!seq\"" "$manifest_file" >/dev/null 2>&1; then
        while IFS= read -r glob; do
          [[ -z "$glob" ]] && continue
          if is_safe_relative_pattern "$glob" && glob_subordinate_to_root "$root_path" "$glob"; then
            pass "scope '$scope_id' $collection entry valid: $glob"
          else
            fail "scope '$scope_id' $collection entry escapes rooted subtree: $glob"
          fi
        done < <(yq -r ".$collection[]?" "$manifest_file" 2>/dev/null || true)
      else
        fail "scope '$scope_id' $collection must be a list"
      fi
    fi
  done

  if yq -e 'has("routing_hints")' "$manifest_file" >/dev/null 2>&1; then
    yq -e '.routing_hints | type == "!!map"' "$manifest_file" >/dev/null 2>&1 \
      && pass "scope '$scope_id' routing_hints map valid" \
      || fail "scope '$scope_id' routing_hints must be a map"
  fi

  if yq -e 'has("mission_defaults")' "$manifest_file" >/dev/null 2>&1; then
    yq -e '.mission_defaults | type == "!!map"' "$manifest_file" >/dev/null 2>&1 \
      && pass "scope '$scope_id' mission_defaults map valid" \
      || fail "scope '$scope_id' mission_defaults must be a map"
  fi

  if [[ -d "$SCOPE_CONTEXT_DIR/$scope_id" ]]; then
    pass "scope '$scope_id' durable context directory exists"
  else
    fail "scope '$scope_id' durable context directory missing: ${SCOPE_CONTEXT_DIR#$ROOT_DIR/}/$scope_id"
  fi
}

main() {
  echo "== Locality Registry Validation =="

  require_yaml_file "$INSTANCE_MANIFEST"
  require_yaml_file "$LOCALITY_MANIFEST"
  require_yaml_file "$LOCALITY_REGISTRY"
  if [[ -f "$SCOPE_SCHEMA_README" ]]; then
    pass "found file: ${SCOPE_SCHEMA_README#$ROOT_DIR/}"
  else
    fail "missing file: ${SCOPE_SCHEMA_README#$ROOT_DIR/}"
  fi
  if [[ -f "$SCOPE_SCHEMA_FILE" ]]; then
    pass "found file: ${SCOPE_SCHEMA_FILE#$ROOT_DIR/}"
    if jq -e '.' "$SCOPE_SCHEMA_FILE" >/dev/null 2>&1; then
      pass "${SCOPE_SCHEMA_FILE#$ROOT_DIR/} parses as JSON"
    else
      fail "${SCOPE_SCHEMA_FILE#$ROOT_DIR/} must parse as JSON"
    fi
  else
    fail "missing file: ${SCOPE_SCHEMA_FILE#$ROOT_DIR/}"
  fi

  if [[ -d "$SCOPES_DIR" ]]; then
    pass "found directory: ${SCOPES_DIR#$ROOT_DIR/}"
  else
    fail "missing directory: ${SCOPES_DIR#$ROOT_DIR/}"
  fi

  if [[ -d "$SCOPE_CONTEXT_DIR" ]]; then
    pass "found directory: ${SCOPE_CONTEXT_DIR#$ROOT_DIR/}"
  else
    fail "missing directory: ${SCOPE_CONTEXT_DIR#$ROOT_DIR/}"
  fi

  if [[ -d "$BLOCKED_SCOPE_CONTINUITY_DIR" ]]; then
    fail "scope continuity is not legal before Packet 7: ${BLOCKED_SCOPE_CONTINUITY_DIR#$ROOT_DIR/}"
  else
    pass "scope continuity remains gated off until Packet 7"
  fi

  [[ "$(yq -r '.schema_version // ""' "$LOCALITY_MANIFEST")" == "octon-locality-manifest-v1" ]] \
    && pass "locality manifest schema version valid" \
    || fail "locality manifest schema_version must be octon-locality-manifest-v1"

  [[ "$(yq -r '.schema_version // ""' "$LOCALITY_REGISTRY")" == "octon-locality-registry-v1" ]] \
    && pass "locality registry schema version valid" \
    || fail "locality registry schema_version must be octon-locality-registry-v1"

  [[ "$(yq -r '.locality.registry_path // ""' "$INSTANCE_MANIFEST")" == ".octon/instance/locality/registry.yml" ]] \
    && pass "instance manifest locality registry path valid" \
    || fail "instance manifest locality.registry_path must be .octon/instance/locality/registry.yml"

  [[ "$(yq -r '.locality.manifest_path // ""' "$INSTANCE_MANIFEST")" == ".octon/instance/locality/manifest.yml" ]] \
    && pass "instance manifest locality manifest path valid" \
    || fail "instance manifest locality.manifest_path must be .octon/instance/locality/manifest.yml"

  [[ "$(yq -r '.registry_path // ""' "$LOCALITY_MANIFEST")" == ".octon/instance/locality/registry.yml" ]] \
    && pass "locality manifest registry path valid" \
    || fail "locality manifest registry_path must be .octon/instance/locality/registry.yml"

  [[ "$(yq -r '.resolution_mode // ""' "$LOCALITY_MANIFEST")" == "single-active-scope" ]] \
    && pass "locality manifest resolution mode valid" \
    || fail "locality manifest resolution_mode must be single-active-scope"

  if yq -e '.scopes | type == "!!seq"' "$LOCALITY_REGISTRY" >/dev/null 2>&1; then
    pass "locality registry scopes list valid"
  else
    fail "locality registry scopes must be a list"
  fi

  local declared_count=0
  local scope_id manifest_path
  while IFS=$'\t' read -r scope_id manifest_path; do
    [[ -z "$scope_id" ]] && continue
    declared_count=$((declared_count + 1))
    if [[ -z "$manifest_path" ]]; then
      fail "registry scope '$scope_id' missing manifest_path"
      continue
    fi
    validate_scope_manifest "$scope_id" "$manifest_path"
  done < <(yq -r '.scopes[]? | [.scope_id // "", .manifest_path // ""] | @tsv' "$LOCALITY_REGISTRY")

  if [[ "$declared_count" -eq 0 ]]; then
    pass "locality registry may be empty, but current repo should prefer at least one live scope"
  fi

  local duplicates
  duplicates="$(yq -r '.scopes[]?.scope_id // ""' "$LOCALITY_REGISTRY" 2>/dev/null | awk 'NF' | sort | uniq -d || true)"
  if [[ -n "$duplicates" ]]; then
    while IFS= read -r scope_id; do
      [[ -z "$scope_id" ]] && continue
      fail "duplicate scope_id declared: $scope_id"
    done <<<"$duplicates"
  else
    pass "registry scope_ids are unique"
  fi

  local ids=("${!ACTIVE_ROOTS[@]}")
  local i j left_id right_id left_root right_root
  for ((i = 0; i < ${#ids[@]}; i += 1)); do
    left_id="${ids[$i]}"
    left_root="${ACTIVE_ROOTS[$left_id]}"
    if [[ "$(yq -r ".scopes[]? | select(.scope_id == \"$left_id\") | .manifest_path" "$LOCALITY_REGISTRY" | xargs -I{} yq -r '.status // ""' "$ROOT_DIR/{}" 2>/dev/null || true)" != "active" ]]; then
      continue
    fi
    for ((j = i + 1; j < ${#ids[@]}; j += 1)); do
      right_id="${ids[$j]}"
      right_root="${ACTIVE_ROOTS[$right_id]}"
      if [[ "$(yq -r ".scopes[]? | select(.scope_id == \"$right_id\") | .manifest_path" "$LOCALITY_REGISTRY" | xargs -I{} yq -r '.status // ""' "$ROOT_DIR/{}" 2>/dev/null || true)" != "active" ]]; then
        continue
      fi
      if path_contains "$left_root" "$right_root" || path_contains "$right_root" "$left_root"; then
        fail "active scopes overlap: $left_id ($left_root) vs $right_id ($right_root)"
      fi
    done
  done

  echo "Validation summary: errors=$errors"
  if [[ $errors -gt 0 ]]; then
    exit 1
  fi
}

main "$@"
