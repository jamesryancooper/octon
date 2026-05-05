#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
HELPER="$SCRIPT_DIR/cleanup-local-run-artifacts.sh"

declare -a ARGS=()
LEGACY_PACKET_ID=""

for arg in "$@"; do
  if [[ -z "$LEGACY_PACKET_ID" && "$arg" != --* ]]; then
    LEGACY_PACKET_ID="$arg"
  else
    ARGS+=("$arg")
  fi
done

if [[ -n "$LEGACY_PACKET_ID" ]]; then
  echo "[INFO] ignoring legacy build-to-delete packet id '${LEGACY_PACKET_ID}'; local residue cleanup is now dry-run-first and reference-aware" >&2
fi

exec "$HELPER" "${ARGS[@]}"
