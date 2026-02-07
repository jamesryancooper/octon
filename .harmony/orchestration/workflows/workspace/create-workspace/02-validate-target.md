---
title: Validate Target
description: Confirm target directory is valid for workspace creation.
---

# Step 2: Validate Target

## Actions

1. Confirm exactly one directory reference was provided
2. Verify target directory exists (offer to create if not)
3. Check if `.workspace/` already exists at target
   - If exists: ask to confirm before overwriting
4. Ask: **"Will an agent work here across multiple sessions, with domain-specific constraints?"**
   - **No** → Suggest a README instead; workspace is overkill
   - **Yes** → Proceed to next step

## Idempotency

**Check:** Is target already validated?
- [ ] Checkpoint file exists: `checkpoints/create-workspace/<target>/02-target.complete`
- [ ] Target path stored in checkpoint

**If Already Complete:**
- Load cached target path
- Skip to next step

**Marker:** `checkpoints/create-workspace/<target>/02-target.complete`
