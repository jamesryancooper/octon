---
title: Inventory Architecture Docs
description: Enumerate all architecture documents and extract key structure.
step_index: 1
action: inventory
---

# Inventory Architecture Docs

## Objective

Walk the architecture docs directory and enumerate all Markdown files, extracting structured metadata from each.

## Inputs

- `workspace_root`: Repository root path
- `docs_path`: Relative path to architecture docs (default: `docs/architecture`)

## Process

1. Recursively discover all `*.md` files under `{workspace_root}/{docs_path}`.
2. For each file, extract:
   - **Path**: Relative path from workspace root
   - **Title**: From H1 heading or frontmatter
   - **Frontmatter**: YAML metadata if present
   - **Headings**: All H1/H2 headings with their hierarchy
   - **Key terms**: Bold text, defined terms, and domain vocabulary
   - **Roles**: Any referenced roles or personas
   - **Processes**: Named processes or workflows
   - **Invariants**: Stated constraints or rules
   - **Controls**: Governance or policy controls
   - **Links**: Internal cross-references to other docs

## Output

Populate `state.inventory` with a list of `FileInventoryItem` objects containing the extracted structure.

## Constraints

- Skip non-Markdown files
- Handle encoding errors gracefully
- Preserve relative paths for provenance

