# Executable Implementation Prompt

generated_at: 2026-06-04T14:44:25Z
generator_route_id: generate-packet-implementation-prompt
proposal_packet_path: .octon/inputs/exploratory/proposals/architecture/evidence-and-receipt-hardening
verdict: ready-for-execution

This prompt is operational guidance only. It is not authority, runtime truth,
generated-effective authority, or implementation proof.

## Gate Receipt

Run before implementation:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/evidence-and-receipt-hardening --require-implementation-authorization
```

Expected result: `errors=0 warnings=0`.

## Objective

Harden lifecycle evidence so autonomous recovery remains compact, replayable, and child-authority preserving.

## Promotion Targets

- `.octon/framework/engine/runtime/spec/`
- `.octon/framework/constitution/contracts/retention/`
- `.octon/framework/engine/runtime/crates/kernel/src/lifecycle_program.rs`
- `.octon/framework/assurance/runtime/_ops/scripts/`
- `.octon/framework/assurance/runtime/_ops/tests/`

## Workstreams

1. Require direct child-owned receipt references for child terminal claims.
2. Add replayable retained evidence pointers when control state is cleaned.
3. Add compact event summaries grouped by blocker class, child, route, and disposition.
4. Add validators or tests that reject parent-summary-only child proof.
5. Preserve generated and input non-authority boundaries.

## Validation And Evidence

- Run affected evidence contract, runtime spec, runner, and validator tests.
- Run proposal standard validation for this packet.
- Record negative-control evidence for parent-summary-only child proof.
- Create or update `support/implementation-run.md` with `verdict`, `implemented_at`, and `promotion_evidence_count`.
- Create or update `support/implementation-conformance-review.md`, then run `validate-proposal-implementation-conformance.sh --package .octon/inputs/exploratory/proposals/architecture/evidence-and-receipt-hardening`.
- Create or update `support/post-implementation-drift-churn-review.md`, then run `validate-proposal-post-implementation-drift.sh --package .octon/inputs/exploratory/proposals/architecture/evidence-and-receipt-hardening`.

## Rollback

Rollback is removal or reversion of evidence hardening changes in the declared targets, followed by the same validators used for implementation.

## Terminal Criteria

Leave `proposal.yml#status` as `accepted`. Refuse closeout or archive claims while implementation-run, conformance, or drift/churn receipts are missing, failing, unresolved, or blocked.
