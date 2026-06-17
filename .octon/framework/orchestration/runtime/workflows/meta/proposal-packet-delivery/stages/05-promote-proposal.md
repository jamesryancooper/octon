# Stage 05: Promote Proposal

Route implemented status through `promote-proposal`.

Required checks:

- `promote-proposal` owns the implemented status transition.
- Promotion evidence points only to durable repository targets.
- The proposal manifest status is `implemented` before terminal closeout or
  archive routing.
- Generated proposal registry and artifact projections are refreshed through
  owning generators after promotion.
- Missing, stale, denied, or mismatched promotion receipts block delivery.
