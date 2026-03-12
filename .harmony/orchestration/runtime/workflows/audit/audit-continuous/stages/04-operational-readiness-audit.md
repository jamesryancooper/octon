---
name: operational-readiness-audit
title: "Run Operational Readiness Audit"
description: "Run audit-operational-readiness unless explicitly disabled."
---

# Step 4: Run Operational Readiness Audit

## Purpose

Assess whether ownership, escalation, resilience, and runbook posture remain durable under continuous operation.

## Actions

### If Skipped (`run_operational=false`)

Record:

```markdown
Operational readiness audit: SKIPPED (run_operational=false)
```

Proceed to step 5.

### If Running

1. Invoke:

   ```text
   /audit-operational-readiness scope="{{subsystem}}" severity_threshold="{{severity_threshold}}" post_remediation="{{post_remediation}}" convergence_k="{{convergence_k}}" seed_list="{{seed_list}}"
   ```

2. Wait for completion and extract summary.
3. Record stage outcome and report path.

## Failure Handling

If stage fails, record failure details and continue to step 5.

## Output

- `.harmony/output/reports/analysis/YYYY-MM-DD-operational-readiness-audit-<run-id>.md` (if run)
- Operational-readiness findings summary for merge

## Proceed When

- [ ] Stage completed, skipped, or failed status is explicitly recorded
