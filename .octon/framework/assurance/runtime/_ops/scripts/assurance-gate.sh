#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
MANIFEST_PATH="$SCRIPT_DIR/../../../../engine/runtime/crates/Cargo.toml"

VALIDATORS=(
  "validate-constitutional-family-live-model.sh"
  "validate-bootstrap-authority-surfaces.sh"
  "validate-support-target-live-claims.sh"
  "validate-disclosure-live-roots.sh"
  "validate-subordinate-owner-identifiers.sh"
)

for validator in "${VALIDATORS[@]}"; do
  echo "==> $validator"
  bash "$SCRIPT_DIR/$validator"
done

cargo run --quiet --manifest-path "$MANIFEST_PATH" \
  -p octon_assurance_tools --bin octon-assurance -- gate "$@"
