---
name: merge
title: "Merge Audit Results"
description: "Combine findings from completed audit stages into a unified view."
---

# Step 6: Merge Audit Results

## Input

- Migration audit summary (step 2: run/skip/fail)
- Health audit summary (step 3)
- Cross-subsystem summary (step 4: run/skip/fail)
- Freshness summary (step 5: run/skip/fail)
- Available individual audit reports

## Purpose

Merge findings from all completed audit stages into one deduplicated collection and compute a release-readiness recommendation.

## Actions

1. **Read available reports:**

   - Migration report (if run and completed)
   - Health report (if completed)
   - Cross-subsystem report (if run and completed)
   - Freshness report (if run and completed)

2. **Build unified findings collection:**

   For each finding, record:
   - Source audit stage
   - Source layer/check class
   - File path and line (if available)
   - Description
   - Original severity

3. **Deduplicate:**

   If the same `file:line` appears in multiple reports:
   - Keep highest severity
   - Record all source stages that flagged it

4. **Classify release impact:**

   | Impact | Criteria | Release Signal |
   |--------|----------|----------------|
   | Blocker | Any CRITICAL finding from any completed stage | NO-GO |
   | Warning | HIGH findings in operational/contract files | CONDITIONAL-GO |
   | Advisory | MEDIUM/LOW findings | GO with follow-up |

5. **Compute recommendation:**

   ```markdown
   ## Go/No-Go Assessment

   | Criterion | Result |
   |-----------|--------|
   | CRITICAL findings | {{count}} (threshold: 0) |
   | HIGH operational findings | {{count}} (threshold: review required) |
   | Migration audit | {{completed|skipped|failed}} |
   | Health audit | {{completed|failed}} |
   | Cross-subsystem audit | {{completed|skipped|failed}} |
   | Freshness audit | {{completed|skipped|failed}} |

   **Recommendation: {{GO|CONDITIONAL-GO|NO-GO}}**
   **Rationale:** {{explanation}}
   ```

## Idempotency

**Check:** Merge inputs unchanged since last merge.

- [ ] Source report set and hashes unchanged

**If Already Complete:**

- Reuse cached merge output
- Re-run if any source report changed

**Marker:** `checkpoints/pre-release-audit/06-merge.complete`

## Error Messages

- No reports available: `NO_AUDIT_RESULTS: No completed audit reports found — cannot merge`
- Parse failure: `REPORT_PARSE_ERROR: Could not parse findings from {{report_path}}`

## Output

- Unified deduplicated findings collection
- Release recommendation with rationale

## Proceed When

- [ ] All available reports are parsed
- [ ] Findings are deduplicated
- [ ] Recommendation is computed
