---
name: subsystem-health-audit
title: "Run Subsystem Health Audit"
description: "Run audit-subsystem-health as mandatory integrity baseline layer."
---

# Step 2: Run Subsystem Health Audit

## Purpose

Execute the mandatory subsystem integrity layer to baseline continuous structural and semantic health.

## Actions

1. Invoke:

   ```text
   /audit-subsystem-health subsystem="{{subsystem}}" severity_threshold="{{severity_threshold}}" post_remediation="{{post_remediation}}" convergence_k="{{convergence_k}}" seed_list="{{seed_list}}"
   ```

2. Wait for completion and extract findings/coverage/convergence summary.
3. Record stage outcome and report path.

## Failure Handling

If stage fails:

- Record failure details
- Continue to subsequent layers for evidence collection
- Mark mandatory layer failure for merge and recommendation logic

## Output

- `.octon/output/reports/analysis/YYYY-MM-DD-subsystem-health-audit.md`
- Subsystem-health findings summary for merge

## Proceed When

- [ ] Stage completed or failed status is explicitly recorded
