---
name: refactor
description: >
  Execute verified codebase refactor with exhaustive audit and mandatory
  verification. Searches all pattern variations (base, slashes, quotes),
  systematically updates references, and loops back until verification
  passes with zero remaining references. Supports checkpoint/resume for
  interrupted sessions.
license: MIT
compatibility: Designed for Claude Code and similar AI coding assistants.
metadata:
  author: Octon Framework
  created: "2026-01-20"
  updated: "2026-02-10"
skill_sets: [executor, guardian]
capabilities: [resumable]
allowed-tools: Read Glob Grep Edit Write(/.octon/state/control/skills/checkpoints/*) Write(/.octon/state/evidence/runs/skills/*) Bash(mv) Bash(mkdir)
---

# Refactor

Execute verified codebase refactors with exhaustive audit and mandatory verification gate.

## When to Use

Use this skill when:

- Renaming patterns across the codebase (variables, directories, files)
- Moving files or directories with reference updates
- Restructuring modules with coordinated changes
- Any change that requires finding and updating ALL references

## Quick Start

```
/refactor ".scratch/ → .scratchpad/"
```

## Core Workflow

1. **Define Scope** — Capture old/new patterns and generate all search variations
2. **Audit** — Exhaustive search for ALL references (8+ pattern variations)
3. **Plan** — Create prioritized manifest of required changes
4. **Execute** — Make changes systematically, tracking each completion
5. **Verify** — MANDATORY GATE: Re-run all searches, loop back if any return results
6. **Document** — Update continuity artifacts (append-only), generate commit message

## Parameters

Parameters are defined in `.octon/framework/capabilities/runtime/skills/registry.yml` (single source of truth).

This skill accepts one required parameter (`scope`) and optional parameters for file types, dry-run mode, and exclusions.

## Output Location

Output paths are defined in `.octon/framework/capabilities/runtime/skills/registry.yml` (single source of truth).

Outputs are written to:
- `/.octon/state/control/skills/checkpoints/refactor/{{refactor-id}}/` — Execution state (checkpoint, manifests, reports) for session recovery
- `/.octon/state/evidence/runs/skills/refactor/` — Execution logs with index

## Verification Gate

**Critical:** A refactor is NOT complete until the verification phase passes with zero remaining references.

- Re-run ALL audit searches from Phase 2
- If ANY search returns results → RETURN TO Phase 4
- Loop until all searches return zero results
- Only then proceed to Phase 6

**Agent instruction:** You may NOT skip verification. You may NOT declare completion if verification fails. The loop is mandatory.

## Boundaries

- Maximum scope: 50 files (escalate to mission if exceeded)
- Maximum modules: 3 distinct systems (warn and offer escalation if exceeded)
- Continuity artifacts (progress logs, decisions, ADRs): APPEND-ONLY during refactors
- No auto-commit: Provide suggested commit message only

## When to Escalate

- Scope exceeds 50 files → Recommend creating a mission
- More than 3 modules affected → Warn user, offer escalation
- External dependencies require coordination → Escalate to mission
- Verification fails repeatedly (>3 loops) → Ask for human intervention
- Continuity artifact modification detected → Stop and warn

## References

For detailed documentation:

- [Behavior phases](references/phases.md) — Full phase-by-phase instructions
- [I/O contract](references/io-contract.md) — Inputs, outputs, dependencies
- [Safety policies](references/safety.md) — Tool policies, boundaries
- [Validation](references/validation.md) — Acceptance criteria, verification gate
- [Examples](references/examples.md) — Full refactor examples
