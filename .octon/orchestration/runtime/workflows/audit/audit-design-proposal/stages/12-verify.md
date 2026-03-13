---
name: verify
title: Verify Design Proposal Audit Completion
description: Validate mode coverage, report presence, and proposal-delta receipts.
---

# Step 12: Verify Design Proposal Audit Completion

## Conditional Standard-Governed Proposal Gate

If the target proposal contains `proposal.yml`, this step must also run:

`bash .octon/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package "<target-package>"`

If the target proposal contains `design-proposal.yml`, this step must also run:

`bash .octon/assurance/runtime/_ops/scripts/validate-design-proposal.sh --package "<target-package>"`

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
- [ ] Proposal validator stack passes when `design-proposal.yml` is present
- [ ] Final readiness verdict is explicit

## Outcome Rules

- Pass only if every checklist item is satisfied.
- Fail if the produced stage set does not match the selected mode.
- Fail if a file-writing stage only produced recommendations.
- Fail if a manifest-bearing proposal does not pass the validator stack.

## Actions

1. Evaluate each checklist item.
2. If `design-proposal.yml` exists, run the baseline and design validators and record the
   result in `validation.md`.
3. Record the final pass/fail result in `validation.md`.
4. If any item fails, return to the producing step and repair the artifacts.

## Workflow Complete When

- [ ] Verification checklist passes
- [ ] `validation.md` records the final result and rationale
