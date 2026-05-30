# Executable Implementation Prompt: Publishable Evidence Receipts

proposal_path: `.octon/inputs/exploratory/proposals/architecture/publishable-evidence-receipts`
next_route: `run-packet-implementation`

## Implementation Scope

Implement only the accepted child packet for `publishable-evidence-receipts`. Do not implement
other children in this packet's change set.

Promotion targets:

- `.octon/framework/constitution/contracts/retention/publishable-evidence-receipt-v1.schema.json`
- `.octon/framework/constitution/contracts/retention/evidence-disclosure-tiers-v1.yml`
- `.octon/framework/product/contracts/`
- `.octon/state/evidence/runs/README.md`
- `.octon/state/evidence/runs/skills/publishable-evidence-receipts/example-run/publishable-receipt.json`

## Workstreams

1. Add `publishable-evidence-receipt-v1.schema.json` with required claim, validation, redaction, limitation, outcome, local reference, and rollback fields.
2. Update the tier contract with the receipt tier id and local reference requirements.
3. Add product-contract references where closeout and repo-hygiene receipts become publishable claim evidence.
4. Define example receipt placement under `.octon/state/evidence/runs/skills/<skill>/<run-id>/publishable-receipt.json`.

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
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/publishable-evidence-receipts --skip-registry-check --skip-promotion-target-checks
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/publishable-evidence-receipts
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/publishable-evidence-receipts --require-implementation-authorization
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-conformance.sh --package .octon/inputs/exploratory/proposals/architecture/publishable-evidence-receipts
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-post-implementation-drift.sh --package .octon/inputs/exploratory/proposals/architecture/publishable-evidence-receipts
```

Also run child-specific validators or add them if this implementation creates
new validator surfaces:

- `validate-proposal-standard.sh`
- `validate-architecture-proposal.sh`
- `future publishable receipt schema validator`
- `future publishable receipt concision validator`

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

Revert the schema and closeout references if receipts cannot prove claims without requiring raw evidence publication.

## Terminal Criteria

Implementation is complete only when promoted files exist where required,
validation passes, and both required receipts pass. Refuse closeout/archive
claims until `support/implementation-conformance-review.md` and
`support/post-implementation-drift-churn-review.md` exist, pass their
validators, and confirm no unresolved authority-boundary risk remains.
