#!/usr/bin/env bash
set -euo pipefail

REMOTE="origin"
REF=""
DRY_RUN=0
ALLOW_EMPTY=0
declare -a REQUIRED_CHECKS=()

usage() {
  cat <<'USAGE'
Usage:
  git-required-checks-at-ref.sh --ref <sha-or-ref> [--remote <name>] [--require-check <name>]... [--allow-empty-check-set] [--dry-run]

Exact-SHA hosted check evidence helper.
Route guard: call only after Change routing selects branch-no-pr or branch-pr.

Behavior:
  - resolves the requested ref to an exact commit SHA
  - requires every supplied check context to be successful for that exact SHA
  - checks both GitHub check-runs and commit status contexts
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

check_run_success() {
  local repo="$1"
  local sha="$2"
  local context="$3"
  gh api "repos/${repo}/commits/${sha}/check-runs?per_page=100" \
    --jq ".check_runs[]? | select(.name == \"${context}\") | select(.status == \"completed\" and .conclusion == \"success\") | .name" \
    2>/dev/null | grep -Fxq "$context"
}

status_success() {
  local repo="$1"
  local sha="$2"
  local context="$3"
  gh api "repos/${repo}/commits/${sha}/status" \
    --jq ".statuses[]? | select(.context == \"${context}\" and .state == \"success\") | .context" \
    2>/dev/null | grep -Fxq "$context"
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --ref)
      shift
      [[ $# -gt 0 ]] || error "--ref requires a value"
      REF="$1"
      ;;
    --remote)
      shift
      [[ $# -gt 0 ]] || error "--remote requires a value"
      REMOTE="$1"
      ;;
    --require-check)
      shift
      [[ $# -gt 0 ]] || error "--require-check requires a value"
      REQUIRED_CHECKS+=("$1")
      ;;
    --allow-empty-check-set)
      ALLOW_EMPTY=1
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

[[ -n "$REF" ]] || error "--ref is required."
if [[ "${#REQUIRED_CHECKS[@]}" -eq 0 && "$ALLOW_EMPTY" -ne 1 ]]; then
  error "At least one --require-check is required unless --allow-empty-check-set is explicit."
fi

REPO_ROOT="$(repo_root)"
[[ -n "$REPO_ROOT" ]] || error "Run this command from inside a git repository."

SHA="$(git -C "$REPO_ROOT" rev-parse --verify "$REF^{commit}")"

if [[ "$DRY_RUN" -eq 1 ]]; then
  echo "[OK] Dry run exact-SHA check validation for $SHA."
  for context in "${REQUIRED_CHECKS[@]}"; do
    echo "[OK] Required check would be verified at exact SHA: $context"
  done
  [[ "${#REQUIRED_CHECKS[@]}" -gt 0 ]] || echo "[OK] Empty check set explicitly allowed."
  exit 0
fi

command -v gh >/dev/null 2>&1 || error "gh is required for hosted check validation."
REPO="$(github_repo)" || error "Unable to resolve GitHub owner/repo from remote '$REMOTE'."

for context in "${REQUIRED_CHECKS[@]}"; do
  if check_run_success "$REPO" "$SHA" "$context" || status_success "$REPO" "$SHA" "$context"; then
    echo "[OK] Required check passed at exact SHA $SHA: $context"
  else
    error "Missing or failing required check at exact SHA $SHA: $context"
  fi
done

[[ "${#REQUIRED_CHECKS[@]}" -gt 0 ]] || echo "[OK] Empty check set explicitly allowed."
echo "[OK] Exact-SHA required checks satisfied for $SHA."
