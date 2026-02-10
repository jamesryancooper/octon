---
title: Update Harness
description: Align an existing .harmony directory with the canonical definition.
access: human
version: "1.1.0"
depends_on:
  - workflow: harness/evaluate-harness
    condition: "optional but recommended to run first"
checkpoints:
  enabled: true
  storage: ".harmony/continuity/checkpoints/"
parallel_steps: []
---

# Update Harness: Overview

Align an existing `.harmony` directory with the canonical harness definition. This is a **mutating operation** that audits structure and applies fixes.

For read-only assessment, use `/evaluate-harness` instead.

## Target

Existing `.harmony/` directory.

## Prerequisites

- Exactly one `.harmony` directory reference provided
- Target `.harmony` directory MUST exist

## Failure Conditions

- Target `.harmony/` does not exist → STOP, suggest `/create-harness` instead
- Target path is not a `.harmony/` directory → STOP, report error

## Steps

1. [Audit state](./01-audit-state.md)
2. [Identify gaps](./02-identify-gaps.md)
3. [Assess tokens](./03-assess-tokens.md)
4. [Propose changes](./04-propose-changes.md)
5. [Execute](./05-execute.md)

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.1.0 | 2025-01-14 | Added gap remediation fields |
| 1.0.0 | 2025-01-05 | Initial version |

## References

- **Canonical:** `docs/architecture/harness/README.md`
- **Templates:** `.harmony/scaffolding/templates/harmony/` (for missing required files)
