# Constitutional Authority Contracts

`/.octon/framework/constitution/contracts/authority/**` defines the
constitutional authority-routing model for governed execution.

## Wave 2 Status

Wave 2 normalizes approval, exception, revocation, decision, and grant-bundle
artifacts without bypassing the existing engine-owned execution boundary.

- normalized approval requests live under:
  `/.octon/state/control/execution/approvals/requests/**`
- normalized approval grants live under:
  `/.octon/state/control/execution/approvals/grants/**`
- normalized exception leases live under:
  `/.octon/state/control/execution/exceptions/**`
- normalized revocations live under:
  `/.octon/state/control/execution/revocations/**`
- retained authority decisions and grant bundles live under:
  `/.octon/state/evidence/control/execution/**`

## Transitional Rules

- Host labels, comments, checks, and similar UI state may project approval
  intent, but they never become authority by themselves.
- The runtime may materialize host or environment approval projections into
  canonical `ApprovalGrant` artifacts during the coexistence window.
- Legacy root-level exception-lease files remain compatibility projections
  while the canonical exception root moves under `state/control/execution/exceptions/**`.

## Canonical Files

- `family.yml`
- `approval-request-v1.schema.json`
- `approval-grant-v1.schema.json`
- `exception-lease-v1.schema.json`
- `revocation-v1.schema.json`
- `decision-artifact-v1.schema.json`
- `grant-bundle-v1.schema.json`
