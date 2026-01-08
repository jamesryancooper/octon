---
title: Detect Issues
description: Identify conflicts, duplications, ambiguities, gaps, and cross-link issues.
step_index: 4
action: detect_issues
---

# Detect Issues

## Objective

Analyze the normalized maps and inventory to detect alignment issues across the architecture documentation.

## Inputs

- `state.inventory`: File inventory
- `state.terminology_map`: Normalized terminology map
- `state.decision_map`: Normalized decision map
- `state.expected_files`: List of expected architecture files (from manifest)
- `state.expected_cross_refs`: Expected cross-reference relationships (from manifest)

## Process

Detect the following issue types:

1. **Conflicts** (severity: high/medium):
   - Same term with different definitions across files
   - Contradictory statements about the same concept
   - Conflicting decision statements

2. **Duplications** (severity: medium):
   - Redundant content across files
   - Repeated definitions that may drift

3. **Ambiguities** (severity: medium):
   - Vague or undefined terms used without context
   - Terms with implicit meanings that should be explicit

4. **Gaps** (severity: high/medium):
   - Expected files that are missing
   - Required sections not present
   - Incomplete documentation

5. **Cross-Link Issues** (severity: medium):
   - Expected cross-references that are missing
   - Broken internal links
   - Orphaned documents with no inbound links

## Output

Populate `state.issue_register` with a list of `Issue` objects, each containing:
- `id`: Unique issue identifier
- `type`: Issue category (conflict, duplication, ambiguity, gap, cross_link)
- `severity`: high, medium, or low
- `location`: File path and line/section reference
- `description`: Human-readable description
- `evidence`: Supporting details

## Constraints

- Assign severity based on impact to documentation coherence
- Provide actionable descriptions
- Include evidence for each issue

