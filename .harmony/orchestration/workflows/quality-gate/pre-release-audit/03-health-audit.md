---
name: health-audit
title: "Run Health Audit"
description: "Run audit-subsystem-health against the target subsystem."
---

# Step 3: Run Health Audit

## Input

- Execution plan from step 1
- Subsystem path, docs path, severity threshold (from parameters)

## Purpose

Run the `audit-subsystem-health` skill to check subsystem coherence — config consistency, schema conformance, and semantic quality. This step always runs.

## Actions

1. **Invoke audit-subsystem-health:**

   ```text
   /audit-subsystem-health subsystem="{{subsystem}}" severity_threshold="{{severity_threshold}}"
   ```

   If `docs` parameter was provided:

   ```text
   /audit-subsystem-health subsystem="{{subsystem}}" docs="{{docs}}" severity_threshold="{{severity_threshold}}"
   ```

2. **Wait for completion:**

   The skill produces its own report at `.harmony/output/reports/YYYY-MM-DD-subsystem-health-audit.md`

3. **Capture results summary:**

   Read the health audit report and extract:
   - Total findings count
   - Severity breakdown (CRITICAL, HIGH, MEDIUM, LOW)
   - Layer breakdown (config consistency, schema conformance, semantic quality)

4. **Record outcome:**

   ```markdown
   Health audit: COMPLETED
   Report: .harmony/output/reports/{{date}}-subsystem-health-audit.md
   Findings: {{total}} ({{critical}} CRITICAL, {{high}} HIGH, {{medium}} MEDIUM, {{low}} LOW)
   ```

### If Failed

If `audit-subsystem-health` fails:

- Record the error with details
- If migration audit also failed (step 2): STOP, both audits failed
- If migration audit succeeded: continue to merge with migration-only results

```markdown
Health audit: FAILED
Error: {{error_message}}
```

## Idempotency

**Check:** Health audit report already exists for today's date.

- [ ] `.harmony/output/reports/YYYY-MM-DD-subsystem-health-audit.md` exists

**If Already Complete:**

- Skip invocation, use existing report
- Re-run if subsystem content has changed

**Marker:** `checkpoints/pre-release-audit/03-health-audit.complete`

## Error Messages

- Skill failed: "HEALTH_AUDIT_FAILED: audit-subsystem-health exited with errors — {{details}}"
- Both failed: "BOTH_AUDITS_FAILED: Neither audit skill completed — cannot produce pre-release report"

## Output

- Health audit report path (or fail status)
- Results summary for merge step

## Proceed When

- [ ] Health audit completed successfully, OR
- [ ] Health audit failed but migration audit succeeded (partial results)
