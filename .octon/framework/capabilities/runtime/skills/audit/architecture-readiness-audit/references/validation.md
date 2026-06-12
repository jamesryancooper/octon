---
acceptance_criteria:
  - "Report includes all required output sections"
  - "Run declares target classification and evaluation mode"
  - "All mandatory phases execute in order for supported targets"
  - "Unsupported targets emit explicit not-applicable verdicts"
  - "Findings include severity, path evidence, and remediation acceptance criteria"
  - "Hard-gate failures are explicit"
  - "Summary JSON validates against architecture-readiness-report.schema.json"
  - "Coverage ledger records unaccounted_files"
  - "Findings use stable IDs with acceptance criteria in bundle mode"
  - "Convergence receipt and done-gate metadata are recorded"
---

# Validation

A run is complete when all acceptance criteria are satisfied and claims are
traceable to concrete evidence.

## Classification Integrity Rule

- `whole-harness` is valid only for `.octon`
- `bounded-domain` is valid only for top-level bounded-surface domains
- unsupported targets must stop at applicability classification

## Reproducibility Rule

Given the same codebase state and parameters, high-level findings should be
substantially stable.

## Done-Gate Rule

- Discovery mode (`post_remediation=false`): pass when bundle contract is valid and done-gate value is recorded.
- Post-remediation mode (`post_remediation=true`): pass only when convergence is stable and no open findings remain at or above threshold.
