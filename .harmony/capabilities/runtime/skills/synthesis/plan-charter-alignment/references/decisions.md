---
title: Plan Charter Alignment Decisions
description: Decision rules for the plan-charter-alignment skill.
---

# Decision Rules

## Scope Rule

Default to `charter-only` planning. If the findings imply follow-on work outside the charter, record that as explicit follow-on scope rather than silently widening the implementation plan.

## Profile Rule

- Select `atomic` unless a hard gate requires `transitional`.
- If both `atomic` and `transitional` appear required, escalate instead of deciding.
- In stable mode, choose the smallest safe profile that satisfies the hard gates.

## Findings Coverage Rule

Every High and Medium finding must be:

- mapped to a planned change,
- mapped to an explicit validation check,
- or explicitly deferred with rationale in `Exceptions/Escalations`.

## Score Target Rule

Do not promise near-100 outcomes unless the planned changes actually close the material findings.
