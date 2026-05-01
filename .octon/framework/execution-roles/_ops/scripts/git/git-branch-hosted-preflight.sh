#!/usr/bin/env bash
set -euo pipefail

TARGET_BRANCH="main"
REMOTE="origin"
RECEIPT_PATH=""
RULESET_JSON=""
DRY_RUN=0
ALLOW_EMPTY_CHECK_SET=0
declare -a REQUIRED_CHECKS=()

usage() {
  cat <<'USAGE'
Usage:
  git-branch-hosted-preflight.sh [--target <branch>] [--remote <name>] [--receipt <path>] [--ruleset-json <path>] [--require-check <name>]... [--allow-empty-check-set] [--dry-run]

Hosted no-PR landing preflight helper.
Route guard: call only after Change routing selects branch-no-pr.

Behavior:
  - refuses main/detached source branches
  - refuses dirty worktrees
  - verifies provider rules do not require a pull request for hosted landing
  - verifies the source branch is pushed to the remote when not in dry-run mode
  - verifies the source ref is current with the remote target branch
  - verifies exact source SHA required checks
  - does not create, update, or merge a PR
USAGE
}

error() {
  echo "[ERROR] $1" >&2
  exit 1
}

repo_root() {
  git rev-parse --show-toplevel 2>/dev/null || true
}

github_repo() {
  local url path
  url="$(git -C "$REPO_ROOT" remote get-url "$REMOTE" 2>/dev/null || true)"
  case "$url" in
    git@github.com:*)
      path="${url#git@github.com:}"
      ;;
    https://github.com/*)
      path="${url#https://github.com/}"
      ;;
    http://github.com/*)
      path="${url#http://github.com/}"
      ;;
    *)
      return 1
      ;;
  esac
  path="${path%.git}"
  [[ "$path" == */* ]] || return 1
  printf '%s\n' "$path"
}

ruleset_requires_pr_file() {
  local file="$1"
  jq -e '.. | objects | select(.type? == "pull_request")' "$file" >/dev/null 2>&1
}

ruleset_requires_pr_live() {
  local repo="$1"
  gh api "repos/${repo}/rules/branches/${TARGET_BRANCH}" \
    --jq '.[]? | select(.type == "pull_request") | .type' 2>/dev/null | grep -Fxq "pull_request"
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --target)
      shift
      [[ $# -gt 0 ]] || error "--target requires a value"
      TARGET_BRANCH="$1"
      ;;
    --remote)
      shift
      [[ $# -gt 0 ]] || error "--remote requires a value"
      REMOTE="$1"
      ;;
    --receipt)
      shift
      [[ $# -gt 0 ]] || error "--receipt requires a value"
      RECEIPT_PATH="$1"
      ;;
    --ruleset-json)
      shift
      [[ $# -gt 0 ]] || error "--ruleset-json requires a value"
      RULESET_JSON="$1"
      ;;
    --require-check)
      shift
      [[ $# -gt 0 ]] || error "--require-check requires a value"
      REQUIRED_CHECKS+=("$1")
      ;;
    --allow-empty-check-set)
      ALLOW_EMPTY_CHECK_SET=1
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

SOURCE_BRANCH="$(git -C "$REPO_ROOT" rev-parse --abbrev-ref HEAD)"
[[ "$SOURCE_BRANCH" != "HEAD" ]] || error "Detached HEAD is not supported."
[[ "$SOURCE_BRANCH" != "$TARGET_BRANCH" ]] || error "Source branch already equals target branch."
[[ "$SOURCE_BRANCH" != "main" ]] || error "Refusing hosted no-PR landing preflight from main."

if ! git -C "$REPO_ROOT" diff --quiet || ! git -C "$REPO_ROOT" diff --cached --quiet; then
  error "Working tree is not clean; commit or preserve branch state before hosted landing."
fi

if [[ -n "$RECEIPT_PATH" ]]; then
  [[ -f "$RECEIPT_PATH" ]] || error "Receipt does not exist: $RECEIPT_PATH"
  jq -e '.selected_route == "branch-no-pr" and ((.durable_history.kind? // "") != "pr") and ((.durable_history.pr_url? // "") == "")' "$RECEIPT_PATH" >/dev/null \
    || error "Receipt must be branch-no-pr and must not contain PR durable history."
fi

if [[ -n "$RULESET_JSON" ]]; then
  [[ -f "$RULESET_JSON" ]] || error "Ruleset JSON does not exist: $RULESET_JSON"
  if ruleset_requires_pr_file "$RULESET_JSON"; then
    error "Provider ruleset requires PR; hosted branch-no-pr landing unavailable."
  fi
  echo "[OK] Provider ruleset evidence allows route-neutral hosted no-PR landing."
elif [[ "$DRY_RUN" -eq 1 ]]; then
  echo "[OK] Dry run did not query provider ruleset; provide --ruleset-json for strict fixture validation."
else
  command -v gh >/dev/null 2>&1 || error "gh is required to inspect provider ruleset without --ruleset-json."
  REPO="$(github_repo)" || error "Unable to resolve GitHub owner/repo from remote '$REMOTE'."
  if ruleset_requires_pr_live "$REPO"; then
    error "Provider ruleset requires PR; hosted branch-no-pr landing unavailable."
  fi
  echo "[OK] Live provider ruleset allows route-neutral hosted no-PR landing."
fi

SOURCE_REF="$(git -C "$REPO_ROOT" rev-parse "$SOURCE_BRANCH")"

if [[ "$DRY_RUN" -eq 0 ]]; then
  git -C "$REPO_ROOT" fetch --quiet "$REMOTE" "$TARGET_BRANCH" "$SOURCE_BRANCH"
  REMOTE_SOURCE_REF="$(git -C "$REPO_ROOT" rev-parse "$REMOTE/$SOURCE_BRANCH")"
  [[ "$REMOTE_SOURCE_REF" == "$SOURCE_REF" ]] || error "Source branch must be pushed to $REMOTE before hosted no-PR landing."
else
  echo "[OK] Dry run did not require remote source branch fetch."
fi

if git -C "$REPO_ROOT" rev-parse --verify "$REMOTE/$TARGET_BRANCH^{commit}" >/dev/null 2>&1; then
  TARGET_REMOTE_REF="$(git -C "$REPO_ROOT" rev-parse "$REMOTE/$TARGET_BRANCH")"
else
  [[ "$DRY_RUN" -eq 1 ]] || error "Unable to resolve $REMOTE/$TARGET_BRANCH."
  TARGET_REMOTE_REF="$(git -C "$REPO_ROOT" rev-parse "$TARGET_BRANCH")"
fi

if git -C "$REPO_ROOT" merge-base --is-ancestor "$TARGET_REMOTE_REF" "$SOURCE_REF"; then
  echo "[OK] Source ref is current with $REMOTE/$TARGET_BRANCH."
else
  error "Source branch is stale; $REMOTE/$TARGET_BRANCH is not an ancestor of $SOURCE_REF."
fi

CHECK_ARGS=("--ref" "$SOURCE_REF" "--remote" "$REMOTE")
for context in "${REQUIRED_CHECKS[@]}"; do
  CHECK_ARGS+=("--require-check" "$context")
done
[[ "$ALLOW_EMPTY_CHECK_SET" -eq 1 ]] && CHECK_ARGS+=("--allow-empty-check-set")
[[ "$DRY_RUN" -eq 1 ]] && CHECK_ARGS+=("--dry-run")

"$REPO_ROOT/.octon/framework/execution-roles/_ops/scripts/git/git-required-checks-at-ref.sh" "${CHECK_ARGS[@]}"

echo "[OK] Hosted no-PR landing preflight passed."
echo "[OK] Route guard: branch-no-pr."
echo "[OK] Source branch: $SOURCE_BRANCH"
echo "[OK] Source ref: $SOURCE_REF"
echo "[OK] Target branch: $TARGET_BRANCH"
echo "[OK] Target remote ref: $TARGET_REMOTE_REF"
