#!/usr/bin/env bash
# validate-tools.sh - Validate tools subsystem manifests and packs.

set -o pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TOOLS_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
MANIFEST="$TOOLS_DIR/manifest.yml"
REGISTRY="$TOOLS_DIR/registry.yml"
CAPABILITIES="$TOOLS_DIR/capabilities.yml"

errors=0
warnings=0

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

log_error() {
  echo -e "${RED}ERROR:${NC} $1"
  ((errors++)) || true
}

log_warning() {
  echo -e "${YELLOW}WARNING:${NC} $1"
  ((warnings++)) || true
}

log_success() {
  echo -e "${GREEN}✓${NC} $1"
}

trim() {
  echo "$1" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//'
}

strip_quotes() {
  echo "$1" | sed "s/^['\"]//;s/['\"]$//"
}

parse_inline_list() {
  local raw="$1"
  raw="${raw#[}"
  raw="${raw%]}"
  raw="${raw//\"/}"
  raw="${raw//\'/}"
  IFS=',' read -ra items <<< "$raw"
  local item
  for item in "${items[@]}"; do
    item="$(trim "$item")"
    [[ -n "$item" ]] && echo "$item"
  done
}

get_builtins() {
  awk '
    /^built_in_tools:/ {in_list=1; next}
    in_list && /^[a-z_]+:/ {exit}
    in_list && /^[[:space:]]*-[[:space:]]*/ {
      line=$0
      sub(/^[[:space:]]*-[[:space:]]*/, "", line)
      gsub(/["'\'' ]/, "", line)
      if (length(line) > 0) print line
    }
  ' "$CAPABILITIES"
}

get_manifest_pack_ids() {
  awk '
    /^packs:/ {in_packs=1; next}
    /^tools:/ {in_packs=0}
    in_packs && /^[[:space:]]*- id:/ {
      id=$3
      gsub(/["'\'' ]/, "", id)
      print id
    }
  ' "$MANIFEST"
}

get_pack_tools_csv() {
  local pack_id="$1"
  awk -v target="$pack_id" '
    /^packs:/ {in_packs=1; next}
    /^tools:/ {if (in_pack) exit; in_packs=0}
    in_packs && /^[[:space:]]*- id:/ {
      id=$3
      gsub(/["'\'' ]/, "", id)
      in_pack=(id==target)
      next
    }
    in_pack && /tools:[[:space:]]*\[/ {
      line=$0
      sub(/.*tools:[[:space:]]*\[/, "", line)
      sub(/\].*/, "", line)
      gsub(/["'\'' ]/, "", line)
      print line
      exit
    }
  ' "$MANIFEST"
}

get_manifest_tool_ids() {
  awk '
    /^tools:/ {in_tools=1; next}
    in_tools && /^[[:space:]]*- id:/ {
      id=$3
      gsub(/["'\'' ]/, "", id)
      print id
    }
  ' "$MANIFEST"
}

get_manifest_tool_field() {
  local tool_id="$1"
  local field="$2"
  awk -v target="$tool_id" -v field="$field" '
    /^tools:/ {in_tools=1; next}
    in_tools && /^[[:space:]]*- id:/ {
      id=$3
      gsub(/["'\'' ]/, "", id)
      found=(id==target)
      next
    }
    found && $1 == field":" {
      line=$0
      sub("^[[:space:]]*"field":[[:space:]]*", "", line)
      gsub(/["'\'' ]/, "", line)
      print line
      exit
    }
    found && /^[[:space:]]*-[[:space:]]*id:/ {exit}
  ' "$MANIFEST"
}

registry_has_tool() {
  local tool_id="$1"
  grep -q "^  ${tool_id}:" "$REGISTRY"
}

has_value() {
  local needle="$1"
  shift
  local v
  for v in "$@"; do
    [[ "$v" == "$needle" ]] && return 0
  done
  return 1
}

main() {
  local required=("$MANIFEST" "$REGISTRY" "$CAPABILITIES" "$TOOLS_DIR/_scaffold/template/TOOL.md")
  local f
  for f in "${required[@]}"; do
    if [[ ! -f "$f" ]]; then
      log_error "Missing required file: $f"
    fi
  done

  if [[ $errors -gt 0 ]]; then
    echo
    echo "Validation failed: $errors error(s), $warnings warning(s)."
    exit 1
  fi

  local builtins
  mapfile -t builtins < <(get_builtins)
  if [[ ${#builtins[@]} -eq 0 ]]; then
    log_error "No built-in tools found in capabilities.yml"
  else
    log_success "Loaded ${#builtins[@]} built-in tools"
  fi

  local pack_ids
  mapfile -t pack_ids < <(get_manifest_pack_ids)
  if [[ ${#pack_ids[@]} -eq 0 ]]; then
    log_error "No packs found in manifest.yml"
  else
    log_success "Found ${#pack_ids[@]} tool pack(s)"
  fi

  local seen_pack_ids=()
  local pack_id
  for pack_id in "${pack_ids[@]}"; do
    if has_value "$pack_id" "${seen_pack_ids[@]}"; then
      log_error "Duplicate pack id: $pack_id"
      continue
    fi
    seen_pack_ids+=("$pack_id")

    local csv
    csv="$(get_pack_tools_csv "$pack_id")"
    if [[ -z "$csv" ]]; then
      log_error "Pack '$pack_id' has no tools list"
      continue
    fi

    local item
    while IFS= read -r item; do
      [[ -z "$item" ]] && continue

      # Scoped Bash(...) is valid.
      if [[ "$item" == Bash\(*\) ]]; then
        continue
      fi

      if has_value "$item" "${builtins[@]}"; then
        continue
      fi

      log_error "Pack '$pack_id' contains unknown tool '$item'"
    done < <(parse_inline_list "[$csv]")
  done

  local tool_ids
  mapfile -t tool_ids < <(get_manifest_tool_ids)
  if [[ ${#tool_ids[@]} -eq 0 ]]; then
    log_success "No custom tools declared (tools: [])"
  fi

  local tool_id
  for tool_id in "${tool_ids[@]}"; do
    if [[ -z "$tool_id" ]]; then
      continue
    fi

    local interface_type
    interface_type="$(get_manifest_tool_field "$tool_id" "interface_type")"
    local path
    path="$(get_manifest_tool_field "$tool_id" "path")"

    if [[ -z "$interface_type" ]]; then
      log_error "Custom tool '$tool_id' missing interface_type in manifest"
    elif ! grep -q "^[[:space:]]*-[[:space:]]*$interface_type$" "$CAPABILITIES"; then
      log_error "Custom tool '$tool_id' has invalid interface_type '$interface_type'"
    fi

    if [[ -z "$path" ]]; then
      log_error "Custom tool '$tool_id' missing path in manifest"
    elif [[ ! -d "$TOOLS_DIR/$path" ]]; then
      log_warning "Custom tool '$tool_id' path not found: $TOOLS_DIR/$path"
    fi

    if registry_has_tool "$tool_id"; then
      log_success "Registry entry found for custom tool '$tool_id'"
    else
      log_warning "No registry metadata entry for custom tool '$tool_id'"
    fi
  done

  echo
  if [[ $errors -gt 0 ]]; then
    echo "Validation failed: $errors error(s), $warnings warning(s)."
    exit 1
  fi

  echo "Validation passed: 0 errors, $warnings warning(s)."
}

main "$@"
