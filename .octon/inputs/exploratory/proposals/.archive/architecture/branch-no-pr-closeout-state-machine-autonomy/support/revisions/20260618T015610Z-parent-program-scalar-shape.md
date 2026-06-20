# Revision Receipt: Parent Program Scalar Shape

revision_id: branch-no-pr-closeout-state-machine-autonomy-parent-program-scalar-shape-20260618T015610Z
status: complete
packet: .octon/inputs/exploratory/proposals/architecture/branch-no-pr-closeout-state-machine-autonomy
recorded_at: 2026-06-18T01:56:10Z

## Trigger

The prior child promotion route proved that the canonical proposal
artifact-index generator expects `proposal.yml#parent_program` to be a scalar
parent proposal identifier. This child packet used the same structured object
shape that caused the first child promotion blocker.

## Route Chosen

The correction uses the packet-local revision route. The child manifest now
records:

```yaml
parent_program: "operator-free-packet-lifecycle-autonomy"
```

This updates only this child packet's proposal-local manifest shape. It does
not change framework generators, the parent program, durable implementation
targets, archive state, closeout state, branch state, cleanup state, or
retained evidence.

## Files Changed

- `.octon/inputs/exploratory/proposals/architecture/branch-no-pr-closeout-state-machine-autonomy/proposal.yml`
- `.octon/inputs/exploratory/proposals/architecture/branch-no-pr-closeout-state-machine-autonomy/support/revisions/20260618T015610Z-parent-program-scalar-shape.md`

## Review Requirement

Because `proposal.yml` changed, the child packet review and strict
pre-integration architecture review receipts must be refreshed against the new
packet digest before implementation prompt generation and promotion.

## Evidence Boundary

This revision does not implement, promote, close out, archive, publish, land,
clean, delete, or claim `cleaned` for this child or the parent program.
