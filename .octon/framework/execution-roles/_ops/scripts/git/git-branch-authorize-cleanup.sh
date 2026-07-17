#!/usr/bin/env bash
set -euo pipefail

REASON="RP00_CONTAINMENT_CLEANUP_DISABLED"
TARGET_BRANCH=""
BASE_BRANCH="main"
REMOTE="origin"
LANDED_REF=""
ROLLBACK_HANDLE=""
SELECTED_ROUTE=""
OUTPUT_PATH=""
DELETE_REMOTE=false
REMOVE_WORKTREES=true
SYNC_MAIN=true

usage() {
  cat <<'USAGE'
Usage:
  git-branch-authorize-cleanup.sh --branch <name> --landed-ref <sha-or-ref> \
    --retained-rollback-ref <ref-or-evidence> \
    --selected-route <branch-no-pr|branch-pr> --output <path> [options]

SI-00 containment: emits only a denied branch-cleanup-authorization-v1
receipt. It performs no fetch, provider lookup, checkout, worktree removal,
sync, prune, or ref mutation.
USAGE
}

error() {
  echo "[ERROR] $1" >&2
  exit 2
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --branch) shift; [[ $# -gt 0 ]] || error "--branch requires a value"; TARGET_BRANCH="$1" ;;
    --base) shift; [[ $# -gt 0 ]] || error "--base requires a value"; BASE_BRANCH="$1" ;;
    --remote) shift; [[ $# -gt 0 ]] || error "--remote requires a value"; REMOTE="$1" ;;
    --landed-ref) shift; [[ $# -gt 0 ]] || error "--landed-ref requires a value"; LANDED_REF="$1" ;;
    --retained-rollback-ref) shift; [[ $# -gt 0 ]] || error "--retained-rollback-ref requires a value"; ROLLBACK_HANDLE="$1" ;;
    --selected-route) shift; [[ $# -gt 0 ]] || error "--selected-route requires a value"; SELECTED_ROUTE="$1" ;;
    --output) shift; [[ $# -gt 0 ]] || error "--output requires a value"; OUTPUT_PATH="$1" ;;
    --delete-remote) DELETE_REMOTE=true ;;
    --no-remove-worktrees) REMOVE_WORKTREES=false ;;
    --no-sync-main) SYNC_MAIN=false ;;
    --target-lifecycle-outcome|--authorization-id) shift; [[ $# -gt 0 ]] || error "$1 requires a value" ;;
    --dry-run) ;;
    -h|--help) usage; exit 0 ;;
    *) error "unknown argument: $1" ;;
  esac
  shift
done

[[ -n "$TARGET_BRANCH" ]] || error "--branch is required"
[[ -n "$LANDED_REF" ]] || error "--landed-ref is required"
[[ -n "$ROLLBACK_HANDLE" ]] || error "--retained-rollback-ref is required"
[[ "$SELECTED_ROUTE" == "branch-no-pr" || "$SELECTED_ROUTE" == "branch-pr" ]] || error "--selected-route must be branch-no-pr or branch-pr"
[[ -n "$OUTPUT_PATH" ]] || error "--output is required"
command -v jq >/dev/null 2>&1 || error "jq is required"

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || true)"
LOCAL_SOURCE_REF=""
REMOTE_SOURCE_REF=""
OBSERVED_BASE_REF=""
if [[ -n "$REPO_ROOT" ]]; then
  LOCAL_SOURCE_REF="$(git -C "$REPO_ROOT" rev-parse --verify "refs/heads/${TARGET_BRANCH}^{commit}" 2>/dev/null || true)"
  REMOTE_SOURCE_REF="$(git -C "$REPO_ROOT" rev-parse --verify "refs/remotes/${REMOTE}/${TARGET_BRANCH}^{commit}" 2>/dev/null || true)"
  OBSERVED_BASE_REF="$(git -C "$REPO_ROOT" rev-parse --verify "refs/remotes/${REMOTE}/${BASE_BRANCH}^{commit}" 2>/dev/null || git -C "$REPO_ROOT" rev-parse --verify "refs/heads/${BASE_BRANCH}^{commit}" 2>/dev/null || true)"
fi

CREATED_AT="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
AUTHORIZATION_ID="rp00-cleanup-denied-${TARGET_BRANCH//[^A-Za-z0-9._-]/-}-${CREATED_AT//[:]/}"
CANDIDATE_ID="${TARGET_BRANCH}@${LANDED_REF}"
mkdir -p "$(dirname -- "$OUTPUT_PATH")"
TMP_PATH="${OUTPUT_PATH}.tmp.$$"
trap 'rm -f -- "$TMP_PATH"' EXIT

jq -n \
  --arg authorization_id "$AUTHORIZATION_ID" \
  --arg reason "$REASON" \
  --arg selected_route "$SELECTED_ROUTE" \
  --arg remote "$REMOTE" \
  --arg base_branch "$BASE_BRANCH" \
  --arg source_branch "$TARGET_BRANCH" \
  --arg candidate_id "$CANDIDATE_ID" \
  --arg requested_landed_ref "$LANDED_REF" \
  --arg local_source_ref "$LOCAL_SOURCE_REF" \
  --arg remote_source_ref "$REMOTE_SOURCE_REF" \
  --arg observed_base_ref "$OBSERVED_BASE_REF" \
  --arg rollback_handle "$ROLLBACK_HANDLE" \
  --argjson delete_remote_requested "$DELETE_REMOTE" \
  --argjson remove_worktrees_requested "$REMOVE_WORKTREES" \
  --argjson sync_main_requested "$SYNC_MAIN" \
  --arg created_at "$CREATED_AT" \
  '{
    schema_version: "branch-cleanup-authorization-v1",
    authorization_id: $authorization_id,
    authorization_result: "denied",
    denial_reason: $reason,
    containment_state: "SI-00",
    selected_route: $selected_route,
    requested_target_lifecycle_outcome: "cleaned",
    actual_lifecycle_outcome: "preserved",
    remote: $remote,
    base_branch: $base_branch,
    source_branch: $source_branch,
    candidate_id: $candidate_id,
    requested_landed_ref: $requested_landed_ref,
    observed_local_source_ref: (if $local_source_ref == "" then null else $local_source_ref end),
    observed_remote_source_ref: (if $remote_source_ref == "" then null else $remote_source_ref end),
    observed_base_ref: (if $observed_base_ref == "" then null else $observed_base_ref end),
    rollback_handle: $rollback_handle,
    rollback_handles: [$rollback_handle],
    delete_remote_requested: $delete_remote_requested,
    remove_worktrees_requested: $remove_worktrees_requested,
    sync_main_requested: $sync_main_requested,
    mutation_permitted: false,
    host_controls_not_bypassed: true,
    created_at: $created_at
  }' >"$TMP_PATH"
mv -- "$TMP_PATH" "$OUTPUT_PATH"
trap - EXIT

echo "[DENIED] ${REASON}: wrote containment-denied receipt to ${OUTPUT_PATH}; all refs and worktrees are preserved." >&2
exit 1
