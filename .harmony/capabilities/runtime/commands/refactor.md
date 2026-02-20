---
description: Execute a verified codebase refactor with exhaustive audit and mandatory verification.
argument-hint: <old-pattern> <new-pattern>
---

# Refactor `/refactor`

Execute a verified codebase refactor (rename, move, restructure) with exhaustive pre-audit, systematic execution, and mandatory post-verification.

## Usage

```text
/refactor <old-pattern> <new-pattern>
```

Examples:

```text
/refactor .scratch .scratchpad
/refactor /old/path/ /new/path/
/refactor OldClassName NewClassName
```

## Parameters

| Parameter | Description |
|-----------|-------------|
| `$1` (old-pattern) | The pattern being replaced (directory, path, name) |
| `$2` (new-pattern) | The new pattern to use |

## Workflow Steps

1. **Define scope** — Capture patterns and search variations
2. **Audit** — Exhaustive search for ALL references
3. **Plan** — Create manifest of all changes
4. **Execute** — Make changes systematically
5. **Verify** — Re-run ALL searches; must return zero
6. **Document** — Update continuity artifacts (append-only)

## Key Features

- **Multiple search variations:** Searches with/without slashes, quotes, etc.
- **Mandatory verification:** Cannot declare complete until searches return zero
- **Continuity protection:** Progress logs and decisions are append-only
- **TodoWrite integration:** Every file tracked as checklist item

## Implementation

Execute the workflow in `.harmony/orchestration/runtime/workflows/quality-gate/refactor/`.

Start with `00-overview.md`, then follow each step in sequence.

**Critical:** Do not skip the verification step (05-verify.md). A refactor is not complete until verification passes.

## Continuity Artifact Rule

When updating `continuity/log.md`, `decisions/*.md`, or similar historical records:

- **Do:** Add new entries documenting the refactor
- **Don't:** Modify existing entries to reflect new names/paths

Historical accuracy is more important than current naming consistency.

## References

- **Workflow:** `.harmony/orchestration/runtime/workflows/quality-gate/refactor/`
- **Checklist:** `.harmony/assurance/complete.md`
- **Conventions:** `.harmony/conventions.md`
