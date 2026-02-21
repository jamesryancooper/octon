---
name: configure
title: "Configure Documentation Quality Gate"
description: "Parse parameters and validate canonical paths before execution."
---

# Step 1: Configure Documentation Quality Gate

## Input

- `docs_root` (required)
- `template_root` (optional)
- `policy_doc` (optional)
- `severity_threshold` (optional)

## Purpose

Validate all required paths and build an execution plan for the audit step.

## Actions

1. Resolve defaults when optional values are not provided:
   - `template_root` -> `.harmony/scaffolding/runtime/templates/docs/documentation-standards`
   - `policy_doc` -> `.harmony/cognition/governance/principles/documentation-is-code.md`
   - `severity_threshold` -> `all`
2. Validate paths exist.
3. Verify `audit-documentation-standards` is active in the skill manifest.
4. Record execution inputs for downstream steps.

## Output

- Validated execution plan
- Resolved paths and thresholds

## Proceed When

- [ ] Required paths exist
- [ ] Skill availability confirmed
- [ ] Execution plan recorded
