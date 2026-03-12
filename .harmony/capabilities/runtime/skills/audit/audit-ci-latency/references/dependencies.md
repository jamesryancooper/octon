# Dependencies

- `gh` must be installed and authenticated for the target repository.
- The shared wrapper must exist at:
  `.harmony/agency/_ops/scripts/ci/audit-ci-latency.sh`
- The policy contract must exist at:
  `.harmony/agency/practices/standards/ci-latency-policy.json`
- The Rust analysis command is expected to be available through:
  `cargo run --manifest-path .harmony/engine/runtime/crates/Cargo.toml -p harmony_assurance_tools -- ci-latency ...`
