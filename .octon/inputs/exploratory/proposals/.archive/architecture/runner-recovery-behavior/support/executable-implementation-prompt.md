# Executable Implementation Prompt

generated_at: 2026-06-04T14:44:25Z
generator_route_id: generate-packet-implementation-prompt
proposal_packet_path: .octon/inputs/exploratory/proposals/architecture/runner-recovery-behavior
verdict: ready-for-execution

This prompt is operational guidance only. It is not authority, runtime truth,
generated-effective authority, or implementation proof.

## Gate Receipt

Run before implementation:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/runner-recovery-behavior --require-implementation-authorization
```

Expected result: `errors=0 warnings=0`.

## Objective

Implement bounded proposal-program lifecycle runner recovery behavior for routine-autonomous and soft blockers while stopping on hard blockers.

## Promotion Targets

- `.octon/framework/engine/runtime/crates/kernel/src/lifecycle_program.rs`
- `.octon/framework/engine/runtime/crates/kernel/src/workflow.rs`
- `.octon/framework/engine/runtime/crates/kernel/tests/`
- `.octon/framework/engine/runtime/crates/lifecycle_executor/src/`
- `.octon/framework/engine/runtime/crates/lifecycle_executor/tests/`
- `.octon/inputs/additive/extensions/octon-proposal-lifecycle/context/lifecycle.contract.yml`
- `.octon/inputs/additive/extensions/octon-proposal-lifecycle/context/lifecycles/proposal-program.contract.yml`
- `.octon/inputs/additive/extensions/octon-proposal-lifecycle/commands/octon-proposal-run-program-lifecycle.md`
- `.octon/inputs/additive/extensions/octon-proposal-lifecycle/skills/octon-proposal-lifecycle-run-program-lifecycle/`

## Workstreams

1. Consume validator recovery diagnostics and taxonomy classes.
2. Add bounded recovery actions for enum drift, stale receipts, stale review digests, publication freshness, generated projection drift, cleanup delegation, and continuable step exhaustion.
3. Add retry and no-progress thresholds for soft blockers.
4. Rerun failed gates after repair and record compact recovery evidence.
5. Stop on hard blockers and preserve child-owned authority.

## Validation And Evidence

- Run runner unit and integration tests touched by the implementation.
- Run proposal-program lifecycle validation scenarios.
- Run proposal standard validation for this packet.
- Record recovery evidence for routine, soft, and hard-blocker scenarios.
- Create or update `support/implementation-run.md` with `verdict`, `implemented_at`, and `promotion_evidence_count`.
- Create or update `support/implementation-conformance-review.md`, then run `validate-proposal-implementation-conformance.sh --package .octon/inputs/exploratory/proposals/architecture/runner-recovery-behavior`.
- Create or update `support/post-implementation-drift-churn-review.md`, then run `validate-proposal-post-implementation-drift.sh --package .octon/inputs/exploratory/proposals/architecture/runner-recovery-behavior`.

## Rollback

Rollback is removal or reversion of runner recovery changes in the declared targets, followed by runner and lifecycle validation.

## Terminal Criteria

Leave `proposal.yml#status` as `accepted`. Refuse closeout or archive claims while implementation-run, conformance, or drift/churn receipts are missing, failing, unresolved, or blocked.
