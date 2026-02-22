---
acceptance_criteria:
  - "Report includes all five required output sections"
  - "Run declares target mode as observed or prospective"
  - "Surface map includes file-path evidence"
  - "Prospective mode explicitly records domain absence evidence and profile baseline"
  - "Critical gaps include both impact and risk"
  - "Recommendations include priority, expected benefit, and tradeoff"
  - "At least one keep-as-is decision is justified when applicable"
  - "Unknowns are stated where evidence is insufficient"
  - "Assumptions are explicit and scoped"
  - "Findings use stable IDs with acceptance criteria in bundle mode"
  - "Coverage ledger records unaccounted_files"
  - "Convergence receipt and done-gate metadata are recorded"
---

# Validation

A run is complete when all acceptance criteria are satisfied and claims are traceable to concrete evidence.

## Reproducibility Rule

Given the same codebase state and parameters, high-level findings should be substantially stable.

## Mode Integrity Rule

- `observed` mode findings must be grounded in on-disk domain evidence.
- `prospective` mode findings must distinguish observed comparator evidence from forward-looking inferences.

## Done-Gate Rule

- Discovery mode (`post_remediation=false`): pass when bundle contract is valid and done-gate value is recorded.
- Post-remediation mode (`post_remediation=true`): pass only when convergence is stable and no open findings remain at or above threshold.
