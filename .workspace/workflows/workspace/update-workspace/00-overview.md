---
title: Update Workspace
description: Align an existing .workspace directory with the canonical definition.
access: human
---

# Update Workspace: Overview

Align an existing `.workspace` directory with the canonical workspace definition. This is a **mutating operation** that audits structure and applies fixes.

For read-only assessment, use `/evaluate-workspace` instead.

## Target

Existing `.workspace/` directory.

## Prerequisites

- Exactly one `.workspace` directory reference provided
- Target `.workspace` directory MUST exist

## Failure Conditions

- Target `.workspace/` does not exist → STOP, suggest `/create-workspace` instead
- Target path is not a `.workspace/` directory → STOP, report error

## Steps

1. [Audit state](./01-audit-state.md)
2. [Identify gaps](./02-identify-gaps.md)
3. [Assess tokens](./03-assess-tokens.md)
4. [Propose changes](./04-propose-changes.md)
5. [Execute](./05-execute.md)

## References

- **Canonical:** `docs/architecture/workspaces/README.md`
- **Templates:** `.workspace/templates/workspace/` (for missing required files)
