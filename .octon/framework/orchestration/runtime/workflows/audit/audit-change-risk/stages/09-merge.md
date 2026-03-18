---
name: merge
title: "Merge Change-Risk Results"
description: "Merge layered findings into one stable change-risk set with explicit risk tiering."
---

# Step 9: Merge Change-Risk Results

## Purpose

Merge stage outputs into a stable change-risk model with deduplicated findings and explicit risk tier.

## Actions

1. Parse available stage reports from steps 2-8.
2. Normalize findings into a common schema.
3. Deduplicate by stable ID rule (`taxonomy + layer + location + predicate`).
4. Preserve acceptance criteria and path-level evidence.
5. Merge coverage and unknowns across all executed stages.
6. Compute risk tier:
   - `T3` if any CRITICAL findings remain or severe cross-layer compounding is present,
   - `T2` if HIGH findings remain without T3 conditions,
   - `T1` if no open findings remain at/above threshold.
7. Compute recommendation signal:
   - `NO-GO` for T3,
   - `CONDITIONAL-GO` for T2,
   - `GO` for T1.

## Output

- Unified findings set
- Unified coverage summary
- Risk tier and recommendation rationale inputs for reporting

## Proceed When

- [ ] No duplicate stable IDs remain
- [ ] Acceptance criteria preserved
- [ ] Coverage summary includes stage-level accounting
