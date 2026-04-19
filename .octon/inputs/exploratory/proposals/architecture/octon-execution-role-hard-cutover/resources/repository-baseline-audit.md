# Repository Baseline Audit

This audit integrates five bounded specialist passes: proposal contract audit,
repository baseline audit, runtime/authorization audit, support/browser/API/proof
audit, and architecture synthesis. The outputs are integrated here rather than
kept as separate durable reports.

## Proposal contract audit

The live proposal workspace requires active proposals under
`/.octon/inputs/exploratory/proposals/<kind>/<proposal_id>/`; the final
directory name must match `proposal_id`; every manifest-governed proposal must
include `proposal.yml`, exactly one subtype manifest, `README.md`,
`navigation/source-of-truth-map.md`, and `navigation/artifact-catalog.md`;
architecture proposals require `architecture-proposal.yml`,
`architecture/target-architecture.md`, `architecture/acceptance-criteria.md`,
and `architecture/implementation-plan.md`.

This packet follows that contract.

## Repository baseline audit

The repo already has the correct super-root model. `.octon/README.md` states
that `.octon` is class-first and that only `framework/**` and `instance/**` are
authored authority. It also classifies `state/**` into continuity, evidence, and
control, and `generated/**` as rebuildable only.

## Agency baseline

Current agency spec still preserves `agents`, `assistants`, and `teams`, while
removing subagents as a first-class artifact. Under the target state this is
obsolete. It must be replaced by execution roles.

## Runtime and authorization baseline

Execution authorization is strong: all material execution must pass through
`authorize_execution(request) -> GrantBundle`; material side effects require a
grant; receipts are mandatory; support-tier routing, reversibility, budget,
egress, context-pack provenance, risk/materiality, rollback posture, and
capability-pack admission participate in authorization.

## Support/browser/API/proof baseline

`support-targets.yml` now uses schema-valid `bounded-admitted-finite`, but
charter mode still carries the `-product` suffix. The runtime service manifest
does not include browser-session or API-client services. Browser/API support
must therefore remain non-live unless services and proof are added.

## Lab/observability baseline

The lab and observability surfaces already cover scenario proof, replay, shadow
runs, adversarial probes, intervention accounting, measurement, drift incidents,
and report bundles. The target state requires making those surfaces
release-blocking and evidence-producing.
