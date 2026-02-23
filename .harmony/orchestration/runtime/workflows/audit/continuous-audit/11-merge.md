---
name: merge
title: "Merge Continuous Audit Results"
description: "Merge layered findings into one stable continuous-risk set."
---

# Step 11: Merge Continuous Audit Results

## Purpose

Merge stage outputs into a stable continuous-risk model that quantifies open risk and trend direction.

## Actions

1. Parse available stage reports from steps 2-10.
2. Normalize findings into a common schema.
3. Deduplicate by stable ID rule (`taxonomy + layer + location + predicate`).
4. Preserve acceptance criteria and path-level evidence.
5. Merge coverage and unresolved unknowns across executed stages.
6. Compute continuous risk tier:
   - `HIGH` when critical or compounding gaps remain,
   - `MEDIUM` when material non-critical gaps remain,
   - `LOW` when no open findings remain at or above threshold.
7. Compute recommendation:
   - `REMEDIATE-NOW` for HIGH,
   - `MONITOR-WITH-PLAN` for MEDIUM,
   - `MAINTAIN` for LOW.

## Output

- Unified findings set
- Unified coverage summary
- Continuous risk tier and recommendation rationale inputs for reporting

## Proceed When

- [ ] No duplicate stable IDs remain
- [ ] Acceptance criteria preserved
- [ ] Coverage summary includes stage-level accounting
