---
title: Refactor
description: Execute a verified refactor with exhaustive audit and mandatory verification.
access: human
version: "1.1.0"
depends_on: []
checkpoints:
  enabled: true
  storage: ".harmony/continuity/checkpoints/"
parallel_steps: []
---

# Refactor: Overview

Execute a codebase refactor (rename, move, restructure) with exhaustive pre-audit, systematic execution, and mandatory post-verification.

## Problem Addressed

Refactors often leave orphaned references because:

- Search patterns miss variations (with/without slashes, quotes, etc.)
- Some file types are overlooked
- No verification step confirms completion
- Completion is declared prematurely

This workflow enforces a **audit → plan → execute → verify** cycle that prevents incomplete refactors.

## Prerequisites

- Clear definition of what is being refactored (old → new)
- Access to search tools (grep, ripgrep, or IDE search)
- TodoWrite or equivalent for tracking

## Failure Conditions

- Verification step finds remaining references → STOP, return to execute phase
- Scope undefined → STOP, define scope first
- Continuity artifacts modified (not appended) → STOP, revert and append instead

## Steps

1. [Define scope](./01-define-scope.md) — Capture old/new patterns and variations
2. [Audit](./02-audit.md) — Exhaustive search for all references
3. [Plan](./03-plan.md) — Create manifest of all required changes
4. [Execute](./04-execute.md) — Make changes systematically
5. [Verify](./05-verify.md) — Re-run audit; must return zero results
6. [Document](./06-document.md) — Update continuity artifacts (append-only)

## Verification Gate

**Critical:** A refactor is NOT complete until step 5 (Verify) passes with zero remaining references. Do not skip this step. Do not declare completion if verification fails.

## Continuity Artifact Rule

Files like `continuity/log.md`, `decisions/*.md`, and similar historical records are **append-only** during refactors:

- **Do:** Add new entries documenting the refactor
- **Don't:** Modify existing entries to reflect new names/paths

Historical accuracy is more important than current naming consistency in these files.

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.1.0 | 2025-01-14 | Added gap remediation fields (version, depends_on, checkpoints, parallel_steps) |
| 1.0.0 | 2025-01-05 | Initial version |

## References

- **Checklist:** `.harmony/assurance/complete.md`
- **Progress log format:** `.harmony/conventions.md#progress-log-format`
