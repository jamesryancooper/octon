#!/usr/bin/env bash
set -euo pipefail

REASON="RP00_CONTAINMENT_PUBLICATION_DISABLED"

if [[ " ${*:-} " == *" --help "* || " ${*:-} " == *" -h "* ]]; then
  cat <<'USAGE'
Usage: git-branch-land.sh [historical options]

SI-00 containment: local no-PR landing is disabled. Every non-help invocation
fails before checkout, merge, commit, or ref mutation with
RP00_CONTAINMENT_PUBLICATION_DISABLED.
USAGE
  exit 0
fi

echo "[DENIED] ${REASON}: local no-PR landing is disabled during SI-00; candidate state is preserved." >&2
exit 1
