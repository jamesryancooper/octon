#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
COGNITION_DIR="$(cd -- "$SCRIPT_DIR/../../.." && pwd)"
KNOWLEDGE_DIR="$COGNITION_DIR/runtime/knowledge"

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

echo "== Validate Runtime Knowledge Surface =="

require_dir "$KNOWLEDGE_DIR"
require_dir "$KNOWLEDGE_DIR/graph"
require_dir "$KNOWLEDGE_DIR/sources"
require_dir "$KNOWLEDGE_DIR/queries"

require_file "$KNOWLEDGE_DIR/index.yml"
require_file "$KNOWLEDGE_DIR/knowledge.md"
require_file "$KNOWLEDGE_DIR/graph/index.yml"
require_file "$KNOWLEDGE_DIR/graph/nodes.yml"
require_file "$KNOWLEDGE_DIR/graph/edges.yml"
require_file "$KNOWLEDGE_DIR/sources/index.yml"
require_file "$KNOWLEDGE_DIR/sources/ingestion-receipts.yml"
require_file "$KNOWLEDGE_DIR/queries/index.yml"
require_file "$KNOWLEDGE_DIR/queries/query-catalog.yml"

check_index_paths "$KNOWLEDGE_DIR/index.yml"
check_index_paths "$KNOWLEDGE_DIR/graph/index.yml"
check_index_paths "$KNOWLEDGE_DIR/sources/index.yml"
check_index_paths "$KNOWLEDGE_DIR/queries/index.yml"

if ! rg -q '^schema_version:[[:space:]]*".+"' "$KNOWLEDGE_DIR/graph/nodes.yml"; then
  fail "nodes dataset missing schema_version"
else
  pass "nodes dataset schema_version present"
fi

if ! rg -q '^schema_version:[[:space:]]*".+"' "$KNOWLEDGE_DIR/graph/edges.yml"; then
  fail "edges dataset missing schema_version"
else
  pass "edges dataset schema_version present"
fi

if [[ $errors -gt 0 ]]; then
  echo "Validation summary: errors=$errors"
  exit 1
fi

echo "Validation summary: errors=0"
