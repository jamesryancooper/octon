# Executable Implementation Prompt: Evidence Tier Validator Gates

proposal_path: `.octon/inputs/exploratory/proposals/architecture/evidence-tier-validator-gates`
next_route: `run-packet-implementation`

## Implementation Scope

Implement only the accepted child packet for `evidence-tier-validator-gates`. Do not implement
other children in this packet's change set.

Promotion targets:

- `.octon/framework/assurance/runtime/_ops/scripts/`
- `.octon/framework/assurance/runtime/_ops/tests/`
- `.octon/framework/constitution/contracts/retention/`

## Workstreams

1. Add or extend assurance validators for local evidence tracking, receipt schema fields, concision thresholds, and hosted closeout checks.
2. Add fixture tests for valid publishable receipts, tracked local evidence denial, missing tier metadata, oversized evidence, and local-only closeout dependency denial.
3. Wire validators into the relevant governance or closeout validation profile without making proposal paths authoritative.
4. Document validator failure modes and remediation routes.

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
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/evidence-tier-validator-gates --skip-registry-check --skip-promotion-target-checks
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/evidence-tier-validator-gates
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/evidence-tier-validator-gates --require-implementation-authorization
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-conformance.sh --package .octon/inputs/exploratory/proposals/architecture/evidence-tier-validator-gates
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-post-implementation-drift.sh --package .octon/inputs/exploratory/proposals/architecture/evidence-tier-validator-gates
```

Also run child-specific validators or add them if this implementation creates
new validator surfaces:

- `validate-proposal-standard.sh`
- `validate-architecture-proposal.sh`
- `future validate-evidence-disclosure-tiers.sh`
- `future test-validate-evidence-disclosure-tiers.sh`

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

Remove or narrow validator gates if they block existing required evidence without improving publication safety.

## Terminal Criteria

Implementation is complete only when promoted files exist where required,
validation passes, and both required receipts pass. Refuse closeout/archive
claims until `support/implementation-conformance-review.md` and
`support/post-implementation-drift-churn-review.md` exist, pass their
validators, and confirm no unresolved authority-boundary risk remains.
