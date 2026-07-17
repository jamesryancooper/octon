#!/usr/bin/env bash
set -euo pipefail

REASON="RP00_CONTAINMENT_CLEANUP_DISABLED"

if [[ " ${*:-} " == *" --help "* || " ${*:-} " == *" -h "* ]]; then
  cat <<'USAGE'
Usage: git-pr-cleanup.sh [historical options]

SI-00 containment: PR cleanup is disabled. Every non-help invocation fails
before checkout, sync, worktree removal, pruning, or ref deletion with
RP00_CONTAINMENT_CLEANUP_DISABLED.
USAGE
  exit 0
fi

echo "[DENIED] ${REASON}: PR cleanup is disabled during SI-00; worktrees and refs are preserved." >&2
exit 1
