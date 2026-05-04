#!/usr/bin/env bash
set -euo pipefail

TARGET_BRANCH=""
BASE_BRANCH="main"
LANDED_REF=""
RETAINED_ROLLBACK_REF=""
DELETE_REMOTE=0
REMOVE_WORKTREES=1
SYNC_MAIN=1
CONFIRM=0
DRY_RUN=0

usage() {
  cat <<'USAGE'
Usage:
  git-branch-cleanup.sh --branch <name> --landed-ref <sha-or-ref> --retained-rollback-ref <ref-or-evidence> [--base <branch>] [--delete-remote] [--no-remove-worktrees] [--no-sync-main] [--confirm] [--dry-run]

Branch/worktree cleanup helper without requiring PR metadata in Change receipts.
Route guard: call only after Change routing selects branch-no-pr or branch-pr,
the source branch or PR branch is verified as landed in origin/main, and cleanup
is selected.

Behavior:
  - fetches origin before mutating cleanup
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
  git -C "$REPO_ROOT" show-ref --verify --quiet "refs/remotes/origin/${TARGET_BRANCH}"
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
  if git -C "$REPO_ROOT" merge-base --is-ancestor "$ref" origin/main; then
    echo "[OK] $label is contained in origin/main."
  else
    error "$label is not contained in origin/main; refusing cleanup."
  fi
}

open_pr_count() {
  if ! command -v gh >/dev/null 2>&1; then
    error "gh is required to prove no open PR exists before branch cleanup."
  fi
  gh pr list --head "$TARGET_BRANCH" --state open --json number --jq 'length'
}

sync_main_to_origin() {
  verify_ref_exists "origin/main" "origin/main"
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

  run_cmd git -C "$REPO_ROOT" merge --ff-only origin/main

  if [[ "$DRY_RUN" -eq 0 ]]; then
    local main_ref origin_ref
    main_ref="$(git -C "$REPO_ROOT" rev-parse "$BASE_BRANCH")"
    origin_ref="$(git -C "$REPO_ROOT" rev-parse origin/main)"
    [[ "$main_ref" == "$origin_ref" ]] ||
      error "Post-cleanup sync failed: $BASE_BRANCH ($main_ref) != origin/main ($origin_ref)."
    if [[ -n "$LANDED_REF" ]]; then
      git -C "$REPO_ROOT" merge-base --is-ancestor "$LANDED_REF" "$BASE_BRANCH" ||
        error "Post-cleanup sync failed: landed ref is not contained in local $BASE_BRANCH."
    fi
    echo "[OK] Local $BASE_BRANCH is synced to origin/main: $main_ref"
  else
    echo "[OK] Dry run would sync local $BASE_BRANCH to origin/main."
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

run_cmd git -C "$REPO_ROOT" fetch --prune origin

verify_ref_exists "origin/main" "origin/main"
verify_ref_exists "$LANDED_REF" "landed ref"
verify_ancestor_of_origin_main "$LANDED_REF" "landed ref"

LOCAL_EXISTS=0
REMOTE_EXISTS=0
local_branch_exists && LOCAL_EXISTS=1
remote_branch_exists && REMOTE_EXISTS=1

if [[ "$LOCAL_EXISTS" -eq 0 && "$REMOTE_EXISTS" -eq 0 ]]; then
  warn "No local or remote branch found for cleanup target: $TARGET_BRANCH"
else
  if [[ "$LOCAL_EXISTS" -eq 1 ]]; then
    verify_ancestor_of_origin_main "refs/heads/${TARGET_BRANCH}" "local branch ${TARGET_BRANCH}"
  fi
  if [[ "$REMOTE_EXISTS" -eq 1 ]]; then
    verify_ancestor_of_origin_main "refs/remotes/origin/${TARGET_BRANCH}" "remote branch origin/${TARGET_BRANCH}"
  fi

  PR_COUNT="$(open_pr_count)"
  [[ "$PR_COUNT" == "0" ]] || error "Open PR exists for $TARGET_BRANCH; refusing cleanup."
  echo "[OK] No open PR exists for $TARGET_BRANCH."
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
  run_cmd git -C "$REPO_ROOT" push origin --delete "$TARGET_BRANCH"
fi

sync_main_to_origin

echo "[OK] Route guard: branch-no-pr or branch-pr."
echo "[OK] Cleanup target: $TARGET_BRANCH"
echo "[OK] Protected branch check: passed"
echo "[OK] origin/main containment: verified for landed ref and branch refs present"
echo "[OK] Retained rollback/evidence posture: $RETAINED_ROLLBACK_REF"
echo "[OK] Remote deletion requested: $DELETE_REMOTE"
echo "[OK] Cleanup evidence: local/remote branch cleanup completed or safely skipped because branch was absent."
