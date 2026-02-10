---
title: Create Harness
description: Scaffold a new .harmony/ directory in a target location.
access: human
version: "1.2.0"
depends_on: []
checkpoints:
  enabled: true
  storage: ".harmony/continuity/checkpoints/"
parallel_steps:
  - group: "validation"
    steps: ["01-validate-prerequisites", "02-validate-target"]
    join_at: "03-analyze-context"
---

# Create Harness: Overview

Scaffold a new `.harmony/` directory in a target location, customized to the directory's context.

## Target

Parent directory where `.harmony/` will be created.

## Prerequisites

- Exactly one parent directory reference provided
- `.harmony/scaffolding/templates/harmony/` exists

## Failure Conditions

- Target directory does not exist → STOP, report error
- `.harmony/` already exists in target → STOP, suggest `/update-harness` instead
- Templates directory missing → STOP, report error

## Steps

1. [Validate prerequisites](./01-validate-prerequisites.md)
2. [Validate target](./02-validate-target.md)
3. [Analyze context](./03-analyze-context.md)
4. [Gather input](./04-gather-input.md)
5. [Copy templates](./05-copy-templates.md)
6. [Customize](./06-customize.md)
7. [Verify](./07-verify.md)

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.2.0 | 2025-01-14 | Added frontmatter and Idempotency sections to all step files |
| 1.1.0 | 2025-01-14 | Added gap remediation fields |
| 1.0.0 | 2025-01-05 | Initial version |

## References

- **Canonical:** `docs/architecture/harness/README.md`
- **Templates:** `.harmony/scaffolding/templates/harmony/`
