---
title: Promote Proposal
description: Rewrite the proposal to implemented state after proving that promotion targets are materialized and independent from proposal-local paths.
---

# Step 2: Promote Proposal

## Actions

1. Validate every `promotion_evidence` path is repo-relative and already exists.
2. Fail closed unless every promotion target exists.
3. Fail closed if any promotion target still references the proposal path or archive path.
4. Rewrite `proposal.yml` from `status: accepted` to `status: implemented`.
5. Regenerate `generated/proposals/registry.yml` from manifests instead of editing it manually.
