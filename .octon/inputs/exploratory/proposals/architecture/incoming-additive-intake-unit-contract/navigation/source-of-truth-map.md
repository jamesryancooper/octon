# Source Of Truth Map

## Packet-Local Authority

- `proposal.yml` is the draft proposal manifest.
- `architecture-proposal.yml` is the architecture subtype manifest.
- `architecture/target-architecture.md` defines the proposed intake-unit
  contract.
- `architecture/implementation-plan.md` defines the later promotion route.
- `architecture/acceptance-criteria.md` defines the proposal acceptance gate.
- `support/implementation-grade-completeness-review.md` records whether the
  draft is complete enough to implement after governance approval.
- `support/proposal-review.md` records the packet-local review verdict and
  implementation prompt authorization.
- `support/executable-implementation-prompt.md` is an operational aid for the
  authorized implementation route. It does not create durable authority.
- `support/follow-up-verification-prompt.md` is an operational aid for the
  verification and correction loop. It does not create durable authority.
- `support/implementation-run.md` records the implementation run boundary,
  scope, and focused validation receipts.
- `support/implementation-conformance-review.md` records implementation
  conformance against the accepted packet.
- `support/post-implementation-drift-churn-review.md` records drift and churn
  checks after implementation.
- `support/validation.md` records final validator outcomes.
- `support/proposal-closeout.md` records the closeout verdict, archive
  authorization boundary, and worktree hygiene blocker state.

## Supporting Material

- `README.md` summarizes the packet.
- `navigation/artifact-catalog.md` inventories visible packet files.
- `resources/source-evidence.md` records source surfaces consulted.
- `architecture/current-state-gap-map.md` maps current behavior to proposed
  contract changes.
- `validation-plan.md` records proposal and implementation validation.
- `RISK-REGISTER.md` records lifecycle and safety risks.

## Durable Authority Boundary

If accepted and promoted, durable authority may change only in the promotion
targets listed in `proposal.yml`. Until then, current Octon input, governance,
workflow, command, and validator surfaces remain canonical.

## Non-Authority Boundary

This packet, `.incoming/**`, `.archive/**`, generated projections, host
projections, external workflow dashboards, and agent summaries do not become
runtime, policy, generated, retained evidence, state/control, publication, or
host-projection authority by reference.
