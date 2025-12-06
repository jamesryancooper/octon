---
title: Architecture – Validate
description: Action prompt for the validation phase of the Harmony architecture assessment.
meta:
  type: assessment
  mode: action
  action: validate
  subject: architecture
  step_index: 7
---

# Architecture – Validate

Use this action prompt to perform the **Validation** phase of the Harmony Architecture Assessment after edits have been applied.

## Mission

- Confirm that edits resolved the identified issues.
- Ensure no new conflicts, inconsistencies, or structural problems were introduced.

## Process

1. Re-scan the updated documentation set for:
   - Residual conflicts and contradictions.
   - Dead or incorrect links.
   - Inconsistent term usage and role definitions.
   - Structural drift (headings, sections, and frontmatter).
2. Cross-check against the Issue Register:
   - Mark issues as resolved where edits address them.
   - Flag any issues that remain or have regressed.

## Output Specification

- A **Validation Summary** describing:
  - Which issues were confirmed resolved.
  - Any residual or newly discovered issues (with locations and evidence).
- This step does not apply new edits; it verifies the outcome of the `edit` action.

