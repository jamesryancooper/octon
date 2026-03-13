#!/usr/bin/env bash
# run-octon-policy.sh - Compatibility shim for engine/runtime/policy.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CAPABILITIES_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
REPO_ROOT="$(cd "$CAPABILITIES_DIR/../.." && pwd)"
ENGINE_POLICY_RUNNER="$REPO_ROOT/.octon/engine/runtime/policy"

if [[ ! -x "$ENGINE_POLICY_RUNNER" ]]; then
  echo "Missing engine policy runner: $ENGINE_POLICY_RUNNER" >&2
  exit 1
fi

exec "$ENGINE_POLICY_RUNNER" "$@"
