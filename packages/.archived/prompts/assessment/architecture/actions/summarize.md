---
title: Architecture – Summarize
description: Action prompt for the summarization phase of the Harmony architecture assessment.
meta:
  type: assessment
  mode: action
  action: summarize
  subject: architecture
  step_index: 8
---

# Architecture – Summarize

Use this action prompt to produce the **Architecture Alignment Report** summarizing findings and edits after validation.

## Mission

- Summarize the assessment results in a concise, publication-ready report.
- Clearly communicate the current alignment status, key misalignments addressed, glossary updates, edits by file, and residual Open Questions.

## Process

1. Compile information from previous steps (maps, Issue Register, Alignment Plan, edits, and validation).
2. Structure the report using these sections:
   - `## Executive Summary`
   - `## Key Misalignments`
   - `## Normalized Glossary`
   - `## Edits by File`
   - `## Open Questions`
3. Within each section:
   - Executive Summary: ≤150 words, overall alignment score (0–100) with brief rationale, and top issues addressed.
   - Key Misalignments: for each, record symptom, impact, evidence (path:line), and either a recommended resolution or options tied to Open Questions.
   - Normalized Glossary: preferred term → aliases.
   - Edits by File: list edits with evidence citations.
   - Open Questions: list unresolved decisions and required follow-ups.

## Output Specification

- A Markdown **Architecture Alignment Report** using the structure above.
- Do not re-open analysis or editing here; this step is purely summarization.

