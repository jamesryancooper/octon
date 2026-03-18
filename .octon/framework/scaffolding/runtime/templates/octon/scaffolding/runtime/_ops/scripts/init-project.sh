#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../.." && pwd)"

exec "$OCTON_DIR/scaffolding/runtime/bootstrap/init-project.sh" "$@"
