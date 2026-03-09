---
title: Verify Pipeline Creation
description: Verify the canonical pipeline and generated workflow projection.
---

# Step 8: Verify Pipeline Creation

## Purpose

This is the mandatory gate for pipeline creation. Creation is not complete until
the canonical pipeline validates and its workflow projection is aligned.

## Verification Checklist

- [ ] Canonical pipeline directory exists
- [ ] `pipeline.yml` declares the required contract fields
- [ ] All declared stage assets exist
- [ ] Pipeline manifest and registry entries are present
- [ ] Workflow projection metadata points back to the pipeline
- [ ] Generated workflow projection exists
- [ ] No live asset references temporary design-package content
- [ ] `validate-pipelines.sh` passes
- [ ] `validate-workflows.sh` passes

## Output

- `PASSED` when the canonical pipeline and workflow projection are aligned
- `FAILED` with explicit remediation targets otherwise

## Proceed When

- [ ] All verification checks pass
