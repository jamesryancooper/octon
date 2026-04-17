#!/usr/bin/env bash
set -euo pipefail

PR_NUMBER=""
TARGET_BRANCH=""
WATCH_PR_NUMBER=""
WATCH_TIMEOUT_SECONDS=86400
SYNC_MAIN=1
DRY_RUN=0

usage() {
  cat <<'USAGE'
Usage:
  git-pr-cleanup.sh [--pr <number>] [--branch <name>] [options]
  git-pr-cleanup.sh --watch-pr <number> [--watch-timeout-seconds <seconds>] [options]

Options:
  --pr <number>                  Cleanup branch state for a closed PR.
  --branch <name>                Cleanup a specific branch if its latest PR is not open.
  --watch-pr <number>            Poll until PR closes, then run cleanup for that PR.
  --watch-timeout-seconds <n>    Max wait when using --watch-pr (default: 86400).
  --no-sync-main                 Do not checkout/sync main after cleanup.
  --dry-run                      Print actions without mutating local/remote state.

Default mode (no --pr/--branch):
  Sweep local branches, prune safe linked worktree directories for closed branches,
  and remove branches whose latest PR is closed/merged.

Worktree housekeeping:
  - Clean linked worktrees for closed branches are pruned automatically when safe.
  - If the current worktree or a dirty/in-use worktree cannot be removed, the
    script prints the exact manual git worktree remove step needed to finish cleanup.
USAGE
}

error() {
  echo "[ERROR] $1" >&2
  exit 1
}

info() {
  echo "[INFO] $1"
}

warn() {
  echo "[WARN] $1"
}

require_cmd() {
  local cmd="$1"
  command -v "$cmd" >/dev/null 2>&1 || error "Missing required command: $cmd"
}

urlencode() {
  jq -nr --arg value "$1" '$value|@uri'
}

origin_repo_slug() {
  local url
  url="$(git remote get-url origin 2>/dev/null || true)"
  case "$url" in
    git@github.com:*)
      url="${url#git@github.com:}"
      ;;
    ssh://git@github.com/*)
      url="${url#ssh://git@github.com/}"
      ;;
    https://github.com/*)
      url="${url#https://github.com/}"
      ;;
    *)
      return 1
      ;;
  esac
  url="${url%.git}"
  printf '%s\n' "$url"
}

gh_api_retry() {
  local attempt output err_file err_text rc
  local -a args=("$@")

  for attempt in 1 2 3; do
    err_file="$(mktemp "${TMPDIR:-/tmp}/gh-api.XXXXXX")"
    if output="$(gh api "${args[@]}" 2>"$err_file")"; then
      rm -f "$err_file"
      printf '%s' "$output"
      return 0
    fi
    rc=$?
    err_text="$(cat "$err_file")"
    rm -f "$err_file"

    if [[ $attempt -lt 3 ]] && [[ "$err_text" == *"error connecting to api.github.com"* ]]; then
      sleep "$attempt"
      continue
    fi

    [[ -n "$err_text" ]] && printf '%s\n' "$err_text" >&2
    return "$rc"
  done

  [[ -n "${err_text:-}" ]] && printf '%s\n' "$err_text" >&2
  return 1
}

manual_worktree_remove_cmd() {
  local path="$1"
  printf 'git worktree remove "%s"' "$path"
}

repo_root() {
  git rev-parse --show-toplevel 2>/dev/null || true
}

run_cmd() {
  if [[ "$DRY_RUN" -eq 1 ]]; then
    echo "[DRY] $*"
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

prune_branch_worktrees() {
  local branch="$1"
  local path=""

  mapfile -t BRANCH_WORKTREES < <(branch_worktree_paths "$branch")
  for path in "${BRANCH_WORKTREES[@]}"; do
    [[ -n "$path" ]] || continue
    if [[ "$path" == "$REPO_ROOT" ]]; then
      continue
    fi

    if [[ "$DRY_RUN" -eq 1 ]]; then
      echo "[DRY] git -C \"$REPO_ROOT\" worktree remove \"$path\""
      continue
    fi

    if git -C "$REPO_ROOT" worktree remove "$path"; then
      info "Removed linked worktree '$path' for branch '$branch'."
      pruned_worktrees=$((pruned_worktrees + 1))
    else
      warn "Linked worktree '$path' for branch '$branch' could not be removed automatically. From another worktree of this repo, run: $(manual_worktree_remove_cmd "$path")"
      worktree_manual_followups=$((worktree_manual_followups + 1))
    fi
  done
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --pr)
      shift
      [[ $# -gt 0 ]] || error "--pr requires a value"
      PR_NUMBER="$1"
      ;;
    --branch)
      shift
      [[ $# -gt 0 ]] || error "--branch requires a value"
      TARGET_BRANCH="$1"
      ;;
    --watch-pr)
      shift
      [[ $# -gt 0 ]] || error "--watch-pr requires a value"
      WATCH_PR_NUMBER="$1"
      ;;
    --watch-timeout-seconds)
      shift
      [[ $# -gt 0 ]] || error "--watch-timeout-seconds requires a value"
      WATCH_TIMEOUT_SECONDS="$1"
      ;;
    --no-sync-main)
      SYNC_MAIN=0
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

if [[ -n "$PR_NUMBER" && -n "$TARGET_BRANCH" ]]; then
  error "Use either --pr or --branch, not both."
fi

if [[ -n "$WATCH_PR_NUMBER" && ( -n "$PR_NUMBER" || -n "$TARGET_BRANCH" ) ]]; then
  error "--watch-pr cannot be combined with --pr/--branch."
fi

require_cmd git
require_cmd gh
require_cmd jq

REPO_ROOT="$(repo_root)"
[[ -n "$REPO_ROOT" ]] || error "Run this command from inside a git repository."
REPO_SLUG="$(origin_repo_slug)"
[[ -n "$REPO_SLUG" ]] || error "Unable to resolve origin repo slug."
REPO_OWNER="${REPO_SLUG%%/*}"

if [[ -n "$WATCH_PR_NUMBER" ]]; then
  [[ "$WATCH_TIMEOUT_SECONDS" =~ ^[0-9]+$ ]] || error "--watch-timeout-seconds must be a positive integer."

  info "Watching PR #${WATCH_PR_NUMBER} for closure (timeout=${WATCH_TIMEOUT_SECONDS}s)."
  start_epoch="$(date +%s)"
  while true; do
    PR_PAYLOAD="$(gh_api_retry "repos/${REPO_SLUG}/pulls/${WATCH_PR_NUMBER}" || true)"
    [[ -n "$PR_PAYLOAD" ]] || {
      sleep 15
      continue
    }

    PR_STATE="$(jq -r '.state | ascii_upcase' <<<"$PR_PAYLOAD")"
    PR_URL="$(jq -r '.html_url // .url' <<<"$PR_PAYLOAD")"
    if [[ "$PR_STATE" != "OPEN" ]]; then
      info "Observed PR closure for #${WATCH_PR_NUMBER} (${PR_URL})."
      PR_NUMBER="$WATCH_PR_NUMBER"
      break
    fi

    now_epoch="$(date +%s)"
    elapsed="$((now_epoch - start_epoch))"
    if (( elapsed >= WATCH_TIMEOUT_SECONDS )); then
      warn "Timeout while waiting for PR #${WATCH_PR_NUMBER} to close."
      exit 0
    fi
    sleep 15
  done
fi

CURRENT_BRANCH="$(git -C "$REPO_ROOT" rev-parse --abbrev-ref HEAD)"
INITIAL_BRANCH="$CURRENT_BRANCH"
CURRENT_GIT_DIR="$(git -C "$REPO_ROOT" rev-parse --absolute-git-dir)"
CURRENT_IS_LINKED_WORKTREE=0
if [[ "$CURRENT_GIT_DIR" == */worktrees/* ]]; then
  CURRENT_IS_LINKED_WORKTREE=1
fi
CURRENT_WORKTREE_MANUAL_PRUNE_PATH=""

ensure_checkout_safe() {
  if ! git -C "$REPO_ROOT" diff --quiet || ! git -C "$REPO_ROOT" diff --cached --quiet; then
    error "Working tree is not clean; cannot switch branches for cleanup."
  fi
}

add_candidate() {
  local branch="$1"
  [[ -n "$branch" ]] || return 0
  [[ "$branch" == "main" ]] && return 0
  for existing in "${CANDIDATES[@]}"; do
    [[ "$existing" == "$branch" ]] && return 0
  done
  CANDIDATES+=("$branch")
}

info "Fetching and pruning origin refs."
run_cmd git -C "$REPO_ROOT" fetch --prune origin

PR_INDEX="$(gh_api_retry --paginate "repos/${REPO_SLUG}/pulls?state=all&per_page=100" | jq -c '[.[] | {number, state:(.state|ascii_upcase), headRefName:.head.ref, baseRefName:.base.ref, url:(.html_url // .url), updatedAt:.updated_at}]')"

CANDIDATES=()
TARGET_BASE_BRANCH="main"

if [[ -n "$PR_NUMBER" ]]; then
  PR_JSON="$(gh_api_retry "repos/${REPO_SLUG}/pulls/${PR_NUMBER}" | jq -c '{number, state:(.state|ascii_upcase), headRefName:.head.ref, baseRefName:.base.ref, url:(.html_url // .url)}' 2>/dev/null || true)"
  [[ -n "$PR_JSON" ]] || error "Unable to load PR #${PR_NUMBER}."
  PR_STATE="$(jq -r '.state' <<<"$PR_JSON")"
  if [[ "$PR_STATE" == "OPEN" ]]; then
    error "PR #${PR_NUMBER} is still open; cleanup runs after closure."
  fi
  add_candidate "$(jq -r '.headRefName' <<<"$PR_JSON")"
  TARGET_BASE_BRANCH="$(jq -r '.baseRefName // "main"' <<<"$PR_JSON")"
elif [[ -n "$TARGET_BRANCH" ]]; then
  BRANCH_PR_JSON="$(jq -c --arg branch "$TARGET_BRANCH" '[.[] | select(.headRefName == $branch)] | sort_by(.number) | last // empty' <<<"$PR_INDEX")"
  if [[ -z "$BRANCH_PR_JSON" ]]; then
    warn "No PR found for branch '$TARGET_BRANCH'; cleaning local/remote refs if present."
    add_candidate "$TARGET_BRANCH"
  else
    BRANCH_PR_STATE="$(jq -r '.state' <<<"$BRANCH_PR_JSON")"
    if [[ "$BRANCH_PR_STATE" == "OPEN" ]]; then
      error "Latest PR for branch '$TARGET_BRANCH' is still open."
    fi
    add_candidate "$TARGET_BRANCH"
    TARGET_BASE_BRANCH="$(jq -r '.baseRefName // "main"' <<<"$BRANCH_PR_JSON")"
  fi
else
  mapfile -t LOCAL_BRANCHES < <(git -C "$REPO_ROOT" for-each-ref refs/heads --format='%(refname:short)' | grep -v '^main$' || true)
  for branch in "${LOCAL_BRANCHES[@]}"; do
    if [[ "$branch" == "$CURRENT_BRANCH" ]]; then
      continue
    fi

    branch_pr_json="$(jq -c --arg branch "$branch" '[.[] | select(.headRefName == $branch)] | sort_by(.number) | last // empty' <<<"$PR_INDEX")"
    if [[ -n "$branch_pr_json" ]]; then
      branch_pr_state="$(jq -r '.state' <<<"$branch_pr_json")"
      if [[ "$branch_pr_state" != "OPEN" ]]; then
        add_candidate "$branch"
      fi
      continue
    fi

    if git -C "$REPO_ROOT" merge-base --is-ancestor "$branch" "origin/main" >/dev/null 2>&1; then
      add_candidate "$branch"
      continue
    fi

    upstream_ref="$(git -C "$REPO_ROOT" for-each-ref "refs/heads/${branch}" --format='%(upstream:short)')"
    if [[ -n "$upstream_ref" ]] && ! git -C "$REPO_ROOT" show-ref --verify --quiet "refs/remotes/${upstream_ref}"; then
      add_candidate "$branch"
    fi
  done
fi

deleted_local=0
deleted_remote=0
pruned_worktrees=0
skipped_open=0
worktree_manual_followups=0

for branch in "${CANDIDATES[@]}"; do
  [[ "$branch" == "main" ]] && continue

  HEAD_QUERY="$(urlencode "${REPO_OWNER}:${branch}")"
  open_count="$(gh_api_retry "repos/${REPO_SLUG}/pulls?state=open&head=${HEAD_QUERY}&per_page=1" | jq 'length')"
  if [[ "$open_count" != "0" ]]; then
    skipped_open=$((skipped_open + 1))
    continue
  fi

  if [[ "$CURRENT_BRANCH" == "$branch" ]]; then
    ensure_checkout_safe
    if git -C "$REPO_ROOT" show-ref --verify --quiet "refs/heads/${TARGET_BASE_BRANCH}"; then
      run_cmd git -C "$REPO_ROOT" checkout "$TARGET_BASE_BRANCH"
      CURRENT_BRANCH="$TARGET_BASE_BRANCH"
    else
      run_cmd git -C "$REPO_ROOT" checkout main
      CURRENT_BRANCH="main"
    fi
    if [[ "$CURRENT_IS_LINKED_WORKTREE" -eq 1 && "$INITIAL_BRANCH" == "$branch" ]]; then
      CURRENT_WORKTREE_MANUAL_PRUNE_PATH="$REPO_ROOT"
    fi
  fi

  prune_branch_worktrees "$branch"

  local_branch_blocked_by_worktree=0
  mapfile -t REMAINING_BRANCH_WORKTREES < <(branch_worktree_paths "$branch")
  for path in "${REMAINING_BRANCH_WORKTREES[@]}"; do
    [[ -n "$path" ]] || continue
    if [[ "$path" != "$REPO_ROOT" ]]; then
      warn "Branch '$branch' is still attached to linked worktree '$path'. Remove that worktree before deleting the local branch: $(manual_worktree_remove_cmd "$path")"
      worktree_manual_followups=$((worktree_manual_followups + 1))
      local_branch_blocked_by_worktree=1
    fi
  done

  if [[ "$local_branch_blocked_by_worktree" -eq 0 ]] && git -C "$REPO_ROOT" show-ref --verify --quiet "refs/heads/${branch}"; then
    run_cmd git -C "$REPO_ROOT" branch -D "$branch"
    deleted_local=$((deleted_local + 1))
  fi

  if git -C "$REPO_ROOT" ls-remote --exit-code --heads origin "$branch" >/dev/null 2>&1; then
    run_cmd git -C "$REPO_ROOT" push origin --delete "$branch"
    deleted_remote=$((deleted_remote + 1))
  fi
done

if [[ "$SYNC_MAIN" -eq 1 ]]; then
  if [[ "$CURRENT_BRANCH" != "main" ]]; then
    ensure_checkout_safe
    run_cmd git -C "$REPO_ROOT" checkout main
    CURRENT_BRANCH="main"
  fi

  if ! git -C "$REPO_ROOT" show-ref --verify --quiet "refs/heads/main"; then
    run_cmd git -C "$REPO_ROOT" checkout -b main origin/main
    CURRENT_BRANCH="main"
  else
    run_cmd git -C "$REPO_ROOT" merge --ff-only origin/main
  fi
fi

run_cmd git -C "$REPO_ROOT" fetch --prune origin

if [[ -n "$CURRENT_WORKTREE_MANUAL_PRUNE_PATH" ]]; then
  warn "Current linked worktree '$CURRENT_WORKTREE_MANUAL_PRUNE_PATH' was preserved because cleanup is running inside it. After leaving that directory, finish housekeeping from another worktree with: $(manual_worktree_remove_cmd "$CURRENT_WORKTREE_MANUAL_PRUNE_PATH")"
  worktree_manual_followups=$((worktree_manual_followups + 1))
fi

echo "[OK] Local branches deleted: ${deleted_local}"
echo "[OK] Remote branches deleted: ${deleted_remote}"
echo "[OK] Linked worktrees pruned: ${pruned_worktrees}"
echo "[OK] Manual worktree follow-ups: ${worktree_manual_followups}"
echo "[OK] Skipped due to open PR: ${skipped_open}"
echo "[OK] Current branch: ${CURRENT_BRANCH}"
