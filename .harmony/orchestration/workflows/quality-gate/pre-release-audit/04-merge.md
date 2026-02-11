---
name: merge
title: "Merge Audit Results"
description: "Combine findings from both audits into a unified view."
---

# Step 4: Merge Audit Results

## Input

- Migration audit results summary (from step 2, may be skipped/failed)
- Health audit results summary (from step 3)
- Both individual audit reports

## Purpose

Read both audit reports, merge findings into a unified collection, deduplicate cross-audit findings, and classify by release-readiness impact.

## Actions

1. **Read available audit reports:**

   - Migration audit report (if step 2 completed)
   - Health audit report (if step 3 completed)

2. **Build unified findings collection:**

   For each finding from both reports, record:
   - Source audit (migration or health)
   - Source layer (grep sweep, cross-ref, semantic, config consistency, schema conformance, etc.)
   - File path and line number
   - Description
   - Original severity

3. **Deduplicate:**

   If the same `file:line` appears in both audit reports:
   - Keep the higher-severity entry
   - Note which audits flagged it
   - This is expected for cross-reference issues that appear in both audits

4. **Classify by release-readiness impact:**

   | Impact | Criteria | Release Decision |
   |--------|----------|------------------|
   | **Blocker** | Any CRITICAL finding from either audit | NO-GO |
   | **Warning** | HIGH findings that affect routing or execution | Conditional GO |
   | **Advisory** | MEDIUM/LOW findings | GO with follow-up |

5. **Compute go/no-go recommendation:**

   ```markdown
   ## Go/No-Go Assessment

   | Criterion | Result |
   |-----------|--------|
   | CRITICAL findings | {{count}} (threshold: 0) |
   | HIGH findings in operational files | {{count}} (threshold: review required) |
   | Migration audit status | {{completed|skipped|failed}} |
   | Health audit status | {{completed|failed}} |

   **Recommendation: {{GO|CONDITIONAL-GO|NO-GO}}**
   **Rationale:** {{explanation}}
   ```

6. **Record merge results:**

   Unified findings collection with impact classification and go/no-go recommendation.

## Idempotency

**Check:** Merge has been completed for the current audit reports.

- [ ] Both source reports are unchanged since last merge

**If Already Complete:**

- Skip merge, use cached results
- Re-run if either source report has been regenerated

**Marker:** `checkpoints/pre-release-audit/04-merge.complete`

## Error Messages

- No reports available: "NO_AUDIT_RESULTS: No audit reports were generated — cannot merge"
- Report parse error: "REPORT_PARSE_ERROR: Could not extract findings from {{report_path}}"

## Output

- Unified, deduplicated findings collection
- Impact classification (blocker/warning/advisory)
- Go/no-go recommendation with rationale

## Proceed When

- [ ] All available audit reports have been read and parsed
- [ ] Findings are deduplicated
- [ ] Go/no-go recommendation is computed
