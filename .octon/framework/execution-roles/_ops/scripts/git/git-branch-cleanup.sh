#!/usr/bin/env bash
set -euo pipefail

TARGET_BRANCH=""
BASE_BRANCH="main"
DELETE_REMOTE=0
REMOVE_WORKTREES=1
CONFIRM=0
DRY_RUN=0

usage() {
  cat <<'USAGE'
Usage:
  git-branch-cleanup.sh --branch <name> [--base <branch>] [--delete-remote] [--no-remove-worktrees] [--confirm] [--dry-run]

Branch/worktree cleanup helper without requiring PR metadata.
Route guard: call only after Change routing selects branch-no-pr or branch-pr and cleanup is selected.

Behavior:
  - refuses main
  - refuses dirty current worktree branch cleanup
  - removes clean linked worktrees for the branch when safe
  - deletes local branch with git branch -d
  - deletes remote branch only with --delete-remote --confirm
  - emits cleanup evidence without requiring PR metadata
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
    --delete-remote)
      DELETE_REMOTE=1
      ;;
    --no-remove-worktrees)
      REMOVE_WORKTREES=0
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
[[ "$TARGET_BRANCH" != "main" ]] || error "Refusing to clean up main."

REPO_ROOT="$(repo_root)"
[[ -n "$REPO_ROOT" ]] || error "Run this command from inside a git repository."

if [[ "$DRY_RUN" -eq 0 && "$CONFIRM" -ne 1 ]]; then
  error "Mutating branch cleanup requires --confirm."
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

if git -C "$REPO_ROOT" show-ref --verify --quiet "refs/heads/${TARGET_BRANCH}"; then
  run_cmd git -C "$REPO_ROOT" branch -d "$TARGET_BRANCH"
fi

if [[ "$DELETE_REMOTE" -eq 1 ]]; then
  run_cmd git -C "$REPO_ROOT" push origin --delete "$TARGET_BRANCH"
fi

echo "[OK] Route guard: branch-no-pr or branch-pr."
echo "[OK] Cleanup target: $TARGET_BRANCH"
echo "[OK] Remote deletion requested: $DELETE_REMOTE"
echo "[OK] Cleanup evidence: local branch/worktree handled or explicitly skipped by flags."
