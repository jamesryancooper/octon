# Executable Implementation Prompt: Evidence Residue Migration Closeout

proposal_path: `.octon/inputs/exploratory/proposals/architecture/evidence-residue-migration-closeout`
next_route: `run-packet-implementation`

## Implementation Scope

Implement only the accepted child packet for `evidence-residue-migration-closeout`. Do not implement
other children in this packet's change set.

Promotion targets:

- `.octon/state/evidence/local/evidence-residue-migration-closeout/20260529T213346Z/`
- `.octon/state/evidence/runs/skills/evidence-residue-migration-closeout/20260529T213346Z/`
- `.octon/state/evidence/disclosure/runs/lifecycle-proposal-program-1780090167014-7a1ddc40-evidence-residue-migration-closeout/`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-evidence-residue-migration-closeout.sh`

## Workstreams

1. Inventory current `.octon/state/evidence/runs/skills/**` cleanup and closeout evidence and classify raw versus publishable material.
2. Create a migration decision table for move-to-local, keep-publishable, replace-with-receipt, retain-with-rationale, or discard-after-archive.
3. Generate publishable replacement receipts for any hosted/shared claim that would otherwise point to local-only evidence.
4. Run validators and record aggregate parent closeout evidence without satisfying child receipts from parent evidence.

## Authority Boundaries

- Do not use proposal-local files as runtime, policy, support, evidence, or
  closeout authority.
- Do not publish raw local evidence.
- Do not make generated read models authoritative.
- Do not satisfy child receipts with parent program evidence.
- Do not claim closeout or archive readiness until post-implementation receipts
  pass.

## Validation

Run these checks at minimum:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/evidence-residue-migration-closeout --skip-registry-check --skip-promotion-target-checks
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/evidence-residue-migration-closeout
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/evidence-residue-migration-closeout --require-implementation-authorization
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-conformance.sh --package .octon/inputs/exploratory/proposals/architecture/evidence-residue-migration-closeout
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-post-implementation-drift.sh --package .octon/inputs/exploratory/proposals/architecture/evidence-residue-migration-closeout
```

Also run child-specific validators or add them if this implementation creates
new validator surfaces:

- `validate-proposal-standard.sh`
- `validate-architecture-proposal.sh`
- `future evidence residue migration validator`
- `validate-proposal-program-structure.sh`

## Evidence And Receipts

After implementation, produce:

- `support/implementation-conformance-review.md`
- `support/post-implementation-drift-churn-review.md`

The conformance receipt must name every promoted file, cover every promotion
target above, record validators run, and explain how the implementation
preserves evidence tier boundaries.

The drift/churn receipt must scan for proposal-path backreferences, naming
conflicts, generated-output authority drift, stale evidence assumptions, and
unnecessary churn.

## Rollback Posture

Restore from local archive or retain old publishable evidence paths if migration produces weaker claim proof.

## Terminal Criteria

Implementation is complete only when promoted files exist where required,
validation passes, and both required receipts pass. Refuse closeout/archive
claims until `support/implementation-conformance-review.md` and
`support/post-implementation-drift-churn-review.md` exist, pass their
validators, and confirm no unresolved authority-boundary risk remains.
