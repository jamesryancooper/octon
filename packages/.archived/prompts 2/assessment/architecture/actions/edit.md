---
title: Architecture – Edit
description: Action prompt for the editing phase of the Harmony architecture assessment.
meta:
  type: assessment
  mode: action
  action: edit
  subject: architecture
  step_index: 6
---

# Architecture – Edit

Use this action prompt to apply **minimal, targeted edits** to the Harmony architecture documentation according to the Alignment Plan.

## Mission

- Implement the agreed alignment decisions with the smallest possible set of edits.
- Preserve the existing voice, structure, and intent of each document.
- Avoid introducing new conflicts, ambiguities, or unnecessary rewrites.

## Process

1. For each planned edit in the Alignment Plan:
   - Normalize terminology and role names where decisions are clear.
   - Add or adjust cross-links; consolidate duplicates by pointing to canonical sources.
   - Clarify ambiguous statements with precise language and short examples only when intent is clearly implied.
2. Align frontmatter/title conventions and heading structures where inconsistent.
3. When resolving a conflict requires choosing between competing options and the intended choice is not explicit:
   - Do **not** edit the affected guidance.
   - Capture or update an Open Question instead.

## Output Specification

- Updated architecture documentation files under `docs/harmony/architecture` reflecting:
  - Normalized terminology and roles.
  - Resolved conflicts and reduced duplication.
  - Improved cross-linking and structural coherence.
- Keep edits as small and surgical as possible; avoid large restructures unless absolutely necessary.

