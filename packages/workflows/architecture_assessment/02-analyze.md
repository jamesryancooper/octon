---
title: Analyze Terminology and Decisions
description: Build terminology and decision maps from the inventory.
step_index: 2
action: analyze
---

# Analyze Terminology and Decisions

## Objective

Analyze the inventory to build comprehensive maps of terminology usage and architectural decisions across all documents.

## Inputs

- `state.inventory`: List of `FileInventoryItem` objects from the inventory step

## Process

1. **Build Terminology Map**:
   - Collect all key terms from the inventory
   - Group terms by normalized form (lowercase, collapse whitespace)
   - Track which files define or reference each term
   - Identify aliases and variations
   - Note any explicit definitions provided

2. **Build Decision Map**:
   - Extract architectural decisions (ADRs, stated choices)
   - Track decision IDs and descriptions
   - Map decisions to the files that reference them
   - Note decision status (proposed, accepted, deprecated)

## Output

Populate:
- `state.terminology_map`: Dict mapping normalized terms to `TerminologyEntry` objects
- `state.decision_map`: List of `DecisionEntry` objects

## Constraints

- Preserve original term casing for display
- Link terms to their source locations for traceability

