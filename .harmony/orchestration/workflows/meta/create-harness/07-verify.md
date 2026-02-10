---
title: Verify and Summarize
description: Confirm harness creation and provide next steps.
---

# Step 7: Verify and Summarize

## Actions

1. List all created files
2. Show customizations made
3. Suggest next steps: **"Run boot sequence in START.md"**

## Verification Checklist

- [ ] `.harmony/` directory exists at target
- [ ] All required files present (START.md, scope.md, conventions.md)
- [ ] No placeholder patterns remain
- [ ] continuity/ directory initialized

## Idempotency

**Check:** Was verification already completed?
- [ ] Checkpoint file exists: `checkpoints/create-harness/<target>/07-verify.complete`

**If Already Complete:**
- Display cached summary
- Workflow already finished

**Marker:** `checkpoints/create-harness/<target>/07-verify.complete`

## Output

- Harness creation complete
- User has clear next steps
