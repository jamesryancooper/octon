---
name: release-core-audit
title: "Run Release Core Audit"
description: "Run audit-release-readiness as mandatory release-core stage."
---

# Step 2: Run Release Core Audit

## Purpose

Execute the mandatory core release-readiness layer that evaluates policy, deployment/rollback safeguards, and gate evidence.

## Actions

1. Invoke release core skill:

   ```text
   /audit-release-readiness scope="{{scope}}" severity_threshold="{{severity_threshold}}" post_remediation="{{post_remediation}}" convergence_k="{{convergence_k}}" seed_list="{{seed_list}}"
   ```

2. Wait for report generation.
3. Capture stage summary:
   - findings by severity
   - coverage accounting status
   - done-gate and convergence fragments
4. Record stage outcome and report path.

## Failure Handling

If stage fails:

- Record failure details
- Continue to supplemental stages for maximum signal
- Mark release-core status for merge and recommendation logic

## Output

- `.octon/output/reports/analysis/YYYY-MM-DD-audit-release-readiness-<run-id>.md`
- Release-core findings summary for merge

## Proceed When

- [ ] Stage completed or failed status is explicitly recorded
