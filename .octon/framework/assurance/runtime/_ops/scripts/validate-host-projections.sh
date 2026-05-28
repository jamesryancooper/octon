#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../../" && pwd)"
OCTON_DIR="${OCTON_DIR_OVERRIDE:-$DEFAULT_OCTON_DIR}"
ROOT_DIR="${OCTON_ROOT_DIR:-$(cd -- "$OCTON_DIR/.." && pwd)}"
source "$OCTON_DIR/framework/orchestration/runtime/_ops/scripts/extensions-common.sh"

ROUTING_FILE="$OCTON_DIR/generated/effective/capabilities/routing.effective.yml"
ARTIFACT_MAP_FILE="$OCTON_DIR/generated/effective/capabilities/artifact-map.yml"
EXTENSIONS_CATALOG="$OCTON_DIR/generated/effective/extensions/catalog.effective.yml"
HOSTS=(claude cursor codex)
EXTENSION_PUBLISHED_PREFIX=".octon/generated/effective/extensions/published/"
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

command_title() {
  awk '/^# / { sub(/^# /, ""); print; exit }' "$1"
}

expected_projection_rows() {
  local host="$1"
  local kind="$2"
  yq -r ".routing_candidates[]? | select(.status == \"active\") | select(.capability_kind == \"$kind\") | select((.host_adapters // []) | contains([\"$host\"])) | [.effective_id, .capability_id] | @tsv" "$ROUTING_FILE" 2>/dev/null || true
}

artifact_field_for_effective_id() {
  local effective_id="$1"
  local query="$2"
  yq -r ".artifacts[]? | select(.effective_id == \"$effective_id\") | $query // \"\"" "$ARTIFACT_MAP_FILE" | head -n 1
}

extension_projection_source_path() {
  local pack_id="$1"
  local source_id="$2"
  local kind="$3"
  local capability_id="$4"
  yq -r ".packs[]? | select(.pack_id == \"$pack_id\" and .source_id == \"$source_id\") | .routing_exports.${kind}s[]? | select(.capability_id == \"$capability_id\") | .projection_source_path // \"\"" "$EXTENSIONS_CATALOG" | head -n 1
}

is_extension_root_or_composite_command() {
  local effective_id="$1" capability_id="$2"
  local source_kind pack_id operator_family

  source_kind="$(artifact_field_for_effective_id "$effective_id" '.source_kind')"
  [[ "$source_kind" == "extension-export" ]] || return 1

  pack_id="$(artifact_field_for_effective_id "$effective_id" '.extension_pack_id')"
  operator_family="$(ext_command_operator_family_for_pack "$pack_id")"
  [[ "$capability_id" == "$pack_id" || "$capability_id" == "$operator_family" ]]
}

verify_compiled_extension_projection_path() {
  local effective_id="$1"
  local source_rel="$2"
  if [[ "$source_rel" == ${EXTENSION_PUBLISHED_PREFIX}* ]]; then
    return 0
  else
    fail "extension projection source must resolve to compiled publication output for $effective_id"
    return 1
  fi
}

projection_source_path() {
  local effective_id="$1"
  local kind="$2"
  local source_kind source_path pack_id source_id capability_id
  source_kind="$(artifact_field_for_effective_id "$effective_id" '.source_kind')"
  source_path="$(artifact_field_for_effective_id "$effective_id" '.source_path')"
  if [[ "$source_kind" == "extension-export" ]]; then
    pack_id="$(artifact_field_for_effective_id "$effective_id" '.extension_pack_id')"
    source_id="$(artifact_field_for_effective_id "$effective_id" '.extension_source_id')"
    capability_id="$(artifact_field_for_effective_id "$effective_id" '.capability_id')"
    source_path="$(extension_projection_source_path "$pack_id" "$source_id" "$kind" "$capability_id")"
    verify_compiled_extension_projection_path "$effective_id" "$source_path" || return 1
    printf '%s\n' "$source_path"
  elif [[ "$kind" == "skill" ]]; then
    dirname "$source_path"
  else
    printf '%s\n' "$source_path"
  fi
}

verify_no_symlinks() {
  local dir="$1"
  if find "$dir" -type l -print | grep -q .; then
    fail "host projection directory must not contain symlinks: ${dir#$ROOT_DIR/}"
  else
    pass "host projection directory contains no symlinks: ${dir#$ROOT_DIR/}"
  fi
}

compare_skill_dirs() {
  local projected_dir="$1"
  local source_dir="$2"
  local projected_list source_list rel
  projected_list="$(cd "$projected_dir" && find . -type f | LC_ALL=C sort)"
  source_list="$(cd "$source_dir" && find . -type f | LC_ALL=C sort)"
  if [[ "$projected_list" == "$source_list" ]]; then
    pass "projected skill file list matches source: ${projected_dir#$ROOT_DIR/}"
  else
    fail "projected skill file list differs from source: ${projected_dir#$ROOT_DIR/}"
  fi
  while IFS= read -r rel; do
    [[ -n "$rel" ]] || continue
    if [[ "$(hash_file "$projected_dir/$rel")" == "$(hash_file "$source_dir/$rel")" ]]; then
      pass "projected skill file hash matches source: ${projected_dir#$ROOT_DIR/}/$rel"
    else
      fail "projected skill file hash differs from source: ${projected_dir#$ROOT_DIR/}/$rel"
    fi
  done < <(cd "$source_dir" && find . -type f | LC_ALL=C sort)
}

validate_host_kind() {
  local host="$1"
  local kind="$2"
  local projection_dir="$ROOT_DIR/.${host}/${kind}s"
  local expected_names=()
  local existing_names
  local effective_id capability_id source_rel projected_path title

  if [[ -d "$projection_dir" ]]; then
    pass "host projection directory exists: ${projection_dir#$ROOT_DIR/}"
  else
    fail "missing host projection directory: ${projection_dir#$ROOT_DIR/}"
    return
  fi

  verify_no_symlinks "$projection_dir"

  while IFS=$'\t' read -r effective_id capability_id; do
    [[ -n "$effective_id" ]] || continue
    source_rel="$(projection_source_path "$effective_id" "$kind")"
    if [[ -z "$source_rel" ]]; then
      fail "missing projection source path for $effective_id"
      continue
    fi
    if [[ "$kind" == "command" ]]; then
      projected_path="$projection_dir/$capability_id.md"
      expected_names+=("$capability_id.md")
      if [[ -f "$projected_path" ]]; then
        pass "projected command exists: ${projected_path#$ROOT_DIR/}"
      else
        fail "missing projected command: ${projected_path#$ROOT_DIR/}"
        continue
      fi
      if [[ "$(hash_file "$projected_path")" == "$(hash_file "$ROOT_DIR/$source_rel")" ]]; then
        pass "projected command hash matches source: ${projected_path#$ROOT_DIR/}"
      else
        fail "projected command hash differs from source: ${projected_path#$ROOT_DIR/}"
      fi
      title="$(command_title "$projected_path")"
      if [[ -n "$title" && "${#title}" -le 64 ]]; then
        pass "projected command title is concise: ${projected_path#$ROOT_DIR/}"
      else
        fail "projected command title must be present and <=64 characters: ${projected_path#$ROOT_DIR/}"
      fi
      if [[ "$title" == "Octon "* ]] && ! is_extension_root_or_composite_command "$effective_id" "$capability_id"; then
        fail "projected command title repeats redundant Octon namespace: ${projected_path#$ROOT_DIR/}"
      else
        pass "projected command title namespace usage is allowed: ${projected_path#$ROOT_DIR/}"
      fi
    else
      projected_path="$projection_dir/$capability_id"
      expected_names+=("$capability_id")
      if [[ -d "$projected_path" ]]; then
        pass "projected skill directory exists: ${projected_path#$ROOT_DIR/}"
      else
        fail "missing projected skill directory: ${projected_path#$ROOT_DIR/}"
        continue
      fi
      if [[ -f "$projected_path/SKILL.md" ]]; then
        pass "projected skill includes SKILL.md: ${projected_path#$ROOT_DIR/}/SKILL.md"
      else
        fail "projected skill missing SKILL.md: ${projected_path#$ROOT_DIR/}/SKILL.md"
      fi
      compare_skill_dirs "$projected_path" "$ROOT_DIR/$source_rel"
    fi
  done < <(expected_projection_rows "$host" "$kind")

  existing_names="$(find "$projection_dir" -mindepth 1 -maxdepth 1 -exec basename {} \; | LC_ALL=C sort)"
  if [[ "$existing_names" == "$(printf '%s\n' "${expected_names[@]}" | awk 'NF' | LC_ALL=C sort)" ]]; then
    pass "host projection set matches routing for ${projection_dir#$ROOT_DIR/}"
  else
    fail "host projection set differs from routing for ${projection_dir#$ROOT_DIR/}"
  fi
}

main() {
  local host
  echo "== Host Projection Validation =="

  [[ -f "$ROUTING_FILE" ]] && pass "found file: ${ROUTING_FILE#$ROOT_DIR/}" || fail "missing file: ${ROUTING_FILE#$ROOT_DIR/}"
  [[ -f "$ARTIFACT_MAP_FILE" ]] && pass "found file: ${ARTIFACT_MAP_FILE#$ROOT_DIR/}" || fail "missing file: ${ARTIFACT_MAP_FILE#$ROOT_DIR/}"
  [[ -f "$EXTENSIONS_CATALOG" ]] && pass "found file: ${EXTENSIONS_CATALOG#$ROOT_DIR/}" || fail "missing file: ${EXTENSIONS_CATALOG#$ROOT_DIR/}"

  for host in "${HOSTS[@]}"; do
    validate_host_kind "$host" command
    validate_host_kind "$host" skill
  done

  echo "Validation summary: errors=$errors"
  if [[ $errors -gt 0 ]]; then
    exit 1
  fi
}

main "$@"
