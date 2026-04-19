#!/usr/bin/env bash
set -euo pipefail

BASE_BRANCH="main"
TYPE=""
SLUG=""
TICKET=""
BRANCH=""
WORKTREE_PATH=""
DRY_RUN=0
RUN_CLEANUP_PREFLIGHT=1

usage() {
  cat <<'USAGE'
Usage:
  git-wt-new.sh --type <type> --slug <slug> [--ticket <ABC-123>] [--base <branch>] [--worktree <path>] [--no-cleanup-preflight] [--dry-run]
  git-wt-new.sh --branch <type/slug-or-ticket-slug> [--base <branch>] [--worktree <path>] [--no-cleanup-preflight] [--dry-run]

Creates a new git worktree and branch using repository branch naming standards.
USAGE
}

error() {
  echo "[ERROR] $1" >&2
  exit 1
}

info() {
  echo "[INFO] $1"
}

require_cmd() {
  local cmd="$1"
  command -v "$cmd" >/dev/null 2>&1 || error "Missing required command: $cmd"
}

repo_root() {
  git rev-parse --show-toplevel 2>/dev/null || true
}

contains_type() {
  local target="$1"
  local value
  for value in ${ALLOWED_TYPES}; do
    if [[ "$value" == "$target" ]]; then
      return 0
    fi
  done
  return 1
}

validate_branch() {
  local branch_name="$1"
  local pattern="^(${ALLOWED_TYPES_REGEX})/((${BASH_TICKET_PATTERN})-)?(${BASH_SLUG_PATTERN})$"

  if [[ ! "$branch_name" =~ $pattern ]]; then
    error "Branch '$branch_name' does not match branch policy contract."
  fi
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --type)
      shift
      [[ $# -gt 0 ]] || error "--type requires a value"
      TYPE="$1"
      ;;
    --slug)
      shift
      [[ $# -gt 0 ]] || error "--slug requires a value"
      SLUG="$1"
      ;;
    --ticket)
      shift
      [[ $# -gt 0 ]] || error "--ticket requires a value"
      TICKET="$1"
      ;;
    --branch)
      shift
      [[ $# -gt 0 ]] || error "--branch requires a value"
      BRANCH="$1"
      ;;
    --base)
      shift
      [[ $# -gt 0 ]] || error "--base requires a value"
      BASE_BRANCH="$1"
      ;;
    --worktree)
      shift
      [[ $# -gt 0 ]] || error "--worktree requires a value"
      WORKTREE_PATH="$1"
      ;;
    --dry-run)
      DRY_RUN=1
      ;;
    --no-cleanup-preflight)
      RUN_CLEANUP_PREFLIGHT=0
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

require_cmd git
require_cmd jq

REPO_ROOT="$(repo_root)"
[[ -n "$REPO_ROOT" ]] || error "Run this command from within a git repository."

STANDARDS_FILE="$REPO_ROOT/.octon/framework/execution-roles/practices/standards/commit-pr-standards.json"
[[ -f "$STANDARDS_FILE" ]] || error "Missing standards file: $STANDARDS_FILE"

if [[ "$RUN_CLEANUP_PREFLIGHT" -eq 1 ]]; then
  SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
  CLEANUP_SCRIPT="${SCRIPT_DIR}/git-pr-cleanup.sh"
  if [[ -x "$CLEANUP_SCRIPT" ]]; then
    info "Running clean-state preflight before creating new worktree."
    if [[ "$DRY_RUN" -eq 1 ]]; then
      echo "[DRY] \"$CLEANUP_SCRIPT\" --no-sync-main"
    else
      "$CLEANUP_SCRIPT" --no-sync-main
    fi
  else
    info "Skipping clean-state preflight (cleanup script not found)."
  fi
fi

ALLOWED_TYPES="$(jq -r '.branch.allowed_types[]' "$STANDARDS_FILE")"
ALLOWED_TYPES_REGEX="$(jq -r '.branch.allowed_types | join("|")' "$STANDARDS_FILE")"
TICKET_PATTERN="$(jq -r '.branch.ticket_pattern' "$STANDARDS_FILE")"
SLUG_PATTERN="$(jq -r '.branch.slug_pattern' "$STANDARDS_FILE")"
BASH_TICKET_PATTERN="${TICKET_PATTERN//\(\?:/(}"
BASH_SLUG_PATTERN="${SLUG_PATTERN//\(\?:/(}"

if [[ -n "$BRANCH" ]]; then
  [[ -z "$TYPE" && -z "$SLUG" && -z "$TICKET" ]] || \
    error "Use either --branch OR --type/--slug/--ticket, not both."
else
  [[ -n "$TYPE" ]] || error "--type is required when --branch is not provided."
  [[ -n "$SLUG" ]] || error "--slug is required when --branch is not provided."

  contains_type "$TYPE" || error "Unsupported --type '$TYPE'."
  [[ "$SLUG" =~ ^${BASH_SLUG_PATTERN}$ ]] || error "Slug '$SLUG' does not match slug policy."

  if [[ -n "$TICKET" ]]; then
    [[ "$TICKET" =~ ^${BASH_TICKET_PATTERN}$ ]] || error "Ticket '$TICKET' does not match ticket policy."
    BRANCH="${TYPE}/${TICKET}-${SLUG}"
  else
    BRANCH="${TYPE}/${SLUG}"
  fi
fi

validate_branch "$BRANCH"

BASE_REF=""
if git -C "$REPO_ROOT" show-ref --verify --quiet "refs/heads/${BASE_BRANCH}"; then
  BASE_REF="$BASE_BRANCH"
elif git -C "$REPO_ROOT" show-ref --verify --quiet "refs/remotes/origin/${BASE_BRANCH}"; then
  BASE_REF="origin/${BASE_BRANCH}"
else
  info "Fetching origin/${BASE_BRANCH} to resolve base ref."
  git -C "$REPO_ROOT" fetch origin "$BASE_BRANCH" >/dev/null
  if git -C "$REPO_ROOT" show-ref --verify --quiet "refs/remotes/origin/${BASE_BRANCH}"; then
    BASE_REF="origin/${BASE_BRANCH}"
  else
    error "Unable to resolve base branch '${BASE_BRANCH}'."
  fi
fi

if [[ -z "$WORKTREE_PATH" ]]; then
  repo_name="$(basename "$REPO_ROOT")"
  WORKTREE_PATH="$(dirname "$REPO_ROOT")/${repo_name}-${BRANCH//\//-}"
fi

worktree_parent="$(cd -- "$(dirname -- "$WORKTREE_PATH")" && pwd)"
WORKTREE_PATH="${worktree_parent}/$(basename -- "$WORKTREE_PATH")"

[[ ! -e "$WORKTREE_PATH" ]] || error "Worktree path already exists: $WORKTREE_PATH"

LOCAL_EXISTS=0
REMOTE_EXISTS=0
git -C "$REPO_ROOT" show-ref --verify --quiet "refs/heads/${BRANCH}" && LOCAL_EXISTS=1 || true
git -C "$REPO_ROOT" ls-remote --exit-code --heads origin "$BRANCH" >/dev/null 2>&1 && REMOTE_EXISTS=1 || true

if [[ "$DRY_RUN" -eq 1 ]]; then
  if [[ "$LOCAL_EXISTS" -eq 1 ]]; then
    echo "[DRY] git -C \"$REPO_ROOT\" worktree add \"$WORKTREE_PATH\" \"$BRANCH\""
  elif [[ "$REMOTE_EXISTS" -eq 1 ]]; then
    echo "[DRY] git -C \"$REPO_ROOT\" worktree add --track -b \"$BRANCH\" \"$WORKTREE_PATH\" \"origin/$BRANCH\""
  else
    echo "[DRY] git -C \"$REPO_ROOT\" worktree add -b \"$BRANCH\" \"$WORKTREE_PATH\" \"$BASE_REF\""
  fi
  exit 0
fi

if [[ "$LOCAL_EXISTS" -eq 1 ]]; then
  git -C "$REPO_ROOT" worktree add "$WORKTREE_PATH" "$BRANCH"
elif [[ "$REMOTE_EXISTS" -eq 1 ]]; then
  git -C "$REPO_ROOT" worktree add --track -b "$BRANCH" "$WORKTREE_PATH" "origin/$BRANCH"
else
  git -C "$REPO_ROOT" worktree add -b "$BRANCH" "$WORKTREE_PATH" "$BASE_REF"
fi

echo "[OK] Branch: $BRANCH"
echo "[OK] Worktree: $WORKTREE_PATH"
