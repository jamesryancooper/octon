# Proposal Program Runner Test Fixture Matrix

This scenario is a validation fixture index only. It is not Octon authority,
runtime policy, lifecycle state, or implementation evidence.

## Coverage Classes

- behavior proof: program child route planning, handoff, execute-routes dispatch,
  max-step bounded execution, resume/replay, cancellation, lock handling, and
  closeout/archive behavior are covered by runtime and shell tests.
- boundary proof: parent receipts, generated outputs, GitHub/CI context, phase
  metadata, and program summaries remain non-authoritative for child packets.
- runtime authorization proof: lifecycle executor tests cover delegation
  contracts, missing contracts, required pre-dispatch receipts, required
  evidence gates, human boundaries, cancellation, timeout, and target mutation
  failure handling.
- generated-output freshness proof: route resolution and lifecycle contract
  validation tests require generated effective route bindings, published prompt
  assets, contract projections, and retired route denials to remain current.
- disclosure proof: operator-facing fixture coverage is enumerated here so
  validation drift is visible without treating this matrix as runtime evidence.

## Source Traceability

- R005: default handoff mode is covered by
  `.octon/framework/engine/runtime/crates/kernel/tests/proposal_program_cli.rs`
  and `.octon/framework/assurance/runtime/_ops/tests/test-lifecycle-runner.sh`.
- R006: execute-routes delegation is covered by
  `.octon/framework/engine/runtime/crates/kernel/tests/proposal_program_cli.rs`
  and `.octon/framework/engine/runtime/crates/kernel/src/lifecycle_program.rs`.
- R009: route inventory, prompt bundle, and generated projection freshness are
  covered by
  `.octon/inputs/additive/extensions/octon-proposal-lifecycle/validation/tests/test-route-resolution.sh`
  and
  `.octon/framework/assurance/runtime/_ops/tests/test-validate-lifecycle-contracts.sh`.
- R016: phase metadata non-authority is covered by
  `.octon/framework/engine/runtime/crates/kernel/tests/proposal_program_cli.rs`
  and `.octon/framework/assurance/runtime/_ops/tests/test-lifecycle-runner.sh`.
- R018: child promotion ownership is covered by
  `.octon/framework/engine/runtime/crates/kernel/src/lifecycle_program.rs` and
  `.octon/inputs/additive/extensions/octon-proposal-lifecycle/validation/tests/test-authority-boundaries.sh`.
- R019: recovery attempt budgets and replay behavior are covered by
  `.octon/framework/engine/runtime/crates/kernel/src/lifecycle_program.rs`.
- R024: verification and correction receipts are covered by
  `.octon/framework/assurance/runtime/_ops/tests/test-validate-proposal-implementation-conformance.sh`
  and
  `.octon/framework/assurance/runtime/_ops/tests/test-validate-proposal-post-implementation-drift.sh`.
- R033: lifecycle residue and hygiene fingerprint behavior is covered by
  `.octon/framework/assurance/runtime/_ops/tests/test-proposal-lifecycle-residue-fingerprint.sh`.
- R060: pre-dispatch receipt and evidence-gate authorization is covered by
  `.octon/framework/engine/runtime/crates/lifecycle_executor/tests/adapter.rs`.
- R061: no-new-status and lifecycle contract schema behavior is covered by
  `.octon/framework/assurance/runtime/_ops/tests/test-validate-lifecycle-contracts.sh`.
- R062: proposal lifecycle pack shape and child path boundaries are covered by
  `.octon/inputs/additive/extensions/octon-proposal-lifecycle/validation/tests/test-pack-shape.sh`
  and
  `.octon/inputs/additive/extensions/octon-proposal-lifecycle/validation/tests/test-authority-boundaries.sh`.

## Negative Controls

- A parent program route, parent receipt, or registry `phase_id` must not replace
  the child packet lifecycle contract route selected for the child.
- Missing required pre-dispatch receipts and missing or failing evidence gates
  must block before executor dispatch and before mock side effects.
- Generated effective projections and validation scenarios must not be treated
  as durable authority or retained implementation evidence.
