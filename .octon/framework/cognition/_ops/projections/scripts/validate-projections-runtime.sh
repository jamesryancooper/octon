#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
COGNITION_DIR="$(cd -- "$SCRIPT_DIR/../../.." && pwd)"
PROJECTIONS_DIR="$COGNITION_DIR/runtime/projections"

errors=0

fail() {
  echo "[ERROR] $1"
  errors=$((errors + 1))
}

pass() {
  echo "[OK] $1"
}

require_file() {
  local path="$1"
  if [[ ! -f "$path" ]]; then
    fail "missing file: ${path#$COGNITION_DIR/}"
  else
    pass "found file: ${path#$COGNITION_DIR/}"
  fi
}

require_dir() {
  local path="$1"
  if [[ ! -d "$path" ]]; then
    fail "missing directory: ${path#$COGNITION_DIR/}"
  else
    pass "found directory: ${path#$COGNITION_DIR/}"
  fi
}

extract_index_paths() {
  local index_file="$1"
  awk '
    /^[[:space:]]+path:[[:space:]]*/ {
      line=$0
      sub(/^[[:space:]]+path:[[:space:]]*/, "", line)
      sub(/[[:space:]]+#.*/, "", line)
      gsub(/^"/, "", line)
      gsub(/"$/, "", line)
      if (length(line) > 0) print line
    }
  ' "$index_file"
}

check_index_paths() {
  local index_file="$1"
  local index_dir path

  require_file "$index_file"
  [[ -f "$index_file" ]] || return
  index_dir="$(cd -- "$(dirname -- "$index_file")" && pwd)"

  while IFS= read -r path; do
    [[ -z "$path" ]] && continue
    if [[ "$path" == /* ]]; then
      fail "absolute path not allowed in index: ${index_file#$COGNITION_DIR/} -> $path"
      continue
    fi
    if [[ -e "$index_dir/$path" ]]; then
      pass "index path resolves: ${index_file#$COGNITION_DIR/} -> $path"
    else
      fail "index path missing target: ${index_file#$COGNITION_DIR/} -> $path"
    fi
  done < <(extract_index_paths "$index_file")
}

echo "== Validate Runtime Projections Surface =="

require_dir "$PROJECTIONS_DIR"
require_dir "$PROJECTIONS_DIR/definitions"
require_dir "$PROJECTIONS_DIR/materialized"

require_file "$PROJECTIONS_DIR/index.yml"
require_file "$PROJECTIONS_DIR/definitions/index.yml"
require_file "$PROJECTIONS_DIR/definitions/cognition-runtime-surface-map.yml"
require_file "$PROJECTIONS_DIR/materialized/index.yml"
require_file "$PROJECTIONS_DIR/materialized/cognition-runtime-surface-map.latest.yml"

check_index_paths "$PROJECTIONS_DIR/index.yml"
check_index_paths "$PROJECTIONS_DIR/definitions/index.yml"
check_index_paths "$PROJECTIONS_DIR/materialized/index.yml"

if ! rg -q '^projection_id:[[:space:]]*' "$PROJECTIONS_DIR/materialized/cognition-runtime-surface-map.latest.yml"; then
  fail "materialized projection missing projection_id"
else
  pass "materialized projection projection_id present"
fi

if ! rg -q '^generated_at:[[:space:]]*' "$PROJECTIONS_DIR/materialized/cognition-runtime-surface-map.latest.yml"; then
  fail "materialized projection missing generated_at"
else
  pass "materialized projection generated_at present"
fi

if [[ $errors -gt 0 ]]; then
  echo "Validation summary: errors=$errors"
  exit 1
fi

echo "Validation summary: errors=0"
