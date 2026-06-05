# Executable Implementation Prompt

generated_at: 2026-06-04T14:44:25Z
generator_route_id: generate-packet-implementation-prompt
proposal_packet_path: .octon/inputs/exploratory/proposals/architecture/token-efficiency-preservation
verdict: ready-for-execution

This prompt is operational guidance only. It is not authority, runtime truth,
generated-effective authority, or implementation proof.

## Gate Receipt

Run before implementation:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/token-efficiency-preservation --require-implementation-authorization
```

Expected result: `errors=0 warnings=0`.

## Objective

Preserve or improve token efficiency while adding autonomous lifecycle recovery.

## Promotion Targets

- `.octon/framework/engine/runtime/crates/kernel/src/lifecycle_program.rs`
- `.octon/framework/engine/runtime/crates/lifecycle_executor/src/`
- `.octon/framework/engine/runtime/spec/`
- `.octon/inputs/additive/extensions/octon-proposal-lifecycle/context/lifecycles/proposal-program.contract.yml`

## Workstreams

1. Define compact recovery receipt and event-summary fields.
2. Require targeted evidence refreshes instead of broad context reloads.
3. Group repeated failure evidence by blocker class, child, route, and disposition.
4. Keep direct child-owned receipt references instead of duplicating child evidence in parent prose.
5. Add validator or test coverage for compactness and replayability.

## Validation And Evidence

- Run touched runner, lifecycle executor, lifecycle contract, and runtime spec validators or tests.
- Run proposal standard validation for this packet.
- Record evidence comparing recovery summary shape before and after implementation where practical.
- Create or update `support/implementation-run.md` with `verdict`, `implemented_at`, and `promotion_evidence_count`.
- Create or update `support/implementation-conformance-review.md`, then run `validate-proposal-implementation-conformance.sh --package .octon/inputs/exploratory/proposals/architecture/token-efficiency-preservation`.
- Create or update `support/post-implementation-drift-churn-review.md`, then run `validate-proposal-post-implementation-drift.sh --package .octon/inputs/exploratory/proposals/architecture/token-efficiency-preservation`.

## Rollback

Rollback is removal or reversion of token-efficiency recovery evidence changes in the declared targets, followed by the same validators used for implementation.

## Terminal Criteria

Leave `proposal.yml#status` as `accepted`. Refuse closeout or archive claims while implementation-run, conformance, or drift/churn receipts are missing, failing, unresolved, or blocked.
