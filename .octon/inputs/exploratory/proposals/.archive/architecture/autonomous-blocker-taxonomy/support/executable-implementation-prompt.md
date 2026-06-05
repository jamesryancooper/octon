# Executable Implementation Prompt

generated_at: 2026-06-04T14:44:25Z
generator_route_id: generate-packet-implementation-prompt
proposal_packet_path: .octon/inputs/exploratory/proposals/architecture/autonomous-blocker-taxonomy
verdict: ready-for-execution

This prompt is operational guidance only. It is not authority, runtime truth,
generated-effective authority, or implementation proof.

## Gate Receipt

Run before implementation:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/autonomous-blocker-taxonomy --require-implementation-authorization
```

Expected result: `errors=0 warnings=0`.

## Objective

Implement the lifecycle-specific blocker taxonomy for routine-autonomous,
soft-blocker, and hard-blocker recovery classes.

## Promotion Targets

- `.octon/framework/engine/runtime/spec/`
- `.octon/framework/cognition/_meta/architecture/inputs/additive/extensions/schemas/extension-lifecycle-contract.schema.json`
- `.octon/inputs/additive/extensions/octon-proposal-lifecycle/context/lifecycles/proposal-program.contract.yml`
- `.octon/inputs/additive/extensions/octon-proposal-lifecycle/context/lifecycle-model.md`

## Workstreams

1. Add the smallest durable taxonomy surface to existing lifecycle specs or contracts.
2. Map enum drift, stale receipts, stale digests, freshness drift, cleanup residue, retryable preflight failures, and continuable step exhaustion to routine or soft recovery.
3. Preserve the hard-blocker list for destructive, ownership, missing child authority, parent-summary-only proof, unsupported scope, external permission, and unrecoverable validation cases.
4. Add validation or test coverage that proves hard blockers remain fail-closed.

## Validation And Evidence

- Run targeted lifecycle contract/spec validators touched by the implementation.
- Run proposal standard validation for this packet.
- Record retained evidence or receipt references for every behavior claim.
- Create or update `support/implementation-run.md` with `verdict`, `implemented_at`, and `promotion_evidence_count`.
- Create or update `support/implementation-conformance-review.md`, then run `validate-proposal-implementation-conformance.sh --package .octon/inputs/exploratory/proposals/architecture/autonomous-blocker-taxonomy`.
- Create or update `support/post-implementation-drift-churn-review.md`, then run `validate-proposal-post-implementation-drift.sh --package .octon/inputs/exploratory/proposals/architecture/autonomous-blocker-taxonomy`.

## Rollback

Rollback is removal or reversion of taxonomy additions in the declared promotion targets, followed by the same validators used for implementation.

## Terminal Criteria

Leave `proposal.yml#status` as `accepted`. Refuse closeout or archive claims while implementation-run, conformance, or drift/churn receipts are missing, failing, unresolved, or blocked.
