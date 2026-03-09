---
name: migration-audit
title: "Run Migration Audit"
description: "Run audit-orchestration-workflow in migration-only mode if a migration manifest was provided."
---

# Step 2: Run Migration Audit

## Input

- Execution plan from step 1
- Migration manifest path (from parameters)

## Purpose

Run `audit-orchestration-workflow` in migration-only mode to check post-migration reference integrity using the same partitioned orchestration path used elsewhere. This step is **skipped** if no migration manifest was provided.

## Actions

### If Skipped (no manifest)

Record:
```markdown
Migration audit: SKIPPED (no manifest provided)
```

Proceed immediately to step 3.

### If Running

1. **Invoke audit-orchestration-workflow (migration-only mode):**

   ```text
   /audit-orchestration-workflow manifest="{{manifest}}" scope="{{subsystem}}" severity_threshold="{{severity_threshold}}" run_cross_subsystem="false" run_freshness="false" post_remediation="{{post_remediation}}" convergence_k="{{convergence_k}}" seed_list="{{seed_list}}"
   ```

2. **Wait for completion:**

   The workflow produces its migration report at `.harmony/output/reports/YYYY-MM-DD-migration-audit-consolidated.md`

3. **Capture results summary:**

   Read the migration audit report and extract:
   - Total findings count
   - Severity breakdown (CRITICAL, HIGH, MEDIUM, LOW)
   - Partition coverage summary (successful partitions, failed partitions)

4. **Record outcome:**

   ```markdown
   Migration audit: COMPLETED
   Report: .harmony/output/reports/{{date}}-migration-audit-consolidated.md
   Findings: {{total}} ({{critical}} CRITICAL, {{high}} HIGH, {{medium}} MEDIUM, {{low}} LOW)
   ```

### If Failed

If `audit-orchestration-workflow` fails:

- Record the error with details
- Continue to step 3 (health audit runs independently)
- Note the failure for the merge step

```markdown
Migration audit: FAILED
Error: {{error_message}}
Note: Health audit will proceed independently
```

## Idempotency

**Check:** Migration audit report already exists for today's date.

- [ ] `.harmony/output/reports/YYYY-MM-DD-migration-audit-consolidated.md` exists

**If Already Complete:**

- Skip invocation, use existing report
- Re-run if manifest content has changed

**Marker:** `checkpoints/audit-pre-release-workflow/02-migration-audit.complete`

## Error Messages

- Workflow failed: "MIGRATION_AUDIT_FAILED: audit-orchestration-workflow migration stage exited with errors — {{details}}"
- Manifest invalid: "MANIFEST_INVALID: audit-orchestration-workflow rejected the manifest — {{validation_error}}"

## Output

- Migration audit report path (or skip/fail status)
- Results summary for merge step

## Proceed When

- [ ] Migration audit completed successfully, OR
- [ ] Migration audit was skipped (no manifest), OR
- [ ] Migration audit failed (recorded, continuing with health audit)
