---
title: Refinement and Meta-Prompt Template
description: Canonical structure for prompts that refine, rewrite, or standardize other prompts without changing their domain or scope.
version: 1.0.0
last_updated: 2025-11-14
---

# Refinement and Meta-Prompt Template

Use this template when a prompt’s primary mission is to rewrite or refine other prompts to improve clarity, structure, and determinism while preserving their underlying domain and scope.

## When to use

- Removing conflicts or contradictions from prompts.
- Standardizing headings, sections, and instructions across prompts.
- Aligning prompts with GPT-5.1 prompting best practices.

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
  - How Target Prompt(s) are supplied (inline, files, metadata).
- `## Principles`
  - Preserve intent and scope.
  - Clarify, simplify, and remove conflicts/ambiguities.
  - Align with GPT-5.1 prompting best practices.
- `## Process`
  - Analyze the target prompt(s).
  - Align with best practices and relevant templates.
  - Rewrite/refactor for clarity and structure.
  - Final review for coherence and determinism.
- `## Output Specification`
  - Typically: output only the refined/standardized prompt text, optionally followed by a short notes section summarizing key changes.
- `## Constraints`
- `## Stop Instruction`

## Checklist

- [ ] Role and Mission describe meta-editing of prompts.
- [ ] Inputs clearly capture how target prompts are provided.
- [ ] Principles include “preserve intent/scope” and “no speculative changes”.
- [ ] Process covers analysis, alignment, rewrite, and review.
- [ ] Output Specification is minimal and unambiguous.

