---
title: Constraints
description: Technical and business rules that limit harness operations.
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
| Required files | `START.md`, `scope.md`, `conventions.md`, `continuity/`, `assurance/` | Minimum viable harness. |
| Constitutional charter change control | Agents may modify `.octon/framework/cognition/governance/principles/principles.md` only under explicit human override instructions with required override evidence. | Preserve a stable, auditable engineering constitution while allowing governed exceptions. |
| Charter override ledger | Every direct charter edit must append a record in `.octon/framework/cognition/governance/exceptions/principles-charter-overrides.md`. | Preserve auditable, append-only override provenance. |
| Main branch update model | `main` updates are PR-first; direct pushes require break-glass criteria and explicit record linkage. | Keep change control reviewable by default while allowing emergency operation. |
| Human-led zone | Agents MUST NOT autonomously access `ideation/scratchpad/**` | Single human-led space for all non-agent content. |
| Human-led collaboration | `ideation/scratchpad/` accessible only under explicit human direction | Enables collaboration without autonomous scanning. |
| Single task in progress | Only one task can have `in_progress` status | Prevents context fragmentation. |

## Process Constraints

| Constraint | Rule | Rationale |
|------------|------|-----------|
| Progress updates | MUST update `/.octon/state/continuity/repo/log.md` before session end | Ensures continuity. |
| Checklist verification | MUST verify against `assurance/practices/complete.md` before completing tasks | Prevents premature completion. |
