---
name: migration-audit
title: "Run Migration Audit"
description: "Run audit-migration if a migration manifest was provided."
---

# Step 2: Run Migration Audit

## Input

- Execution plan from step 1
- Migration manifest path (from parameters)

## Purpose

Run the `audit-migration` skill to check for post-migration reference integrity. This step is **skipped** if no migration manifest was provided.

## Actions

### If Skipped (no manifest)

Record:
```markdown
Migration audit: SKIPPED (no manifest provided)
```

Proceed immediately to step 3.

### If Running

1. **Invoke audit-migration:**

   ```text
   /audit-migration manifest="{{manifest}}" scope="{{subsystem}}" severity_threshold="{{severity_threshold}}"
   ```

2. **Wait for completion:**

   The skill produces its own report at `.harmony/output/reports/YYYY-MM-DD-migration-audit.md`

3. **Capture results summary:**

   Read the migration audit report and extract:
   - Total findings count
   - Severity breakdown (CRITICAL, HIGH, MEDIUM, LOW)
   - Layer breakdown (grep sweep, cross-ref, semantic)

4. **Record outcome:**

   ```markdown
   Migration audit: COMPLETED
   Report: .harmony/output/reports/{{date}}-migration-audit.md
   Findings: {{total}} ({{critical}} CRITICAL, {{high}} HIGH, {{medium}} MEDIUM, {{low}} LOW)
   ```

### If Failed

If `audit-migration` fails:

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

- [ ] `.harmony/output/reports/YYYY-MM-DD-migration-audit.md` exists

**If Already Complete:**

- Skip invocation, use existing report
- Re-run if manifest content has changed

**Marker:** `checkpoints/pre-release-audit/02-migration-audit.complete`

## Error Messages

- Skill failed: "MIGRATION_AUDIT_FAILED: audit-migration exited with errors — {{details}}"
- Manifest invalid: "MANIFEST_INVALID: audit-migration rejected the manifest — {{validation_error}}"

## Output

- Migration audit report path (or skip/fail status)
- Results summary for merge step

## Proceed When

- [ ] Migration audit completed successfully, OR
- [ ] Migration audit was skipped (no manifest), OR
- [ ] Migration audit failed (recorded, continuing with health audit)
