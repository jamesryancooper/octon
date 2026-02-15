---
name: freshness-audit
title: "Run Freshness And Supersession Audit"
description: "Run audit-freshness-and-supersession for staleness and supersession integrity."
---

# Step 7: Run Freshness And Supersession Audit

## Input

- Execution plan from step 1
- `max_age_days` and severity threshold

## Purpose

Run `audit-freshness-and-supersession` to detect stale artifacts, broken supersession chains, and contradictory current-state markers. This step runs by default and can be skipped with `run_freshness=false`.

## Actions

### If Skipped (`run_freshness=false`)

Record:

```markdown
Freshness audit: SKIPPED (run_freshness=false)
```

Proceed to step 8.

### If Running

1. **Invoke audit-freshness-and-supersession:**

   ```text
   /audit-freshness-and-supersession scope=".harmony" max_age_days="{{max_age_days}}" severity_threshold="{{severity_threshold}}"
   ```

2. **Wait for completion:**

   The skill writes `.harmony/output/reports/YYYY-MM-DD-freshness-and-supersession-audit.md`.

3. **Capture results summary:**

   - Total findings count
   - Severity breakdown (CRITICAL, HIGH, MEDIUM, LOW)
   - Freshness classes (stale authoritative, stale derivative, broken supersession, orphan history)

4. **Record outcome:**

   ```markdown
   Freshness audit: COMPLETED
   Report: .harmony/output/reports/{{date}}-freshness-and-supersession-audit.md
   Findings: {{total}} ({{critical}} CRITICAL, {{high}} HIGH, {{medium}} MEDIUM, {{low}} LOW)
   ```

### If Failed

If `audit-freshness-and-supersession` fails:

- Record the error with details
- Continue to step 8 (report)
- Note the failure for consolidated recommendation

```markdown
Freshness audit: FAILED
Error: {{error_message}}
```

## Idempotency

**Check:** Freshness report already exists for today's date.

- [ ] `.harmony/output/reports/YYYY-MM-DD-freshness-and-supersession-audit.md` exists

**If Already Complete:**

- Skip invocation and reuse existing report
- Re-run if target artifact families changed

**Marker:** `checkpoints/orchestrate-audit/07-freshness-audit.complete`

## Error Messages

- Skill failed: `FRESHNESS_AUDIT_FAILED: audit-freshness-and-supersession exited with errors — {{details}}`

## Output

- Freshness audit report path (or skip/fail status)
- Results summary for report step

## Proceed When

- [ ] Freshness audit completed, OR
- [ ] Freshness audit skipped by configuration, OR
- [ ] Freshness audit failed and failure is documented
