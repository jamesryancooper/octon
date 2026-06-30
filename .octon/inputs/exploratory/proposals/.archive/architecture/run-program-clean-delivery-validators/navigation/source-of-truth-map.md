# Source Of Truth Map

## Durable Authorities

- `.octon/framework/assurance/runtime/_ops/scripts/validate-run-program-clean-delivery.sh`
  is the promoted read-only aggregate validator.
- `.octon/framework/assurance/runtime/_ops/tests/test-run-program-clean-delivery-validator.sh`
  is the promoted regression test.
- Existing validators called by the aggregate validator remain the owning
  authorities for their receipt families.

## Packet-Local Lifecycle Sources

- `proposal.yml` is the packet lifecycle manifest.
- `architecture-proposal.yml` is the architecture subtype manifest.
- `architecture/target-architecture.md` defines the validator boundary.
- `architecture/implementation-plan.md` defines the concrete implementation.
- `architecture/acceptance-criteria.md` defines pass/fail acceptance.
- `validation-plan.md` defines required validation.
- `support/affected-artifact-map.md` maps exact promotion targets.
- `support/proposal-review.md` and
  `support/pre-integration-architecture-review.yml` authorize implementation
  for this packet only.

## Derived Projections And Evidence

- Generated proposal registry and artifact-index outputs are derived-only.
- Lifecycle run evidence under `.octon/state/evidence/runs/**` is retained
  evidence, not packet authority.
- Proposal-local support receipts are packet evidence and do not satisfy
  delivery, archive, Change closeout, cleanup, branch cleanup, generated
  publication, or terminal proof gates.

## Boundary Rules

- Raw `inputs/**` proposal files never become runtime or policy authority.
- The aggregate validator may cite target-owned receipts but cannot replace
  them.
- Host state, chat, tool availability, and model memory are non-authority.
- Any failure routes to the owning lifecycle, closeout, archive, generated
  publication, cleanup, or validation route rather than authorizing mutation.
