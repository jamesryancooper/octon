#!/usr/bin/env bash
# compile-deny-by-default-policy.sh - Build normalized deny-by-default policy catalog for services.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SERVICES_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
MANIFEST="$SERVICES_DIR/manifest.yml"
DEFAULT_OUT="$SERVICES_DIR/_ops/state/deny-by-default-policy.catalog.yml"
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

get_service_rows() {
  awk '
    /^services:/ {in_services=1; next}
    in_services && /^[[:space:]]*- id:/ {
      id=$3
      gsub(/["'\'' ]/, "", id)
      next
    }
    in_services && /^[[:space:]]*path:/ {
      path=$2
      gsub(/["'\'' ]/, "", path)
      next
    }
    in_services && /^[[:space:]]*status:/ {
      status=$2
      gsub(/["'\'' ]/, "", status)
      next
    }
    in_services && /^[[:space:]]*interface_type:/ {
      iface=$2
      gsub(/["'\'' ]/, "", iface)
      if (id != "" && path != "") {
        print id "\t" path "\t" status "\t" iface
      }
      id=""
      path=""
      status=""
      iface=""
    }
  ' "$MANIFEST"
}

get_fail_closed() {
  local service_md="$1"
  awk '
    /^---/ {
      delim_count++
      if (delim_count == 2) exit
      next
    }
    delim_count == 1 && /^[[:space:]]*fail_closed:/ {
      line=$0
      sub(/^[[:space:]]*fail_closed:[[:space:]]*/, "", line)
      gsub(/["'\'' ]/, "", line)
      print tolower(line)
      exit
    }
  ' "$service_md"
}

mkdir -p "$(dirname "$OUT_PATH")"
tmp_path="$(mktemp "${OUT_PATH}.tmp.XXXXXX")"
trap 'rm -f "$tmp_path"' EXIT

normalize_generated_at() {
  sed -E 's/^generated_at: "[^"]*"/generated_at: "__GENERATED_AT__"/'
}

{
  echo "schema_version: \"1.0\""
  echo "generated_at: \"__GENERATED_AT__\""
  echo "source_manifest: \"$MANIFEST\""
  echo "services:"

  while IFS=$'\t' read -r service_id service_path service_status interface_type; do
    local_service_dir="$SERVICES_DIR/$service_path"
    service_md="$local_service_dir/SERVICE.md"
    fail_closed=""
    allowed_raw=""

    if [[ -f "$service_md" ]]; then
      fail_closed="$(get_fail_closed "$service_md")"
      allowed_raw="$(grep -E "^allowed-tools:" "$service_md" | head -1 | sed 's/allowed-tools:[[:space:]]*//')"
    fi

    echo "  - id: \"$service_id\""
    echo "    path: \"$service_path\""
    echo "    status: \"$service_status\""
    echo "    interface_type: \"$interface_type\""
    if [[ -n "$fail_closed" ]]; then
      echo "    fail_closed: $fail_closed"
    else
      echo "    fail_closed: null"
    fi
    echo "    allowed_tools:"
    if [[ -n "$allowed_raw" ]]; then
      while IFS= read -r token; do
        [[ -z "$token" ]] && continue
        escaped_token=$(printf '%s' "$token" | sed 's/"/\\"/g')
        echo "      - \"$escaped_token\""
      done < <(split_allowed_tools "$allowed_raw")
    fi
  done < <(get_service_rows)
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
