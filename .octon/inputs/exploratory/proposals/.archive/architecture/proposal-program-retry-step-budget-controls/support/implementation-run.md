verdict: pass
implemented_at: 2026-07-08T01:20:59Z
implementer: Codex proposal lifecycle operator
promotion_evidence_count: 6
implementation_run_id: proposal-program-retry-step-budget-controls-implementation-20260708T012059Z

# Implementation Run

## Implemented Change

Added retry-attempt budget controls to `octon lifecycle program retry`:

- `--max-steps`
- `--timeout-seconds`
- `--max-child-concurrency`

The retry path now accepts an explicit retry-options record, merges supplied
retry controls over checkpointed execution limits, and falls back to the
existing one-step/single-child retry defaults when no retained limit exists.
The retry remains bound to the existing checkpoint, run id, lifecycle id,
target, registry binding, run inputs, event log, approvals, cancellation,
child filtering, blocker, freshness, dependency, and child-owned evidence
gates.

## Promotion Target Evidence

- `.octon/framework/engine/runtime/crates/kernel/src/main.rs`
- `.octon/framework/engine/runtime/crates/kernel/src/lifecycle.rs`
- `.octon/framework/engine/runtime/crates/kernel/src/lifecycle_program.rs`
- `.octon/inputs/additive/extensions/octon-proposal-lifecycle/README.md`
- `.octon/inputs/additive/extensions/octon-proposal-lifecycle/skills/octon-proposal-lifecycle-run-program-lifecycle/SKILL.md`
- `.octon/inputs/additive/extensions/octon-proposal-lifecycle/context/lifecycle-model.md`

## Validation Evidence

- `cargo fmt --manifest-path .octon/framework/engine/runtime/crates/Cargo.toml --all`
- `cargo test --manifest-path .octon/framework/engine/runtime/crates/Cargo.toml -p octon_kernel program_retry -- --nocapture`
- `cargo test --manifest-path .octon/framework/engine/runtime/crates/Cargo.toml -p octon_kernel approval_grant_is_consumed_by_retry_without_unattended_cli_policy -- --nocapture`
- `cargo test --manifest-path .octon/framework/engine/runtime/crates/Cargo.toml -p octon_kernel program_operator_controls_use_checkpointed_event_log -- --nocapture`
- `cargo test --manifest-path .octon/framework/engine/runtime/crates/Cargo.toml -p octon_kernel cli_parses_lifecycle_commands -- --nocapture`
