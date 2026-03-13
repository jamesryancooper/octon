---
title: "ADR-004: Refactor Workflow and Universal Commands"
description: Verified refactor workflow with mandatory audit/verification and universal command pattern.
date: 2026-01-14
status: accepted
mutability: append-only
---

# ADR-004: Refactor Workflow and Universal Commands

## Status

Accepted

## Context

Two problems were identified with how refactors were being executed:

1. **Incomplete refactors**: When executing codebase refactors (renames, moves, restructures), references were frequently missed. Multiple passes were needed before completion, and even then confidence was low.

2. **Continuity artifact modification**: During refactors, historical records in `progress/log.md` and `decisions/*.md` were being modified to reflect new names, destroying the historical record.

Additionally, the refactor command needed to be available across all agent harnesses (Cursor, Claude Code, Codex) following the universal skills pattern.

## Decision

### 1. Create Verified Refactor Workflow

Implement a 6-step workflow in `.octon/orchestration/workflows/refactor/` with mandatory verification:

```
01-define-scope.md   → Capture patterns and search variations
02-audit.md          → Exhaustive search for ALL references
03-plan.md           → Create manifest of all changes
04-execute.md        → Make changes systematically
05-verify.md         → Re-run ALL searches; must return zero
06-document.md       → Update continuity artifacts (append-only)
```

**Key innovations:**
- Multiple search variations (with/without slashes, quotes, etc.)
- Mandatory verification gate — cannot declare complete until all searches return zero
- Continuity protection — progress logs and decisions are append-only
- TodoWrite integration — every file tracked as checklist item

### 2. Establish Continuity Artifact Rule

Files like `progress/log.md`, `decisions/*.md`, and similar historical records are **append-only** during refactors:

- **Do:** Add new entries documenting the refactor
- **Don't:** Modify existing entries to reflect new names/paths

Historical accuracy is more important than current naming consistency.

### 3. Universal Command Pattern

Create commands in `.octon/capabilities/commands/` and symlink from harness directories:

```
.octon/capabilities/commands/refactor.md           ← Source of truth
.cursor/commands/refactor.md  → ../../.octon/capabilities/commands/refactor.md
.claude/commands/refactor.md  → ../../.octon/capabilities/commands/refactor.md
```

Use cross-compatible frontmatter for Claude Code and Codex:

```yaml
---
description: Execute a verified codebase refactor...
argument-hint: <old-pattern> <new-pattern>
---
```

**Codex limitation:** Codex CLI does not support project-level custom commands (only `~/.codex/prompts/`). Users invoke the workflow directly instead.

## Rationale

### Why Mandatory Verification

Previous refactors declared completion after making changes, without confirming all references were updated. The verification step forces re-running all audit searches — if anything remains, the refactor loops back to execution.

### Why Append-Only Continuity

Historical records serve as a timeline of decisions and changes. If we update old entries to reflect new names, we lose the ability to understand what was true at any point in time. A log entry from January 13 should forever say `.scratch/` even if we later renamed it to `.scratchpad/`.

### Why Universal Commands

Following the skills pattern (`.octon/capabilities/skills/` with symlinks), commands can be defined once and used across all harnesses. This reduces duplication and ensures consistency.

## Consequences

### Benefits

- **Verified completion**: Refactors cannot be declared complete until verification passes
- **Historical accuracy**: Continuity artifacts preserve the timeline of changes
- **Reduced duplication**: Universal commands defined once, used everywhere
- **Cross-harness consistency**: Same workflow available in Cursor, Claude Code, and Codex

### Tradeoffs

- **Longer refactor process**: Audit and verification steps add time
- **Codex limitation**: Must invoke workflow directly (no `/refactor` command)

## Files Changed

### Created

- `.octon/orchestration/workflows/refactor/00-overview.md` — Workflow overview
- `.octon/orchestration/workflows/refactor/01-define-scope.md` — Pattern definition step
- `.octon/orchestration/workflows/refactor/02-audit.md` — Exhaustive search step
- `.octon/orchestration/workflows/refactor/03-plan.md` — Change manifest step
- `.octon/orchestration/workflows/refactor/04-execute.md` — Systematic execution step
- `.octon/orchestration/workflows/refactor/05-verify.md` — Mandatory verification step
- `.octon/orchestration/workflows/refactor/06-document.md` — Documentation step
- `.octon/capabilities/commands/refactor.md` — Universal command definition
- `.claude/commands/refactor.md` — Symlink to universal command
- `.cursor/commands/refactor.md` — Symlink to universal command (replaced file)

### Updated

- `.octon/README.md` — Added refactor command, documented command symlink pattern
- `.gitattributes` — Added symlink preservation rules for commands

## Related Decisions

- **D013**: Refactor verification — Mandatory verification gate before completion
- **D014**: Continuity artifact immutability — Append-only rule for historical records
- **D015**: Universal commands — Symlink pattern for cross-harness commands
- **D016**: Mutability frontmatter — `mutability: append-only` property signals protected files

---

## Addendum: Continuity Artifact Safeguards (2026-01-14)

Implementation of the continuity artifact protection established in this ADR.

### 1. Mutability Frontmatter Property

Added `mutability: append-only` to all continuity artifact frontmatter:

```yaml
---
title: Progress Log
description: Chronological record of session work and decisions.
mutability: append-only
---
```

**Files updated:**
- `progress/log.md`
- `context/decisions.md`
- `decisions/001-octon-shared-foundation.md`
- `decisions/002-consolidated-scratchpad-zone.md`
- `decisions/003-projects-elevation-and-funnel.md`
- `decisions/004-refactor-workflow.md`

### 2. Conventions Documentation

Added "Continuity Artifacts" section to `.octon/conventions.md`:

- Protected files table listing all append-only files
- Mutability frontmatter example and documentation
- "What append-only means" table (allowed vs not allowed operations)
- Refactor-specific guidance with concrete examples
- Cross-references to D014, ADR-004, and refactor workflow

### 3. Progress Log Immutability Rule

Added explicit immutability statement to Progress Log Format section:

> **Immutability rule:** Past entries in `progress/log.md` are immutable. New sessions append new entries; existing entries are never modified.

### Implementation Decision

- **D016**: Mutability frontmatter — `mutability: append-only` property provides machine-readable signal for protected files
