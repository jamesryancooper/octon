---
title: Verify Updated Pipeline Surface
description: Verify the updated canonical pipeline and its workflow projection.
---

# Step 5: Verify Updated Pipeline Surface

## Purpose

Close the update only when the canonical pipeline and workflow projection are
aligned again.

## Verification Checklist

- [ ] Canonical pipeline contract validates
- [ ] Declared stage assets exist and match the contract
- [ ] Workflow projection regenerates cleanly
- [ ] No projection drift remains
- [ ] No live asset references temporary design-package content

## Output

- Final verification receipt showing whether the updated pipeline surface is
  ready

## Proceed When

- [ ] `validate-pipelines.sh` passes
- [ ] `validate-workflows.sh` passes
