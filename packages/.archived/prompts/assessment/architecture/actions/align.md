---
title: Architecture – Align
description: Action prompt for the alignment design phase of the Harmony architecture assessment.
meta:
  type: assessment
  mode: action
  action: align
  subject: architecture
  step_index: 5
---

# Architecture – Align

Use this action prompt to design the **alignment plan** for the Harmony architecture documentation based on the detected issues, terminology map, and decision map.

## Mission

- Decide how to normalize terminology and role names.
- Decide which document is canonical for each concept or decision.
- Design cross-links and structural adjustments that will resolve issues while preserving intent and voice.

## Process

1. Review the **Issue Register** from `detect_issues` and the normalized maps from `map`.
2. For each terminology inconsistency:
   - Choose a canonical term; list aliases; decide where to update text vs add a glossary entry.
3. For each duplicated or drifting concept:
   - Select a canonical file/section; plan references (`See also`) in secondary locations.
4. For each architectural misalignment:
   - When the intended decision is clear in the docs, propose a concrete alignment change.
   - When the intended decision is ambiguous or contested, capture an Open Question instead of forcing a choice.
5. For cross-link and structure issues:
   - Plan minimal changes to headings, frontmatter, and links to improve navigation and coherence.

## Output Specification

- An **Alignment Plan** containing:
  - Terminology normalization decisions.
  - Canonical sources for key concepts and decisions.
  - Planned edits and cross-links by file/section.
  - Open Questions where decisions are still pending.
- This step designs the alignment; actual file edits occur in the `edit` action.

