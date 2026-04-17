#!/usr/bin/env bash
set -euo pipefail

PR_NUMBER=""
REQUEST_READY=0
REQUEST_AUTOMERGE=0
DRY_RUN=0
LABELS_CSV=""
WAIT_FOR_CLOSE=0
WAIT_TIMEOUT_SECONDS=1800
RUN_CLEANUP=1
BACKGROUND_WATCH_TIMEOUT_SECONDS=86400

usage() {
  cat <<'USAGE'
Usage:
  git-pr-ship.sh [--pr <number>] [options]

Options:
  --label <name>         Add additional label(s) before requesting ship actions (repeatable).
  --request-ready        Request the ready-for-review transition.
  --request-automerge    Request GitHub squash auto-merge.
  --wait                 Wait for PR closure after requesting auto-merge.
  --wait-timeout-seconds Seconds to wait for closure before background watcher (default: 1800).
  --no-cleanup           Do not run local cleanup after PR closure.
  --dry-run              Print actions without mutating PR state.

Default behavior:
  Report current PR status, lane hints, and blockers without mutating PR state.
  Use explicit request flags to ask GitHub for ready or auto-merge transitions.
  GitHub required checks and review rules remain the final merge gate.
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

while [[ $# -gt 0 ]]; do
  case "$1" in
    --pr)
      shift
      [[ $# -gt 0 ]] || error "--pr requires a value"
      PR_NUMBER="$1"
      ;;
    --label)
      shift
      [[ $# -gt 0 ]] || error "--label requires a value"
      if [[ -z "$LABELS_CSV" ]]; then
        LABELS_CSV="$1"
      else
        LABELS_CSV="${LABELS_CSV},$1"
      fi
      ;;
    --request-ready)
      REQUEST_READY=1
      ;;
    --request-automerge)
      REQUEST_AUTOMERGE=1
      ;;
    --wait)
      WAIT_FOR_CLOSE=1
      ;;
    --wait-timeout-seconds)
      shift
      [[ $# -gt 0 ]] || error "--wait-timeout-seconds requires a value"
      WAIT_TIMEOUT_SECONDS="$1"
      ;;
    --no-cleanup)
      RUN_CLEANUP=0
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

require_cmd gh
require_cmd jq

REPO_SLUG="$(origin_repo_slug)"
[[ -n "$REPO_SLUG" ]] || error "Unable to resolve origin repo slug."
REPO_OWNER="${REPO_SLUG%%/*}"

[[ "$WAIT_TIMEOUT_SECONDS" =~ ^[0-9]+$ ]] || error "--wait-timeout-seconds must be a positive integer."

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
CLEANUP_SCRIPT="${SCRIPT_DIR}/git-pr-cleanup.sh"

launch_background_watcher() {
  local reason="$1"
  local watcher_log="${TMPDIR:-/tmp}/octon-pr-cleanup-${PR_NUMBER}.log"

  if [[ "$DRY_RUN" -eq 1 ]]; then
    echo "[DRY] nohup \"$CLEANUP_SCRIPT\" --watch-pr \"$PR_NUMBER\" --watch-timeout-seconds \"$BACKGROUND_WATCH_TIMEOUT_SECONDS\" >\"$watcher_log\" 2>&1 &"
    return 0
  fi

  if [[ ! -x "$CLEANUP_SCRIPT" ]]; then
    warn "Cleanup script is not executable: $CLEANUP_SCRIPT"
    return 0
  fi

  nohup "$CLEANUP_SCRIPT" \
    --watch-pr "$PR_NUMBER" \
    --watch-timeout-seconds "$BACKGROUND_WATCH_TIMEOUT_SECONDS" \
    >"$watcher_log" 2>&1 &
  info "Started background cleanup watcher (pid=$!, reason=$reason, log=$watcher_log)."
}

if [[ -z "$PR_NUMBER" ]]; then
  CURRENT_BRANCH="$(git rev-parse --abbrev-ref HEAD 2>/dev/null || true)"
  [[ -n "$CURRENT_BRANCH" && "$CURRENT_BRANCH" != "HEAD" ]] || error "Unable to resolve current branch PR. Pass --pr <number>."
  HEAD_QUERY="$(urlencode "${REPO_OWNER}:${CURRENT_BRANCH}")"
  PR_NUMBER="$(gh_api_retry "repos/${REPO_SLUG}/pulls?state=open&head=${HEAD_QUERY}&per_page=1" | jq -r '.[0].number // empty' 2>/dev/null || true)"
  if [[ -z "$PR_NUMBER" ]]; then
    if [[ "$REQUEST_READY" -eq 0 && "$REQUEST_AUTOMERGE" -eq 0 ]]; then
      echo "[WARN] Unable to resolve the current branch PR right now."
      echo "[OK] Status unavailable. GitHub API lookup is currently failing, so treat this as a blocker rather than as proof of readiness."
      exit 0
    fi
    error "Unable to resolve current branch PR. Pass --pr <number>."
  fi
fi

PR_PAYLOAD="$(gh_api_retry "repos/${REPO_SLUG}/pulls/${PR_NUMBER}" || true)"
if [[ -z "$PR_PAYLOAD" ]]; then
  if [[ "$REQUEST_READY" -eq 0 && "$REQUEST_AUTOMERGE" -eq 0 ]]; then
    echo "[WARN] Unable to load PR #${PR_NUMBER} right now."
    echo "[OK] Status unavailable. GitHub API lookup is currently failing, so treat this as a blocker rather than as proof of readiness."
    exit 0
  fi
  error "Unable to load PR #${PR_NUMBER}."
fi

PR_STATE="$(jq -r '.state | ascii_upcase' <<<"$PR_PAYLOAD")"
PR_IS_DRAFT="$(jq -r '.draft' <<<"$PR_PAYLOAD")"
PR_URL="$(jq -r '.html_url // .url' <<<"$PR_PAYLOAD")"
PR_HEAD_REF="$(jq -r '.head.ref' <<<"$PR_PAYLOAD")"

if [[ "$PR_STATE" != "OPEN" ]]; then
  error "PR #${PR_NUMBER} is not open (state=$PR_STATE)."
fi

lane_hint="autonomous-candidate"
if [[ "$PR_HEAD_REF" == exp/* ]]; then
  lane_hint="manual"
fi

if [[ "$REQUEST_AUTOMERGE" -eq 1 && "$PR_IS_DRAFT" == "true" && "$REQUEST_READY" -eq 0 ]]; then
  error "Cannot request auto-merge while the PR is draft. Add --request-ready or move the PR to ready first."
fi

if [[ "$REQUEST_READY" -eq 0 && "$REQUEST_AUTOMERGE" -eq 0 ]]; then
  info "Status for PR #${PR_NUMBER}: state=${PR_STATE}, draft=${PR_IS_DRAFT}, lane-hint=${lane_hint}."
  if [[ "$PR_IS_DRAFT" == "true" ]]; then
    info "Blocker: PR is still draft. Use --request-ready when author action items are closed."
  else
    info "PR is already in a non-draft state."
  fi
  echo "[OK] Status only. Use --request-ready and/or --request-automerge to request transitions. GitHub remains the final merge gate: $PR_URL"
  exit 0
fi

info "Preparing helper requests for PR #${PR_NUMBER}. GitHub remains the final merge gate."

LABELS_TO_ADD="$LABELS_CSV"

if [[ -n "$LABELS_TO_ADD" ]]; then
  if [[ "$DRY_RUN" -eq 1 ]]; then
    echo "[DRY] gh pr edit \"$PR_NUMBER\" --add-label \"$LABELS_TO_ADD\""
  else
    gh pr edit "$PR_NUMBER" --add-label "$LABELS_TO_ADD"
  fi
fi

if [[ "$REQUEST_READY" -eq 1 && "$PR_IS_DRAFT" == "true" ]]; then
  if [[ "$DRY_RUN" -eq 1 ]]; then
    echo "[DRY] gh pr ready \"$PR_NUMBER\""
  else
    gh pr ready "$PR_NUMBER"
  fi
fi

if [[ "$REQUEST_AUTOMERGE" -eq 1 ]]; then
  if [[ "$DRY_RUN" -eq 1 ]]; then
    echo "[DRY] gh pr merge \"$PR_NUMBER\" --auto --squash --delete-branch"
  else
    gh pr merge "$PR_NUMBER" --auto --squash --delete-branch
  fi
fi

if [[ "$RUN_CLEANUP" -eq 1 ]]; then
  if [[ "$REQUEST_AUTOMERGE" -eq 1 && "$WAIT_FOR_CLOSE" -eq 1 ]]; then
    if [[ "$DRY_RUN" -eq 1 ]]; then
      echo "[DRY] wait for PR closure (timeout=${WAIT_TIMEOUT_SECONDS}s), then run \"$CLEANUP_SCRIPT\" --pr \"$PR_NUMBER\""
    else
      info "Waiting for PR #${PR_NUMBER} to close (timeout=${WAIT_TIMEOUT_SECONDS}s)."
      start_epoch="$(date +%s)"
      while true; do
        PR_STATUS_PAYLOAD="$(gh_api_retry "repos/${REPO_SLUG}/pulls/${PR_NUMBER}" || true)"
        if [[ -n "$PR_STATUS_PAYLOAD" ]]; then
          current_state="$(jq -r '.state | ascii_upcase' <<<"$PR_STATUS_PAYLOAD")"
          if [[ "$current_state" != "OPEN" ]]; then
            info "PR #${PR_NUMBER} is now ${current_state}; running local cleanup."
            [[ -x "$CLEANUP_SCRIPT" ]] || error "Cleanup script is missing or not executable: $CLEANUP_SCRIPT"
            "$CLEANUP_SCRIPT" --pr "$PR_NUMBER"
            break
          fi
        fi

        now_epoch="$(date +%s)"
        elapsed="$((now_epoch - start_epoch))"
        if (( elapsed >= WAIT_TIMEOUT_SECONDS )); then
          warn "PR #${PR_NUMBER} is still open after ${WAIT_TIMEOUT_SECONDS}s."
          launch_background_watcher "wait-timeout"
          break
        fi
        sleep 10
      done
    fi
  elif [[ "$REQUEST_AUTOMERGE" -eq 1 && "$WAIT_FOR_CLOSE" -eq 0 ]]; then
    launch_background_watcher "no-wait"
  fi
fi

READY_SUMMARY="did not request ready-for-review"
if [[ "$REQUEST_READY" -eq 1 ]]; then
  if [[ "$PR_IS_DRAFT" == "true" ]]; then
    READY_SUMMARY="requested ready-for-review"
  else
    READY_SUMMARY="left PR in its existing non-draft state"
  fi
fi

MERGE_SUMMARY="did not request auto-merge"
if [[ "$REQUEST_AUTOMERGE" -eq 1 ]]; then
  MERGE_SUMMARY="requested squash auto-merge"
fi

if [[ "$DRY_RUN" -eq 1 ]]; then
  echo "[OK] Helper plan: ${READY_SUMMARY}; ${MERGE_SUMMARY}. GitHub still decides mergeability: $PR_URL"
else
  echo "[OK] Helper completed: ${READY_SUMMARY}; ${MERGE_SUMMARY}. GitHub remains the final merge gate: $PR_URL"
fi
