# Child Packet Contract

## Child Authority

Each child packet owns its proposal manifest, review receipt, implementation evidence, validation verdicts, promotion targets, conformance review, drift/churn review, closeout evidence, and archive metadata.

Parent program artifacts may summarize child status but never replace child-owned receipts or child authority.

## Required Child Properties

- Each child is a sibling packet under `.octon/inputs/exploratory/proposals/architecture/`.
- Each child declares `change_profile: atomic`.
- Each child remains `status: draft` until independently reviewed.
- Each child includes implementation-grade completeness evidence.
- Each child must preserve generated and input non-authority boundaries.

## Shared Negative Constraint

No child may treat route-graph output, operator help text, generated summaries, proposal-local prompts, chat history, or model memory as authority for delivery, closeout, archive, cleanup, branch mutation, or terminal proof.
