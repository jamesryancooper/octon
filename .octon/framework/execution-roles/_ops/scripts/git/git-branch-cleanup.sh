#!/usr/bin/env bash
set -euo pipefail

TARGET_BRANCH=""
BASE_BRANCH="main"
REMOTE="origin"
LANDED_REF=""
RETAINED_ROLLBACK_REF=""
AUTHORIZATION_PATH=""
DELETE_REMOTE=0
REMOVE_WORKTREES=1
SYNC_MAIN=1
CONFIRM=0
DRY_RUN=0

usage() {
  cat <<'USAGE'
Usage:
  git-branch-cleanup.sh --branch <name> --landed-ref <sha-or-ref> --retained-rollback-ref <ref-or-evidence> --authorization <path> [--base <branch>] [--remote <name>] [--delete-remote] [--no-remove-worktrees] [--no-sync-main] [--confirm] [--dry-run]

Branch/worktree cleanup helper without requiring PR metadata in Change receipts.
Route guard: call only after Change routing selects branch-no-pr or branch-pr,
the source branch or PR branch is verified as landed in origin/main, and cleanup
is selected.

Behavior:
  - fetches origin before mutating cleanup
  - requires a validating branch-cleanup-authorization-v1 receipt before mutation
  - refuses protected branches
  - requires retained rollback/evidence posture before mutating cleanup
  - refuses dirty current worktree branch cleanup
  - refuses cleanup unless the landed ref and target branch tips are contained in origin/main
  - refuses cleanup when an open PR exists for the branch
  - removes clean linked worktrees for the branch when safe
  - deletes local branch with git branch -d
  - deletes remote branch only with --delete-remote --confirm
  - syncs local main to origin/main after cleanup unless --no-sync-main is set
  - emits cleanup evidence without requiring PR metadata in the Change receipt
USAGE
}

error() {
  echo "[ERROR] $1" >&2
  exit 1
}

warn() {
  echo "[WARN] $1"
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
  "$@"
}

branch_worktree_paths() {
  local branch="$1"
  git -C "$REPO_ROOT" worktree list --porcelain | awk -v ref="refs/heads/${branch}" '
    /^worktree / {
      path = substr($0, 10)
      next
    }
    /^branch / {
      if ($2 == ref) {
        print path
      }
    }
  '
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

remote_branch_exists() {
  git -C "$REPO_ROOT" show-ref --verify --quiet "refs/remotes/${REMOTE}/${TARGET_BRANCH}"
}

local_branch_exists() {
  git -C "$REPO_ROOT" show-ref --verify --quiet "refs/heads/${TARGET_BRANCH}"
}

verify_ref_exists() {
  local ref="$1"
  local label="$2"
  git -C "$REPO_ROOT" rev-parse --verify --quiet "${ref}^{commit}" >/dev/null ||
    error "$label does not resolve to a commit: $ref"
}

verify_ancestor_of_origin_main() {
  local ref="$1"
  local label="$2"
  if git -C "$REPO_ROOT" merge-base --is-ancestor "$ref" "$REMOTE/$BASE_BRANCH"; then
    echo "[OK] $label is contained in $REMOTE/$BASE_BRANCH."
  else
    error "$label is not contained in $REMOTE/$BASE_BRANCH; refusing cleanup."
  fi
}

json_value() {
  local path="$1"
  local expr="$2"
  jq -r "($expr) as \$value | if \$value == null then \"\" else \$value end" "$path"
}

validate_cleanup_authorization() {
  local authorization_path="$1"
  [[ -f "$authorization_path" ]] || error "Branch cleanup authorization receipt does not exist: $authorization_path"
  jq -e '.' "$authorization_path" >/dev/null 2>&1 || error "Branch cleanup authorization receipt must parse as JSON."

  local schema result route target_outcome auth_remote auth_base auth_source auth_landed auth_origin auth_local auth_rollback controls policy local_synced origin_contains local_contains source_contained protected open_pr_count delete_remote_requested remove_worktrees_requested sync_main_requested
  local expected_delete_remote expected_remove_worktrees expected_sync_main
  schema="$(json_value "$authorization_path" '.schema_version')"
  result="$(json_value "$authorization_path" '.authorization_result')"
  route="$(json_value "$authorization_path" '.selected_route')"
  target_outcome="$(json_value "$authorization_path" '.target_lifecycle_outcome')"
  auth_remote="$(json_value "$authorization_path" '.remote')"
  auth_base="$(json_value "$authorization_path" '.base_branch')"
  auth_source="$(json_value "$authorization_path" '.source_branch')"
  auth_landed="$(json_value "$authorization_path" '.landed_ref')"
  auth_origin="$(json_value "$authorization_path" '.origin_main_ref')"
  auth_local="$(json_value "$authorization_path" '.local_main_ref')"
  auth_rollback="$(json_value "$authorization_path" '.rollback_handle')"
  controls="$(json_value "$authorization_path" '.host_controls_not_bypassed')"
  policy="$(json_value "$authorization_path" '.cleanup_policy_allowed')"
  local_synced="$(json_value "$authorization_path" '.local_main_synced_to_origin_main')"
  origin_contains="$(json_value "$authorization_path" '.origin_main_contains_landed_ref')"
  local_contains="$(json_value "$authorization_path" '.local_main_contains_landed_ref')"
  source_contained="$(json_value "$authorization_path" '.source_branch_contained_in_origin_main')"
  protected="$(json_value "$authorization_path" '.source_branch_protected')"
  open_pr_count="$(json_value "$authorization_path" '.open_pr_count')"
  delete_remote_requested="$(json_value "$authorization_path" '.delete_remote_requested')"
  remove_worktrees_requested="$(json_value "$authorization_path" '.remove_worktrees_requested')"
  sync_main_requested="$(json_value "$authorization_path" '.sync_main_requested')"
  expected_delete_remote="$([[ "$DELETE_REMOTE" -eq 1 ]] && printf true || printf false)"
  expected_remove_worktrees="$([[ "$REMOVE_WORKTREES" -eq 1 ]] && printf true || printf false)"
  expected_sync_main="$([[ "$SYNC_MAIN" -eq 1 ]] && printf true || printf false)"

  [[ "$schema" == "branch-cleanup-authorization-v1" ]] || error "Branch cleanup authorization schema_version must be branch-cleanup-authorization-v1."
  [[ "$result" == "approved" ]] || error "Branch cleanup authorization result must be approved."
  [[ "$route" == "branch-no-pr" || "$route" == "branch-pr" ]] || error "Branch cleanup authorization route must be branch-no-pr or branch-pr."
  [[ "$target_outcome" == "cleaned" ]] || error "Branch cleanup authorization target lifecycle outcome must be cleaned."
  [[ "$auth_remote" == "$REMOTE" ]] || error "Branch cleanup authorization remote is stale or mismatched."
  [[ "$auth_base" == "$BASE_BRANCH" ]] || error "Branch cleanup authorization base branch is stale or mismatched."
  [[ "$auth_source" == "$TARGET_BRANCH" ]] || error "Branch cleanup authorization source branch is stale or mismatched."
  [[ "$auth_landed" == "$LANDED_SHA" ]] || error "Branch cleanup authorization landed ref is stale or mismatched."
  [[ "$auth_origin" == "$ORIGIN_MAIN_REF" ]] || error "Branch cleanup authorization origin/main ref is stale; re-run authorization."
  [[ "$auth_local" == "$LOCAL_MAIN_REF" ]] || error "Branch cleanup authorization local main ref is stale; re-run authorization."
  [[ "$auth_rollback" == "$RETAINED_ROLLBACK_REF" ]] || error "Branch cleanup authorization rollback handle is stale or mismatched."
  [[ "$controls" == "true" ]] || error "Branch cleanup authorization must preserve host/platform safety boundaries."
  [[ "$policy" == "true" ]] || error "Branch cleanup authorization must prove cleanup policy allowed."
  [[ "$local_synced" == "true" && "$origin_contains" == "true" && "$local_contains" == "true" && "$source_contained" == "true" ]] ||
    error "Branch cleanup authorization must prove main sync, landed-ref containment, and source branch containment."
  [[ "$protected" == "false" ]] || error "Branch cleanup authorization must prove the source branch is not protected."
  [[ "$open_pr_count" == "0" ]] || error "Branch cleanup authorization must prove no open PR exists."
  [[ "$delete_remote_requested" == "$expected_delete_remote" ]] ||
    error "Branch cleanup authorization remote-delete intent is stale or mismatched."
  [[ "$remove_worktrees_requested" == "$expected_remove_worktrees" ]] ||
    error "Branch cleanup authorization worktree-removal intent is stale or mismatched."
  [[ "$sync_main_requested" == "$expected_sync_main" ]] ||
    error "Branch cleanup authorization local-main-sync intent is stale or mismatched."

  if [[ "$LOCAL_EXISTS" -eq 1 ]]; then
    [[ "$(json_value "$authorization_path" '.local_branch_exists')" == "true" ]] ||
      error "Branch cleanup authorization did not account for local source branch."
    [[ "$(json_value "$authorization_path" '.local_source_ref')" == "$LOCAL_SOURCE_REF" ]] ||
      error "Branch cleanup authorization local source ref is stale; re-run authorization."
  fi
  if [[ "$REMOTE_EXISTS" -eq 1 ]]; then
    [[ "$(json_value "$authorization_path" '.remote_branch_exists')" == "true" ]] ||
      error "Branch cleanup authorization did not account for remote source branch."
    [[ "$(json_value "$authorization_path" '.remote_source_ref')" == "$REMOTE_SOURCE_REF" ]] ||
      error "Branch cleanup authorization remote source ref is stale; re-run authorization."
  fi

  echo "[OK] Branch cleanup authorization receipt validates."
}

open_pr_count() {
  if ! command -v gh >/dev/null 2>&1; then
    error "gh is required to prove no open PR exists before branch cleanup."
  fi
  gh pr list --head "$TARGET_BRANCH" --state open --json number --jq 'length'
}

sync_main_to_origin() {
  verify_ref_exists "$REMOTE/$BASE_BRANCH" "$REMOTE/$BASE_BRANCH"
  if [[ "$SYNC_MAIN" -ne 1 ]]; then
    warn "Local main sync skipped by --no-sync-main; receipt must record deferred sync disposition."
    return
  fi

  local current_branch
  current_branch="$(git -C "$REPO_ROOT" rev-parse --abbrev-ref HEAD)"
  if [[ "$current_branch" != "$BASE_BRANCH" ]]; then
    if ! git -C "$REPO_ROOT" diff --quiet || ! git -C "$REPO_ROOT" diff --cached --quiet; then
      error "Current worktree is dirty; cannot switch to $BASE_BRANCH for post-cleanup sync."
    fi
    run_cmd git -C "$REPO_ROOT" checkout "$BASE_BRANCH"
  fi

  run_cmd git -C "$REPO_ROOT" merge --ff-only "$REMOTE/$BASE_BRANCH"

  if [[ "$DRY_RUN" -eq 0 ]]; then
    local main_ref origin_ref
    main_ref="$(git -C "$REPO_ROOT" rev-parse "$BASE_BRANCH")"
    origin_ref="$(git -C "$REPO_ROOT" rev-parse "$REMOTE/$BASE_BRANCH")"
    [[ "$main_ref" == "$origin_ref" ]] ||
      error "Post-cleanup sync failed: $BASE_BRANCH ($main_ref) != $REMOTE/$BASE_BRANCH ($origin_ref)."
    if [[ -n "$LANDED_REF" ]]; then
      git -C "$REPO_ROOT" merge-base --is-ancestor "$LANDED_REF" "$BASE_BRANCH" ||
        error "Post-cleanup sync failed: landed ref is not contained in local $BASE_BRANCH."
    fi
    echo "[OK] Local $BASE_BRANCH is synced to $REMOTE/$BASE_BRANCH: $main_ref"
  else
    echo "[OK] Dry run would sync local $BASE_BRANCH to $REMOTE/$BASE_BRANCH."
  fi
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
    --authorization)
      shift
      [[ $# -gt 0 ]] || error "--authorization requires a value"
      AUTHORIZATION_PATH="$1"
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
    --confirm)
      CONFIRM=1
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

REPO_ROOT="$(repo_root)"
[[ -n "$REPO_ROOT" ]] || error "Run this command from inside a git repository."

if is_protected_branch "$TARGET_BRANCH"; then
  error "Refusing to clean up protected branch: $TARGET_BRANCH"
fi

if [[ "$DRY_RUN" -eq 0 && "$CONFIRM" -ne 1 ]]; then
  error "Mutating branch cleanup requires --confirm."
fi
if [[ "$DRY_RUN" -eq 0 && -z "$AUTHORIZATION_PATH" ]]; then
  error "Mutating branch cleanup requires --authorization <branch-cleanup-authorization-v1 receipt>."
fi

run_cmd git -C "$REPO_ROOT" fetch --prune "$REMOTE"

verify_ref_exists "$REMOTE/$BASE_BRANCH" "$REMOTE/$BASE_BRANCH"
verify_ref_exists "$BASE_BRANCH" "$BASE_BRANCH"
verify_ref_exists "$LANDED_REF" "landed ref"
LANDED_SHA="$(git -C "$REPO_ROOT" rev-parse "$LANDED_REF")"
ORIGIN_MAIN_REF="$(git -C "$REPO_ROOT" rev-parse "$REMOTE/$BASE_BRANCH")"
LOCAL_MAIN_REF="$(git -C "$REPO_ROOT" rev-parse "$BASE_BRANCH")"
[[ "$LOCAL_MAIN_REF" == "$ORIGIN_MAIN_REF" ]] ||
  error "Local $BASE_BRANCH is not synchronized to $REMOTE/$BASE_BRANCH; refusing cleanup."
verify_ancestor_of_origin_main "$LANDED_REF" "landed ref"

LOCAL_EXISTS=0
REMOTE_EXISTS=0
LOCAL_SOURCE_REF=""
REMOTE_SOURCE_REF=""
local_branch_exists && LOCAL_EXISTS=1
remote_branch_exists && REMOTE_EXISTS=1

if [[ "$LOCAL_EXISTS" -eq 0 && "$REMOTE_EXISTS" -eq 0 ]]; then
  warn "No local or remote branch found for cleanup target: $TARGET_BRANCH"
else
  if [[ "$LOCAL_EXISTS" -eq 1 ]]; then
    LOCAL_SOURCE_REF="$(git -C "$REPO_ROOT" rev-parse "refs/heads/${TARGET_BRANCH}")"
    verify_ancestor_of_origin_main "refs/heads/${TARGET_BRANCH}" "local branch ${TARGET_BRANCH}"
  fi
  if [[ "$REMOTE_EXISTS" -eq 1 ]]; then
    REMOTE_SOURCE_REF="$(git -C "$REPO_ROOT" rev-parse "refs/remotes/${REMOTE}/${TARGET_BRANCH}")"
    verify_ancestor_of_origin_main "refs/remotes/${REMOTE}/${TARGET_BRANCH}" "remote branch ${REMOTE}/${TARGET_BRANCH}"
  fi

  PR_COUNT="$(open_pr_count)"
  [[ "$PR_COUNT" == "0" ]] || error "Open PR exists for $TARGET_BRANCH; refusing cleanup."
  echo "[OK] No open PR exists for $TARGET_BRANCH."
fi

if [[ "$DRY_RUN" -eq 0 || -n "$AUTHORIZATION_PATH" ]]; then
  validate_cleanup_authorization "$AUTHORIZATION_PATH"
fi

CURRENT_BRANCH="$(git -C "$REPO_ROOT" rev-parse --abbrev-ref HEAD)"

if [[ "$CURRENT_BRANCH" == "$TARGET_BRANCH" ]]; then
  if ! git -C "$REPO_ROOT" diff --quiet || ! git -C "$REPO_ROOT" diff --cached --quiet; then
    error "Current worktree is dirty; cannot switch away for cleanup."
  fi
  run_cmd git -C "$REPO_ROOT" checkout "$BASE_BRANCH"
fi

if [[ "$REMOVE_WORKTREES" -eq 1 ]]; then
  while IFS= read -r path; do
    [[ -n "$path" ]] || continue
    if [[ "$path" == "$REPO_ROOT" ]]; then
      warn "Current repository root is attached to '$TARGET_BRANCH'; switch from another worktree to remove it."
      continue
    fi
    run_cmd git -C "$REPO_ROOT" worktree remove "$path"
  done < <(branch_worktree_paths "$TARGET_BRANCH")
fi

if [[ "$LOCAL_EXISTS" -eq 1 ]]; then
  run_cmd git -C "$REPO_ROOT" branch -d "$TARGET_BRANCH"
fi

if [[ "$DELETE_REMOTE" -eq 1 && "$REMOTE_EXISTS" -eq 1 ]]; then
  run_cmd git -C "$REPO_ROOT" push "$REMOTE" --delete "$TARGET_BRANCH"
fi

sync_main_to_origin

echo "[OK] Route guard: branch-no-pr or branch-pr."
echo "[OK] Cleanup target: $TARGET_BRANCH"
echo "[OK] Protected branch check: passed"
echo "[OK] $REMOTE/$BASE_BRANCH containment: verified for landed ref and branch refs present"
echo "[OK] origin/main containment: verified when remote/base is origin/main"
echo "[OK] Retained rollback/evidence posture: $RETAINED_ROLLBACK_REF"
echo "[OK] Branch cleanup authorization: ${AUTHORIZATION_PATH:-dry-run-only}"
echo "[OK] Remote deletion requested: $DELETE_REMOTE"
echo "[OK] Cleanup evidence: local/remote branch cleanup completed or safely skipped because branch was absent."
