---
name: test-quality-audit
title: "Run Test Quality Audit"
description: "Run audit-test-quality unless explicitly disabled."
---

# Step 6: Run Test Quality Audit

## Purpose

Assess whether the regression suite and test signal quality remain sufficient for ongoing drift containment.

## Actions

### If Skipped (`run_test_quality=false`)

Record:

```markdown
Test quality audit: SKIPPED (run_test_quality=false)
```

Proceed to step 7.

### If Running

1. Invoke:

   ```text
   /audit-test-quality scope="{{subsystem}}" severity_threshold="{{severity_threshold}}" post_remediation="{{post_remediation}}" convergence_k="{{convergence_k}}" seed_list="{{seed_list}}"
   ```

2. Wait for completion and extract summary.
3. Record stage outcome and report path.

## Failure Handling

If stage fails, record failure details and continue to step 7.

## Output

- `.harmony/output/reports/YYYY-MM-DD-test-quality-audit-<run-id>.md` (if run)
- Test-quality findings summary for merge

## Proceed When

- [ ] Stage completed, skipped, or failed status is explicitly recorded
