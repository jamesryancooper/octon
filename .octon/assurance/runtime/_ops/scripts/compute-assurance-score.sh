#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
MANIFEST_PATH="$SCRIPT_DIR/../../../../engine/runtime/crates/Cargo.toml"

cargo run --quiet --manifest-path "$MANIFEST_PATH" \
  -p octon_assurance_tools --bin octon-assurance -- score "$@"
