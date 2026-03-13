---
title: Validation
description: Completion criteria for audit-freshness-and-supersession.
---

# Validation

A run is complete when the bounded contract is satisfied:

- Scope and artifact globs are recorded
- Artifact inventory is classified and counted
- Freshness checks are executed with configured threshold
- Supersession integrity checks are executed
- Self-challenge outcomes are documented
- Coverage accounting is complete (`unaccounted_files` recorded)
- Stable IDs and acceptance criteria are assigned for all findings (bundle mode)
- Convergence receipt metadata is recorded
- Done-gate result is evaluated and written

## Mode Rules

- Discovery mode (`post_remediation=false`): pass when bundle contract is valid and done-gate value is recorded.
- Post-remediation mode (`post_remediation=true`): pass only when convergence is stable and no open findings remain at or above threshold.
