# Executable Implementation Prompt: Closeout Repo Hygiene Evidence Flow

proposal_path: `.octon/inputs/exploratory/proposals/architecture/closeout-repo-hygiene-evidence-flow`
next_route: `run-packet-implementation`

## Implementation Scope

Implement only the accepted child packet for `closeout-repo-hygiene-evidence-flow`. Do not implement
other children in this packet's change set.

Promotion targets:

- `.octon/framework/capabilities/runtime/skills/remediation/closeout-change/SKILL.md`
- `.octon/framework/capabilities/runtime/skills/remediation/repo-hygiene-cleanup/SKILL.md`
- `.octon/framework/product/contracts/default-work-unit.yml`
- `.octon/instance/governance/policies/repo-hygiene.yml`
- `.octon/framework/assurance/runtime/_ops/scripts/`

## Workstreams

1. Update closeout-change guidance to require publishable receipts for hosted/shared closeout claims.
2. Update repo-hygiene-cleanup guidance to split raw local logs from publishable receipts.
3. Update default work unit and repo-hygiene policy references so routine cleanup can remain audited without publishing raw logs.
4. Add validation hooks proving hosted branch-no-pr cleaned claims do not require local-only evidence.

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
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/closeout-repo-hygiene-evidence-flow --skip-registry-check --skip-promotion-target-checks
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/closeout-repo-hygiene-evidence-flow
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/closeout-repo-hygiene-evidence-flow --require-implementation-authorization
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-conformance.sh --package .octon/inputs/exploratory/proposals/architecture/closeout-repo-hygiene-evidence-flow
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-post-implementation-drift.sh --package .octon/inputs/exploratory/proposals/architecture/closeout-repo-hygiene-evidence-flow
```

Also run child-specific validators or add them if this implementation creates
new validator surfaces:

- `validate-proposal-standard.sh`
- `validate-architecture-proposal.sh`
- `validate-repo-hygiene-governance.sh`
- `future hosted closeout publishable evidence validator`

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

Revert closeout and repo-hygiene guidance if it prevents required closeout evidence or collapses lifecycle boundaries.

## Terminal Criteria

Implementation is complete only when promoted files exist where required,
validation passes, and both required receipts pass. Refuse closeout/archive
claims until `support/implementation-conformance-review.md` and
`support/post-implementation-drift-churn-review.md` exist, pass their
validators, and confirm no unresolved authority-boundary risk remains.
