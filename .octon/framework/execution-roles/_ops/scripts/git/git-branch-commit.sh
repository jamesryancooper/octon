#!/usr/bin/env bash
set -euo pipefail

MESSAGE=""
STAGE_ALL=0
DRY_RUN=0
declare -a INCLUDE_PATHS=()

usage() {
  cat <<'USAGE'
Usage:
  git-branch-commit.sh --message "<type(scope): summary>" [--include <path>]... [--stage-all] [--dry-run]

Branch-local commit helper.
Route guard: call only after Change routing selects branch-no-pr or branch-pr.

Behavior:
  - refuses to commit from main
  - stages only --include paths unless --stage-all is used
  - commits staged intended files with the supplied message
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

run_git_mutation_preflight() {
  [[ "$DRY_RUN" -eq 1 ]] && return 0
  "$REPO_ROOT/.octon/framework/execution-roles/_ops/scripts/git/git-branch-mutation-preflight.sh" \
    --repo "$REPO_ROOT" \
    --check-index ||
    error "Git mutation preflight failed before branch-local commit."
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --message)
      shift
      [[ $# -gt 0 ]] || error "--message requires a value"
      MESSAGE="$1"
      ;;
    --include)
      shift
      [[ $# -gt 0 ]] || error "--include requires a value"
      INCLUDE_PATHS+=("$1")
      ;;
    --stage-all)
      STAGE_ALL=1
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

[[ -n "$MESSAGE" ]] || error "--message is required."

REPO_ROOT="$(repo_root)"
[[ -n "$REPO_ROOT" ]] || error "Run this command from inside a git repository."

CURRENT_BRANCH="$(git -C "$REPO_ROOT" rev-parse --abbrev-ref HEAD)"
[[ "$CURRENT_BRANCH" != "HEAD" ]] || error "Detached HEAD is not supported."
[[ "$CURRENT_BRANCH" != "main" ]] || error "Refusing branch-local commit from main."
run_git_mutation_preflight

if [[ "$STAGE_ALL" -eq 1 && "${#INCLUDE_PATHS[@]}" -gt 0 ]]; then
  error "Use either --stage-all or --include, not both."
fi

if [[ "$STAGE_ALL" -eq 1 ]]; then
  run_cmd git -C "$REPO_ROOT" add -A
elif [[ "${#INCLUDE_PATHS[@]}" -gt 0 ]]; then
  run_cmd git -C "$REPO_ROOT" add -- "${INCLUDE_PATHS[@]}"
fi

if git -C "$REPO_ROOT" diff --cached --quiet; then
  error "No staged changes to commit. Use --include or --stage-all, or stage intended files first."
fi

run_cmd git -C "$REPO_ROOT" commit -m "$MESSAGE"
echo "[OK] Branch-local commit route guard satisfied: branch-no-pr or branch-pr."
