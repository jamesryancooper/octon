---
title: General / Generation Prompt Template
description: Canonical minimal structure for prompts that generate new content and do not fit more specific templates.
version: 1.0.0
last_updated: 2025-11-14
---

# General / Generation Prompt Template

Use this template when a prompt generates new content (for example, drafts, examples, or explanations) and does not clearly fall into assessment, comparison, refinement, or conversion categories.

## When to use

- Content generation with clear constraints and outputs.
- Explanatory prompts that guide the model to produce structured responses.
- Prompts that orchestrate multi-step reasoning but are not primarily about alignment, comparison, refinement, or conversion.

## Required structure (minimum)

- YAML frontmatter:
  - `title`
  - `description`
  - `version`
  - `last_updated`
- `#` H1: Prompt name.
- `## Role`
- `## Mission`
- `## Inputs`
- `## Process`
- `## Output Specification`
- `## Constraints` (or equivalent section capturing limitations, safety, and scope).
- Optional:
  - `## Principles`
  - `## Stop Instruction`

## Checklist

- [ ] Role and Mission clearly describe what to generate and for whom.
- [ ] Inputs are explicit and typed where useful.
- [ ] Process guides the model through the main reasoning or generation steps.
- [ ] Output Specification defines required sections/format of the response.
- [ ] Constraints capture scope, safety, and non-goals.

