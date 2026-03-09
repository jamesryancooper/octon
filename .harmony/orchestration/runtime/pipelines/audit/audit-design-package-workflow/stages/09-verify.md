---
name: verify
title: Verify Design Package Audit Completion
description: Validate mode coverage, report presence, and package-delta receipts.
---

# Step 9: Verify Design Package Audit Completion

## Verification Checklist

- [ ] Selected mode is recorded in `bundle.yml`
- [ ] Selected stage set matches the chosen mode
- [ ] Every selected stage report exists under `bundle/reports/`
- [ ] Every file-writing stage has a change manifest or zero-change receipt
- [ ] `package-delta.md` exists
- [ ] `validation.md` exists
- [ ] Top-level summary report exists
- [ ] Final readiness verdict is explicit

## Outcome Rules

- Pass only if every checklist item is satisfied.
- Fail if the produced stage set does not match the selected mode.
- Fail if a file-writing stage only produced recommendations.

## Actions

1. Evaluate each checklist item.
2. Record the final pass/fail result in `validation.md`.
3. If any item fails, return to the producing step and repair the artifacts.

## Workflow Complete When

- [ ] Verification checklist passes
- [ ] `validation.md` records the final result and rationale
