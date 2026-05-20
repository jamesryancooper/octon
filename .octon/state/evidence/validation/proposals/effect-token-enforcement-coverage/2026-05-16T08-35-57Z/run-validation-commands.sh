#!/usr/bin/env bash
set -u

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../../../../../../.." && pwd)"
EVIDENCE_DIR="$ROOT_DIR/.octon/state/evidence/validation/proposals/effect-token-enforcement-coverage/2026-05-16T08-35-57Z"
SUMMARY="$EVIDENCE_DIR/command-summary.tsv"

mkdir -p "$EVIDENCE_DIR/logs"
printf 'label\texit_code\tlog\n' >"$SUMMARY"

run_logged() {
  local label="$1"
  shift
  local log="$EVIDENCE_DIR/logs/${label}.log"
  printf '== %s ==\n' "$label"
  printf '$ %s\n' "$*" >"$log"
  "$@" >>"$log" 2>&1
  local code=$?
  printf '%s\t%s\t%s\n' "$label" "$code" "${log#$ROOT_DIR/}" >>"$SUMMARY"
  tail -n 60 "$log"
  printf '\n[%s] exit=%s log=%s\n\n' "$label" "$code" "${log#$ROOT_DIR/}"
  return 0
}

run_logged validate-proposal-standard \
  bash "$ROOT_DIR/.octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh" \
  --package "$ROOT_DIR/.octon/inputs/exploratory/proposals/architecture/effect-token-enforcement-coverage"
run_logged validate-architecture-proposal \
  bash "$ROOT_DIR/.octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh" \
  --package "$ROOT_DIR/.octon/inputs/exploratory/proposals/architecture/effect-token-enforcement-coverage"
run_logged validate-proposal-implementation-readiness \
  bash "$ROOT_DIR/.octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh" \
  --package "$ROOT_DIR/.octon/inputs/exploratory/proposals/architecture/effect-token-enforcement-coverage"
run_logged validate-proposal-review-gate \
  bash "$ROOT_DIR/.octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh" \
  --package "$ROOT_DIR/.octon/inputs/exploratory/proposals/architecture/effect-token-enforcement-coverage" \
  --require-implementation-authorization
run_logged checksum-before-receipt-refresh \
  sh -c 'cd "$1" && shasum -a 256 -c SHA256SUMS.txt' sh \
  "$ROOT_DIR/.octon/inputs/exploratory/proposals/architecture/effect-token-enforcement-coverage"
run_logged validate-material-side-effect-inventory \
  bash "$ROOT_DIR/.octon/framework/assurance/runtime/_ops/scripts/validate-material-side-effect-inventory.sh"
run_logged validate-authorization-boundary-coverage \
  bash "$ROOT_DIR/.octon/framework/assurance/runtime/_ops/scripts/validate-authorization-boundary-coverage.sh"
run_logged validate-authorized-effect-token-enforcement \
  bash "$ROOT_DIR/.octon/framework/assurance/runtime/_ops/scripts/validate-authorized-effect-token-enforcement.sh"
run_logged test-material-side-effect-token-bypass-denials \
  bash "$ROOT_DIR/.octon/framework/assurance/runtime/_ops/tests/test-material-side-effect-token-bypass-denials.sh"
run_logged test-authorized-effect-token-negative-bypass \
  bash "$ROOT_DIR/.octon/framework/assurance/runtime/_ops/tests/test-authorized-effect-token-negative-bypass.sh"
run_logged test-authorized-effect-token-consumption \
  bash "$ROOT_DIR/.octon/framework/assurance/runtime/_ops/tests/test-authorized-effect-token-consumption.sh"
run_logged test-material-side-effect-coverage-fixtures \
  bash "$ROOT_DIR/.octon/framework/assurance/runtime/_ops/tests/test-material-side-effect-coverage-fixtures.sh"
run_logged cargo-test-octon-authorized-effects \
  cargo test --manifest-path "$ROOT_DIR/.octon/framework/engine/runtime/crates/Cargo.toml" -p octon_authorized_effects
run_logged cargo-test-octon-authority-engine-lib \
  cargo test --manifest-path "$ROOT_DIR/.octon/framework/engine/runtime/crates/Cargo.toml" -p octon_authority_engine --lib
run_logged cargo-test-octon-kernel-bin \
  cargo test --manifest-path "$ROOT_DIR/.octon/framework/engine/runtime/crates/Cargo.toml" -p octon_kernel --bin octon
run_logged validate-support-envelope-reconciliation \
  bash "$ROOT_DIR/.octon/framework/assurance/runtime/_ops/scripts/validate-support-envelope-reconciliation.sh"
run_logged validate-run-health-read-model \
  bash "$ROOT_DIR/.octon/framework/assurance/runtime/_ops/scripts/validate-run-health-read-model.sh"
run_logged validate-architecture-conformance \
  bash "$ROOT_DIR/.octon/framework/assurance/runtime/_ops/scripts/validate-architecture-conformance.sh"
run_logged cleanup-local-run-artifacts-summary \
  bash "$ROOT_DIR/.octon/framework/assurance/runtime/_ops/scripts/cleanup-local-run-artifacts.sh" --summary-only
