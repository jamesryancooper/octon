#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RULES_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
MANIFEST="$RULES_DIR/manifest.yml"
PROJECT_ROOT="$(cd "$RULES_DIR/../../../.." && pwd)"

RULE_FILTER="${1:-}"

if [[ ! -f "$MANIFEST" ]]; then
  echo "Error: manifest not found: $MANIFEST" >&2
  exit 1
fi

parse_manifest() {
  awk '
    BEGIN { rule_id=""; harness=""; source=""; target="" }
    $1 == "-" && $2 == "rule_id:" {
      rule_id=$3
      gsub(/"/, "", rule_id)
      next
    }
    $1 == "harness:" {
      harness=$2
      gsub(/"/, "", harness)
      next
    }
    $1 == "source:" {
      source=$2
      gsub(/"/, "", source)
      next
    }
    $1 == "target:" {
      target=$2
      gsub(/"/, "", target)
      if (rule_id != "" && harness != "" && source != "" && target != "") {
        print rule_id "|" harness "|" source "|" target
      }
      harness=""
      source=""
      target=""
      next
    }
  ' "$MANIFEST"
}

rel_prefix_for_dir() {
  local dir="$1"
  local cleaned="${dir#./}"

  if [[ -z "$cleaned" || "$cleaned" == "." ]]; then
    printf ""
    return
  fi

  local depth
  depth=$(awk -F'/' '{print NF}' <<<"$cleaned")

  local prefix=""
  local i
  for ((i = 0; i < depth; i++)); do
    prefix+="../"
  done
  printf "%s" "$prefix"
}

create_link() {
  local rule_id="$1"
  local source_rel="$2"
  local target_rel="$3"

  local source_abs="$RULES_DIR/$source_rel"
  local target_abs="$PROJECT_ROOT/$target_rel"
  local target_dir
  target_dir="$(dirname "$target_rel")"

  if [[ ! -f "$source_abs" ]]; then
    echo "  [error] missing source for $rule_id: $source_abs" >&2
    return 1
  fi

  if ! mkdir -p "$(dirname "$target_abs")" 2>/dev/null; then
    echo "  [skip] $target_rel (cannot create target directory)"
    return 0
  fi

  local prefix
  prefix=$(rel_prefix_for_dir "$target_dir")
  local link_target="${prefix}.octon/engine/governance/rules/$source_rel"

  if [[ -L "$target_abs" ]]; then
    local existing_target
    existing_target="$(readlink "$target_abs")"
    if [[ "$existing_target" == "$link_target" ]]; then
      echo "  [skip] $target_rel (already linked)"
      return 0
    fi
    rm "$target_abs"
  elif [[ -e "$target_abs" ]]; then
    rm "$target_abs"
  fi

  ln -s "$link_target" "$target_abs"
  echo "  [linked] $target_rel -> $link_target"
}

echo "Setting up harness rule links..."
echo "Project root: $PROJECT_ROOT"
echo "Rules dir: $RULES_DIR"

while IFS='|' read -r rule_id harness source target; do
  [[ -n "$rule_id" ]] || continue
  if [[ -n "$RULE_FILTER" && "$RULE_FILTER" != "$rule_id" ]]; then
    continue
  fi
  create_link "$rule_id" "$source" "$target"
done < <(parse_manifest)

echo "Done."
