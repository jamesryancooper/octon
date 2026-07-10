---
title: Configure Post-Integration Architecture Review
---

Resolve the implemented target, conformance receipt, drift/churn receipt,
promotion evidence, and retained implementation evidence.

## Method selection (advisory, non-authority)

Select exactly one review method and record it in run evidence.
`balanced-architecture-review-method` is the default when no method is chosen;
recording it preserves the pre-suite behavior. Per the `review-routing.yml`
`method_selection` layer, the companion methods advised for this occasion are
`failure-mode-review-method` when runtime or governance failure behavior is in
doubt, `evolution-fitness-review-method` when long-lived mechanism health is in
doubt, and `boundary-authority-review-method` when authority location is in
doubt. Method selection creates no lifecycle gate and grants the review output
no authority; the v1 support receipt stays method-free and post-integration
review remains evidence-only.
