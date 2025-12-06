---
title: Conversion and Transformation Prompt Template
description: Canonical structure for prompts that convert content between formats or representations while preserving meaning.
version: 1.0.0
last_updated: 2025-11-14
---

# Conversion and Transformation Prompt Template

Use this template when a prompt’s primary mission is to convert content from one representation to another (for example, narrative to structured spec, Markdown to table, or document to checklist) while preserving semantics.

## When to use

- Format conversions (for example, prose → table, doc → checklist).
- Representation changes (for example, narrative requirements → structured specification).
- Any transformation where meaning must be preserved while structure changes.

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
  - Source content and format.
  - Target format and any schemas or examples.
- `## Principles`
  - Preserve semantics and key decisions.
  - Do not invent unsupported requirements or behaviors.
- `## Process`
  - Parse/understand source.
  - Map concepts to target structure.
  - Generate the target representation.
  - Validate completeness and consistency.
- `## Output Specification`
  - Define the exact output shape and any constraints on what is printed vs written to files.
- `## Constraints`
- `## Stop Instruction`

## Checklist

- [ ] Source and target formats are clearly defined.
- [ ] Principles emphasize semantic preservation and no speculation.
- [ ] Process describes mapping and validation steps.
- [ ] Output Specification is precise and structured.

