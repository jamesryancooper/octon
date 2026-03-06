#!/usr/bin/env bash
# compile-deny-by-default-policy.sh - Build normalized deny-by-default policy catalog for skills.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLS_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
REPO_ROOT="$(cd "$SKILLS_DIR/../../../.." && pwd)"
MANIFEST="$SKILLS_DIR/manifest.yml"
DEFAULT_OUT="$SKILLS_DIR/_ops/state/deny-by-default-policy.catalog.yml"
OUT_PATH="${1:-$DEFAULT_OUT}"

split_allowed_tools() {
  local raw="$1"
  local token=""
  local depth=0
  local ch
  local i

  for ((i=0; i<${#raw}; i++)); do
    ch="${raw:i:1}"
    case "$ch" in
      "(")
        depth=$((depth + 1))
        token+="$ch"
        ;;
      ")")
        if [[ $depth -gt 0 ]]; then
          depth=$((depth - 1))
        fi
        token+="$ch"
        ;;
      " " | $'\t')
        if [[ $depth -eq 0 ]]; then
          if [[ -n "$token" ]]; then
            echo "$token"
            token=""
          fi
        else
          token+="$ch"
        fi
        ;;
      *)
        token+="$ch"
        ;;
    esac
  done

  if [[ -n "$token" ]]; then
    echo "$token"
  fi
}

split_space_list() {
  local raw="$1"
  local item
  for item in $raw; do
    [[ -n "$item" ]] && echo "$item"
  done
}

get_skill_rows() {
  awk '
    /^skills:/ {in_skills=1; next}
    in_skills && /^[[:space:]]*- id:/ {
      id=$3
      gsub(/["'\'' ]/, "", id)
      next
    }
    in_skills && /^[[:space:]]*path:/ {
      path=$2
      gsub(/["'\'' ]/, "", path)
      next
    }
    in_skills && /^[[:space:]]*status:/ {
      status=$2
      gsub(/["'\'' ]/, "", status)
      if (id != "" && path != "") {
        print id "\t" path "\t" status
      }
      id=""
      path=""
      status=""
    }
  ' "$MANIFEST"
}

mkdir -p "$(dirname "$OUT_PATH")"
tmp_path="$(mktemp "${OUT_PATH}.tmp.XXXXXX")"
trap 'rm -f "$tmp_path"' EXIT

normalize_generated_at() {
  sed -E 's/^generated_at: "[^"]*"/generated_at: "__GENERATED_AT__"/'
}

RELATIVE_MANIFEST="${MANIFEST#$REPO_ROOT/}"

{
  echo "schema_version: \"1.0\""
  echo "generated_at: \"__GENERATED_AT__\""
  echo "source_manifest: \"$RELATIVE_MANIFEST\""
  echo "skills:"

  while IFS=$'\t' read -r skill_id skill_path skill_status; do
    skill_dir="$SKILLS_DIR/$skill_path"
    skill_md="$skill_dir/SKILL.md"
    allowed_tools_raw=""
    allowed_services_raw=""
    broad_write_scope=false

    if [[ -f "$skill_md" ]]; then
      allowed_tools_raw="$(
        { grep -E "^allowed-tools:" "$skill_md" || true; } | head -1 | sed 's/allowed-tools:[[:space:]]*//'
      )"
      allowed_services_raw="$(
        { grep -E "^allowed-services:" "$skill_md" || true; } | head -1 | sed 's/allowed-services:[[:space:]]*//'
      )"

      if [[ -n "$allowed_tools_raw" ]]; then
        while IFS= read -r token; do
          [[ -z "$token" ]] && continue
          if [[ "$token" =~ ^Write\((.*)\)$ ]]; then
            write_scope="${BASH_REMATCH[1]}"
            if [[ "$write_scope" == *"**"* ]]; then
              broad_write_scope=true
              break
            fi
          fi
        done < <(split_allowed_tools "$allowed_tools_raw")
      fi
    fi

    echo "  - id: \"$skill_id\""
    echo "    path: \"$skill_path\""
    echo "    status: \"$skill_status\""
    echo "    broad_write_scope: $broad_write_scope"
    echo "    allowed_tools:"
    if [[ -n "$allowed_tools_raw" ]]; then
      while IFS= read -r token; do
        [[ -z "$token" ]] && continue
        escaped_token=$(printf '%s' "$token" | sed 's/"/\\"/g')
        echo "      - \"$escaped_token\""
      done < <(split_allowed_tools "$allowed_tools_raw")
    fi
    echo "    allowed_services:"
    if [[ -n "$allowed_services_raw" ]]; then
      while IFS= read -r service_id; do
        [[ -z "$service_id" ]] && continue
        escaped_service=$(printf '%s' "$service_id" | sed 's/"/\\"/g')
        echo "      - \"$escaped_service\""
      done < <(split_space_list "$allowed_services_raw")
    fi
  done < <(get_skill_rows)
} > "$tmp_path"

generated_at="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
if [[ -f "$OUT_PATH" ]]; then
  existing_generated_at="$(awk -F'"' '/^generated_at:/ {print $2; exit}' "$OUT_PATH")"
  if [[ -n "$existing_generated_at" ]]; then
    existing_normalized="$(normalize_generated_at < "$OUT_PATH")"
    candidate_normalized="$(normalize_generated_at < "$tmp_path")"
    if [[ "$existing_normalized" == "$candidate_normalized" ]]; then
      generated_at="$existing_generated_at"
    fi
  fi
fi

sed "s|__GENERATED_AT__|$generated_at|" "$tmp_path" > "$OUT_PATH"
rm -f "$tmp_path"
trap - EXIT

echo "$OUT_PATH"
