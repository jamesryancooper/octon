# Executable Implementation Prompt

route_id: run-packet-implementation
proposal_id: proposal-churn-retained-run-evidence-efficiency
authorized_by: support/proposal-review.md

## Goal

Implement the accepted retained evidence efficiency packet without weakening
retained evidence, control truth, continuity, closeout, disclosure, or cleanup
authority.

## Authorized Promotion Targets

- `.octon/framework/engine/runtime/spec/evidence-store-v1.md`
- `.octon/framework/assurance/runtime/_ops/scripts/generate-retained-run-evidence-index.sh`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-retained-run-evidence-index.sh`
- `.octon/framework/assurance/runtime/_ops/scripts/cleanup-local-run-artifacts.sh`
- `.octon/framework/assurance/runtime/_ops/tests/`

## Workstreams

1. Improve retained-run evidence indexes as discovery and replay aids only.
   Add retrieval or coverage metrics that make retained proof cheaper to
   inspect without replacing source receipts or raw evidence.
2. Improve cleanup dry-run reporting so retained evidence, active control
   state, continuity, cleanup candidates, and manual-review paths remain
   visibly separated.
3. Add or update tests for reference integrity, generated-index substitution
   refusal, cleanup candidate separation, and retained evidence/control
   protection.
4. Update evidence-store documentation only to describe the durable
   non-authority boundary and reporting behavior implemented here.

## Hard Boundaries

- Do not delete retained evidence.
- Do not mutate control truth.
- Do not weaken continuity guarantees.
- Do not use generated indexes as retained proof, child receipts, closeout
  evidence, control truth, support proof, or authority.
- Do not widen promotion targets.
- Do not hand-edit generated/effective outputs.
- Do not claim closeout, archive readiness, branch landing, cleanup, or a
  `cleaned` worktree from this implementation route.

## Required Validation

Run and record results for:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-churn-retained-run-evidence-efficiency
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-churn-retained-run-evidence-efficiency
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-churn-retained-run-evidence-efficiency --require-implementation-authorization
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-churn-retained-run-evidence-efficiency
bash .octon/framework/assurance/runtime/_ops/tests/test-retained-run-evidence-index.sh
bash .octon/framework/assurance/runtime/_ops/tests/test-generate-retained-run-evidence-index.sh
bash .octon/framework/assurance/runtime/_ops/tests/test-cleanup-local-run-artifacts.sh
bash .octon/framework/assurance/runtime/_ops/scripts/cleanup-local-run-artifacts.sh --summary-only
```

Also run retained-run evidence index validation against a materialized fixture
index and run reference-integrity checks or tests that prove generated indexes
cannot replace retained proof.

## Evidence To Produce

After implementation, write or refresh:

- `support/implementation-run.md`
- `support/implementation-conformance-review.md`
- `support/post-implementation-drift-churn-review.md`
- `support/validation.md`

`support/implementation-conformance-review.md` and
`support/post-implementation-drift-churn-review.md` must record
`verdict: pass` and `unresolved_items_count: 0` before any closeout or archive
claim.

## Rollback

Rollback is limited to the documentation, generator, validator, cleanup helper,
and test changes in the authorized promotion targets. Existing retained
evidence and control truth must be left intact. Supersede retained indexes with
newer governed indexes rather than deleting retained proof casually.

## Closeout Refusal Criteria

Refuse closeout or archive claims when implementation conformance is missing,
post-implementation drift/churn review is missing, unresolved items are
nonzero, retained evidence deletion is attempted, control truth is mutated, or
generated indexes are treated as authority or retained proof.
