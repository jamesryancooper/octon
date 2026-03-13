---
name: configure
title: "Configure Documentation Audit"
description: "Parse parameters and build bounded execution plan with deterministic controls."
---

# Step 1: Configure Documentation Audit

## Input

- `docs_root` (required)
- `template_root` (optional)
- `policy_doc` (optional)
- `severity_threshold` (optional, default `all`)
- `post_remediation` (optional, default `false`)
- `convergence_k` (optional, default `3`)
- `seed_list` (optional)

## Purpose

Validate all required paths and build a bounded execution plan with explicit done-gate semantics.

## Actions

1. Resolve defaults when optional values are not provided:
   - `template_root` -> `.octon/scaffolding/runtime/templates/docs/documentation-standards`
   - `policy_doc` -> `.octon/cognition/governance/principles/documentation-is-code.md`
   - `severity_threshold` -> `all`
2. Validate required paths exist.
3. Verify `audit-documentation-standards` is active in the skill manifest.
4. Record deterministic controls (`post_remediation`, `convergence_k`, seed policy) for downstream reporting.
5. Persist bounded execution plan.

## Output

- Validated execution plan
- Resolved paths and thresholds
- Recorded deterministic controls

## Proceed When

- [ ] Required paths exist
- [ ] Skill availability confirmed
- [ ] Deterministic controls are recorded
- [ ] Execution plan recorded
