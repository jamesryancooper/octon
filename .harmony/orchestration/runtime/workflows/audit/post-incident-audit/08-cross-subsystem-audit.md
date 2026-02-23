---
name: cross-subsystem-audit
title: "Run Cross-Subsystem Coherence Audit"
description: "Run audit-cross-subsystem-coherence unless explicitly disabled."
---

# Step 8: Run Cross-Subsystem Coherence Audit

## Purpose

Assess whether incident remediation created or exposed contract/policy conflicts across subsystem boundaries.

## Actions

### If Skipped (`run_cross_subsystem=false`)

Record:

```markdown
Cross-subsystem audit: SKIPPED (run_cross_subsystem=false)
```

Proceed to step 9.

### If Running

1. Invoke:

   ```text
   /audit-cross-subsystem-coherence scope=".harmony" severity_threshold="{{severity_threshold}}" post_remediation="{{post_remediation}}" convergence_k="{{convergence_k}}" seed_list="{{seed_list}}"
   ```

2. If `docs` is provided, include it in invocation.
3. Wait for completion and extract summary.
4. Record stage outcome and report path.

## Failure Handling

If stage fails, record failure details and continue to step 9.

## Output

- `.harmony/output/reports/YYYY-MM-DD-cross-subsystem-coherence-audit.md` (if run)
- Cross-subsystem findings summary for merge

## Proceed When

- [ ] Stage completed, skipped, or failed status is explicitly recorded
