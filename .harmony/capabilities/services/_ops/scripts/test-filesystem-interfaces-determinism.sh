#!/usr/bin/env bash
# test-filesystem-interfaces-determinism.sh - determinism and runtime-state exclusion checks.

set -o pipefail

HARMONY_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
REPO_ROOT="$(cd "$HARMONY_DIR/.." && pwd)"
RUNTIME_RUN="$HARMONY_DIR/runtime/run"
STATE_DIR=".harmony/runtime/_ops/state/snapshots"

if [[ ! -x "$RUNTIME_RUN" ]]; then
  echo "ERROR: runtime launcher not found: $RUNTIME_RUN"
  exit 1
fi

build_snapshot() {
  "$RUNTIME_RUN" tool interfaces/filesystem-snapshot snapshot.build --json '{"root":".","state_dir":".harmony/runtime/_ops/state/snapshots","set_current":false}'
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
if ! rg -q '"ok"[[:space:]]*:[[:space:]]*true' <<<"$OUT1"; then
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
if ! rg -q '"ok"[[:space:]]*:[[:space:]]*true' <<<"$OUT2"; then
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

if rg -n "\"path\":\"\\.harmony/runtime/_ops/state/" "$FILES_JSONL" >/dev/null 2>&1; then
  echo "ERROR: runtime state paths leaked into snapshot artifact"
  rg -n "\"path\":\"\\.harmony/runtime/_ops/state/" "$FILES_JSONL" || true
  exit 1
fi

echo "filesystem-interfaces determinism passed: $SNAP1"
