#!/usr/bin/env bash
# policy-acp-eval.sh - Evaluate ACP gate requests via octon-policy.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CAPABILITIES_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
REPO_ROOT="$(cd "$CAPABILITIES_DIR/../.." && pwd)"
POLICY_RUNNER="$REPO_ROOT/.octon/engine/runtime/policy"
DEFAULT_POLICY="$CAPABILITIES_DIR/governance/policy/deny-by-default.v2.yml"

usage() {
  cat <<'USAGE'
Usage:
  policy-acp-eval.sh <preflight|enforce> --request <path> [--policy <path>]
USAGE
}

main() {
  local mode="${1:-}"
  shift || true

  local request_path=""
  local policy_path="$DEFAULT_POLICY"

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --request) request_path="$2"; shift 2 ;;
      --policy) policy_path="$2"; shift 2 ;;
      -h|--help|help) usage; exit 0 ;;
      *) echo "Unknown option: $1" >&2; usage >&2; exit 1 ;;
    esac
  done

  if [[ "$mode" == "help" || "$mode" == "-h" || "$mode" == "--help" ]]; then
    usage
    exit 0
  fi

  [[ -n "$mode" ]] || { usage >&2; exit 1; }
  [[ -n "$request_path" ]] || { echo "--request is required" >&2; exit 1; }
  [[ -f "$request_path" ]] || { echo "Missing request file: $request_path" >&2; exit 1; }
  [[ -x "$POLICY_RUNNER" ]] || { echo "Missing policy runner: $POLICY_RUNNER" >&2; exit 1; }

  case "$mode" in
    preflight)
      "$POLICY_RUNNER" acp-preflight --policy "$policy_path" --request "$request_path"
      ;;
    enforce)
      "$POLICY_RUNNER" acp-enforce --policy "$policy_path" --request "$request_path"
      ;;
    *)
      echo "Invalid mode '$mode' (expected preflight|enforce)" >&2
      exit 1
      ;;
  esac
}

main "$@"
