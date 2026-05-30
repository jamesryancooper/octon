# Executable Implementation Prompt: Local Evidence Store Boundary

proposal_path: `.octon/inputs/exploratory/proposals/architecture/local-evidence-store-boundary`
next_route: `run-packet-implementation`

## Implementation Scope

Implement only the accepted child packet for `local-evidence-store-boundary`. Do not implement
other children in this packet's change set.

Promotion targets:

- `.octon/state/evidence/local/README.md`
- `.octon/state/evidence/.gitignore`
- `.octon/instance/governance/policies/repo-hygiene.yml`

## Workstreams

1. Create `.octon/state/evidence/local/README.md` with allowed contents, forbidden consumers, and promotion route.
2. Create `.octon/state/evidence/.gitignore` with `local/**` and narrow exceptions only if durable marker files must be tracked.
3. Update repo-hygiene policy so local evidence is protected from generic cleanup and excluded from hosted closeout evidence gates.
4. Define the operator rule for local archive retention versus explicit discard.

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
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/local-evidence-store-boundary --skip-registry-check --skip-promotion-target-checks
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/local-evidence-store-boundary
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/local-evidence-store-boundary --require-implementation-authorization
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-conformance.sh --package .octon/inputs/exploratory/proposals/architecture/local-evidence-store-boundary
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-post-implementation-drift.sh --package .octon/inputs/exploratory/proposals/architecture/local-evidence-store-boundary
```

Also run child-specific validators or add them if this implementation creates
new validator surfaces:

- `validate-proposal-standard.sh`
- `validate-architecture-proposal.sh`
- `future local evidence ignore validator`
- `validate-repo-hygiene-governance.sh`

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

Remove the local README, scoped ignore rule, and repo-hygiene references if the local root creates ambiguity or blocks required evidence retention.

## Terminal Criteria

Implementation is complete only when promoted files exist where required,
validation passes, and both required receipts pass. Refuse closeout/archive
claims until `support/implementation-conformance-review.md` and
`support/post-implementation-drift-churn-review.md` exist, pass their
validators, and confirm no unresolved authority-boundary risk remains.
