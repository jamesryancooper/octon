---
name: migration-impact-audit
title: "Run Migration Impact Audit"
description: "Run audit-migration when migration manifest is available and enabled."
---

# Step 3: Run Migration Impact Audit

## Purpose

Assess path/reference migration risk and blast-radius consistency for the planned or executed change.

## Actions

### If Skipped (`run_migration=false` or `manifest` missing)

Record:

```markdown
Migration impact audit: SKIPPED (run_migration=false or manifest missing)
```

Proceed to step 4.

### If Running

1. Invoke:

   ```text
   /audit-migration manifest="{{manifest}}" scope="{{subsystem}}" severity_threshold="{{severity_threshold}}" post_remediation="{{post_remediation}}" convergence_k="{{convergence_k}}" seed_list="{{seed_list}}"
   ```

2. Wait for completion and extract summary.
3. Record stage outcome and report path.

## Failure Handling

If stage fails, record failure details and continue to step 4.

## Output

- `.octon/output/reports/analysis/YYYY-MM-DD-migration-audit.md` (if run)
- Migration-impact findings summary for merge

## Proceed When

- [ ] Stage completed, skipped, or failed status is explicitly recorded
