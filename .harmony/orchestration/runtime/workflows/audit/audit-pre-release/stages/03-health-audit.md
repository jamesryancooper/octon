---
name: health-audit
title: "Run Health Audit"
description: "Run audit-subsystem-health against the target subsystem."
---

# Step 3: Run Health Audit

## Input

- Execution plan from step 1
- Subsystem path, docs path, severity threshold

## Purpose

Run `audit-subsystem-health` to verify subsystem coherence (config consistency, schema conformance, semantic quality). This step always runs.

## Actions

1. **Invoke audit-subsystem-health:**

   ```text
   /audit-subsystem-health subsystem="{{subsystem}}" severity_threshold="{{severity_threshold}}" post_remediation="{{post_remediation}}" convergence_k="{{convergence_k}}" seed_list="{{seed_list}}"
   ```

   If `docs` parameter was provided:

   ```text
   /audit-subsystem-health subsystem="{{subsystem}}" docs="{{docs}}" severity_threshold="{{severity_threshold}}" post_remediation="{{post_remediation}}" convergence_k="{{convergence_k}}" seed_list="{{seed_list}}"
   ```

2. **Wait for completion:**

   The skill writes `.harmony/output/reports/analysis/YYYY-MM-DD-subsystem-health-audit.md`.

3. **Capture results summary:**

   - Total findings
   - Severity breakdown
   - Layer breakdown (config consistency, schema conformance, semantic quality)

4. **Record outcome:**

   ```markdown
   Health audit: COMPLETED
   Report: .harmony/output/reports/analysis/{{date}}-subsystem-health-audit.md
   Findings: {{total}} ({{critical}} CRITICAL, {{high}} HIGH, {{medium}} MEDIUM, {{low}} LOW)
   ```

### If Failed

If `audit-subsystem-health` fails:

- Record the error with details
- Continue to step 4 (cross-subsystem audit)
- Note failure for merge/recommendation

```markdown
Health audit: FAILED
Error: {{error_message}}
```

## Idempotency

**Check:** Health report already exists for today's date.

- [ ] `.harmony/output/reports/analysis/YYYY-MM-DD-subsystem-health-audit.md` exists

**If Already Complete:**

- Reuse existing report
- Re-run if subsystem content changed

**Marker:** `checkpoints/audit-pre-release/03-health-audit.complete`

## Error Messages

- Skill failed: `HEALTH_AUDIT_FAILED: audit-subsystem-health exited with errors — {{details}}`

## Output

- Health audit report path (or fail status)
- Results summary for merge step

## Proceed When

- [ ] Health audit completed, OR
- [ ] Health audit failed and failure is documented
