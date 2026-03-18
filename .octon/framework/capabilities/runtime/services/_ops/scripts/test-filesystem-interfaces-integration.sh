#!/usr/bin/env bash
# test-filesystem-interfaces-integration.sh - runtime integration checks for snapshot/graph/discovery flows.

set -o pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SERVICES_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
FRAMEWORK_DIR="$(cd "$SERVICES_DIR/../../.." && pwd)"
OCTON_DIR="$(cd "$FRAMEWORK_DIR/.." && pwd)"
REPO_ROOT="$(cd "$OCTON_DIR/.." && pwd)"
RUNTIME_RUN="$OCTON_DIR/framework/engine/runtime/run"
export OCTON_RUNTIME_PREFER_SOURCE="${OCTON_RUNTIME_PREFER_SOURCE:-1}"
STATE_DIR_BASE=".octon/framework/engine/_ops/state/snapshots"
STATE_DIR="${FILESYSTEM_INTERFACES_STATE_DIR:-$STATE_DIR_BASE/integration-$$}"
SNAPSHOT_ROOT=".octon/framework/capabilities/runtime/services/interfaces"
TARGET_NODE="file:.octon/framework/capabilities/runtime/services/interfaces/filesystem-snapshot/SERVICE.md"
TARGET_DIR_NODE="dir:.octon/framework/capabilities/runtime/services/interfaces/filesystem-snapshot"
HAS_RG=false

cleanup() {
  rm -rf "$REPO_ROOT/$STATE_DIR"
}
trap cleanup EXIT

if command -v rg >/dev/null 2>&1; then
  HAS_RG=true
fi

payload_has_regex() {
  local payload="$1"
  local pattern="$2"

  if [[ "$HAS_RG" == "true" ]]; then
    rg -q "$pattern" <<<"$payload"
    return $?
  fi

  printf '%s\n' "$payload" | grep -Eq -- "$pattern"
}

if [[ ! -x "$RUNTIME_RUN" ]]; then
  echo "ERROR: runtime launcher not found: $RUNTIME_RUN"
  exit 1
fi

extract_json_string_field() {
  local json="$1"
  local field="$2"
  printf '%s' "$json" | tr -d '\n' | sed -nE "s/.*\"$field\"[[:space:]]*:[[:space:]]*\"([^\"]+)\".*/\\1/p"
}

assert_contains() {
  local payload="$1"
  local pattern="$2"
  local message="$3"
  if ! payload_has_regex "$payload" "$pattern"; then
    echo "ERROR: $message"
    echo "$payload"
    exit 1
  fi
}

run_op() {
  local op="$1"
  local payload="$2"
  local service
  case "$op" in
    fs.*|snapshot.*)
      service="interfaces/filesystem-snapshot"
      ;;
    kg.*|discover.*)
      service="interfaces/filesystem-discovery"
      ;;
    watch.*)
      service="interfaces/filesystem-watch"
      ;;
    *)
      echo "ERROR: unsupported op in integration script: $op" >&2
      return 1
      ;;
  esac
  "$RUNTIME_RUN" tool "$service" "$op" --json "$payload"
}

BUILD_OUT="$(run_op snapshot.build "$(printf '{"root":"%s","state_dir":"%s","set_current":false}' "$SNAPSHOT_ROOT" "$STATE_DIR")")"
assert_contains "$BUILD_OUT" '"snapshot_id"[[:space:]]*:[[:space:]]*"snap-[a-f0-9]{8,64}"' "snapshot.build missing valid snapshot_id"
SNAPSHOT_ID="$(extract_json_string_field "$BUILD_OUT" "snapshot_id")"
if [[ -z "$SNAPSHOT_ID" ]]; then
  echo "ERROR: could not extract snapshot_id from snapshot.build output"
  echo "$BUILD_OUT"
  exit 1
fi

DIFF_IN="$(printf '{"base":"%s","head":"%s","state_dir":"%s"}' "$SNAPSHOT_ID" "$SNAPSHOT_ID" "$STATE_DIR")"
DIFF_OUT="$(run_op snapshot.diff "$DIFF_IN")"
assert_contains "$DIFF_OUT" '"added"[[:space:]]*:[[:space:]]*0' "snapshot.diff expected added=0 for same snapshot"
assert_contains "$DIFF_OUT" '"removed"[[:space:]]*:[[:space:]]*0' "snapshot.diff expected removed=0 for same snapshot"
assert_contains "$DIFF_OUT" '"changed"[[:space:]]*:[[:space:]]*0' "snapshot.diff expected changed=0 for same snapshot"

GET_NODE_IN="$(printf '{"snapshot_id":"%s","node_id":"%s","state_dir":"%s"}' "$SNAPSHOT_ID" "$TARGET_NODE" "$STATE_DIR")"
GET_NODE_OUT="$(run_op kg.get-node "$GET_NODE_IN")"
assert_contains "$GET_NODE_OUT" '"node_id"[[:space:]]*:[[:space:]]*"file:.octon/framework/capabilities/runtime/services/interfaces/filesystem-snapshot/SERVICE.md"' "kg.get-node missing expected node"

DISCOVER_START_IN="$(printf '{"snapshot_id":"%s","query":"octon","limit":6,"content_scan_limit":80,"max_op_ms":5000,"state_dir":"%s"}' "$SNAPSHOT_ID" "$STATE_DIR")"
DISCOVER_START_OUT="$(run_op discover.start "$DISCOVER_START_IN")"
assert_contains "$DISCOVER_START_OUT" '"frontier_node_ids"[[:space:]]*:' "discover.start missing frontier results"

DISCOVER_EXPAND_IN="$(printf '{"snapshot_id":"%s","node_ids":["%s"],"limit":64,"state_dir":"%s"}' "$SNAPSHOT_ID" "$TARGET_DIR_NODE" "$STATE_DIR")"
DISCOVER_EXPAND_OUT="$(run_op discover.expand "$DISCOVER_EXPAND_IN")"
assert_contains "$DISCOVER_EXPAND_OUT" '"next_node_ids"[[:space:]]*:' "discover.expand missing next_node_ids"

DISCOVER_EXPLAIN_IN="$(printf '{"snapshot_id":"%s","candidate_node_ids":["%s"],"query":"octon","state_dir":"%s"}' "$SNAPSHOT_ID" "$TARGET_NODE" "$STATE_DIR")"
DISCOVER_EXPLAIN_OUT="$(run_op discover.explain "$DISCOVER_EXPLAIN_IN")"
assert_contains "$DISCOVER_EXPLAIN_OUT" '"input_fingerprint"[[:space:]]*:' "discover.explain missing provenance.input_fingerprint"

DISCOVER_RESOLVE_IN="$(printf '{"snapshot_id":"%s","node_id":"%s","state_dir":"%s"}' "$SNAPSHOT_ID" "$TARGET_NODE" "$STATE_DIR")"
DISCOVER_RESOLVE_OUT="$(run_op discover.resolve "$DISCOVER_RESOLVE_IN")"
assert_contains "$DISCOVER_RESOLVE_OUT" '"exists"[[:space:]]*:[[:space:]]*(true|false)' "discover.resolve missing exists flag"

BROKEN_ID="snap-deadbeef$(printf '%08x' "$RANDOM")"
BADFMT_ID="snap-feedface$(printf '%08x' "$RANDOM")"
INCOMPLETE_ID="snap-00000000deadbeef"
BROKEN_DIR="$REPO_ROOT/$STATE_DIR/$BROKEN_ID"
BADFMT_DIR="$REPO_ROOT/$STATE_DIR/$BADFMT_ID"
INCOMPLETE_DIR="$REPO_ROOT/$STATE_DIR/$INCOMPLETE_ID"
STAGING_DIR="$REPO_ROOT/$STATE_DIR/.staging-snap-cleanup-test"
LOCK_FILE="$REPO_ROOT/$STATE_DIR/.snapshot-build.lock"
trap 'rm -rf "$BROKEN_DIR" "$BADFMT_DIR" "$INCOMPLETE_DIR" "$STAGING_DIR"; rm -f "$LOCK_FILE"' EXIT
mkdir -p "$BROKEN_DIR"
printf '{"snapshot_id":"%s"}\n' "$BROKEN_ID" > "$BROKEN_DIR/manifest.json"

BROKEN_IN="$(printf '{"snapshot_id":"%s","query":"octon","limit":3,"state_dir":"%s"}' "$BROKEN_ID" "$STATE_DIR")"
BROKEN_OUT="$(run_op discover.start "$BROKEN_IN")"
assert_contains "$BROKEN_OUT" '"code"[[:space:]]*:[[:space:]]*"ERR_FILESYSTEM_INTERFACES_SNAPSHOT_INVALID"' "corrupt snapshot should return ERR_FILESYSTEM_INTERFACES_SNAPSHOT_INVALID"
assert_contains "$BROKEN_OUT" 'Rebuild snapshot artifacts' "corrupt snapshot response missing remediation guidance"

mkdir -p "$BADFMT_DIR"
cat > "$BADFMT_DIR/manifest.json" <<EOF
{"snapshot_format_version":999,"snapshot_id":"$BADFMT_ID","root":".","input_fingerprint":"0000000000000000000000000000000000000000000000000000000000000000","created_at":"2026-02-16T00:00:00Z","counts":{"files":0,"nodes":0,"edges":0}}
EOF
: > "$BADFMT_DIR/files.jsonl"
: > "$BADFMT_DIR/nodes.jsonl"
: > "$BADFMT_DIR/edges.jsonl"
printf 'ready_at=%s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)" > "$BADFMT_DIR/.ready"

BADFMT_IN="$(printf '{"snapshot_id":"%s","query":"octon","limit":3,"state_dir":"%s"}' "$BADFMT_ID" "$STATE_DIR")"
BADFMT_OUT="$(run_op discover.start "$BADFMT_IN")"
assert_contains "$BADFMT_OUT" '"code"[[:space:]]*:[[:space:]]*"ERR_FILESYSTEM_INTERFACES_FORMAT_UNSUPPORTED"' "unsupported snapshot format should return ERR_FILESYSTEM_INTERFACES_FORMAT_UNSUPPORTED"

NOW_MS="$(($(date +%s) * 1000))"
printf 'created_ms=%s\ncreated_at=%s\n' "$NOW_MS" "$(date -u +%Y-%m-%dT%H:%M:%SZ)" > "$LOCK_FILE"
LOCKED_OUT="$(run_op snapshot.build "$(printf '{"root":"%s","state_dir":"%s","set_current":false}' "$SNAPSHOT_ROOT" "$STATE_DIR")")"
assert_contains "$LOCKED_OUT" '"code"[[:space:]]*:[[:space:]]*"ERR_FILESYSTEM_INTERFACES_LOCKED"' "pre-existing build lock should return ERR_FILESYSTEM_INTERFACES_LOCKED"
rm -f "$LOCK_FILE"

mkdir -p "$STAGING_DIR"
printf 'staging-junk\n' > "$STAGING_DIR/junk.txt"
mkdir -p "$INCOMPLETE_DIR"
printf 'started_at=%s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)" > "$INCOMPLETE_DIR/.building"
CLEANUP_OUT="$(run_op snapshot.build "$(printf '{"root":"%s","state_dir":"%s","set_current":false}' "$SNAPSHOT_ROOT" "$STATE_DIR")")"
assert_contains "$CLEANUP_OUT" '"ok"[[:space:]]*:[[:space:]]*true' "snapshot.build should succeed while cleaning stale transients"
if [[ -d "$STAGING_DIR" ]]; then
  echo "ERROR: stale staging directory was not cleaned: $STAGING_DIR"
  exit 1
fi
if [[ -d "$INCOMPLETE_DIR" ]]; then
  echo "ERROR: incomplete snapshot directory was not cleaned: $INCOMPLETE_DIR"
  exit 1
fi

LIMIT_OUT="$(run_op snapshot.build "$(printf '{"root":"%s","state_dir":"%s","set_current":false,"max_files":1}' "$SNAPSHOT_ROOT" "$STATE_DIR")")"
assert_contains "$LIMIT_OUT" '"code"[[:space:]]*:[[:space:]]*"ERR_FILESYSTEM_INTERFACES_LIMIT_EXCEEDED"' "snapshot.build max_files cap should trigger ERR_FILESYSTEM_INTERFACES_LIMIT_EXCEEDED"

WATCH_OUT="$(run_op watch.poll '{"root":".octon/framework/capabilities/runtime/services/interfaces","state_key":"filesystem-watch:integration","max_events":30,"max_files":100000}')"
assert_contains "$WATCH_OUT" '"cursor"[[:space:]]*:[[:space:]]*"watch-[a-f0-9]{16}"' "watch.poll missing deterministic cursor"
assert_contains "$WATCH_OUT" '"summary"[[:space:]]*:' "watch.poll missing summary payload"

echo "filesystem-interfaces integration checks passed: $SNAPSHOT_ID"
