---
title: Validate Prerequisites
description: Confirm template directory exists before workspace creation.
---

# Step 1: Validate Prerequisites

## Actions

1. Confirm `.harmony/scaffolding/templates/harmony/` exists
2. If missing, report error: **"Template directory not found at `.harmony/scaffolding/templates/harmony/`. Create templates first."**
3. If exists, proceed to next step

## Idempotency

**Check:** Are prerequisites already validated?
- [ ] Checkpoint file exists: `checkpoints/create-workspace/<target>/01-prerequisites.complete`

**If Already Complete:**
- Skip validation
- Proceed to next step

**Marker:** `checkpoints/create-workspace/<target>/01-prerequisites.complete`
