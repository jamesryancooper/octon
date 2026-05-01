#!/usr/bin/env bash
set -euo pipefail

REMOTE="origin"
DRY_RUN=0

usage() {
  cat <<'USAGE'
Usage:
  git-branch-push.sh [--remote <name>] [--dry-run]

Branch push helper without opening a PR.
Route guard: call only after Change routing selects branch-no-pr or branch-pr.

Behavior:
  - refuses to push main
  - pushes the current branch and sets upstream when needed
  - emits remote branch evidence for Change receipts
  - does not create or update a PR
USAGE
}

error() {
  echo "[ERROR] $1" >&2
  exit 1
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

while [[ $# -gt 0 ]]; do
  case "$1" in
    --remote)
      shift
      [[ $# -gt 0 ]] || error "--remote requires a value"
      REMOTE="$1"
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

REPO_ROOT="$(repo_root)"
[[ -n "$REPO_ROOT" ]] || error "Run this command from inside a git repository."

CURRENT_BRANCH="$(git -C "$REPO_ROOT" rev-parse --abbrev-ref HEAD)"
[[ "$CURRENT_BRANCH" != "HEAD" ]] || error "Detached HEAD is not supported."
[[ "$CURRENT_BRANCH" != "main" ]] || error "Refusing branch push helper from main."
SOURCE_REF="$(git -C "$REPO_ROOT" rev-parse "$CURRENT_BRANCH")"

if git -C "$REPO_ROOT" rev-parse --abbrev-ref --symbolic-full-name "@{u}" >/dev/null 2>&1; then
  run_cmd git -C "$REPO_ROOT" push
else
  run_cmd git -C "$REPO_ROOT" push -u "$REMOTE" "$CURRENT_BRANCH"
fi

echo "[OK] Branch pushed without PR mutation. Route guard: branch-no-pr or branch-pr."
echo "[OK] Remote branch ref: ${REMOTE}/${CURRENT_BRANCH}"
echo "[OK] Source ref: $SOURCE_REF"
