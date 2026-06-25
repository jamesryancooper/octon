#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
if [[ -n "${OCTON_DIR_OVERRIDE:-}" ]]; then
  OCTON_DIR="$OCTON_DIR_OVERRIDE"
  ROOT_DIR="${OCTON_ROOT_DIR:-$(cd -- "$OCTON_DIR/.." && pwd)}"
else
  OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../.." && pwd)"
  ROOT_DIR="$(cd -- "$OCTON_DIR/.." && pwd)"
fi
source "$OCTON_DIR/framework/assurance/runtime/_ops/scripts/publication-wrapper-common.sh"

enter_publication_runtime_boundary host-projections

ROUTING_FILE="$OCTON_DIR/generated/effective/capabilities/routing.effective.yml"
ARTIFACT_MAP_FILE="$OCTON_DIR/generated/effective/capabilities/artifact-map.yml"
EXTENSIONS_CATALOG="$OCTON_DIR/generated/effective/extensions/catalog.effective.yml"

HOSTS=(claude cursor codex)
EXTENSION_PUBLISHED_PREFIX=".octon/generated/effective/extensions/published/"

require_file() {
  local file="$1"
  [[ -f "$file" ]] || {
    echo "[ERROR] missing file: ${file#$ROOT_DIR/}" >&2
    exit 1
  }
}

expected_projection_rows() {
  local host="$1"
  local kind="$2"
  yq -r ".routing_candidates[]? | select(.status == \"active\") | select(.capability_kind == \"$kind\") | select((.host_adapters // []) | contains([\"$host\"])) | [.effective_id, .capability_id, .origin_class] | @tsv" "$ROUTING_FILE" 2>/dev/null || true
}

assert_unique_projection_names() {
  local host="$1"
  local kind="$2"
  local duplicates
  duplicates="$(expected_projection_rows "$host" "$kind" | awk -F'\t' 'NF {print $2}' | LC_ALL=C sort | uniq -d)"
  if [[ -n "$duplicates" ]]; then
    echo "[ERROR] duplicate projection names for $host/$kind: $duplicates" >&2
    exit 1
  fi
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

require_compiled_extension_projection_path() {
  local effective_id="$1"
  local source_rel="$2"
  [[ "$source_rel" == ${EXTENSION_PUBLISHED_PREFIX}* ]] || {
    echo "[ERROR] extension projection for $effective_id must resolve to compiled publication output" >&2
    exit 1
  }
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
    require_compiled_extension_projection_path "$effective_id" "$source_path"
    printf '%s\n' "$source_path"
  elif [[ "$kind" == "skill" ]]; then
    dirname "$source_path"
  else
    printf '%s\n' "$source_path"
  fi
}

ensure_dir() {
  local dir="$1"
  mkdir -p "$dir"
}

host_projection_writable() {
  local host="$1"
  local kind dir parent
  parent="$ROOT_DIR/.${host}"
  for kind in commands skills; do
    dir="$parent/${kind}"
    if [[ -e "$dir" && ! -w "$dir" ]]; then
      return 1
    fi
    if [[ ! -e "$dir" && -e "$parent" && ! -w "$parent" ]]; then
      return 1
    fi
  done
  return 0
}

copy_command_projection() {
  local source_rel="$1"
  local dest_file="$2"
  local source_abs="$ROOT_DIR/$source_rel"
  [[ -f "$source_abs" ]] || {
    echo "[ERROR] missing command projection source: $source_rel" >&2
    exit 1
  }
  if [[ -L "$dest_file" || -d "$dest_file" ]]; then
    rm -r -f "$dest_file"
  fi
  cp "$source_abs" "$dest_file"
}

copy_skill_projection() {
  local source_rel="$1"
  local dest_dir="$2"
  local source_abs="$ROOT_DIR/$source_rel"
  local source_entry dest_entry rel
  [[ -d "$source_abs" ]] || {
    echo "[ERROR] missing skill projection source dir: $source_rel" >&2
    exit 1
  }
  if [[ -L "$dest_dir" || ( -e "$dest_dir" && ! -d "$dest_dir" ) ]]; then
    rm -r -f "$dest_dir"
  fi
  if [[ ! -e "$dest_dir" ]]; then
    cp -R "$source_abs" "$dest_dir"
    return 0
  fi
  while IFS= read -r -d '' source_entry; do
    rel="${source_entry#$source_abs/}"
    mkdir -p "$dest_dir/$rel"
  done < <(find "$source_abs" -mindepth 1 -type d -print0 | sort -z)
  while IFS= read -r -d '' source_entry; do
    rel="${source_entry#$source_abs/}"
    mkdir -p "$(dirname "$dest_dir/$rel")"
    if [[ -L "$dest_dir/$rel" || -d "$dest_dir/$rel" ]]; then
      rm -r -f "$dest_dir/$rel"
    fi
    cp "$source_entry" "$dest_dir/$rel"
  done < <(find "$source_abs" -mindepth 1 -type f -print0 | sort -z)
  while IFS= read -r -d '' dest_entry; do
    rel="${dest_entry#$dest_dir/}"
    if [[ ! -e "$source_abs/$rel" ]]; then
      rm -r -f "$dest_entry"
    fi
  done < <(find "$dest_dir" -mindepth 1 -depth -print0 | sort -zr)
}

prune_unexpected_entries() {
  local dir="$1"
  shift
  local expected=("$@")
  local entry base keep
  [[ -d "$dir" ]] || return 0
  while IFS= read -r entry; do
    [[ -n "$entry" ]] || continue
    base="$(basename "$entry")"
    keep=0
    for name in "${expected[@]}"; do
      if [[ "$base" == "$name" ]]; then
        keep=1
        break
      fi
    done
    if [[ $keep -eq 0 ]]; then
      rm -r -f "$entry"
    fi
  done < <(find "$dir" -mindepth 1 -maxdepth 1 -print | sort)
}

publish_host_kind() {
  local host="$1"
  local kind="$2"
  local projection_dir="$ROOT_DIR/.${host}/${kind}s"
  local expected_names=()
  local effective_id capability_id origin_class source_rel

  ensure_dir "$projection_dir"
  assert_unique_projection_names "$host" "$kind"

  while IFS=$'\t' read -r effective_id capability_id origin_class; do
    [[ -n "$effective_id" ]] || continue
    source_rel="$(projection_source_path "$effective_id" "$kind")"
    [[ -n "$source_rel" ]] || {
      echo "[ERROR] missing projection source for $effective_id" >&2
      exit 1
    }
    if [[ "$kind" == "command" ]]; then
      copy_command_projection "$source_rel" "$projection_dir/$capability_id.md"
      expected_names+=("$capability_id.md")
    else
      copy_skill_projection "$source_rel" "$projection_dir/$capability_id"
      expected_names+=("$capability_id")
    fi
  done < <(expected_projection_rows "$host" "$kind")

  prune_unexpected_entries "$projection_dir" "${expected_names[@]}"
}

main() {
  local host
  require_file "$ROUTING_FILE"
  require_file "$ARTIFACT_MAP_FILE"
  require_file "$EXTENSIONS_CATALOG"

  for host in "${HOSTS[@]}"; do
    if ! host_projection_writable "$host"; then
      echo "[OK] skipped read-only host capability projections: .$host"
      continue
    fi
    publish_host_kind "$host" command
    publish_host_kind "$host" skill
  done

  echo "[OK] published host capability projections"
}

main "$@"
