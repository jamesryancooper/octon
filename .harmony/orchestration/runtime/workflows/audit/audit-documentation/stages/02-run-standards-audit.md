---
name: run-standards-audit
title: "Run Documentation Standards Audit"
description: "Execute audit-documentation-standards in bounded mode and capture findings/coverage inputs."
---

# Step 2: Run Documentation Standards Audit

## Input

- Execution plan from step 1

## Purpose

Run the audit skill and collect findings, coverage, and convergence inputs for recommendation and done-gate evaluation.

## Actions

1. Invoke:

```text
/audit-documentation-standards docs_root="{{docs_root}}" template_root="{{template_root}}" policy_doc="{{policy_doc}}" severity_threshold="{{severity_threshold}}" post_remediation="{{post_remediation}}" convergence_k="{{convergence_k}}" seed_list="{{seed_list}}"
```

2. Wait for report generation.
3. Read report summary and capture:
   - findings by severity
   - coverage accounting status
   - remediation batch summary
   - determinism receipt fragments (seed/fingerprint policy if present)

## Output

- `.harmony/output/reports/analysis/YYYY-MM-DD-documentation-standards-audit.md`
- Findings/coverage/convergence summary for step 3

## Proceed When

- [ ] Audit report exists
- [ ] Findings summary extracted
- [ ] Coverage summary extracted
- [ ] Determinism inputs extracted
