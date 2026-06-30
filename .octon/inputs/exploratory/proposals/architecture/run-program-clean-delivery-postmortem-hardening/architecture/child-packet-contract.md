# Child Packet Contract

Each child packet is a sibling proposal under
`.octon/inputs/exploratory/proposals/architecture/` and remains child-owned.

## Required Child Evidence

- Proposal manifest and architecture proposal manifest.
- Target architecture, implementation plan, acceptance criteria, validation
  plan, source lineage, and navigation artifacts.
- Implementation-grade completeness receipt before review acceptance.
- Accepted proposal review and strict pre-integration architecture review
  before implementation.
- Child-owned implementation, conformance, drift/churn, validation, closeout,
  and archive evidence before parent closeout.

## Boundaries

- Parent evidence may summarize child evidence, but cannot satisfy it.
- Child durable changes must stay inside child promotion targets unless a
  child revision expands scope.
- Generated outputs must be refreshed only through canonical generators.
- Cleanup detection is routing evidence only and does not authorize deletion.
- Manual Git or hosted actions must be reconciled through Change closeout or
  explicitly downgraded.
- Terminal delivery claims must cite delivery and Change receipts, not parent
  lifecycle summaries.
