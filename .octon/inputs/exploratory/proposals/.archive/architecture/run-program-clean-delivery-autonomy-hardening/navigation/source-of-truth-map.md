# Source Of Truth Map

## Authoritative Inputs For Future Implementation

- Constitutional kernel under `.octon/framework/constitution/**`.
- Product and Change policy contracts under `.octon/framework/product/contracts/**`.
- Runtime workflow, lifecycle, closeout, and capability contracts under
  `.octon/framework/**`.
- Validated receipts and live repo state produced by child-owned routes.

## Non-Authority Inputs

- This parent proposal and sibling child proposals are planning inputs only.
- Postmortem prose, chat history, generated read models, local dashboards, and
  host UI state may inform implementation but cannot authorize side effects.
- Generated run-health projections are diagnostic unless a route-owned receipt
  promotes a specific path and digest.

## Claim Boundaries

- Parent summaries do not satisfy child-owned authority.
- Classifiers detect residue but do not authorize deletion.
- Landing authorization receipts may authorize hosted mutation only when fresh,
  exact-SHA-bound, provider-rule-complete, and consumed by the approved route.
