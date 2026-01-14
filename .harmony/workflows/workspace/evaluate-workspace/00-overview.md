---
title: Evaluate Workspace
description: Evaluate a .workspace directory for token efficiency and effectiveness.
access: human
---

# Evaluate Workspace: Overview

Evaluate a `.workspace` directory for token efficiency and agent effectiveness. This is a **read-only assessment** that produces a report only.

To apply fixes after evaluation, use `/update-workspace`.

## Target

Existing `.workspace/` directory.

## Prerequisites

- Exactly one `.workspace` directory reference provided
- Target `.workspace` directory MUST exist

## Failure Conditions

- Target `.workspace/` does not exist → STOP, suggest `/create-workspace` instead
- Target path is not a `.workspace/` directory → STOP, report error

## Steps

1. [Assess files](./01-assess-files.md)
2. [Classify content](./02-classify-content.md)
3. [Generate report](./03-generate-report.md)

## References

- **Canonical:** `docs/architecture/workspaces/README.md`
