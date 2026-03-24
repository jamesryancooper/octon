---
name: verify
title: Verify Architecture Proposal Audit Completion
description: Validate mode coverage, report presence, and package-delta receipts.
---

# Step 12: Verify Architecture Proposal Audit Completion

## Conditional Standard-Governed Package Gate

This step must run the fail-closed architecture proposal validator stack:

- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package "<target-package>"`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package "<target-package>"`

## Verification Checklist

- [ ] Selected mode is recorded in `bundle.yml`
- [ ] Selected stage set matches the chosen mode
- [ ] Every selected stage report exists under `bundle/reports/`
- [ ] Every file-writing stage has a change manifest or zero-change receipt
- [ ] `commands.md` exists
- [ ] `inventory.md` exists
- [ ] `package-delta.md` exists
- [ ] `validation.md` exists
- [ ] `stage-inputs/` and `stage-logs/` exist
- [ ] Top-level summary report exists
- [ ] Baseline proposal validator passes
- [ ] Architecture proposal validator passes
- [ ] Final readiness verdict is explicit

## Outcome Rules

- Pass only if every checklist item is satisfied.
- Fail if the produced stage set does not match the selected mode.
- Fail if a file-writing stage only produced recommendations.
- Fail if a manifest-bearing package does not pass the standard validator.

## Actions

1. Evaluate each checklist item.
2. Run the baseline and architecture validators and record the result in
   `validation.md`.
3. Record the final pass/fail result in `validation.md`.
4. If any item fails, return to the producing step and repair the artifacts.

## Workflow Complete When

- [ ] Verification checklist passes
- [ ] `validation.md` records the final result and rationale
