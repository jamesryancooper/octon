---
title: Architecture – Map
description: Action prompt for the mapping phase of the Harmony architecture assessment.
meta:
  type: assessment
  mode: action
  action: map
  subject: architecture
  step_index: 3
---

# Architecture – Map

Use this action prompt to **refine and consolidate mapping artefacts** (terminology and decision maps) for the Harmony architecture documentation, based on the analysis results.

## Mission

- Turn the raw analysis outputs into **normalized maps** that clearly show:
  - Preferred terms and their aliases.
  - Key architectural decisions and where they are represented.
  - Relationships between concepts, patterns, technologies, and structural elements.

## Process

1. Start from the terminology and decision maps produced by the **Analyze** action.
2. Normalize term naming:
   - Choose a preferred label for each concept; list aliases and synonyms.
   - Flag terms that appear to describe the same concept but differ in wording.
3. Normalize decision representation:
   - For each architectural decision, ensure the description is clear and self-contained.
   - Link decisions to the files/sections where they appear.
4. Identify clusters and relationships:
   - Group related decisions (for example, runtime model, deployment strategy, data consistency).
   - Note dependencies or conflicts between decisions.

## Output Specification

- A **Normalized Terminology Map**: `preferred_term → {aliases, files, notes}`.
- A **Normalized Decision Map**: `decision_id → {description, files/sections, related_decisions}`.
- These maps will be used by subsequent actions (`detect_issues`, `align`, `edit`); do not edit source files in this step.

