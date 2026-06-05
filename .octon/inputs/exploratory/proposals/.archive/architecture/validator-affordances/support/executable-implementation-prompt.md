# Executable Implementation Prompt

generated_at: 2026-06-04T14:44:25Z
generator_route_id: generate-packet-implementation-prompt
proposal_packet_path: .octon/inputs/exploratory/proposals/architecture/validator-affordances
verdict: ready-for-execution

This prompt is operational guidance only. It is not authority, runtime truth,
generated-effective authority, or implementation proof.

## Gate Receipt

Run before implementation:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/validator-affordances --require-implementation-authorization
```

Expected result: `errors=0 warnings=0`.

## Objective

Add compact machine-readable validator diagnostics that lifecycle runners can use for bounded recovery decisions.

## Promotion Targets

- `.octon/framework/assurance/runtime/_ops/scripts/`
- `.octon/framework/assurance/runtime/_ops/tests/`
- `.octon/inputs/additive/extensions/octon-proposal-lifecycle/validation/tests/`

## Workstreams

1. Inventory proposal-program lifecycle validators that emit blocker or freshness failures.
2. Add diagnostics such as `recovery_class`, `failing_path`, `observed_value`, `accepted_values`, `stale_source_ref`, `expected_digest`, `minimal_repair_hint`, `rerun_gate`, and `hard_blocker_reason`.
3. Ensure validators recommend repairs only; validators must not mutate files.
4. Add positive and negative fixture tests for enum drift, stale evidence, freshness drift, and hard blockers.

## Validation And Evidence

- Run affected assurance script tests.
- Run proposal lifecycle validation tests touched by the implementation.
- Run proposal standard validation for this packet.
- Create or update `support/implementation-run.md` with `verdict`, `implemented_at`, and `promotion_evidence_count`.
- Create or update `support/implementation-conformance-review.md`, then run `validate-proposal-implementation-conformance.sh --package .octon/inputs/exploratory/proposals/architecture/validator-affordances`.
- Create or update `support/post-implementation-drift-churn-review.md`, then run `validate-proposal-post-implementation-drift.sh --package .octon/inputs/exploratory/proposals/architecture/validator-affordances`.

## Rollback

Rollback is removal or reversion of validator diagnostic and fixture changes in the declared targets, followed by the same validators used for implementation.

## Terminal Criteria

Leave `proposal.yml#status` as `accepted`. Refuse closeout or archive claims while implementation-run, conformance, or drift/churn receipts are missing, failing, unresolved, or blocked.
