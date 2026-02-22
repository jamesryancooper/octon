---
title: Validation
description: Completion criteria for audit-cross-subsystem-coherence.
---

# Validation

A run is complete when the bounded contract is satisfied:

- Scope and subsystem set are recorded
- Contract graph is built with unresolved-node accounting
- Cross-subsystem consistency checks are executed
- Conflict/drift analysis is executed
- Self-challenge outcomes are documented
- Coverage accounting is complete (`unaccounted_files` recorded)
- Stable IDs and acceptance criteria are assigned for all findings (bundle mode)
- Convergence receipt metadata is recorded
- Done-gate result is evaluated and written

## Mode Rules

- Discovery mode (`post_remediation=false`): pass when bundle contract is valid and done-gate value is recorded.
- Post-remediation mode (`post_remediation=true`): pass only when convergence is stable and no open findings remain at or above threshold.
