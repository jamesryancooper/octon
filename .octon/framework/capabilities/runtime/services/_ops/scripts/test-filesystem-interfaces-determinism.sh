#!/usr/bin/env bash
# test-filesystem-interfaces-determinism.sh - determinism and runtime-state exclusion checks.

set -o pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SERVICES_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
FRAMEWORK_DIR="$(cd "$SERVICES_DIR/../../.." && pwd)"
OCTON_DIR="$(cd "$FRAMEWORK_DIR/.." && pwd)"
REPO_ROOT="$(cd "$OCTON_DIR/.." && pwd)"
RUNTIME_RUN="$OCTON_DIR/framework/engine/runtime/run"
export OCTON_RUNTIME_PREFER_SOURCE="${OCTON_RUNTIME_PREFER_SOURCE:-1}"
STATE_DIR_BASE=".octon/framework/engine/_ops/state/snapshots"
STATE_DIR="${FILESYSTEM_INTERFACES_STATE_DIR:-$STATE_DIR_BASE/determinism-$$}"
HAS_RG=false

cleanup() {
  rm -rf "$REPO_ROOT/$STATE_DIR"
}
trap cleanup EXIT

if command -v rg >/dev/null 2>&1; then
  HAS_RG=true
fi

has_payload_match() {
  local pattern="$1"
  local payload="$2"

  if [[ "$HAS_RG" == "true" ]]; then
    rg -q "$pattern" <<<"$payload"
    return $?
  fi

  printf '%s\n' "$payload" | grep -Eq -- "$pattern"
}

has_file_match() {
  local pattern="$1"
  local file="$2"

  if [[ "$HAS_RG" == "true" ]]; then
    rg -n "$pattern" "$file" >/dev/null 2>&1
    return $?
  fi

  grep -nE -- "$pattern" "$file" >/dev/null 2>&1
}

print_file_matches() {
  local pattern="$1"
  local file="$2"

  if [[ "$HAS_RG" == "true" ]]; then
    rg -n "$pattern" "$file" || true
    return 0
  fi

  grep -nE -- "$pattern" "$file" || true
}

if [[ ! -x "$RUNTIME_RUN" ]]; then
  echo "ERROR: runtime launcher not found: $RUNTIME_RUN"
  exit 1
fi

build_snapshot() {
  local payload
  payload="$(printf '{"root":".octon/framework/capabilities/runtime/services/interfaces","state_dir":"%s","set_current":false}' "$STATE_DIR")"
  "$RUNTIME_RUN" tool interfaces/filesystem-snapshot snapshot.build --json "$payload"
}

extract_json_string_field() {
  local json="$1"
  local field="$2"
  printf '%s' "$json" | tr -d '\n' | sed -nE "s/.*\"$field\"[[:space:]]*:[[:space:]]*\"([^\"]+)\".*/\\1/p"
}

OUT1="$(build_snapshot)" || {
  echo "ERROR: first snapshot build failed"
  echo "$OUT1"
  exit 1
}
if ! has_payload_match '"ok"[[:space:]]*:[[:space:]]*true' "$OUT1"; then
  echo "ERROR: first snapshot build returned failure payload"
  echo "$OUT1"
  exit 1
fi
SNAP1="$(extract_json_string_field "$OUT1" "snapshot_id")"

OUT2="$(build_snapshot)" || {
  echo "ERROR: second snapshot build failed"
  echo "$OUT2"
  exit 1
}
if ! has_payload_match '"ok"[[:space:]]*:[[:space:]]*true' "$OUT2"; then
  echo "ERROR: second snapshot build returned failure payload"
  echo "$OUT2"
  exit 1
fi
SNAP2="$(extract_json_string_field "$OUT2" "snapshot_id")"

if [[ -z "$SNAP1" || -z "$SNAP2" ]]; then
  echo "ERROR: missing snapshot ids from build outputs"
  echo "$OUT1"
  echo "$OUT2"
  exit 1
fi

if [[ "$SNAP1" != "$SNAP2" ]]; then
  echo "ERROR: deterministic snapshot test failed ($SNAP1 != $SNAP2)"
  DIFF_INPUT="$(printf '{"base":"%s","head":"%s","state_dir":"%s"}' "$SNAP1" "$SNAP2" "$STATE_DIR")"
  "$RUNTIME_RUN" tool interfaces/filesystem-snapshot snapshot.diff --json "$DIFF_INPUT"
  exit 1
fi

FILES_JSONL="$REPO_ROOT/$STATE_DIR/$SNAP1/files.jsonl"
if [[ ! -f "$FILES_JSONL" ]]; then
  echo "ERROR: files.jsonl missing for snapshot: $SNAP1"
  exit 1
fi

if has_file_match "\"path\":\"\\.octon/framework/engine/_ops/state/" "$FILES_JSONL"; then
  echo "ERROR: runtime state paths leaked into snapshot artifact"
  print_file_matches "\"path\":\"\\.octon/framework/engine/_ops/state/" "$FILES_JSONL"
  exit 1
fi

echo "filesystem-interfaces determinism passed: $SNAP1"
