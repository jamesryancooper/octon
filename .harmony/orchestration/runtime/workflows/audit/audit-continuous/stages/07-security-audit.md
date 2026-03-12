---
name: security-audit
title: "Run Security Compliance Audit"
description: "Run audit-security-compliance unless explicitly disabled."
---

# Step 7: Run Security Compliance Audit

## Purpose

Assess whether security controls, access boundaries, and secret handling remain stable between releases.

## Actions

### If Skipped (`run_security=false`)

Record:

```markdown
Security audit: SKIPPED (run_security=false)
```

Proceed to step 8.

### If Running

1. Invoke:

   ```text
   /audit-security-compliance scope="{{subsystem}}" severity_threshold="{{severity_threshold}}" post_remediation="{{post_remediation}}" convergence_k="{{convergence_k}}" seed_list="{{seed_list}}"
   ```

2. Wait for completion and extract summary.
3. Record stage outcome and report path.

## Failure Handling

If stage fails, record failure details and continue to step 8.

## Output

- `.harmony/output/reports/analysis/YYYY-MM-DD-security-compliance-audit-<run-id>.md` (if run)
- Security findings summary for merge

## Proceed When

- [ ] Stage completed, skipped, or failed status is explicitly recorded
