---
name: observability-audit
title: "Run Observability Coverage Audit"
description: "Run audit-observability-coverage as mandatory drift-detection layer."
---

# Step 3: Run Observability Coverage Audit

## Purpose

Assess whether telemetry, alerting, SLOs, and diagnostics continue to provide early drift detection for the subsystem.

## Actions

1. Invoke:

   ```text
   /audit-observability-coverage scope="{{subsystem}}" severity_threshold="{{severity_threshold}}" post_remediation="{{post_remediation}}" convergence_k="{{convergence_k}}" seed_list="{{seed_list}}"
   ```

2. Wait for completion and extract findings/coverage/convergence summary.
3. Record stage outcome and report path.

## Failure Handling

If stage fails:

- Record failure details
- Continue to subsequent layers for evidence collection
- Mark mandatory layer failure for merge and recommendation logic

## Output

- `.harmony/output/reports/YYYY-MM-DD-observability-coverage-audit-<run-id>.md`
- Observability findings summary for merge

## Proceed When

- [ ] Stage completed or failed status is explicitly recorded
