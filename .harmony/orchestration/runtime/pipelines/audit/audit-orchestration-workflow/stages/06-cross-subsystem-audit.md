---
name: cross-subsystem-audit
title: "Run Cross-Subsystem Coherence Audit"
description: "Run audit-cross-subsystem-coherence for whole-harness contract alignment."
---

# Step 6: Run Cross-Subsystem Coherence Audit

## Input

- Execution plan from step 1
- Optional docs path and severity threshold

## Purpose

Run `audit-cross-subsystem-coherence` to detect cross-subsystem contract conflicts, path drift, and policy contradictions that partitioned migration checks cannot fully detect. This step runs by default and can be skipped with `run_cross_subsystem=false`.

## Actions

### If Skipped (`run_cross_subsystem=false`)

Record:

```markdown
Cross-subsystem audit: SKIPPED (run_cross_subsystem=false)
```

Proceed to step 7.

### If Running

1. **Invoke audit-cross-subsystem-coherence:**

   ```text
   /audit-cross-subsystem-coherence scope=".harmony" severity_threshold="{{severity_threshold}}" post_remediation="{{post_remediation}}" convergence_k="{{convergence_k}}" seed_list="{{seed_list}}"
   ```

   If `docs` parameter was provided:

   ```text
   /audit-cross-subsystem-coherence scope=".harmony" docs="{{docs}}" severity_threshold="{{severity_threshold}}" post_remediation="{{post_remediation}}" convergence_k="{{convergence_k}}" seed_list="{{seed_list}}"
   ```

2. **Wait for completion:**

   The skill writes `.harmony/output/reports/YYYY-MM-DD-cross-subsystem-coherence-audit.md`.

3. **Capture results summary:**

   - Total findings count
   - Severity breakdown (CRITICAL, HIGH, MEDIUM, LOW)
   - Conflict classes (contract mismatch, policy conflict, broken cross-reference, ownership collision)

4. **Record outcome:**

   ```markdown
   Cross-subsystem audit: COMPLETED
   Report: .harmony/output/reports/{{date}}-cross-subsystem-coherence-audit.md
   Findings: {{total}} ({{critical}} CRITICAL, {{high}} HIGH, {{medium}} MEDIUM, {{low}} LOW)
   ```

### If Failed

If `audit-cross-subsystem-coherence` fails:

- Record the error with details
- Continue to step 7 (freshness audit)
- Note the failure for step 8 report recommendation

```markdown
Cross-subsystem audit: FAILED
Error: {{error_message}}
```

## Idempotency

**Check:** Cross-subsystem report already exists for today's date.

- [ ] `.harmony/output/reports/YYYY-MM-DD-cross-subsystem-coherence-audit.md` exists

**If Already Complete:**

- Skip invocation and reuse existing report
- Re-run if cross-subsystem contract surfaces changed

**Marker:** `checkpoints/audit-orchestration-workflow/06-cross-subsystem-audit.complete`

## Error Messages

- Skill failed: `CROSS_SUBSYSTEM_AUDIT_FAILED: audit-cross-subsystem-coherence exited with errors — {{details}}`

## Output

- Cross-subsystem audit report path (or skip/fail status)
- Results summary for report step

## Proceed When

- [ ] Cross-subsystem audit completed, OR
- [ ] Cross-subsystem audit skipped by configuration, OR
- [ ] Cross-subsystem audit failed and failure is documented
