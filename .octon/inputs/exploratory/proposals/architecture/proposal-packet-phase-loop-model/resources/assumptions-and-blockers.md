# Assumptions And Blockers

## Assumptions

- The conversation-bound architecture decision is represented by the explicit
  constraints and intended lifecycle route in the operator request.
- The proposal should be scoped as one architecture packet under
  `.octon/inputs/exploratory/proposals/architecture/proposal-packet-phase-loop-model/`.
- The initial proposal status should be `draft`; review acceptance is a later
  lifecycle step.
- The correct placement is layered/both because generic runner mechanics and
  proposal route semantics need separate owners.
- Generated effective projections are useful for comparison, but not source
  authority.

## Blockers

There are no product-semantic blockers for proposal creation.

Implementation remains blocked until:

- this packet is reviewed and accepted;
- the implementation-grade completeness receipt remains passing;
- strict proposal-review authorization passes with a fresh digest;
- implementation prompt generation is routed through the governed proposal
  lifecycle;
- implementation run evidence is retained outside `inputs/**`.

## Deferred Decisions

The later implementation must decide the exact schema shape for `phases[]` and
whether current `loops:` remains a top-level field or gains phase-scoped
binding. That decision is implementation design detail, not a blocker for this
architecture proposal because both options preserve the same authority
boundary.
