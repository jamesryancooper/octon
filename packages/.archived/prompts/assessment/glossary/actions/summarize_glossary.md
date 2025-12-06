---
title: Docs Glossary – Summarize
description: Action prompt for building the final glossary report.
meta:
  type: assessment
  mode: action
  action: summarize_glossary
  subject: glossary
  step_index: 2
---

# Docs Glossary – Summarize

Use this action prompt to perform the **Summarize** phase of the Harmony Documentation Glossary Sweep defined in `assessment/glossary/docs-glossary.md`.

## Mission

Convert the collected term data into a deterministic glossary report with an executive summary and ObservaKit-friendly metadata.

## Process

1. Sort terms by occurrences (desc) and term (asc) for tie-breakers.
2. Limit to `max_terms` from the manifest.
3. For each term:
   - Draft a single-sentence description using nearby text fragments.
   - Include up to three representative `source_files`.
4. Compute stats: files scanned, unique terms, total occurrences.
5. Produce an executive summary calling out obvious gaps or follow-ups.

## Output Specification

Emit a `glossary_report` object:

- `run_id`, `flow_name`, `docs_path`, `max_terms`
- `stats`
- `entries`
- `summary`
- `notes` (optional recommendations)

Return the report to FlowKit; do not modify files.


