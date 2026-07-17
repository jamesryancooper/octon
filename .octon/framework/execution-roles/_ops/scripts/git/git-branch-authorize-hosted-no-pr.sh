#!/usr/bin/env bash
set -euo pipefail

REASON="RP00_CONTAINMENT_PUBLICATION_DISABLED"

if [[ " ${*:-} " == *" --help "* || " ${*:-} " == *" -h "* ]]; then
  cat <<'USAGE'
Usage: git-branch-authorize-hosted-no-pr.sh [historical options]

SI-00 containment: no current branch-landing authorization can be minted.
Every non-help invocation fails before remote observation, receipt approval,
or provider/ref mutation with RP00_CONTAINMENT_PUBLICATION_DISABLED.
USAGE
  exit 0
fi

echo "[DENIED] ${REASON}: hosted no-PR authorization is disabled during SI-00; no approval receipt was emitted." >&2
exit 1
