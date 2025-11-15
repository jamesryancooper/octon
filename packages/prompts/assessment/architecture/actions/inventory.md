---
title: Architecture – Inventory
description: Action prompt for the inventory phase of the Harmony architecture assessment.
meta:
  type: assessment
  mode: action
  action: inventory
  subject: architecture
  step_index: 1
---

# Architecture – Inventory

Use this action prompt to perform only the **Inventory** phase of the Harmony Architecture Assessment defined in `assessment/architecture/architecture-assessment.md`.

Reuse the **Role**, **Scope**, **Constraints**, and **Quality Rubric** from the canonical architecture assessment; focus exclusively on building a complete, structured inventory of the documentation set.

## Mission

- Enumerate all Markdown files under `docs/harmony/architecture` (including subfolders).
- For each file, extract:
  - Title and frontmatter.
  - H1/H2 headings.
  - Key terms/definitions.
  - Roles and processes.
  - Invariants and controls/policies.
  - Referenced artifacts and links.

## Process

1. Recursively list all `*.md` files under `docs/harmony/architecture`.
2. For each file, parse frontmatter and headings; identify key terms, roles, processes, invariants, controls, and referenced artifacts.
3. Record the results in a structured form (for example, a table or map keyed by `relative/path.md`).

## Output Specification

- Produce an **Architecture Inventory** that, for each file, includes:
  - Relative path.
  - Title and main headings.
  - Key terms/definitions.
  - Roles, processes, invariants, controls, and referenced artifacts.
- Do **not** modify any files in this step; this action is read-only.

