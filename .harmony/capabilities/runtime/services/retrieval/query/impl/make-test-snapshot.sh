#!/usr/bin/env bash
# make-test-snapshot.sh - Generate minimal local snapshot artifacts for Phase 1 testing.

set -euo pipefail

output_root=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --output-root)
      output_root="${2:-}"
      shift 2
      ;;
    *)
      echo "Unknown argument: $1" >&2
      exit 2
      ;;
  esac
done

if [[ -z "$output_root" ]]; then
  if repo_root="$(git rev-parse --show-toplevel 2>/dev/null)"; then
    output_root="$repo_root/indexes"
  else
    output_root="./indexes"
  fi
fi

mkdir -p "$output_root/test-snapshot" "$output_root/test-snapshot-no-graph" "$output_root/test-snapshot-missing-keyword"

write_chunks() {
  local target_dir="$1"
  cat > "$target_dir/chunks.jsonl" <<'JSONL'
{"chunk_id":"doc:flags#c:0001","doc_id":"doc:flags","locator":"docs/flags.md:42","text":"Rollout gates require owner approval before staged enablement and production exposure."}
{"chunk_id":"doc:owners#c:0001","doc_id":"doc:owners","locator":"docs/ownership.md:15","text":"Platform owner approves staged rollout and monitors safety gates."}
{"chunk_id":"doc:owners#c:0002","doc_id":"doc:owners","locator":"docs/ownership.md:27","text":"Ownership decisions require escalation to platform leads for policy exceptions."}
{"chunk_id":"doc:migration#c:0001","doc_id":"doc:migration","locator":"docs/migration.md:9","text":"Migration guide explains v2 rollout changes and fallback procedures."}
JSONL
}

write_keyword() {
  local target_dir="$1"
  cat > "$target_dir/keyword.json" <<'JSON'
{
  "version": "0.1.0",
  "index_type": "test-keyword",
  "notes": "Fixture-friendly keyword artifact for query phase1 runtime tests."
}
JSON
}

write_links() {
  local target_dir="$1"
  cat > "$target_dir/links.jsonl" <<'JSONL'
{"src":"doc:flags#c:0001","dst":"doc:owners#c:0001","weight":0.7,"edge":"internal"}
{"src":"doc:flags#c:0001","dst":"doc:owners#c:0002","weight":0.4,"edge":"internal"}
{"src":"doc:owners#c:0001","dst":"doc:migration#c:0001","weight":0.2,"edge":"related"}
JSONL
}

write_hierarchical() {
  local target_dir="$1"
  mkdir -p "$target_dir/hierarchical"
  cat > "$target_dir/hierarchical/summaries.jsonl" <<'JSONL'
{"summary_id":"h:0001","text":"release authority governance posture escalation pathways","leaf_chunk_ids":["doc:flags#c:0001","doc:owners#c:0002"]}
{"summary_id":"h:0002","text":"staged rollout monitoring by platform owner","leaf_chunk_ids":["doc:owners#c:0001"]}
JSONL
}

write_graph_global() {
  local target_dir="$1"
  mkdir -p "$target_dir/graph_global"
  cat > "$target_dir/graph_global/community_summaries.jsonl" <<'JSONL'
{"community_id":"g:0001","summary":"global policy narrative accountability and migration posture","chunk_ids":["doc:owners#c:0002","doc:migration#c:0001"]}
{"community_id":"g:0002","summary":"authority gates and staged release controls","chunk_ids":["doc:flags#c:0001","doc:owners#c:0001"]}
JSONL
}

write_chunks "$output_root/test-snapshot"
write_keyword "$output_root/test-snapshot"
write_links "$output_root/test-snapshot"
write_hierarchical "$output_root/test-snapshot"
write_graph_global "$output_root/test-snapshot"

write_chunks "$output_root/test-snapshot-no-graph"
write_keyword "$output_root/test-snapshot-no-graph"
write_hierarchical "$output_root/test-snapshot-no-graph"

write_chunks "$output_root/test-snapshot-missing-keyword"
write_links "$output_root/test-snapshot-missing-keyword"
write_graph_global "$output_root/test-snapshot-missing-keyword"

cat <<MSG
Generated query test snapshots under:
- $output_root/test-snapshot
- $output_root/test-snapshot-no-graph
- $output_root/test-snapshot-missing-keyword
MSG
