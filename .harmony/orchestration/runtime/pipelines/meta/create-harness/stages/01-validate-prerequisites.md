---
title: Validate Prerequisites
description: Confirm template directory exists before harness creation.
---

# Step 1: Validate Prerequisites

## Actions

1. Confirm `.harmony/scaffolding/runtime/templates/harmony/` exists
2. If missing, report error: **"Template directory not found at `.harmony/scaffolding/runtime/templates/harmony/`. Create templates first."**
3. If exists, proceed to next step

## Idempotency

**Check:** Are prerequisites already validated?
- [ ] Checkpoint file exists: `checkpoints/create-harness/<target>/01-prerequisites.complete`

**If Already Complete:**
- Skip validation
- Proceed to next step

**Marker:** `checkpoints/create-harness/<target>/01-prerequisites.complete`
