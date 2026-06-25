#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd -- "$SCRIPT_DIR/../../../../../.." && pwd)"

bash "$SCRIPT_DIR/test-validate-proposal-review-gate.sh"
bash "$SCRIPT_DIR/test-architectural-review-validators.sh"
cargo test \
  -p octon_kernel \
  --manifest-path "$ROOT_DIR/.octon/framework/engine/runtime/crates/Cargo.toml" \
  passing_implementation_evidence_suppresses_missing_prompt_route \
  -- --nocapture
cargo test \
  -p octon_kernel \
  --manifest-path "$ROOT_DIR/.octon/framework/engine/runtime/crates/Cargo.toml" \
  closeout_handoff_preflight_does_not_require_codex_executor_runtime \
  -- --nocapture

echo "[OK] batched review digest refresh regression suite passed"
