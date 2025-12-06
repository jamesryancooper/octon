---
title: Assessment and Alignment Prompt Template
description: Canonical structure for Harmony assessment and alignment prompts (for example, architecture alignment or 3-way harmony alignment).
version: 1.0.0
last_updated: 2025-11-14
---

# Assessment and Alignment Prompt Template

Use this template when a prompt’s primary mission is to assess, analyze, and align a documentation set, process, or system (for example, architecture, methodology, or multi-set consistency).

## When to use

- Architecture or system alignment (for example, architecture docs consistency).
- Cross-set alignment (for example, architecture + methodology + toolkit).
- Any prompt that inventories artifacts, detects conflicts/gaps, and proposes edits or recommendations.

## Required structure

- YAML frontmatter:
  - `title`
  - `description`
  - `version`
  - `last_updated`
- `#` H1: Prompt name.
- Optional introductory paragraph describing the assessment and its style.
- `## Role`
- `## Mission`
- `## Scope (strict)` or `## Scope`
- Horizontal rule (`---`) to separate high-level context from execution details.
- `## Objectives (What success looks like)`
- `## How to work (Process)` or `## Process`
  - Use numbered steps.
  - Clearly separate passes (for example, Inventory/Analysis vs Edits/Validation).
- Optional focus/coverage sections, such as:
  - `## Output Specification` or `## Deliver format`
  - `## Quality Rubric (guide your judgment)`
- `## Constraints`
- Optional `## Stop Instruction` describing when to stop analysis and editing.

## Checklist

- [ ] Exactly one H1 after frontmatter.
- [ ] Role and Mission are specific, actionable, and aligned.
- [ ] Scope is explicit and bounded.
- [ ] Objectives clearly express what “done” and “success” look like.
- [ ] Process is stepwise and deterministic.
- [ ] Output/deliverables are clearly described.
- [ ] Constraints and stop conditions are explicit.

