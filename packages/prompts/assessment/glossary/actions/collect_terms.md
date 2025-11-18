---
title: Docs Glossary – Collect Terms
description: Action prompt for gathering candidate glossary terms from docs/harmony.
meta:
  type: assessment
  mode: action
  action: collect_terms
  subject: glossary
  step_index: 1
---

# Docs Glossary – Collect Terms

Use this action prompt to perform the **Collection** phase of the Harmony Documentation Glossary Sweep defined in `assessment/glossary/docs-glossary.md`.

## Mission

- Recursively scan `docs/harmony/**/*.md`.
- Extract headings, emphasized phrases, and definition rows (`Term: description`).
- Emit a deterministic list of candidate terms with occurrence counts and source files.

## Process

1. List Markdown files (respect `.gitignore`).
2. Parse each file:
   - Capture `#`/`##` headings.
   - Collect `**bold**` phrases and definition-style rows.
3. Normalize term strings (trim whitespace, collapse spaces, lowercase storage key but preserve original text).
4. Increment counts and append the file path (once per term per file).

## Output Specification

Produce a JSON payload with:

- `files_scanned`
- `terms`: array of `{ term, normalized_term, occurrences, source_files[] }`
- `collected_at`: ISO timestamp

Do not exceed the configured `max_terms`; downstream nodes will perform the final truncation.


