---
title: Summarize Glossary
description: Produce a glossary report with the top terms and usage statistics.
step_index: 2
action: summarize_glossary
---

# Summarize Glossary

## Objective

Compile the collected terms into a structured `GlossaryReport` for consumption by stakeholders and downstream tools.

## Inputs

- `state.collected_terms`: List of `CollectedTerm` objects from collect step
- `state.files_scanned`: Number of files processed
- `max_terms`: Maximum terms to include (from manifest, default: 25)
- `run_id`: Unique run identifier
- `docs_path`: The scanned directory path
- `flow_name`: Flow identifier (default: `docs_glossary`)

## Process

1. **Select Top Terms**:
   - Take the top N terms (up to `max_terms`)
   - Terms are already sorted by occurrence frequency

2. **Build Glossary Entries**:
   For each top term, create a `GlossaryEntry`:
   - `term`: The representative term
   - `description`: Auto-generated description with occurrence stats
   - `occurrences`: Count of appearances
   - `source_files`: List of files where term appears

3. **Calculate Statistics**:
   - `files_scanned`: Total Markdown files processed
   - `unique_terms`: Total distinct terms discovered
   - `total_occurrences`: Sum of all term occurrences

4. **Generate Summary**:
   One-paragraph overview including:
   - Number of files scanned
   - Directory scanned
   - Unique terms found
   - Number of entries returned

5. **Add Notes**:
   Include warnings or observations:
   - If no files found: suggest checking docs_path
   - If few terms: suggest widening scope or lowering min_term_length

## Output

Populate `state.glossary_report` with a `GlossaryReport`:
- `run_id`: Execution identifier
- `flow_name`: `docs_glossary`
- `docs_path`: Scanned directory
- `max_terms`: Configuration value
- `stats`: `GlossaryStats` object
- `entries`: List of `GlossaryEntry` objects
- `summary`: One-paragraph overview
- `notes`: List of warnings/observations

## Constraints

- Respect max_terms limit
- Generate actionable notes for edge cases
- Ensure all fields are populated for downstream consumption

