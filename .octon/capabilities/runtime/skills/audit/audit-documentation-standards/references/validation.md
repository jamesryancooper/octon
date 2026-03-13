---
title: Validation
description: Completion criteria for audit-documentation-standards.
---

# Validation

A run is complete when the bounded contract is satisfied:

- Scope is enumerated and recorded
- Policy checks are executed
- Template checks are executed
- Self-challenge checks are executed
- Severity-tiered findings are reported
- Coverage accounting includes checked-clean files and exclusions
- Stable IDs and acceptance criteria are assigned for all findings (bundle mode)
- Convergence receipt metadata is recorded
- Done-gate result is evaluated and written
- Report and log artifacts are written

## Mode Rules

- Discovery mode (`post_remediation=false`): pass when bundle contract is valid and done-gate value is recorded.
- Post-remediation mode (`post_remediation=true`): pass only when convergence is stable and no open findings remain at or above threshold.
