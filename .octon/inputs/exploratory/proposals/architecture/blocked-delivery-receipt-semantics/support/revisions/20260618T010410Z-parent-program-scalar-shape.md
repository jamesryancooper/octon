# Revision Receipt: Parent Program Scalar Shape

revision_id: blocked-delivery-receipt-semantics-parent-program-scalar-shape-20260618T010410Z
status: complete
packet: .octon/inputs/exploratory/proposals/architecture/blocked-delivery-receipt-semantics
recorded_at: 2026-06-18T01:04:10Z

## Trigger

Child-only promotion was blocked because the canonical proposal artifact-index
generator expects `proposal.yml#parent_program` to be a scalar parent proposal
identifier. This child packet used a structured object for that field, causing
the generator to raise a Python `TypeError` before terminal freshness could be
checked.

## Route Chosen

The correction uses the packet-local revision route. The child manifest now
records:

```yaml
parent_program: "operator-free-packet-lifecycle-autonomy"
```

This is the smallest governed route because it updates only this child packet's
proposal-local manifest shape and avoids changing
`.octon/framework/assurance/runtime/_ops/scripts/generate-proposal-artifact-index.sh`,
which is outside this child's declared durable `promotion_targets`.

## Files Changed

- `.octon/inputs/exploratory/proposals/architecture/blocked-delivery-receipt-semantics/proposal.yml`
- `.octon/inputs/exploratory/proposals/architecture/blocked-delivery-receipt-semantics/support/revisions/20260618T010410Z-parent-program-scalar-shape.md`
- `.octon/inputs/exploratory/proposals/architecture/blocked-delivery-receipt-semantics/support/correction-prompts/promotion-artifact-index-parent-program-shape.md`

## Review Requirement

Because `proposal.yml` changed, the child packet review and strict
pre-integration architecture review receipts must be refreshed against the new
packet digest before promotion is retried.

## Evidence Boundary

This revision does not promote the child, does not promote the parent program,
does not close out, archive, publish, land, clean, delete retained evidence, or
claim `cleaned`.
