---
name: api-contract-audit
title: "Run API Contract Audit"
description: "Run audit-api-contract unless explicitly disabled."
---

# Step 4: Run API Contract Audit

## Purpose

Assess interface breakage risk from contract drift, conformance gaps, and lifecycle governance weaknesses.

## Actions

### If Skipped (`run_api_contract=false`)

Record:

```markdown
API contract audit: SKIPPED (run_api_contract=false)
```

Proceed to step 5.

### If Running

1. Invoke:

   ```text
   /audit-api-contract scope="{{subsystem}}" severity_threshold="{{severity_threshold}}" post_remediation="{{post_remediation}}" convergence_k="{{convergence_k}}" seed_list="{{seed_list}}"
   ```

2. Wait for completion and extract summary.
3. Record stage outcome and report path.

## Failure Handling

If stage fails, record failure details and continue to step 5.

## Output

- `.harmony/output/reports/YYYY-MM-DD-api-contract-audit-<run-id>.md` (if run)
- API-contract findings summary for merge

## Proceed When

- [ ] Stage completed, skipped, or failed status is explicitly recorded
