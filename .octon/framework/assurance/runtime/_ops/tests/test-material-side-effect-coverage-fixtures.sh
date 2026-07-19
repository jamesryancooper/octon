#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../../../../../.." && pwd)"

OCTON_DISCOVERY_ROOT_DIR="$ROOT_DIR" \
  bash "$ROOT_DIR/.octon/framework/assurance/runtime/_ops/tests/test-material-side-effect-token-bypass-denials.sh"
bash "$ROOT_DIR/.octon/framework/assurance/runtime/_ops/tests/test-generated-effective-publication-live-wrapper.sh"
bash "$ROOT_DIR/.octon/framework/assurance/runtime/_ops/tests/test-publication-runtime-boundary-delegation.sh"
bash "$ROOT_DIR/.octon/framework/assurance/runtime/_ops/tests/test-protected-ci-live-wrapper.sh"
cargo test \
  --manifest-path "$ROOT_DIR/.octon/framework/engine/runtime/crates/Cargo.toml" \
  -p octon_kernel --bin octon workflow::tests::create_design_package_writes_execution_artifacts

cargo test \
  --manifest-path "$ROOT_DIR/.octon/framework/engine/runtime/crates/Cargo.toml" \
  -p octon_kernel --bin octon pipeline::tests::mock_generic_workflow_writes_execution_artifacts -- --exact
