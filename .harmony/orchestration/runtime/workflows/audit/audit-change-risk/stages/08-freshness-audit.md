---
name: freshness-audit
title: "Run Freshness And Supersession Audit"
description: "Run audit-freshness-and-supersession unless explicitly disabled."
---

# Step 8: Run Freshness And Supersession Audit

## Purpose

Assess stale-context risk that can amplify rollout uncertainty or invalidate change assumptions.

## Actions

### If Skipped (`run_freshness=false`)

Record:

```markdown
Freshness audit: SKIPPED (run_freshness=false)
```

Proceed to step 9.

### If Running

1. Invoke:

   ```text
   /audit-freshness-and-supersession scope=".harmony" max_age_days="{{max_age_days}}" severity_threshold="{{severity_threshold}}" post_remediation="{{post_remediation}}" convergence_k="{{convergence_k}}" seed_list="{{seed_list}}"
   ```

2. Wait for completion and extract summary.
3. Record stage outcome and report path.

## Failure Handling

If stage fails, record failure details and continue to step 9.

## Output

- `.harmony/output/reports/analysis/YYYY-MM-DD-freshness-and-supersession-audit.md` (if run)
- Freshness findings summary for merge

## Proceed When

- [ ] Stage completed, skipped, or failed status is explicitly recorded
