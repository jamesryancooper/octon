#!/usr/bin/env bash
set -euo pipefail

TARGET_BRANCH="main"
METHOD="fast-forward"
CONFIRM=0
DRY_RUN=0

usage() {
  cat <<'USAGE'
Usage:
  git-branch-land.sh [--target <branch>] [--method fast-forward|merge-commit|squash|cherry-pick] [--confirm] [--dry-run]

Local no-PR branch landing helper.
Route guard: call only after Change routing selects branch-no-pr and PR-required predicates are false.

Behavior:
  - refuses dirty worktrees
  - refuses to run from main
  - records pre/post refs in output
  - requires --confirm for mutating runs
  - does not create or update a PR
  - does not update hosted main; use git-branch-land-hosted-no-pr.sh for hosted fast-forward no-PR landing
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
    --target)
      shift
      [[ $# -gt 0 ]] || error "--target requires a value"
      TARGET_BRANCH="$1"
      ;;
    --method)
      shift
      [[ $# -gt 0 ]] || error "--method requires a value"
      METHOD="$1"
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

case "$METHOD" in
  fast-forward|merge-commit|squash|cherry-pick) ;;
  *) error "Unsupported --method '$METHOD'." ;;
esac

REPO_ROOT="$(repo_root)"
[[ -n "$REPO_ROOT" ]] || error "Run this command from inside a git repository."

SOURCE_BRANCH="$(git -C "$REPO_ROOT" rev-parse --abbrev-ref HEAD)"
[[ "$SOURCE_BRANCH" != "HEAD" ]] || error "Detached HEAD is not supported."
[[ "$SOURCE_BRANCH" != "$TARGET_BRANCH" ]] || error "Source branch already equals target branch."
[[ "$SOURCE_BRANCH" != "main" ]] || error "Refusing no-PR branch landing from main."

if ! git -C "$REPO_ROOT" diff --quiet || ! git -C "$REPO_ROOT" diff --cached --quiet; then
  error "Working tree is not clean; commit or preserve branch state before landing."
fi

SOURCE_REF="$(git -C "$REPO_ROOT" rev-parse "$SOURCE_BRANCH")"
TARGET_PRE_REF="$(git -C "$REPO_ROOT" rev-parse "$TARGET_BRANCH")"

if [[ "$DRY_RUN" -eq 0 && "$CONFIRM" -ne 1 ]]; then
  error "Mutating branch landing requires --confirm."
fi

run_cmd git -C "$REPO_ROOT" checkout "$TARGET_BRANCH"

case "$METHOD" in
  fast-forward)
    run_cmd git -C "$REPO_ROOT" merge --ff-only "$SOURCE_BRANCH"
    ;;
  merge-commit)
    run_cmd git -C "$REPO_ROOT" merge --no-ff "$SOURCE_BRANCH"
    ;;
  squash)
    run_cmd git -C "$REPO_ROOT" merge --squash "$SOURCE_BRANCH"
    run_cmd git -C "$REPO_ROOT" commit -m "merge(${SOURCE_BRANCH}): land branch without PR"
    ;;
  cherry-pick)
    CHERRY_PICK_COMMITS="$(git -C "$REPO_ROOT" rev-list --reverse "$TARGET_PRE_REF..$SOURCE_REF")"
    [[ -n "$CHERRY_PICK_COMMITS" ]] || error "No source commits to cherry-pick from $SOURCE_BRANCH onto $TARGET_BRANCH."
    while IFS= read -r commit; do
      [[ -n "$commit" ]] || continue
      run_cmd git -C "$REPO_ROOT" cherry-pick "$commit"
    done <<<"$CHERRY_PICK_COMMITS"
    ;;
esac

if [[ "$DRY_RUN" -eq 1 ]]; then
  TARGET_POST_REF="<dry-run>"
else
  TARGET_POST_REF="$(git -C "$REPO_ROOT" rev-parse "$TARGET_BRANCH")"
fi

echo "[OK] Route guard: branch-no-pr."
echo "[OK] Source branch: $SOURCE_BRANCH"
echo "[OK] Source ref: $SOURCE_REF"
echo "[OK] Target branch: $TARGET_BRANCH"
echo "[OK] Target pre-ref: $TARGET_PRE_REF"
echo "[OK] Target post-ref: $TARGET_POST_REF"
echo "[OK] Integration method: $METHOD"
echo "[OK] Hosted main updated: false"
