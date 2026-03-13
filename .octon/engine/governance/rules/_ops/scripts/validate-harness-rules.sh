#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RULES_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
MANIFEST="$RULES_DIR/manifest.yml"
PROJECT_ROOT="$(cd "$RULES_DIR/../../../.." && pwd)"
CHECK_LINKS=false

if [[ "${1:-}" == "--check-links" ]]; then
  CHECK_LINKS=true
fi

if [[ ! -f "$MANIFEST" ]]; then
  echo "Error: manifest not found: $MANIFEST" >&2
  exit 1
fi

parse_manifest() {
  awk '
    BEGIN { rule_id=""; profile=""; harness=""; source=""; target="" }
    $1 == "-" && $2 == "rule_id:" {
      rule_id=$3
      gsub(/"/, "", rule_id)
      next
    }
    $1 == "profile:" {
      profile=$2
      gsub(/"/, "", profile)
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
      if (rule_id != "" && profile != "" && harness != "" && source != "" && target != "") {
        print rule_id "|" profile "|" harness "|" source "|" target
      }
      profile=""
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

errors=0

rows="$(parse_manifest)"

duplicates="$(printf '%s\n' "$rows" | awk -F'|' '{print $1 "|" $3}' | sort | uniq -d)"
if [[ -n "$duplicates" ]]; then
  while IFS= read -r key; do
    [[ -n "$key" ]] || continue
    echo "ERROR: duplicate manifest mapping for $key"
    errors=$((errors + 1))
  done <<< "$duplicates"
fi

while IFS='|' read -r rule_id profile harness source target; do
  [[ -n "$rule_id" ]] || continue

  profile_path="$RULES_DIR/profiles/$profile.yml"
  if [[ ! -f "$profile_path" ]]; then
    echo "ERROR: missing profile for $rule_id ($harness): $profile_path"
    errors=$((errors + 1))
  fi

  source_path="$RULES_DIR/$source"
  if [[ ! -f "$source_path" ]]; then
    echo "ERROR: missing adapter source for $rule_id ($harness): $source_path"
    errors=$((errors + 1))
  fi

  if [[ "$CHECK_LINKS" == true ]]; then
    target_path="$PROJECT_ROOT/$target"
    if [[ ! -L "$target_path" ]]; then
      echo "ERROR: target is not a symlink for $rule_id ($harness): $target_path"
      errors=$((errors + 1))
    else
      target_dir="$(dirname "$target")"
      prefix=$(rel_prefix_for_dir "$target_dir")
      expected="${prefix}.octon/engine/governance/rules/$source"
      actual="$(readlink "$target_path")"
      if [[ "$actual" != "$expected" ]]; then
        echo "ERROR: symlink mismatch for $rule_id ($harness): expected $expected got $actual"
        errors=$((errors + 1))
      fi
    fi
  fi
done <<< "$rows"

if [[ "$errors" -gt 0 ]]; then
  echo "Validation failed with $errors error(s)." >&2
  exit 1
fi

echo "Harness rule manifest validation passed."
if [[ "$CHECK_LINKS" == true ]]; then
  echo "Symlink integrity validation passed."
fi
