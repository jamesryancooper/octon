---
title: Evaluate Workspace
description: Evaluate a .harmony directory for token efficiency and effectiveness.
access: human
version: "1.1.0"
depends_on: []
checkpoints:
  enabled: true
  storage: ".harmony/continuity/checkpoints/"
parallel_steps: []
---

# Evaluate Workspace: Overview

Evaluate a `.harmony` directory for token efficiency and agent effectiveness. This is a **read-only assessment** that produces a report only.

To apply fixes after evaluation, use `/update-workspace`.

## Target

Existing `.harmony/` directory.

## Prerequisites

- Exactly one `.harmony` directory reference provided
- Target `.harmony` directory MUST exist

## Failure Conditions

- Target `.harmony/` does not exist → STOP, suggest `/create-workspace` instead
- Target path is not a `.harmony/` directory → STOP, report error

## Steps

1. [Assess files](./01-assess-files.md)
2. [Classify content](./02-classify-content.md)
3. [Generate report](./03-generate-report.md)

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.1.0 | 2025-01-14 | Added gap remediation fields |
| 1.0.0 | 2025-01-05 | Initial version |

## References

- **Canonical:** `docs/architecture/workspaces/README.md`
