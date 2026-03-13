---
name: observability-audit
title: "Run Observability Coverage Audit"
description: "Run audit-observability-coverage unless explicitly disabled."
---

# Step 6: Run Observability Coverage Audit

## Purpose

Assess telemetry, SLO, alerting, and runbook observability readiness.

## Actions

### If Skipped (`run_observability=false`)

Record:

```markdown
Observability audit: SKIPPED (run_observability=false)
```

Proceed to step 7.

### If Running

1. Invoke:

   ```text
   /audit-observability-coverage scope="{{scope}}" severity_threshold="{{severity_threshold}}" post_remediation="{{post_remediation}}" convergence_k="{{convergence_k}}" seed_list="{{seed_list}}"
   ```

2. Wait for completion and extract summary.
3. Record stage outcome and report path.

## Failure Handling

If stage fails, record failure details and continue to step 7.

## Output

- `.octon/output/reports/analysis/YYYY-MM-DD-observability-coverage-audit-<run-id>.md` (if run)
- Observability stage findings summary for merge

## Proceed When

- [ ] Stage completed, skipped, or failed status is explicitly recorded
