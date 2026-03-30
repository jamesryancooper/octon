# Constitutional Authority Contracts

`/.octon/framework/constitution/contracts/authority/**` defines the
constitutional authority-routing model for governed execution.

## Status

The authority family is fully active.

- normalized approval requests live under:
  `/.octon/state/control/execution/approvals/requests/**`
- normalized approval grants live under:
  `/.octon/state/control/execution/approvals/grants/**`
- normalized exception leases live under:
  `/.octon/state/control/execution/exceptions/**`
- normalized revocations live under:
  `/.octon/state/control/execution/revocations/**`
- normalized quorum policy semantics live under:
  `/.octon/framework/constitution/contracts/authority/quorum-policy-v1.schema.json`
  and the repo policy binding at
  `/.octon/instance/governance/policies/mission-autonomy.yml#quorum`
- retained authority decisions and grant bundles live under:
  `/.octon/state/evidence/control/execution/**`

## Final Rules

- Host labels, comments, checks, and similar UI state may mirror approval or
  blocker status, but they never become authority by themselves.
- Runtime resolves approval only from canonical `ApprovalRequest`,
  `ApprovalGrant`, revocation, exception, decision, and grant-bundle
  artifacts.

## Canonical Files

- `family.yml`
- `approval-request-v1.schema.json`
- `approval-grant-v1.schema.json`
- `exception-lease-v1.schema.json`
- `revocation-v1.schema.json`
- `quorum-policy-v1.schema.json`
- `decision-artifact-v1.schema.json`
- `grant-bundle-v1.schema.json`
