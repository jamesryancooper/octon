---
name: data-governance-audit
title: "Run Data Governance Audit"
description: "Run audit-data-governance unless explicitly disabled."
---

# Step 8: Run Data Governance Audit

## Purpose

Assess classification, retention, lineage, privacy, and governance evidence posture.

## Actions

### If Skipped (`run_data_governance=false`)

Record:

```markdown
Data governance audit: SKIPPED (run_data_governance=false)
```

Proceed to step 9.

### If Running

1. Invoke:

   ```text
   /audit-data-governance scope="{{scope}}" severity_threshold="{{severity_threshold}}" post_remediation="{{post_remediation}}" convergence_k="{{convergence_k}}" seed_list="{{seed_list}}"
   ```

2. Wait for completion and extract summary.
3. Record stage outcome and report path.

## Failure Handling

If stage fails, record failure details and continue to step 9.

## Output

- `.octon/output/reports/analysis/YYYY-MM-DD-data-governance-audit-<run-id>.md` (if run)
- Data governance stage findings summary for merge

## Proceed When

- [ ] Stage completed, skipped, or failed status is explicitly recorded
