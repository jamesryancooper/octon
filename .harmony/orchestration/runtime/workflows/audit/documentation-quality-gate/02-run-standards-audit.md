---
name: run-standards-audit
title: "Run Documentation Standards Audit"
description: "Execute audit-documentation-standards and capture findings summary."
---

# Step 2: Run Documentation Standards Audit

## Input

- Execution plan from step 1

## Purpose

Run the audit skill and collect severity and coverage results for gate
decisioning.

## Actions

1. Invoke:

```text
/audit-documentation-standards docs_root="{{docs_root}}" template_root="{{template_root}}" policy_doc="{{policy_doc}}" severity_threshold="{{severity_threshold}}"
```

2. Wait for report generation.
3. Read report summary:
   - findings by severity
   - coverage summary
   - recommended remediation batches

## Output

- `.harmony/output/reports/YYYY-MM-DD-documentation-standards-audit.md`
- Findings summary for step 3

## Proceed When

- [ ] Audit report exists
- [ ] Findings summary extracted
