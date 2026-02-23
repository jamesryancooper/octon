---
acceptance_criteria:
  - "Report includes all required output sections"
  - "Run declares scope baseline source and confidence mode"
  - "All three mandatory coverage layers execute in isolation"
  - "Coverage matrix includes in-scope surface accounting"
  - "Findings include severity, path evidence, and remediation acceptance criteria"
  - "Unknowns are explicit where evidence is insufficient"
  - "Coverage ledger records unaccounted_files"
  - "Findings use stable IDs with acceptance criteria in bundle mode"
  - "Convergence receipt and done-gate metadata are recorded"
---

# Validation

A run is complete when all acceptance criteria are satisfied and claims are
traceable to concrete evidence.

## Reproducibility Rule

Given the same codebase state and parameters, high-level findings should be
substantially stable.

## Layer Integrity Rule

- `Signal Contract Coverage` findings must be grounded in service and contract artifacts.
- `SLO and Alert Coverage` findings must cite objective and alert evidence.
- `Runbook and Dashboard Coverage` findings must cite operator guidance artifacts or explicit absences.

## Done-Gate Rule

- Discovery mode (`post_remediation=false`): pass when bundle contract is valid and done-gate value is recorded.
- Post-remediation mode (`post_remediation=true`): pass only when convergence is stable and no open findings remain at or above threshold.
