# Validation

Validation results from the final sweep:

- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-assurance-disclosure-expansion.sh`
  Result: PASS
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-execution-constitution-closeout.sh`
  Result: PASS
- `bash .octon/framework/assurance/runtime/_ops/scripts/alignment-check.sh --profile harness,mission-autonomy`
  Result: PASS
- `cargo build --manifest-path .octon/framework/engine/runtime/crates/Cargo.toml -p policy_engine --bin octon-policy`
  Result: PASS
- `cargo test --manifest-path .octon/framework/engine/runtime/crates/Cargo.toml -p octon_kernel`
  Result: FAIL
  Notes: the default parallel fixture run still hits intermittent `failed to parse ACP decision output` errors in ACP-wrapper-backed workflow fixtures.
- `cargo test --manifest-path .octon/framework/engine/runtime/crates/Cargo.toml -p octon_kernel -- --test-threads=1`
  Result: PASS
  Notes: serializing the kernel fixtures eliminates the ACP-wrapper bootstrap race and the suite passes `30/30`.
