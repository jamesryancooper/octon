---
title: Constraints
description: Technical and business rules that limit workspace operations.
---

# Constraints

Rules that limit what can be done. Agents MUST respect these constraints.

## Technical Constraints

| Constraint | Limit | Rationale |
|------------|-------|-----------|
| Token budget (total) | ~5,000 max | Leave context window for actual work. |
| Token budget (file) | ~500 max | Prevent any single file from dominating context. |
| Token budget (START.md) | ~300 max | Boot sequence must be quick to load. |
| Workflow steps | 3-7 steps | Agents lose track with deep nesting. |
| Frontmatter description | 160 characters max | Consistent with SEO conventions. |

## Structural Constraints

| Constraint | Rule | Rationale |
|------------|------|-----------|
| Required files | `START.md`, `scope.md`, `conventions.md`, `continuity/`, `quality/` | Minimum viable workspace. |
| Human-led zone | Agents MUST NOT autonomously access `ideation/scratchpad/**` | Single human-led space for all non-agent content. |
| Human-led collaboration | `ideation/scratchpad/` accessible only under explicit human direction | Enables collaboration without autonomous scanning. |
| Single task in progress | Only one task can have `in_progress` status | Prevents context fragmentation. |

## Process Constraints

| Constraint | Rule | Rationale |
|------------|------|-----------|
| Progress updates | MUST update `continuity/log.md` before session end | Ensures continuity. |
| Checklist verification | MUST verify against `quality/complete.md` before completing tasks | Prevents premature completion. |

