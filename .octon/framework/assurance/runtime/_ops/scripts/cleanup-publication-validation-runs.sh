#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
HELPER="$SCRIPT_DIR/cleanup-local-run-artifacts.sh"

declare -a ARGS=()
LEGACY_PACKET_ID=""
TMP_BUDGET_REPORT=0
ROOT_OVERRIDE=""

while [[ "$#" -gt 0 ]]; do
  case "$1" in
    --tmp-budget-report)
      TMP_BUDGET_REPORT=1
      ARGS+=("$1")
      shift
      ;;
    --root)
      [[ "$#" -ge 2 ]] || {
        echo "missing value for --root" >&2
        exit 2
      }
      ROOT_OVERRIDE="$2"
      ARGS+=("$1" "$2")
      shift 2
      ;;
    --*)
      ARGS+=("$1")
      shift
      ;;
    *)
      if [[ -z "$LEGACY_PACKET_ID" ]]; then
        LEGACY_PACKET_ID="$1"
      else
        ARGS+=("$1")
      fi
      shift
      ;;
  esac
done

if [[ -n "$LEGACY_PACKET_ID" ]]; then
  echo "[INFO] ignoring legacy build-to-delete packet id '${LEGACY_PACKET_ID}'; local residue cleanup is now dry-run-first and reference-aware" >&2
fi

if [[ "$TMP_BUDGET_REPORT" -eq 1 ]]; then
  if [[ -n "$ROOT_OVERRIDE" ]]; then
    export OCTON_ROOT_DIR="$ROOT_OVERRIDE"
    export OCTON_DIR_OVERRIDE="$ROOT_OVERRIDE/.octon"
  fi
  source "$SCRIPT_DIR/publication-wrapper-common.sh"
  publication_write_scratch_budget_report "$ROOT_DIR/.octon/generated/.tmp"
  exit 0
fi

exec "$HELPER" "${ARGS[@]}"
