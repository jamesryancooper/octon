---
title: Comparison and Merge Prompt Template
description: Canonical structure for Harmony prompts that compare primary vs secondary sources and integrate improvements.
version: 1.0.0
last_updated: 2025-11-14
---

# Comparison and Merge Prompt Template

Use this template when a prompt’s primary mission is to compare one or more primary documents against secondary sources, then merge or enhance the primaries while preserving their core intent and decisions.

## When to use

- Primary vs secondary documentation comparison.
- Migration or consolidation of overlapping documents.
- Enhancement of a canonical document set using reference materials.

## Required structure

- YAML frontmatter:
  - `title`
  - `description`
  - `version`
  - `last_updated`
- `#` H1: Prompt name.
- `## Role`
- `## Mission`
- Horizontal rule (`---`).
- `## Inputs`
  - Distinguish primaries from secondaries.
  - Define labels (for example: P1..Pm, S1..Sn) and any pairing rules.
- `## Principles`
  - Preserve vs improve trade-offs.
  - How to handle conflicts and objective corrections.
- `## Process`
  - Structured, numbered steps (scope, outline, align, identify deltas, integrate, resolve conflicts, normalize/validate, iterate until stable).
- `## Output Specification`
  - Define what is updated in files vs what appears in chat (change summary, source map, conflicts report, open questions, validation checklist, etc.).
- Optional supporting sections:
  - `## Formatting Guidelines`
  - `## Safeguards`
  - `## Output Template (use this structure)`
- `## Stop Instruction`

## Checklist

- [ ] Primaries and secondaries are clearly identified.
- [ ] Merge rules (preserve vs correct) are explicit.
- [ ] Process covers at least: outline, compare, integrate, resolve conflicts, validate, iterate.
- [ ] Output Specification prevents printing full documents when not desired.
- [ ] Safeguards prevent unintended semantic changes.

