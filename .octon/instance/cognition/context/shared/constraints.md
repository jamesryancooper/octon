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
| Protected principles change control | Agents may modify `.octon/framework/cognition/governance/principles/principles.md` only under explicit human override instructions with required override evidence. | Preserve a stable, auditable cognition-governance principles surface without confusing it with the repo-local constitutional kernel. |
| Principles override ledger | Every direct protected-principles edit must append a record in `.octon/framework/cognition/governance/exceptions/principles-charter-overrides.md`. | Preserve auditable, append-only override provenance for the protected principles surface. |
| Main branch update model | During SI-00, no Octon route selects direct-main or hosted branch-no-PR landing. A `main` update requires the separately authorized protected-PR provider route; otherwise preserve or stage only. | Keep the containment baseline fail-closed while preserving exact candidate work. |
| External-tool integrity | Treat external tools as immutable dependencies. Never recommend or require forking, patching, modifying, reengineering, or maintaining a private derivative; solve Octon requirements in Octon-owned code through supported interfaces or record a blocker or reduced scope. | Keep Octon self-contained, maintainable, and independent of private upstream variants. |
| Human-led zone | Agents MUST NOT autonomously access `ideation/scratchpad/**` | Single human-led space for all non-agent content. |
| Human-led collaboration | `ideation/scratchpad/` accessible only under explicit human direction | Enables collaboration without autonomous scanning. |
| Single task in progress | Only one task can have `in_progress` status | Prevents context fragmentation. |

## Process Constraints

| Constraint | Rule | Rationale |
|------------|------|-----------|
| Progress updates | MUST update `/.octon/state/continuity/repo/log.md` before session end | Ensures continuity. |
| Checklist verification | MUST verify against `assurance/practices/complete.md` before completing tasks | Prevents premature completion. |
