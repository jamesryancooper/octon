---
title: Architecture – Analyze
description: Action prompt for the analysis phase of the Harmony architecture assessment.
meta:
  type: assessment
  mode: action
  action: analyze
  subject: architecture
  step_index: 2
---

# Architecture – Analyze

Use this action prompt to perform the **Analysis** phase of the Harmony Architecture Assessment using the inventory produced in the previous step.

Reuse the **Role**, **Scope**, **Constraints**, and **Quality Rubric** from `assessment/architecture/architecture-assessment.md`; focus here on building analytic views over the inventory.

## Mission

From the architecture inventory:

- Build a **terminology map** showing how key terms are defined and used across files.
- Build an **architectural decision map** capturing concepts, patterns, technologies, practices, structures, paradigms, runtime/deployment models, data/consistency strategies, operational practices, constraints, assumptions, and quality attributes.

## Process

1. **Terminology map**
   - Collect all key terms/definitions from the inventory.
   - For each term, list definitions/usages across files; flag discrepancies or synonyms needing normalization.
2. **Architectural decision map**
   - Identify explicit and implied architectural decisions across the set.
   - For each decision, capture:
     - Decision description.
     - Related files/sections.
     - Any notes on ambiguity or partial coverage.

## Output Specification

- A **Terminology Map**: `term → {definitions/usages, files, notes, normalization candidates}`.
- An **Architectural Decision Map**: `decision → {files/sections, status (clear/ambiguous/partial), notes}`.
- Do not yet propose edits; this step prepares the analytic foundation for later actions.

