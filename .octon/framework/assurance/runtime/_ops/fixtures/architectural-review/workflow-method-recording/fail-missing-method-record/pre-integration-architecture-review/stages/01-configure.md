---
title: Configure Pre-Integration Architecture Review (NC-01 fixture)
---

## Method selection (advisory, non-authority)

`balanced-architecture-review-method` is the default when no method is chosen.
This fixture keeps the advisory intact but omits the method-id run-evidence
record artifact, so the workflows validator fails closed with
missing_method_record for exactly one reason.
