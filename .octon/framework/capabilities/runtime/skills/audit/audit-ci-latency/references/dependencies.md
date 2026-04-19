# Dependencies

- `gh` must be installed and authenticated for the target repository.
- The shared wrapper must exist at:
  `.octon/framework/execution-roles/_ops/scripts/ci/audit-ci-latency.sh`
- The policy contract must exist at:
  `.octon/framework/execution-roles/practices/standards/ci-latency-policy.json`
- The Rust analysis command is expected to be available through:
  `cargo run --manifest-path .octon/framework/engine/runtime/crates/Cargo.toml -p octon_assurance_tools -- ci-latency ...`
