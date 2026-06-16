#!/usr/bin/env bash
set -euo pipefail

TARGET_BRANCH=""
BASE_BRANCH="main"
REMOTE="origin"
LANDED_REF=""
RETAINED_ROLLBACK_REF=""
SELECTED_ROUTE=""
TARGET_LIFECYCLE_OUTCOME="cleaned"
OUTPUT_PATH=""
DELETE_REMOTE=0
REMOVE_WORKTREES=1
SYNC_MAIN=1
DRY_RUN=0

usage() {
  cat <<'USAGE'
Usage:
  git-branch-authorize-cleanup.sh --branch <name> --landed-ref <sha-or-ref> --retained-rollback-ref <ref-or-evidence> --selected-route <branch-no-pr|branch-pr> --output <path> [--base <branch>] [--remote <name>] [--delete-remote] [--no-remove-worktrees] [--no-sync-main] [--dry-run]

Governed branch cleanup authorization helper.
Route guard: call only from singular closeout-change after a branch route has
landed and before deleting local or remote source branch refs.

Behavior:
  - fetches the remote before evaluating cleanup authorization
  - refuses protected branch cleanup
  - requires local base branch to be synchronized with the remote base branch
  - requires the landed ref to be contained in both local base and remote base
  - requires all present source branch refs to be contained in the remote base
  - requires proof that no open PR exists for the source branch
  - requires retained rollback or discard posture
  - emits branch-cleanup-authorization-v1 JSON and performs no cleanup mutation
USAGE
}

error() {
  echo "[ERROR] $1" >&2
  case "$1" in
    *fetch*|*remote*|*push*|*ref*|*branch*|*sandbox*|*host*|*platform*|*provider*|*permission*|*denied*|*gh*|*PR*)
      sandbox_guidance
      ;;
  esac
  exit 1
}

sandbox_guidance() {
  echo "[INFO] Governed rerun path: rerun this same helper in an environment authorized for the required git fetch, remote-check, push, ref-write, or provider PR lookup operation. Do not bypass platform, sandbox, provider, or host controls." >&2
}

repo_root() {
  git rev-parse --show-toplevel 2>/dev/null || true
}

run_cmd() {
  if [[ "$DRY_RUN" -eq 1 ]]; then
    printf '[DRY] '
    printf '%q ' "$@"
    printf '\n'
    return 0
  fi
  if ! "$@"; then
    echo "[ERROR] command failed: $*" >&2
    sandbox_guidance
    exit 1
  fi
}

is_protected_branch() {
  case "$1" in
    main|master|production|prod|develop|release/*|protected/*)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

local_branch_exists() {
  git -C "$REPO_ROOT" show-ref --verify --quiet "refs/heads/${TARGET_BRANCH}"
}

remote_branch_exists() {
  git -C "$REPO_ROOT" show-ref --verify --quiet "refs/remotes/${REMOTE}/${TARGET_BRANCH}"
}

verify_ref_exists() {
  local ref="$1"
  local label="$2"
  git -C "$REPO_ROOT" rev-parse --verify --quiet "${ref}^{commit}" >/dev/null ||
    error "$label does not resolve to a commit: $ref"
}

ref_sha() {
  git -C "$REPO_ROOT" rev-parse "$1"
}

verify_ancestor() {
  local ancestor="$1"
  local descendant="$2"
  local label="$3"
  if git -C "$REPO_ROOT" merge-base --is-ancestor "$ancestor" "$descendant"; then
    echo "[OK] $label"
  else
    error "$label failed."
  fi
}

open_pr_count() {
  local count
  if ! command -v gh >/dev/null 2>&1; then
    error "gh is required to prove no open PR exists before branch cleanup authorization."
  fi
  if ! count="$(gh pr list --head "$TARGET_BRANCH" --state open --json number --jq 'length')"; then
    error "gh PR lookup failed for $TARGET_BRANCH before branch cleanup authorization."
  fi
  printf '%s\n' "$count"
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --branch)
      shift
      [[ $# -gt 0 ]] || error "--branch requires a value"
      TARGET_BRANCH="$1"
      ;;
    --base)
      shift
      [[ $# -gt 0 ]] || error "--base requires a value"
      BASE_BRANCH="$1"
      ;;
    --remote)
      shift
      [[ $# -gt 0 ]] || error "--remote requires a value"
      REMOTE="$1"
      ;;
    --landed-ref)
      shift
      [[ $# -gt 0 ]] || error "--landed-ref requires a value"
      LANDED_REF="$1"
      ;;
    --retained-rollback-ref)
      shift
      [[ $# -gt 0 ]] || error "--retained-rollback-ref requires a value"
      RETAINED_ROLLBACK_REF="$1"
      ;;
    --selected-route)
      shift
      [[ $# -gt 0 ]] || error "--selected-route requires a value"
      SELECTED_ROUTE="$1"
      ;;
    --target-lifecycle-outcome)
      shift
      [[ $# -gt 0 ]] || error "--target-lifecycle-outcome requires a value"
      TARGET_LIFECYCLE_OUTCOME="$1"
      ;;
    --output)
      shift
      [[ $# -gt 0 ]] || error "--output requires a value"
      OUTPUT_PATH="$1"
      ;;
    --delete-remote)
      DELETE_REMOTE=1
      ;;
    --no-remove-worktrees)
      REMOVE_WORKTREES=0
      ;;
    --no-sync-main)
      SYNC_MAIN=0
      ;;
    --dry-run)
      DRY_RUN=1
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      error "Unknown argument: $1"
      ;;
  esac
  shift
done

[[ -n "$TARGET_BRANCH" ]] || error "--branch is required."
[[ -n "$LANDED_REF" ]] || error "--landed-ref is required."
[[ -n "$RETAINED_ROLLBACK_REF" ]] || error "--retained-rollback-ref is required."
[[ -n "$SELECTED_ROUTE" ]] || error "--selected-route is required."
[[ -n "$OUTPUT_PATH" ]] || error "--output is required."

case "$SELECTED_ROUTE" in
  branch-no-pr|branch-pr) ;;
  *) error "--selected-route must be branch-no-pr or branch-pr." ;;
esac
[[ "$TARGET_LIFECYCLE_OUTCOME" == "cleaned" ]] || error "Branch cleanup authorization is only valid for target_lifecycle_outcome cleaned."

REPO_ROOT="$(repo_root)"
[[ -n "$REPO_ROOT" ]] || error "Run this command from inside a git repository."

if is_protected_branch "$TARGET_BRANCH"; then
  error "Refusing to authorize cleanup for protected branch: $TARGET_BRANCH"
fi

run_cmd git -C "$REPO_ROOT" fetch --prune "$REMOTE"

verify_ref_exists "$REMOTE/$BASE_BRANCH" "$REMOTE/$BASE_BRANCH"
verify_ref_exists "$BASE_BRANCH" "$BASE_BRANCH"
verify_ref_exists "$LANDED_REF" "landed ref"

LANDED_SHA="$(ref_sha "$LANDED_REF")"
ORIGIN_MAIN_REF="$(ref_sha "$REMOTE/$BASE_BRANCH")"
LOCAL_MAIN_REF="$(ref_sha "$BASE_BRANCH")"

[[ "$LOCAL_MAIN_REF" == "$ORIGIN_MAIN_REF" ]] ||
  error "Local $BASE_BRANCH is not synchronized to $REMOTE/$BASE_BRANCH; refusing cleanup authorization."

verify_ancestor "$LANDED_SHA" "$REMOTE/$BASE_BRANCH" "$REMOTE/$BASE_BRANCH contains landed ref"
verify_ancestor "$LANDED_SHA" "$BASE_BRANCH" "$BASE_BRANCH contains landed ref"

LOCAL_EXISTS=false
REMOTE_EXISTS=false
LOCAL_SOURCE_REF=""
REMOTE_SOURCE_REF=""
SOURCE_CONTAINED=true

if local_branch_exists; then
  LOCAL_EXISTS=true
  LOCAL_SOURCE_REF="$(ref_sha "refs/heads/${TARGET_BRANCH}")"
  verify_ancestor "$LOCAL_SOURCE_REF" "$REMOTE/$BASE_BRANCH" "local source branch is contained in $REMOTE/$BASE_BRANCH"
fi

if remote_branch_exists; then
  REMOTE_EXISTS=true
  REMOTE_SOURCE_REF="$(ref_sha "refs/remotes/${REMOTE}/${TARGET_BRANCH}")"
  verify_ancestor "$REMOTE_SOURCE_REF" "$REMOTE/$BASE_BRANCH" "remote source branch is contained in $REMOTE/$BASE_BRANCH"
fi

PR_COUNT="$(open_pr_count)"
[[ "$PR_COUNT" == "0" ]] || error "Open PR exists for $TARGET_BRANCH; refusing cleanup authorization."

CREATED_AT="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
AUTHORIZATION_ID="branch-cleanup-${TARGET_BRANCH//\//-}-${CREATED_AT//[:]/}"
DELETE_REMOTE_JSON="$([[ "$DELETE_REMOTE" -eq 1 ]] && printf true || printf false)"
REMOVE_WORKTREES_JSON="$([[ "$REMOVE_WORKTREES" -eq 1 ]] && printf true || printf false)"
SYNC_MAIN_JSON="$([[ "$SYNC_MAIN" -eq 1 ]] && printf true || printf false)"

mkdir -p "$(dirname "$OUTPUT_PATH")"
jq -n \
  --arg schema_version "branch-cleanup-authorization-v1" \
  --arg authorization_id "$AUTHORIZATION_ID" \
  --arg authorization_result "approved" \
  --arg selected_route "$SELECTED_ROUTE" \
  --arg target_lifecycle_outcome "$TARGET_LIFECYCLE_OUTCOME" \
  --arg remote "$REMOTE" \
  --arg base_branch "$BASE_BRANCH" \
  --arg source_branch "$TARGET_BRANCH" \
  --arg landed_ref "$LANDED_SHA" \
  --arg origin_main_ref "$ORIGIN_MAIN_REF" \
  --arg local_main_ref "$LOCAL_MAIN_REF" \
  --arg local_source_ref "$LOCAL_SOURCE_REF" \
  --arg remote_source_ref "$REMOTE_SOURCE_REF" \
  --arg rollback_handle "$RETAINED_ROLLBACK_REF" \
  --arg runtime_safety_boundary "Octon cleanup authorization is required before branch deletion, but it does not bypass platform, sandbox, provider, or host safety controls." \
  --arg created_at "$CREATED_AT" \
  --argjson local_branch_exists "$LOCAL_EXISTS" \
  --argjson remote_branch_exists "$REMOTE_EXISTS" \
  --argjson open_pr_count "$PR_COUNT" \
  --argjson delete_remote_requested "$DELETE_REMOTE_JSON" \
  --argjson remove_worktrees_requested "$REMOVE_WORKTREES_JSON" \
  --argjson sync_main_requested "$SYNC_MAIN_JSON" \
  '{
    schema_version: $schema_version,
    authorization_id: $authorization_id,
    authorization_result: $authorization_result,
    selected_route: $selected_route,
    target_lifecycle_outcome: $target_lifecycle_outcome,
    remote: $remote,
    base_branch: $base_branch,
    source_branch: $source_branch,
    landed_ref: $landed_ref,
    origin_main_ref: $origin_main_ref,
    local_main_ref: $local_main_ref,
    local_branch_exists: $local_branch_exists,
    remote_branch_exists: $remote_branch_exists,
    local_main_synced_to_origin_main: true,
    origin_main_contains_landed_ref: true,
    local_main_contains_landed_ref: true,
    source_branch_contained_in_origin_main: true,
    source_branch_protected: false,
    open_pr_count: $open_pr_count,
    rollback_handle: $rollback_handle,
    cleanup_policy_allowed: true,
    delete_remote_requested: $delete_remote_requested,
    remove_worktrees_requested: $remove_worktrees_requested,
    sync_main_requested: $sync_main_requested,
    host_controls_not_bypassed: true,
    runtime_safety_boundary: $runtime_safety_boundary,
    created_at: $created_at
  }
  | if $local_source_ref != "" then .local_source_ref = $local_source_ref else . end
  | if $remote_source_ref != "" then .remote_source_ref = $remote_source_ref else . end' >"$OUTPUT_PATH"

echo "[OK] Branch cleanup authorization receipt written: $OUTPUT_PATH"
echo "[OK] Source branch: $TARGET_BRANCH"
echo "[OK] Landed ref: $LANDED_SHA"
echo "[OK] Local $BASE_BRANCH and $REMOTE/$BASE_BRANCH synchronized: $LOCAL_MAIN_REF"
echo "[OK] No open PR exists for $TARGET_BRANCH."
echo "[OK] Cleanup authorization preserves platform, sandbox, provider, and host safety controls."
