---
title: Collect Terms
description: Scan documentation files and extract key terms.
step_index: 1
action: collect_terms
---

# Collect Terms

## Objective

Walk the documentation directory and extract key terms from all Markdown files, counting occurrences and tracking source locations.

## Inputs

- `workspace_root`: Repository root path
- `docs_path`: Relative path to docs directory (from manifest, default: `docs`)
- `min_term_length`: Minimum character length for valid terms (from manifest, default: 4)

## Process

1. **Discover Files**:
   - Recursively find all `*.md` files under `{workspace_root}/{docs_path}`
   - Skip non-Markdown files and handle encoding errors gracefully

2. **Extract Terms**:
   For each Markdown file, extract terms from:
   - H1/H2 headings (pattern: `^#{1,2}\s+(.+)$`)
   - Bold text (pattern: `\*\*([^*]+)\*\*`)
   - Definition patterns (pattern: `^([A-Z][\w\s\-/]+)\s*[:–-]\s+.+$`)

3. **Normalize Terms**:
   - Lowercase and collapse whitespace
   - Filter by minimum term length
   - Exclude generic filler words: Overview, Introduction, Summary

4. **Count and Track**:
   - Count total occurrences per normalized term
   - Track which files contain each term (limit to top 5 for output)
   - Preserve a representative (original casing) term for display

## Output

Populate:
- `state.files_scanned`: Number of Markdown files processed
- `state.collected_terms`: List of `CollectedTerm` objects, sorted by:
  1. Occurrences (descending)
  2. Term alphabetically (ascending)

Each `CollectedTerm` contains:
- `term`: Representative term (original casing)
- `normalized_term`: Lowercase normalized form
- `occurrences`: Total count across all files
- `source_files`: List of up to 5 file paths where term appears

## Constraints

- Handle Unicode gracefully
- Skip files that cannot be decoded
- Preserve source file paths relative to workspace root

