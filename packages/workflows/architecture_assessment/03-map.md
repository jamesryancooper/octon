---
title: Map and Normalize
description: Normalize terminology and decision representations.
step_index: 3
action: map
---

# Map and Normalize

## Objective

Refine the terminology and decision maps by normalizing terms and consolidating decision representations for consistency analysis.

## Inputs

- `state.terminology_map`: Raw terminology map from analysis
- `state.decision_map`: Raw decision map from analysis

## Process

1. **Normalize Terminology**:
   - Identify canonical forms for each term cluster
   - Merge obvious aliases (e.g., "kit" vs "Kit" vs "kits")
   - Flag terms with multiple distinct definitions

2. **Consolidate Decisions**:
   - Normalize decision identifiers
   - Link related decisions
   - Identify superseded or conflicting decisions

3. **Cross-Reference**:
   - Map terms to decisions that reference them
   - Map decisions to the terminology they define

## Output

Updated `state.terminology_map` and `state.decision_map` with normalized representations.

## Constraints

- Preserve source information through normalization
- Do not discard information; consolidate and annotate

