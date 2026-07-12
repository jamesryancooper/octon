# Rust Runtime Test Results

All builds used separate CARGO_TARGET_DIR paths beneath /tmp to avoid writing
build artifacts into the repository.

## authority_engine

Command:

CARGO_TARGET_DIR=/tmp/octon-amr-authority-target cargo test
--manifest-path .octon/framework/engine/runtime/crates/Cargo.toml
-p octon_authority_engine --lib

Result: exit 0; 75 passed, 0 failed, 0 ignored.

The suite included sequential token single-use, expiry, revocation, wrong
scope/class/route/run/support, forged digest, missing token, approval,
rollback, budget, egress, lifecycle, and context binding cases.

## lifecycle_executor

Command:

CARGO_TARGET_DIR=/tmp/octon-amr-lifecycle-target cargo test
--manifest-path .octon/framework/engine/runtime/crates/Cargo.toml
-p octon_lifecycle_executor --lib

Result: exit 0; 15 passed, 0 failed, 0 ignored.

## runtime_bus

Command:

CARGO_TARGET_DIR=/tmp/octon-amr-runtime-bus-target cargo test
--manifest-path .octon/framework/engine/runtime/crates/Cargo.toml
-p octon_runtime_bus --lib

Result: exit 0; 17 passed, 0 failed, 0 ignored.

The suite included tested tamper and lifecycle transition denials.

## Interpretation

Classification: DYNAMICALLY_EXECUTED. These results prove only the executed
test cases at the reviewed commit. They do not cover concurrent consumption,
multi-process journal append, crash/power-loss durability, unknown external
outcomes, or complete launch/effect mediation.

