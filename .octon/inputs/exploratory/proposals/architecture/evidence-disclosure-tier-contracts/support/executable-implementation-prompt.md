# Executable Implementation Prompt: Evidence Disclosure Tier Contracts

proposal_path: `.octon/inputs/exploratory/proposals/architecture/evidence-disclosure-tier-contracts`
next_route: `run-packet-implementation`

## Implementation Scope

Implement only the accepted child packet for `evidence-disclosure-tier-contracts`. Do not implement
other children in this packet's change set.

Promotion targets:

- `.octon/framework/constitution/contracts/retention/evidence-disclosure-tiers-v1.yml`
- `.octon/framework/engine/runtime/spec/evidence-disclosure-tiers-v1.md`
- `.octon/framework/engine/runtime/spec/evidence-store-v1.md`
- `.octon/framework/constitution/obligations/evidence.yml`

## Workstreams

1. Add `evidence-disclosure-tiers-v1.yml` with tier ids, allowed roots, Git posture, authority roles, promotion rule, and forbidden consumers.
2. Add `evidence-disclosure-tiers-v1.md` explaining the operator-facing model and path semantics.
3. Revise `evidence-store-v1.md` so retained evidence no longer implies publishable raw transcript completeness.
4. Update `evidence.yml` obligations so consequential evidence records carry tier classification where publication or closeout claims depend on them.

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
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/evidence-disclosure-tier-contracts --skip-registry-check --skip-promotion-target-checks
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/evidence-disclosure-tier-contracts
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/evidence-disclosure-tier-contracts --require-implementation-authorization
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-conformance.sh --package .octon/inputs/exploratory/proposals/architecture/evidence-disclosure-tier-contracts
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-post-implementation-drift.sh --package .octon/inputs/exploratory/proposals/architecture/evidence-disclosure-tier-contracts
```

Also run child-specific validators or add them if this implementation creates
new validator surfaces:

- `validate-proposal-standard.sh`
- `validate-architecture-proposal.sh`
- `validate-evidence-obligation-ids.sh`
- `future evidence disclosure tier contract validator`

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

Revert the new tier contract, runtime prose updates, and obligation deltas if they weaken current evidence-store completeness or make generated views authoritative.

## Terminal Criteria

Implementation is complete only when promoted files exist where required,
validation passes, and both required receipts pass. Refuse closeout/archive
claims until `support/implementation-conformance-review.md` and
`support/post-implementation-drift-churn-review.md` exist, pass their
validators, and confirm no unresolved authority-boundary risk remains.
