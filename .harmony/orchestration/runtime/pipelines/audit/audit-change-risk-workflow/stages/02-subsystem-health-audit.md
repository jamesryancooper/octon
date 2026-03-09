---
name: subsystem-health-audit
title: "Run Subsystem Health Audit"
description: "Run audit-subsystem-health as mandatory integrity layer."
---

# Step 2: Run Subsystem Health Audit

## Purpose

Execute the mandatory subsystem integrity layer to baseline change safety for structure, schema, and semantics.

## Actions

1. Invoke health audit:

   ```text
   /audit-subsystem-health subsystem="{{subsystem}}" severity_threshold="{{severity_threshold}}" post_remediation="{{post_remediation}}" convergence_k="{{convergence_k}}" seed_list="{{seed_list}}"
   ```

2. If `docs` is provided, include it in invocation.
3. Wait for completion and extract findings/coverage/convergence summary.
4. Record stage outcome and report path.

## Failure Handling

If stage fails:

- Record failure details
- Continue to remaining stages for evidence collection
- Mark mandatory layer failure for merge and recommendation logic

## Output

- `.harmony/output/reports/YYYY-MM-DD-subsystem-health-audit.md`
- Subsystem-health findings summary for merge

## Proceed When

- [ ] Stage completed or failed status is explicitly recorded
