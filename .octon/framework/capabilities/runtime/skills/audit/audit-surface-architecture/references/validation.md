---
acceptance_criteria:
  - "Report includes all required output sections"
  - "Run classifies the target as contract-first, mixed, markdown-first, human-led/non-executable, or not-applicable"
  - "Target normalization result and confidence mode are recorded"
  - "Coverage matrix includes in-scope artifact accounting"
  - "Findings include severity, path evidence, and remediation acceptance criteria"
  - "Unknowns are explicit where evidence is insufficient"
  - "Recommendations name exact durable artifacts and artifact class"
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

- `Target Resolution and Applicability Gate` findings must be grounded in path
  normalization and scope evidence.
- `Authority and Artifact Mapping` findings must cite contracts, indices,
  validators, and supporting artifacts.
- `Surface Needs and Drift Analysis` findings must cite the authority artifact
  that fails or the missing artifact required to make the surface robust.

## Done-Gate Rule

- Discovery mode (`post_remediation=false`): pass when bundle contract is valid
  and done-gate value is recorded.
- Post-remediation mode (`post_remediation=true`): pass only when convergence is
  stable and no open findings remain at or above threshold.
