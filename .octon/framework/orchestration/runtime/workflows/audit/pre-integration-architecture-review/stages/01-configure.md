---
title: Configure Pre-Integration Architecture Review
---

Resolve `proposal_path`, confirm it is an architecture proposal, and load the
Balanced Architecture Review Method, naming model, routing model, proposal
manifest, architecture manifest, source-of-truth map, and validation plan.

## Method selection (advisory, non-authority)

Select exactly one review method and record it in run evidence.
`balanced-architecture-review-method` is the default when no method is chosen;
recording it as the selected method preserves the pre-suite behavior. Per the
`review-routing.yml` `method_selection` layer, the companion methods are
advisory options for this occasion: escalate to
`greenfield-reference-architecture-review-method` when the target does not exist
yet, `tradeoff-review-method` when two or more viable target designs are in
play, `failure-mode-review-method` when runtime or governance failure behavior
is in doubt, `evolution-fitness-review-method` when long-lived mechanism health
is in doubt, and `boundary-authority-review-method` when authority location is
in doubt. Method selection creates no lifecycle gate and grants the review
output no authority; the v1 support receipt stays method-free.
