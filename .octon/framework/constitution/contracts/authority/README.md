# Constitutional Authority Contracts

`/.octon/framework/constitution/contracts/authority/**` defines the
constitutional authority-routing model for governed execution.

## Status

The authority family is fully active.

- normalized approval requests live under:
  `/.octon/state/control/execution/approvals/requests/**`
- normalized approval grants live under:
  `/.octon/state/control/execution/approvals/grants/**`
- authority zone decisions are retained under the current run or control
  evidence roots before governed dispatch
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
- Runtime resolves autonomous execution only after an Authority Zone decision
  proves the operation, path, artifact ownership, write scope, run binding,
  idempotency posture, and evidence requirement are allowed. A `.octon/` path
  prefix is not an authority grant by itself.
- Shared delegated-governance contracts may classify a surface as delegated
  execution, typed human exception, deny-only, projection-only, generated
  non-authority, grant consumption, or evidence-gap posture. They do not create
  authority by route shape, workflow shape, extension shape, adapter shape, or
  generic importance.
- Grant consumption is delegated execution against an already-bound grant; it
  never mints fresh authority.

## Canonical Files

- `family.yml`
- `approval-request-v1.schema.json`
- `approval-grant-v1.schema.json`
- `authority-zone-v1.schema.json`
- `authority-zone-policy.yml`
- `exception-lease-v1.schema.json`
- `revocation-v1.schema.json`
- `quorum-policy-v1.schema.json`
- `decision-artifact-v1.schema.json`
- `grant-bundle-v1.schema.json`
- `delegated-governance-contract-v1.schema.json`

## Canonical Roots

- approval requests: `/.octon/state/control/execution/approvals/requests/**`
- approval grants: `/.octon/state/control/execution/approvals/grants/**`
- exception leases: `/.octon/state/control/execution/exceptions/**`
- revocations: `/.octon/state/control/execution/revocations/**`
- retained authority evidence: `/.octon/state/evidence/control/execution/**`

## Compatibility/Historical Surfaces

No active compatibility-only authority schemas are expected in the live path.

## Non-Authority Note

Host labels, comments, checks, and workflow-native state may mirror authority
status, but they never mint authority by themselves.

Generated outputs and read models may satisfy evidence gates only when a
contract explicitly permits that use. They remain forbidden as authority,
policy, support, control, promotion, closeout, or terminal truth sources.

## Validator Obligations

- `verify-host-authority-purity.sh`
- `validate-projection-shell-boundaries.sh`
