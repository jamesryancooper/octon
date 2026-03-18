---
name: merge
title: "Merge Post-Incident Results"
description: "Merge layered findings into one stable post-incident closure set."
---

# Step 10: Merge Post-Incident Results

## Purpose

Merge stage outputs into a stable closure model that quantifies residual incident risk and remediation completeness.

## Actions

1. Parse available stage reports from steps 2-9.
2. Normalize findings into a common schema.
3. Deduplicate by stable ID rule (`taxonomy + layer + location + predicate`).
4. Preserve acceptance criteria and path-level evidence.
5. Merge coverage and unresolved unknowns across executed stages.
6. Compute residual risk tier:
   - `HIGH` when critical/compounding gaps remain,
   - `MEDIUM` when material non-critical gaps remain,
   - `LOW` when no open findings remain at/above threshold.
7. Compute recommendation:
   - `NO-CLOSE` for HIGH,
   - `CONDITIONAL-CLOSE` for MEDIUM,
   - `CLOSE` for LOW.

## Output

- Unified findings set
- Unified coverage summary
- Residual risk tier and recommendation rationale inputs for reporting

## Proceed When

- [ ] No duplicate stable IDs remain
- [ ] Acceptance criteria preserved
- [ ] Coverage summary includes stage-level accounting
