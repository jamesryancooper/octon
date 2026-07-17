#!/usr/bin/env bash
set -euo pipefail

REASON="RP00_CONTAINMENT_PUBLICATION_DISABLED"

if [[ " ${*:-} " == *" --help "* || " ${*:-} " == *" -h "* ]]; then
  cat <<'USAGE'
Usage: git-branch-land-hosted-no-pr.sh [historical options]

SI-00 containment: hosted no-PR landing is disabled. Every non-help
invocation fails before fetch, push, remote update, or ref mutation with
RP00_CONTAINMENT_PUBLICATION_DISABLED.
USAGE
  exit 0
fi

echo "[DENIED] ${REASON}: hosted no-PR landing is disabled during SI-00; candidate and remote refs are preserved." >&2
exit 1
