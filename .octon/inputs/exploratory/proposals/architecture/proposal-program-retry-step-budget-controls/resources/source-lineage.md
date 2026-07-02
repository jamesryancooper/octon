# Source Lineage

This packet was created from side-conversation operational analysis of a
proposal-program lifecycle run that was continuable but inefficient because
`lifecycle program retry` preserved a one-step budget.

## Observed Runtime Surfaces

- `.octon/framework/engine/runtime/crates/kernel/src/main.rs`
  - `lifecycle run` exposes `--max-steps`, `--timeout-seconds`, and `--max-child-concurrency`.
  - `lifecycle program retry` currently exposes `--run-id` and optional `--child`.
- `.octon/framework/engine/runtime/crates/kernel/src/lifecycle.rs`
  - Dispatches `LifecycleProgramCmd::Retry` without retry-time execution option overrides.
- `.octon/framework/engine/runtime/crates/kernel/src/lifecycle_program.rs`
  - Defines default program max steps and retry max steps.
  - Reconstructs retry options from the checkpoint and bounded retry defaults.
- `.octon/inputs/additive/extensions/octon-proposal-lifecycle/skills/octon-proposal-lifecycle-run-program-lifecycle/SKILL.md`
  - Documents `--max-steps` as the bounded plan-execute-replan dispatch budget.

## Interpretation

The generic run surface can already continue a retained run id with a larger
bounded budget. The narrower program retry surface should expose the same safe
controls so operators do not need to switch command families for routine
continuation.

