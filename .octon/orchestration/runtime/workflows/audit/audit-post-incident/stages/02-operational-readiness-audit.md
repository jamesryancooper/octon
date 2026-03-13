---
name: operational-readiness-audit
title: "Run Operational Readiness Audit"
description: "Run audit-operational-readiness as mandatory incident-response layer."
---

# Step 2: Run Operational Readiness Audit

## Purpose

Assess whether ownership, runbook, escalation, and resilience posture are sufficient after the incident.

## Actions

1. Invoke:

   ```text
   /audit-operational-readiness scope="{{subsystem}}" severity_threshold="{{severity_threshold}}" post_remediation="{{post_remediation}}" convergence_k="{{convergence_k}}" seed_list="{{seed_list}}"
   ```

2. Wait for completion and extract findings/coverage/convergence summary.
3. Record stage outcome and report path.

## Failure Handling

If stage fails:

- Record failure details
- Continue to subsequent layers for evidence collection
- Mark mandatory layer failure for merge and recommendation logic

## Output

- `.octon/output/reports/analysis/YYYY-MM-DD-operational-readiness-audit-<run-id>.md`
- Operational-readiness findings summary for merge

## Proceed When

- [ ] Stage completed or failed status is explicitly recorded
