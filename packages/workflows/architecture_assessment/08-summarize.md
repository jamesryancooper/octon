---
title: Summarize Report
description: Build the Architecture Alignment Report from previous artifacts.
step_index: 8
action: summarize
---

# Summarize Report

## Objective

Compile all assessment artifacts into a comprehensive `AlignmentReport` for stakeholder consumption.

## Inputs

- `state.issue_register`: All detected issues
- `state.validation_summary`: Validation results
- `state.alignment_plan`: Proposed decisions
- `state.terminology_map`: Normalized terminology
- `state.edits_applied`: Recorded edits

## Process

1. **Calculate Alignment Score** (0–100):
   - Based on ratio of resolved to total issues
   - Weighted by issue severity
   - Score = 100 if no issues found

2. **Build Executive Summary**:
   - One-paragraph assessment of documentation health
   - Key statistics (issues found, resolved, remaining)

3. **Compile Key Misalignments**:
   - List all high/medium severity issues
   - Include location and description

4. **Build Normalized Glossary**:
   - Extract preferred terms from terminology map
   - Include aliases for each term

5. **Organize Edits by File**:
   - Group recorded edits by target file
   - Provide actionable edit summaries

6. **Collect Open Questions**:
   - Gather unresolved items from alignment plan
   - Prepare for human review

## Output

Populate `state.alignment_report` with an `AlignmentReport`:
- `executive_summary`: One-paragraph overview
- `alignment_score`: 0–100 score
- `key_misalignments`: List of significant issues
- `normalized_glossary`: Dict of term → aliases
- `edits_by_file`: Dict of file → edit summaries
- `open_questions`: List of items needing human input

## Quality Rubric

| Score | Criteria |
|-------|----------|
| 90–100 | No high-severity issues; minor gaps only |
| 70–89 | Some medium-severity issues; core concepts aligned |
| 50–69 | Significant gaps or conflicts; requires attention |
| < 50 | Major misalignments; immediate remediation needed |

