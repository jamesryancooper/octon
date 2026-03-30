#!/usr/bin/env bash
set -euo pipefail

PR_NUMBER=""
MARK_READY=1
REQUEST_AUTOMERGE=1
DRY_RUN=0
LABELS_CSV=""
WAIT_FOR_CLOSE=1
WAIT_TIMEOUT_SECONDS=1800
RUN_CLEANUP=1
BACKGROUND_WATCH_TIMEOUT_SECONDS=86400

usage() {
  cat <<'USAGE'
Usage:
  git-pr-ship.sh [--pr <number>] [options]

Options:
  --label <name>         Add additional label(s) before shipping (repeatable).
  --no-ready             Do not convert draft PR to ready state.
  --no-automerge         Skip auto-merge request call.
  --no-wait              Do not block waiting for PR closure.
  --wait-timeout-seconds Seconds to wait for closure before background watcher (default: 1800).
  --no-cleanup           Do not run local cleanup after PR closure.
  --dry-run              Print actions without mutating PR state.

Default behavior:
  1) mark draft PR as ready,
  2) request squash auto-merge.
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
    --no-ready)
      MARK_READY=0
      ;;
    --no-automerge)
      REQUEST_AUTOMERGE=0
      ;;
    --no-wait)
      WAIT_FOR_CLOSE=0
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
  PR_NUMBER="$(gh pr view --json number --jq '.number' 2>/dev/null || true)"
  [[ -n "$PR_NUMBER" ]] || error "Unable to resolve current branch PR. Pass --pr <number>."
fi

PR_PAYLOAD="$(gh pr view "$PR_NUMBER" --json state,isDraft,url,headRefName 2>/dev/null || true)"
[[ -n "$PR_PAYLOAD" ]] || error "Unable to load PR #${PR_NUMBER}."

PR_STATE="$(jq -r '.state' <<<"$PR_PAYLOAD")"
PR_IS_DRAFT="$(jq -r '.isDraft' <<<"$PR_PAYLOAD")"
PR_URL="$(jq -r '.url' <<<"$PR_PAYLOAD")"

if [[ "$PR_STATE" != "OPEN" ]]; then
  error "PR #${PR_NUMBER} is not open (state=$PR_STATE)."
fi

LABELS_TO_ADD="$LABELS_CSV"

if [[ -n "$LABELS_TO_ADD" ]]; then
  if [[ "$DRY_RUN" -eq 1 ]]; then
    echo "[DRY] gh pr edit \"$PR_NUMBER\" --add-label \"$LABELS_TO_ADD\""
  else
    gh pr edit "$PR_NUMBER" --add-label "$LABELS_TO_ADD"
  fi
fi

if [[ "$MARK_READY" -eq 1 && "$PR_IS_DRAFT" == "true" ]]; then
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
        PR_STATUS_PAYLOAD="$(gh pr view "$PR_NUMBER" --json state,url 2>/dev/null || true)"
        if [[ -n "$PR_STATUS_PAYLOAD" ]]; then
          current_state="$(jq -r '.state' <<<"$PR_STATUS_PAYLOAD")"
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
  elif [[ "$REQUEST_AUTOMERGE" -eq 0 ]]; then
    launch_background_watcher "manual-lane"
  fi
fi

echo "[OK] PR ready for canonical auto-merge checks: $PR_URL"
