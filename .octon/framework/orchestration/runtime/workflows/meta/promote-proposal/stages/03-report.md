---
title: Report Promotion
description: Summarize the promotion result and persist the workflow bundle receipts.
---

# Step 3: Report Promotion

## Actions

1. Write a top-level summary with proposal identity, kind, validator result,
   gate receipt status, and evidence inputs, including whether
   `promotion_evidence` was selected-child-bound or rejected before status
   mutation.
2. Persist `summary.md`, `commands.md`, `inventory.md`, `validation.md`, and `bundle.yml`.
3. Emit an explicit final verdict that names the implementation-grade,
   conformance, and drift/churn gate states.
