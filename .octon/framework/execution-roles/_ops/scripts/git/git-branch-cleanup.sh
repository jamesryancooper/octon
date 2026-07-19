#!/usr/bin/env bash
set -euo pipefail

REASON="RP00_CONTAINMENT_CLEANUP_DISABLED"
TARGET_BRANCH=""
BASE_BRANCH="main"
REMOTE="origin"
DRY_RUN=0

usage() {
  cat <<'USAGE'
Usage: git-branch-cleanup.sh --branch <name> [historical options] [--dry-run]

SI-00 containment: mutating cleanup is disabled. --dry-run may inventory the
observed local, remote, and base refs only. No invocation fetches, checks out,
syncs, removes a worktree, prunes, or deletes a ref.
USAGE
}

error() { echo "[ERROR] $1" >&2; exit 2; }

while [[ $# -gt 0 ]]; do
  case "$1" in
    --branch) shift; [[ $# -gt 0 ]] || error "--branch requires a value"; TARGET_BRANCH="$1" ;;
    --base) shift; [[ $# -gt 0 ]] || error "--base requires a value"; BASE_BRANCH="$1" ;;
    --remote) shift; [[ $# -gt 0 ]] || error "--remote requires a value"; REMOTE="$1" ;;
    --landed-ref|--retained-rollback-ref|--authorization) shift; [[ $# -gt 0 ]] || error "$1 requires a value" ;;
    --delete-remote|--no-remove-worktrees|--no-sync-main|--confirm) ;;
    --dry-run) DRY_RUN=1 ;;
    -h|--help) usage; exit 0 ;;
    *) error "unknown argument: $1" ;;
  esac
  shift
done

[[ -n "$TARGET_BRANCH" ]] || error "--branch is required"

if [[ "$DRY_RUN" -ne 1 ]]; then
  echo "[DENIED] ${REASON}: branch cleanup is disabled during SI-00; all refs and worktrees are preserved." >&2
  exit 1
fi

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || true)"
[[ -n "$REPO_ROOT" ]] || error "run inside a Git repository"
LOCAL_SOURCE_REF="$(git -C "$REPO_ROOT" rev-parse --verify "refs/heads/${TARGET_BRANCH}^{commit}" 2>/dev/null || true)"
REMOTE_SOURCE_REF="$(git -C "$REPO_ROOT" rev-parse --verify "refs/remotes/${REMOTE}/${TARGET_BRANCH}^{commit}" 2>/dev/null || true)"
OBSERVED_BASE_REF="$(git -C "$REPO_ROOT" rev-parse --verify "refs/remotes/${REMOTE}/${BASE_BRANCH}^{commit}" 2>/dev/null || git -C "$REPO_ROOT" rev-parse --verify "refs/heads/${BASE_BRANCH}^{commit}" 2>/dev/null || true)"

printf 'containment_state=SI-00\n'
printf 'denial_reason=%s\n' "$REASON"
printf 'source_branch=%s\n' "$TARGET_BRANCH"
printf 'observed_local_source_ref=%s\n' "${LOCAL_SOURCE_REF:-absent}"
printf 'observed_remote_source_ref=%s\n' "${REMOTE_SOURCE_REF:-absent}"
printf 'observed_base_ref=%s\n' "${OBSERVED_BASE_REF:-absent}"
printf 'mutation_permitted=false\n'
printf 'candidate_preserved=true\n'
